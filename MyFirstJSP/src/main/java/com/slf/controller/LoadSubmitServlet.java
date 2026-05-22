package com.slf.controller;

import com.slf.dao.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.*;
import java.util.*;

// zennnne แก้
@WebServlet("/submit")
public class LoadSubmitServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer empId = (Integer) session.getAttribute("loggedInEmpId");
        if (empId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String showParam = request.getParameter("show");
        if (showParam == null || showParam.trim().isEmpty()) showParam = "pending";
        String sortParam = request.getParameter("sort");
        if (!"desc".equals(sortParam)) sortParam = "asc";

        int currentPage = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            try { currentPage = Math.max(1, Integer.parseInt(pageParam)); }
            catch (NumberFormatException ignored) {}
        }
        int pageSize = 50;
        int offset = (currentPage - 1) * pageSize;

        List<String> statusConds = new ArrayList<>();
        for (String s : showParam.split(",")) {
            switch (s.trim().toLowerCase()) {
                case "pending":  statusConds.add("(NVL(ls.STATE_STEP,0) BETWEEN 0 AND 4 AND RF.DEADLINE >= TRUNC(SYSDATE))"); break;
                case "overdue":  statusConds.add("(NVL(ls.STATE_STEP,0) BETWEEN 0 AND 4 AND RF.DEADLINE < TRUNC(SYSDATE))");  break;
                case "rejected": statusConds.add("NVL(ls.STATE_STEP,0) < 0");  break;
                case "approved": statusConds.add("NVL(ls.STATE_STEP,0) >= 5"); break;
            }
        }
        String statusWhere = statusConds.isEmpty() ? "1=0"
            : "(" + String.join(" OR ", statusConds) + ")";
        String orderDir = "desc".equals(sortParam) ? "DESC" : "ASC";

        String sql =
            "WITH latest_step AS ( " +
            "    SELECT FORMID, STATE_STEP, " +
            "           ROW_NUMBER() OVER (PARTITION BY FORMID ORDER BY APPROVALID DESC) AS RN " +
            "    FROM APPROVALINFO " +
            ") " +
            "SELECT RF.FORMID, RF.TITLEFORM, RF.DEADLINE, RF.IS_EDITED, " +
            "       NVL(ls.STATE_STEP, 0) AS STATE_STEP " +
            "FROM REQUISITIONFORM RF " +
            "LEFT JOIN latest_step ls ON ls.FORMID = RF.FORMID AND ls.RN = 1 " +
            "WHERE RF.EMPID = ? " +
            "AND " + statusWhere + " " +
            "ORDER BY RF.DEADLINE " + orderDir + ", RF.FORMID DESC " +
            "OFFSET ? ROWS FETCH FIRST ? ROWS ONLY";

        List<Map<String, Object>> formList = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, empId);
            pstmt.setInt(2, offset);
            pstmt.setInt(3, pageSize);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("FORMID",    rs.getInt("FORMID"));
                    row.put("TITLEFORM", rs.getString("TITLEFORM"));
                    row.put("DEADLINE",  rs.getDate("DEADLINE"));
                    row.put("IS_EDITED", rs.getInt("IS_EDITED"));
                    row.put("STATE_STEP", rs.getInt("STATE_STEP"));
                    formList.add(row);
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Failed to load submit list", e);
        }

        request.setAttribute("formList",    formList);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("pageSize",    pageSize);
        request.setAttribute("showParam",   showParam);
        request.setAttribute("sortParam",   sortParam);

        request.getRequestDispatcher("/submit.jsp").forward(request, response);
    }
}
// zennnne แก้
