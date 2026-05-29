package com.slf.controller;

import com.slf.dao.DBConnection;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

// zennnne แก้
@WebServlet("/dashboardBarData")
public class DashboardBarDataServlet extends HttpServlet {

    private static final List<String> ALLOWED_ROLES = Arrays.asList("Admin", "Director");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loggedInEmpId") == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        String position = (String) session.getAttribute("position");
        if (!ALLOWED_ROLES.contains(position)) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        resp.setContentType("application/json;charset=UTF-8");
        resp.setHeader("Cache-Control", "no-cache");

        int deptId = parseIntParam(req, "deptId");
        int secId  = parseIntParam(req, "secId");
        int empId  = parseIntParam(req, "empId");

        String timeFilter = req.getParameter("timeFilter");
        if (timeFilter == null) timeFilter = "30days";
        String startDate = nvl(req.getParameter("startDate"));
        String endDate   = nvl(req.getParameter("endDate"));

        List<String>  labels  = new ArrayList<>();
        List<Integer> values  = new ArrayList<>();
        boolean queryOk = false;

        List<String> whereParts = new ArrayList<>();
        List<Object> params     = new ArrayList<>();

        if ("custom".equals(timeFilter) && !startDate.isEmpty() && !endDate.isEmpty()) {
            whereParts.add("RF.CREATE_DATE BETWEEN TO_DATE(?, 'YYYY-MM-DD') AND TO_DATE(?, 'YYYY-MM-DD')");
            params.add(startDate); params.add(endDate);
        }
        if (empId > 0) {
            whereParts.add("RF.EMPID = ?"); params.add(empId);
        } else if (secId > 0) {
            whereParts.add("S.SECID = ?"); params.add(secId);
        } else if (deptId > 0) {
            whereParts.add("D.DEPTID = ?"); params.add(deptId);
        }

        String whereStr = whereParts.isEmpty() ? "" : " WHERE " + String.join(" AND ", whereParts);
        String sql =
            "SELECT RT.TYPENAME AS CATEGORY, COUNT(*) AS TOTAL " +
            "FROM REQUISITIONFORM RF " +
            "JOIN REQUEST REQ ON REQ.FORMID = RF.FORMID " +
            "JOIN REQUESTTYPE RT ON RT.TYPEID = REQ.TYPEID " +
            "JOIN EMPLOYEE E ON RF.EMPID = E.EMPID " +
            "JOIN SECTION S ON E.SECID = S.SECID " +
            "JOIN DEPARTMENT D ON S.DEPTID = D.DEPTID " +
            whereStr +
            " GROUP BY RT.TYPENAME ORDER BY TOTAL DESC FETCH FIRST 5 ROWS ONLY";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String cat = rs.getString("CATEGORY");
                    labels.add(escapeJson(cat != null ? cat : "ทั่วไป"));
                    values.add(rs.getInt("TOTAL"));
                }
            }
            queryOk = true;
        } catch (SQLException ignored) {}

        PrintWriter out = resp.getWriter();
        out.print("{\"ok\":");
        out.print(queryOk);
        out.print(",\"labels\":[");
        for (int i = 0; i < labels.size(); i++) {
            if (i > 0) out.print(",");
            out.print("\""); out.print(labels.get(i)); out.print("\"");
        }
        out.print("],\"values\":[");
        for (int i = 0; i < values.size(); i++) {
            if (i > 0) out.print(",");
            out.print(values.get(i));
        }
        out.print("]}");
    }

    private int parseIntParam(HttpServletRequest req, String name) {
        try {
            String v = req.getParameter(name);
            return (v != null && !v.trim().isEmpty()) ? Integer.parseInt(v.trim()) : 0;
        } catch (NumberFormatException e) { return 0; }
    }

    private String nvl(String s) { return s != null ? s : ""; }

    private String escapeJson(String s) {
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }
}
// zennnne แก้ end
