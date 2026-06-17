package com.slf.controller;

import com.slf.model.RequisitionForm;
import com.slf.model.RequestItem;
import com.slf.dao.RequisitionDAO;
import com.slf.dao.DBConnection;
import com.slf.dao.OracleRequisitionDAO;
import com.slf.notification.ApprovalNotificationService;
import com.slf.util.AuthUtil;
import com.slf.util.SecurityUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@WebServlet("/submitRequest")   // This maps the URL to this servlet
public class SubmitRequestServlet extends HttpServlet {

    private RequisitionDAO requisitionDAO = new OracleRequisitionDAO();
    private final ApprovalNotificationService approvalNotificationService = new ApprovalNotificationService();

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Set character encoding to handle Thai UTF-8 properly
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        Integer empID = (Integer) session.getAttribute("loggedInEmpId");
        if (empID == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (!SecurityUtil.isValidCsrfToken(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid CSRF token");
            return;
        }
        String position = (String) session.getAttribute("position");
        if (AuthUtil.isApprovalOnlyRole(position)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "This role cannot submit requisition forms");
            return;
        }

        // 1. Read the header fields (except section, which will be resolved from request types)
        RequisitionForm form = new RequisitionForm();
        form.setEmpID(empID);
        form.setDate(trimToEmpty(request.getParameter("date")));
        form.setDeadline(trimToEmpty(request.getParameter("deadline")));
        form.setRequestTopic(trimToEmpty(request.getParameter("requestTopic")));

        Integer editedFormId;
        try {
            editedFormId = parseEditedFormId(request.getParameter("editedFormId"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/submit.jsp");
            return;
        }
        if (editedFormId != null) {
            try {
                if (!canEditRejectedForm(editedFormId, empID)) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "You cannot edit this requisition form");
                    return;
                }
            } catch (Exception e) {
                throw new ServletException("Database error checking requisition ownership", e);
            }
        }

        // 2. Read the item arrays
        String[] types = request.getParameterValues("requestType[]");
        if (types == null) types = new String[0];

        String headerValidationError = validateHeader(form, types);
        if (headerValidationError != null) {
            forwardFormError(request, response, headerValidationError);
            return;
        }

        // Resolve destination IT section from selected request types
        int assignedSecId;
        try {
            assignedSecId = resolveAssignedSecId(types);
            form.setSection(String.valueOf(assignedSecId));
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/Form.jsp").forward(request, response);
            return;
        }

        // zennnne แก้
        // Validate every requestType[] value is a parseable integer before touching the DAO.
        // Gives a specific error (which item number) instead of a generic rollback message.
        for (int i = 0; i < types.length; i++) {
            try {
                Integer.parseInt(types[i] == null ? "" : types[i].trim());
            } catch (NumberFormatException e) {
                request.setAttribute("error",
                        "ประเภทคำขอที่ระบุไม่ถูกต้อง (รายการที่ " + (i + 1) + "): \""
                        + types[i] + "\" ต้องเป็นตัวเลขเท่านั้น");
                request.getRequestDispatcher("/WEB-INF/views/Form.jsp").forward(request, response);
                return;
            }
        }
        // zennnne แก้

        List<RequestItem> items = new ArrayList<>();
        for (int i = 0; i < types.length; i++) {
            RequestItem item = new RequestItem();
            item.setRequestTypeId(Integer.parseInt(types[i]));
            // For optional arrays, use helper method to get index safely
            item.setProgramName(trimToEmpty(getParamValue(request, "programName[]", i)));
            item.setServerName(trimToEmpty(getParamValue(request, "serverName[]", i)));
            item.setServerFolder(trimToEmpty(getParamValue(request, "serverFolder[]", i)));
            item.setSubFolder(trimToEmpty(getParamValue(request, "subFolder[]", i)));
            item.setOtherRequest(trimToEmpty(getParamValue(request, "otherRequest[]", i)));
            item.setObjective(trimToEmpty(getParamValue(request, "objective[]", i)));
            item.setCurrentMethod(trimToEmpty(getParamValue(request, "currentMethod[]", i)));

            // Handle checkboxes with improved indexed naming (folderPermission_0[], etc.)
            String[] folderPerms = getPermissionValues(request, "folderPermission", i);
            if (folderPerms != null) {
                item.setFolderPermissions(Arrays.asList(folderPerms));
            }
            String[] subPerms = getPermissionValues(request, "subFolderPermission", i);
            if (subPerms != null) { 
                item.setSubFolderPermissions(Arrays.asList(subPerms));
            }

            items.add(item);
        }

        String itemValidationError = validateItems(items);
        if (itemValidationError != null) {
            forwardFormError(request, response, itemValidationError);
            return;
        }
        form.setItems(items);

        // 3. Save using DAO
        try {
            requisitionDAO.save(form);
            if (editedFormId != null) {
                markOriginalFormAsEdited(editedFormId, empID);
            }
            approvalNotificationService.notifyFormSubmitted(form.getFormId(), empID, form.getRequestTopic());
            // 4. Redirect to success page so refresh does not resubmit the POST.
            response.sendRedirect(request.getContextPath() + "/submit-success?formId=" + form.getFormId());
        } catch (Exception e) {
            getServletContext().log("Failed to submit requisition form", e);
            request.setAttribute("error", "ไม่สามารถบันทึกใบขอได้ กรุณาตรวจสอบข้อมูลและลองอีกครั้ง");
            request.getRequestDispatcher("/WEB-INF/views/Form.jsp").forward(request, response);
        }
    }

