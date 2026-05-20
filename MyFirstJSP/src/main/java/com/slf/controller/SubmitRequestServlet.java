package com.slf.controller;

import com.slf.model.RequisitionForm;
import com.slf.model.RequestItem;
import com.slf.dao.RequisitionDAO;
import com.slf.dao.DBConnection;
import com.slf.dao.OracleRequisitionDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
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

        // 1. Read the header fields (except section, which will be resolved from request types)
        RequisitionForm form = new RequisitionForm();
        form.setEmpID(empID);
        form.setDate(request.getParameter("date"));
        form.setDeadline(request.getParameter("deadline"));
        form.setRequestTopic(request.getParameter("requestTopic"));

        // 2. Read the item arrays
        String[] types = request.getParameterValues("requestType[]");
        if (types == null) types = new String[0];

        // Resolve destination IT section from selected request types
        int assignedSecId;
        try {
            assignedSecId = resolveAssignedSecId(types);
            form.setSection(String.valueOf(assignedSecId));
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/form.jsp").forward(request, response);
            return;
        }

        List<RequestItem> items = new ArrayList<>();
        for (int i = 0; i < types.length; i++) {
            RequestItem item = new RequestItem();
            item.setRequestTypeId(Integer.parseInt(types[i]));
            // For optional arrays, use helper method to get index safely
            item.setProgramName(getParamValue(request, "programName[]", i));
            item.setServerName(getParamValue(request, "serverName[]", i));
            item.setServerFolder(getParamValue(request, "serverFolder[]", i));
            item.setSubFolder(getParamValue(request, "subFolder[]", i));
            item.setOtherRequest(getParamValue(request, "otherRequest[]", i));
            item.setObjective(getParamValue(request, "objective[]", i));
            item.setCurrentMethod(getParamValue(request, "currentMethod[]", i));

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
        form.setItems(items);

        // 3. Save using DAO
        try {
            requisitionDAO.save(form);
            // 4. Forward to success page
            request.getRequestDispatcher("/submit-success.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            // In case of error, send back to form with error message
            request.setAttribute("error", "เกิดข้อผิดพลาดในการบันทึกข้อมูล: " + e.getMessage());
            request.getRequestDispatcher("/form.jsp").forward(request, response);
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
}