package com.slf.controller;

import com.slf.dao.DBConnection;
import com.slf.dao.LookupDAO;
import com.slf.model.Department;
import com.slf.model.Employee;
import com.slf.model.Section;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import com.fasterxml.jackson.core.JsonProcessingException; // zennnne แก้
import com.fasterxml.jackson.databind.ObjectMapper;        // zennnne แก้

@WebServlet("/editForm")
public class EditFormServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ----- Session check -----
        HttpSession session = request.getSession();
        Integer empId = (Integer) session.getAttribute("loggedInEmpId");
        if (empId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // ----- Validate formId param -----
        String formIdStr = request.getParameter("formId");
        if (formIdStr == null || formIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/submit.jsp");
            return;
        }
        int formId;
        try {
            formId = Integer.parseInt(formIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/submit.jsp");
            return;
        }

        // ----- Load same lookups as LoadFormServlet -----
        LookupDAO lookupDao = new LookupDAO();
        try {
            Employee emp = lookupDao.findEmployeeById(empId);
            // Extra safety: if employee record missing, redirect to login
            if (emp == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            Section empSection = lookupDao.getSectionById(emp.getSecId());
            Department empDepartment = lookupDao.getDepartmentById(empSection.getDeptId());

            request.setAttribute("loggedInEmployee", emp);
            request.setAttribute("empDeptId", empSection.getDeptId());
            request.setAttribute("empSectionId", emp.getSecId());
            request.setAttribute("empDeptName", empDepartment != null ? empDepartment.getDeptName() : "");
            request.setAttribute("empSectionName", empSection.getSecName());
            request.setAttribute("requestTypes", lookupDao.getAllRequestTypes());
            request.setAttribute("departments", lookupDao.getAllDepartments());
            request.setAttribute("allSections", lookupDao.getAllSections());
        } catch (SQLException e) {
            throw new ServletException("Failed to load lookups", e);
        }

        // ----- Build prefill JSON from old form -----
        // zennnne แก้
        try {
            String prefillJson = buildPrefillJson(formId, empId);
            if (prefillJson == null) {
                // Form doesn't belong to this user — ownership check failed
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
                return;
            }
            request.setAttribute("prefillJson", prefillJson);
            request.setAttribute("editedFormId", formId);
        } catch (SQLException e) {
            throw new ServletException("Failed to load old form data", e);
        }
        // zennnne แก้

        request.getRequestDispatcher("/form.jsp").forward(request, response);
    }

    // ---------------------------------------------------------------
    //  Build JSON string representing the old form's data
    // ---------------------------------------------------------------
    // zennnne แก้
    private String buildPrefillJson(int formId, int empId) throws SQLException {
    // zennnne แก้
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();

            // ---------- Header ----------
            String titleForm = "";
            String deadline   = "";
            int    sectionId  = 0;
            int    deptId     = 0;

            // zennnne แก้
            // SEC-3: เพิ่ม AND r.EMPID = ? เพื่อตรวจ ownership ป้องกัน IDOR
            String headerSql =
                "SELECT r.TITLEFORM, TO_CHAR(r.DEADLINE,'YYYY-MM-DD') AS DEADLINE, " +
                "r.ASSIGN_SECID, NVL(s.DEPTID, 0) AS DEPTID " +
                "FROM REQUISITIONFORM r " +
                "LEFT JOIN SECTION s ON r.ASSIGN_SECID = s.SECID " +
                "WHERE r.FORMID = ? AND r.EMPID = ?";
            try (PreparedStatement ps = conn.prepareStatement(headerSql)) {
                ps.setInt(1, formId);
                ps.setInt(2, empId);
                // zennnne แก้
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        titleForm = nvl(rs.getString("TITLEFORM"));
                        deadline  = nvl(rs.getString("DEADLINE"));
                        sectionId = rs.getInt("ASSIGN_SECID");
                        deptId    = rs.getInt("DEPTID");
                    } else {
                        return null; // zennnne แก้ — form ไม่ใช่ของ user คนนี้
                    }
                }
            }

            // ---------- Permissions (ISROOT 1 = main folder, 0 = sub folder) ----------
            String   serverName    = "";
            String   serverFolder  = "";
            String   subFolder     = "";
            List<String> folderPerms    = new ArrayList<>();
            List<String> subFolderPerms = new ArrayList<>();

            String permSql =
                "SELECT ISROOT, PATH, HASFULLCONTROL, HASMODIFY, " +
                "HASREADEXECUTE, HASREAD, HASWRITE " +
                "FROM PERMISSIONDETAILS WHERE FORMID = ? ORDER BY ISROOT DESC";
            try (PreparedStatement ps = conn.prepareStatement(permSql)) {
                ps.setInt(1, formId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int    isRoot = rs.getInt("ISROOT");
                        String path   = nvl(rs.getString("PATH"));
                        String[] parts = parsePath(path);

                        if (isRoot == 1) {
                            serverName   = parts.length > 0 ? parts[0] : "";
                            serverFolder = parts.length > 1 ? parts[1] : "";
                            if (rs.getInt("HASFULLCONTROL") == 1) folderPerms.add("Full control");
                            if (rs.getInt("HASMODIFY")      == 1) folderPerms.add("Modify");
                            if (rs.getInt("HASREADEXECUTE") == 1) folderPerms.add("Read & Execute");
                            if (rs.getInt("HASREAD")        == 1) folderPerms.add("Read");
                            if (rs.getInt("HASWRITE")       == 1) folderPerms.add("Write");
                        } else {
                            // sub path = \\server\folder\sub  →  parts[2]
                            subFolder = parts.length > 2 ? parts[2] : "";
                            if (rs.getInt("HASFULLCONTROL") == 1) subFolderPerms.add("Full control");
                            if (rs.getInt("HASMODIFY")      == 1) subFolderPerms.add("Modify");
                            if (rs.getInt("HASREADEXECUTE") == 1) subFolderPerms.add("Read & Execute");
                            if (rs.getInt("HASREAD")        == 1) subFolderPerms.add("Read");
                            if (rs.getInt("HASWRITE")       == 1) subFolderPerms.add("Write");
                        }
                    }
                }
            }

            // ---------- Request items ----------
            // zennnne แก้
            // MAINT-6: เปลี่ยนจาก List<String> raw JSON → List<Map> แล้วให้ Jackson serialize
            List<Map<String, Object>> items = new ArrayList<>();
            boolean serverUsed = false;

            String itemSql =
                "SELECT req.TYPEID, rt.TYPENAME, req.OTHERDETAILS_OR_PROGRAM, " +
                "req.DETAILOBJECTIVE, req.CURRENTMETHOD " +
                "FROM REQUEST req " +
                "JOIN REQUESTTYPE rt ON req.TYPEID = rt.TYPEID " +
                "WHERE req.FORMID = ? ORDER BY req.REQUESTID";
            try (PreparedStatement ps = conn.prepareStatement(itemSql)) {
                ps.setInt(1, formId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int    typeId         = rs.getInt("TYPEID");
                        String typeName       = nvl(rs.getString("TYPENAME"));
                        String programOrOther = nvl(rs.getString("OTHERDETAILS_OR_PROGRAM"));
                        String objective      = nvl(rs.getString("DETAILOBJECTIVE"));
                        String currentMethod  = nvl(rs.getString("CURRENTMETHOD"));

                        boolean isServerType = typeName.contains("สิทธิ์") && typeName.contains("ข้อมูล");

                        Map<String, Object> item = new LinkedHashMap<>();
                        item.put("typeId",         typeId);
                        item.put("programOrOther", programOrOther);
                        item.put("objective",      objective);
                        item.put("currentMethod",  currentMethod);
                        if (isServerType && !serverUsed) {
                            item.put("serverName",     serverName);
                            item.put("serverFolder",   serverFolder);
                            item.put("subFolder",      subFolder);
                            item.put("folderPerms",    folderPerms);
                            item.put("subFolderPerms", subFolderPerms);
                            serverUsed = true;
                        } else {
                            item.put("serverName",     "");
                            item.put("serverFolder",   "");
                            item.put("subFolder",      "");
                            item.put("folderPerms",    new ArrayList<>());
                            item.put("subFolderPerms", new ArrayList<>());
                        }
                        items.add(item);
                    }
                }
            }

            // ---------- Assemble with Jackson (handles all escaping correctly) ----------
            try {
                ObjectMapper mapper = new ObjectMapper();
                Map<String, Object> root = new LinkedHashMap<>();
                root.put("titleForm", titleForm);
                root.put("deadline",  deadline);
                root.put("sectionId", sectionId);
                root.put("deptId",    deptId);
                root.put("items",     items);
                return mapper.writeValueAsString(root);
            } catch (JsonProcessingException e) {
                throw new SQLException("JSON serialization failed", e);
            }
            // zennnne แก้

        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    }

    private String[] parsePath(String path) {
        if (path == null || !path.startsWith("\\\\")) return new String[]{"", ""};
        String noPrefix = path.substring(2);
        int i1 = noPrefix.indexOf("\\");
        if (i1 < 0) return new String[]{noPrefix, ""};
        String server = noPrefix.substring(0, i1);
        String rest   = noPrefix.substring(i1 + 1);
        int i2 = rest.indexOf("\\");
        if (i2 < 0) return new String[]{server, rest};
        return new String[]{server, rest.substring(0, i2), rest.substring(i2 + 1)};
    }

    private String nvl(String s) {
        return s == null ? "" : s.trim();
    }
}