    // Helper method to safely get array values even if array is shorter
    private String getParamValue(HttpServletRequest request, String paramName, int index) {
        String[] values = request.getParameterValues(paramName);
        if (values != null && index < values.length) {
            return values[index]; // may be empty string but not null
        }
        return "";
    }

    private void forwardFormError(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("error", message);
        request.getRequestDispatcher("/WEB-INF/views/Form.jsp").forward(request, response);
    }

    private String validateHeader(RequisitionForm form, String[] types) {
        if (isBlank(form.getRequestTopic())) {
            return "กรุณาระบุชื่อหัวข้อความต้องการ";
        }
        if (isBlank(form.getDeadline())) {
            return "กรุณาระบุ Deadline";
        }
        try {
            Date.valueOf(form.getDeadline());
        } catch (IllegalArgumentException e) {
            return "รูปแบบ Deadline ไม่ถูกต้อง";
        }
        if (types == null || types.length == 0) {
            return "กรุณาเพิ่มรายการคำขออย่างน้อย 1 รายการ";
        }
        return null;
    }

    private String validateItems(List<RequestItem> items) {
        if (items == null || items.isEmpty()) {
            return "กรุณาเพิ่มรายการคำขออย่างน้อย 1 รายการ";
        }
        for (int i = 0; i < items.size(); i++) {
            RequestItem item = items.get(i);
            int itemNumber = i + 1;
            if (item.getRequestTypeId() <= 0) {
                return "ประเภทคำขอรายการที่ " + itemNumber + " ไม่ถูกต้อง";
            }
            if (isBlank(item.getObjective())) {
                return "กรุณาระบุวัตถุประสงค์ / ความต้องการ รายการที่ " + itemNumber;
            }
            if (!hasItemDetail(item)) {
                return "กรุณาระบุรายละเอียดคำขอ รายการที่ " + itemNumber;
            }
            if (hasServerAccessDetail(item) && isBlank(item.getServerFolder())) {
                return "กรุณาระบุ Folder สำหรับรายการขอใช้สิทธิ์ Server รายการที่ " + itemNumber;
            }
            if (hasServerAccessDetail(item) && isEmpty(item.getFolderPermissions())) {
                return "กรุณาเลือกสิทธิ์ Folder สำหรับรายการที่ " + itemNumber;
            }
            if (isBlank(item.getSubFolder()) && !isEmpty(item.getSubFolderPermissions())) {
                return "กรุณาระบุ Sub Folder หรือยกเลิกการเลือกสิทธิ์ Sub Folder รายการที่ " + itemNumber;
            }
            if (!isBlank(item.getSubFolder()) && isEmpty(item.getSubFolderPermissions())) {
                return "กรุณาเลือกสิทธิ์ Sub Folder สำหรับรายการที่ " + itemNumber;
            }
        }
        return null;
    }

    private boolean hasItemDetail(RequestItem item) {
        return !isBlank(item.getObjective())
            || !isBlank(item.getProgramName())
            || !isBlank(item.getOtherRequest())
            || hasServerAccessDetail(item);
    }

    private boolean hasServerAccessDetail(RequestItem item) {
        return !isBlank(item.getServerName()) || !isBlank(item.getServerFolder());
    }

