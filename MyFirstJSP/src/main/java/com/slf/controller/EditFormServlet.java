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
import java.util.List;

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
        try {
            String prefillJson = buildPrefillJson(formId);
            request.setAttribute("prefillJson", prefillJson);
        } catch (SQLException e) {
            throw new ServletException("Failed to load old form data", e);
        }

        request.getRequestDispatcher("/form.jsp").forward(request, response);
    }

    // ---------------------------------------------------------------
    //  Build JSON string representing the old form's data
    // ---------------------------------------------------------------
    private String buildPrefillJson(int formId) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();

            // ---------- Header ----------
            String titleForm = "";
            String deadline   = "";
            int    sectionId  = 0;
            int    deptId     = 0;

            String headerSql =
                "SELECT r.TITLEFORM, TO_CHAR(r.DEADLINE,'YYYY-MM-DD') AS DEADLINE, " +
                "r.ASSIGN_SECID, NVL(s.DEPTID, 0) AS DEPTID " +
                "FROM REQUISITIONFORM r " +
                "LEFT JOIN SECTION s ON r.ASSIGN_SECID = s.SECID " +
                "WHERE r.FORMID = ?";
            try (PreparedStatement ps = conn.prepareStatement(headerSql)) {
                ps.setInt(1, formId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        titleForm = nvl(rs.getString("TITLEFORM"));
                        deadline  = nvl(rs.getString("DEADLINE"));
                        sectionId = rs.getInt("ASSIGN_SECID");
                        deptId    = rs.getInt("DEPTID");
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
            List<String> itemsJson   = new ArrayList<>();
            boolean      serverUsed  = false; // attach permissions to first server item only

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
                        int    typeId        = rs.getInt("TYPEID");
                        String typeName      = nvl(rs.getString("TYPENAME"));
                        String programOrOther = nvl(rs.getString("OTHERDETAILS_OR_PROGRAM"));
                        String objective     = nvl(rs.getString("DETAILOBJECTIVE"));
                        String currentMethod = nvl(rs.getString("CURRENTMETHOD"));

                        boolean isServerType = typeName.contains("สิทธิ์") && typeName.contains("ข้อมูล");

                        StringBuilder sb = new StringBuilder("{");
                        sb.append("\"typeId\":").append(typeId).append(",");
                        sb.append("\"programOrOther\":\"").append(esc(programOrOther)).append("\",");
                        sb.append("\"objective\":\"").append(esc(objective)).append("\",");
                        sb.append("\"currentMethod\":\"").append(esc(currentMethod)).append("\",");

                        if (isServerType && !serverUsed) {
                            sb.append("\"serverName\":\"").append(esc(serverName)).append("\",");
                            sb.append("\"serverFolder\":\"").append(esc(serverFolder)).append("\",");
                            sb.append("\"subFolder\":\"").append(esc(subFolder)).append("\",");
                            sb.append("\"folderPerms\":").append(toJsonArr(folderPerms)).append(",");
                            sb.append("\"subFolderPerms\":").append(toJsonArr(subFolderPerms));
                            serverUsed = true;
                        } else {
                            sb.append("\"serverName\":\"\",\"serverFolder\":\"\",\"subFolder\":\"\",");
                            sb.append("\"folderPerms\":[],\"subFolderPerms\":[]");
                        }
                        sb.append("}");
                        itemsJson.add(sb.toString());
                    }
                }
            }

            // ---------- Assemble ----------
            StringBuilder json = new StringBuilder("{");
            json.append("\"titleForm\":\"").append(esc(titleForm)).append("\",");
            json.append("\"deadline\":\"").append(esc(deadline)).append("\",");
            json.append("\"sectionId\":").append(sectionId).append(",");
            json.append("\"deptId\":").append(deptId).append(",");
            json.append("\"items\":[").append(String.join(",", itemsJson)).append("]");
            json.append("}");
            return json.toString();

        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    }

    /**
     * Parse \\server\folder[\subfolder] → ["server", "folder"] or ["server", "folder", "subfolder"]
     */
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

    /** Escape for embedding inside a JS string literal */
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t")
                .replace("<", "\\u003C")
                .replace(">", "\\u003E")
                .replace("/", "\\/");
    }

    private String toJsonArr(List<String> list) {
        if (list == null || list.isEmpty()) return "[]";
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            if (i > 0) sb.append(",");
            sb.append("\"").append(esc(list.get(i))).append("\"");
        }
        sb.append("]");
        return sb.toString();
    }
}