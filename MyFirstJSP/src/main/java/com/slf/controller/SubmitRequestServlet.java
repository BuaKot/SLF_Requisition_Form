package com.slf.controller;

import com.slf.model.RequisitionForm;
import com.slf.model.RequestItem;
import com.slf.dao.RequisitionDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import com.slf.dao.OracleRequisitionDAO;

@WebServlet("/submitRequest")   // This maps the URL to this servlet
public class SubmitRequestServlet extends HttpServlet {

    // For now, use mock DAO; later you'll swap with OracleRequisitionDAO
    private RequisitionDAO requisitionDAO = new OracleRequisitionDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        
        
        HttpSession session = request.getSession();
        Integer empID = (Integer) session.getAttribute("loggedInEmpId");
        if (empID == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Set character encoding to handle Thai UTF-8 properly
        request.setCharacterEncoding("UTF-8");

        // 1. Read the header fields
        RequisitionForm form = new RequisitionForm();
        form.setEmpID(empID);
        form.setSection(request.getParameter("section"));
        form.setDate(request.getParameter("date"));
        form.setDeadline(request.getParameter("deadline"));
        form.setRequestTopic(request.getParameter("requestTopic"));

        // 2. Read the item arrays
        String[] types = request.getParameterValues("requestType[]");
        if (types == null) types = new String[0];

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

            // Checkboxes are trickier. For now, skip them or store as comma list.
            // Later you can parse them properly. I'll show a simple way:
            String[] folderPerms = request.getParameterValues("folderPermission[]");
            if (folderPerms != null) {
                item.setFolderPermissions(Arrays.asList(folderPerms));
            }
            String[] subPerms = request.getParameterValues("subFolderPermission[]");
            if (subPerms != null) {
                item.setSubFolderPermissions(Arrays.asList(subPerms));
            }

            items.add(item);
        }
        form.setItems(items);

        // 3. Save using DAO (now just prints to console)
        try {
            requisitionDAO.save(form);
            // 4. Forward to success page
            request.getRequestDispatcher("/submit-success.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            // In case of error, send to an error page or show message
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
        return ""; // or null, but empty string is safer for printing
    }
}