    private boolean isEmpty(List<?> values) {
        return values == null || values.isEmpty();
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    /**
     * Improved permission checkbox handling.
     * First tries the indexed name (e.g., folderPermission_0[]) for a specific item.
     * Falls back to the legacy flat name (folderPermission[]) only for the first item (index 0).
     */
    private String[] getPermissionValues(HttpServletRequest request, String baseName, int index) {
        // Try indexed name first: baseName + "_" + index + "[]"
        String indexedName = baseName + "_" + index + "[]";
        String[] indexedValues = request.getParameterValues(indexedName);
        if (indexedValues != null) {
            return indexedValues;
        }

        // Fallback to flat name only for the first item (backward compatibility)
        if (index == 0) {
            return request.getParameterValues(baseName + "[]");
        }
        return null;
    }

    /**
     * Looks up the destination IT section (SECID) for each selected request type.
     * Throws an exception if the types belong to different sections.
     * Returns the single common SECID.
     */
    private int resolveAssignedSecId(String[] typeValues) throws Exception {
        if (typeValues == null || typeValues.length == 0) {
            throw new Exception("กรุณาเลือกประเภทคำขออย่างน้อย 1 รายการ");
        }

        Set<Integer> sectionIds = new LinkedHashSet<>();

        String sql = "SELECT SECID FROM REQUESTTYPE WHERE TYPEID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (String typeValue : typeValues) {
                int typeId;
                try {
                    typeId = Integer.parseInt(typeValue);
                } catch (NumberFormatException e) {
                    throw new Exception("ประเภทคำขอไม่ถูกต้อง");
                }

                ps.setInt(1, typeId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        throw new Exception("ไม่พบประเภทคำขอที่เลือก");
                    }
                    int secId = rs.getInt("SECID");
                    if (rs.wasNull()) {
                        throw new Exception("ประเภทคำขอที่เลือกยังไม่ได้กำหนดส่วนผู้รับผิดชอบ");
                    }
                    sectionIds.add(secId);
                }
            }
        }

        if (sectionIds.size() > 1) {
            throw new Exception("กรุณาเลือกประเภทคำขอที่อยู่ในส่วนผู้รับผิดชอบเดียวกัน");
        }

        return sectionIds.iterator().next();
    }

    static Integer parseEditedFormId(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        int formId = Integer.parseInt(value.trim());
        if (formId <= 0) {
            throw new NumberFormatException("editedFormId must be positive");
        }
        return Integer.valueOf(formId);
    }

    private void markOriginalFormAsEdited(int editedFormId, int empId) throws Exception {
        String sql =
            "UPDATE REQUISITIONFORM rf " +
            "SET rf.IS_EDITED = 1 " +
            "WHERE rf.FORMID = ? " +
            "AND rf.EMPID = ? " +
            "AND NVL(rf.IS_EDITED, 0) = 0 " +
            "AND EXISTS ( " +
            "    SELECT 1 FROM APPROVALINFO ai " +
            "    WHERE ai.FORMID = rf.FORMID " +
            "    AND ai.APPROVALID = ( " +
            "        SELECT MAX(ai2.APPROVALID) FROM APPROVALINFO ai2 WHERE ai2.FORMID = rf.FORMID " +
            "    ) " +
            "    AND ai.STATE_STEP < 0 " +
            ")";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, editedFormId);
            ps.setInt(2, empId);
            int updatedRows = ps.executeUpdate();
            if (updatedRows == 0) {
                throw new Exception("Cannot mark original form as edited");
            }
        }
    }

    private boolean canEditRejectedForm(int editedFormId, int empId) throws Exception {
        String sql =
            "SELECT 1 FROM REQUISITIONFORM rf " +
            "WHERE rf.FORMID = ? " +
            "AND rf.EMPID = ? " +
            "AND NVL(rf.IS_EDITED, 0) = 0 " +
            "AND EXISTS ( " +
            "    SELECT 1 FROM APPROVALINFO ai " +
            "    WHERE ai.FORMID = rf.FORMID " +
            "    AND ai.APPROVALID = ( " +
            "        SELECT MAX(ai2.APPROVALID) FROM APPROVALINFO ai2 WHERE ai2.FORMID = rf.FORMID " +
            "    ) " +
            "    AND ai.STATE_STEP < 0 " +
            ")";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, editedFormId);
            ps.setInt(2, empId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

}
