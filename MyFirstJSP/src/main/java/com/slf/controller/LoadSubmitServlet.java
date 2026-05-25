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
        if (showParam == null || showParam.trim().isEmpty()) showParam = "pending,overdue,rejected,approved";
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
                case "pending":  statusConds.add("(NVL(ls.STATE_STEP,0) BETWEEN 0 AND 4 AND (RF.DEADLINE IS NULL OR RF.DEADLINE >= TRUNC(SYSDATE)))"); break;
                case "overdue":  statusConds.add("(NVL(ls.STATE_STEP,0) BETWEEN 0 AND 4 AND RF.DEADLINE < TRUNC(SYSDATE))");  break;
                case "rejected": statusConds.add("NVL(ls.STATE_STEP,0) < 0");  break;
                case "approved": statusConds.add("NVL(ls.STATE_STEP,0) >= 5"); break;
            }
        }
        String statusWhere = statusConds.isEmpty() ? "1=0"
            : "(" + String.join(" OR ", statusConds) + ")";
        String orderDir = "desc".equals(sortParam) ? "DESC" : "ASC";

        // zennnne แก้ — CTE นำกลับมาใช้ใน count + main query
        String cteBase =
            "WITH latest_step AS ( " +
            "    SELECT FORMID, STATE_STEP, " +
            "           ROW_NUMBER() OVER (PARTITION BY FORMID ORDER BY APPROVALID DESC) AS RN " +
            "    FROM APPROVALINFO " +
            ") ";

        String countSql = cteBase +
            "SELECT " +
            "    COUNT(*) AS TOTAL, " +
            "    SUM(CASE WHEN NVL(ls.STATE_STEP,0) BETWEEN 0 AND 4 AND RF.DEADLINE >= TRUNC(SYSDATE) THEN 1 ELSE 0 END) AS CNT_PENDING, " +
            "    SUM(CASE WHEN NVL(ls.STATE_STEP,0) BETWEEN 0 AND 4 AND RF.DEADLINE <  TRUNC(SYSDATE) THEN 1 ELSE 0 END) AS CNT_OVERDUE, " +
            "    SUM(CASE WHEN NVL(ls.STATE_STEP,0) < 0            THEN 1 ELSE 0 END) AS CNT_REJECTED, " +
            "    SUM(CASE WHEN NVL(ls.STATE_STEP,0) >= 5           THEN 1 ELSE 0 END) AS CNT_APPROVED " +
            "FROM REQUISITIONFORM RF " +
            "LEFT JOIN latest_step ls ON ls.FORMID = RF.FORMID AND ls.RN = 1 " +
            "WHERE RF.EMPID = ?";

        // zennnne แก้ — add step timestamps via conditional aggregation
        String sql = cteBase +
            "SELECT RF.FORMID, RF.TITLEFORM, RF.DEADLINE, RF.IS_EDITED, " +
            "       NVL(ls.STATE_STEP, 0) AS STATE_STEP, " +
            "       MAX(CASE WHEN ABS(ai.STATE_STEP) = 1 THEN ai.APPROVED_DATE END) AS TS1, " +
            "       MAX(CASE WHEN ABS(ai.STATE_STEP) = 2 THEN ai.APPROVED_DATE END) AS TS2, " +
            "       MAX(CASE WHEN ABS(ai.STATE_STEP) = 3 THEN ai.APPROVED_DATE END) AS TS3, " +
            "       MAX(CASE WHEN ABS(ai.STATE_STEP) = 4 THEN ai.APPROVED_DATE END) AS TS4 " +
            "FROM REQUISITIONFORM RF " +
            "LEFT JOIN latest_step ls ON ls.FORMID = RF.FORMID AND ls.RN = 1 " +
            "LEFT JOIN APPROVALINFO ai ON ai.FORMID = RF.FORMID " +
            "WHERE RF.EMPID = ? " +
            "AND " + statusWhere + " " +
            "GROUP BY RF.FORMID, RF.TITLEFORM, RF.DEADLINE, RF.IS_EDITED, NVL(ls.STATE_STEP, 0) " +
            "ORDER BY RF.DEADLINE " + orderDir + ", RF.FORMID DESC " +
            "OFFSET ? ROWS FETCH FIRST ? ROWS ONLY";
        // zennnne แก้
        // zennnne แก้

        List<Map<String, Object>> formList = new ArrayList<>();
        // zennnne แก้
        int cntTotal = 0, cntPending = 0, cntOverdue = 0, cntRejected = 0, cntApproved = 0;

        try (Connection conn = DBConnection.getConnection()) {
            // run count query first
            try (PreparedStatement psCount = conn.prepareStatement(countSql)) {
                psCount.setInt(1, empId);
                try (ResultSet rsCount = psCount.executeQuery()) {
                    if (rsCount.next()) {
                        cntTotal    = rsCount.getInt("TOTAL");
                        cntPending  = rsCount.getInt("CNT_PENDING");
                        cntOverdue  = rsCount.getInt("CNT_OVERDUE");
                        cntRejected = rsCount.getInt("CNT_REJECTED");
                        cntApproved = rsCount.getInt("CNT_APPROVED");
                    }
                }
            }

            // run paginated main query
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, empId);
                pstmt.setInt(2, offset);
                pstmt.setInt(3, pageSize);

                try (ResultSet rs = pstmt.executeQuery()) {
                    // zennnne แก้
                    while (rs.next()) {
                        Map<String, Object> row = new HashMap<>();
                        row.put("FORMID",    rs.getInt("FORMID"));
                        row.put("TITLEFORM", rs.getString("TITLEFORM"));
                        row.put("DEADLINE",  rs.getDate("DEADLINE"));
                        row.put("IS_EDITED", rs.getInt("IS_EDITED"));
                        row.put("STATE_STEP", rs.getInt("STATE_STEP"));
                        row.put("TS1", rs.getTimestamp("TS1"));
                        row.put("TS2", rs.getTimestamp("TS2"));
                        row.put("TS3", rs.getTimestamp("TS3"));
                        row.put("TS4", rs.getTimestamp("TS4"));
                        formList.add(row);
                    }
                    // zennnne แก้
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Failed to load submit list", e);
        }
        // zennnne แก้

        request.setAttribute("formList",    formList);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("pageSize",    pageSize);
        request.setAttribute("showParam",   showParam);
        request.setAttribute("sortParam",   sortParam);
        // zennnne แก้
        request.setAttribute("cntTotal",    cntTotal);
        request.setAttribute("cntPending",  cntPending);
        request.setAttribute("cntOverdue",  cntOverdue);
        request.setAttribute("cntRejected", cntRejected);
        request.setAttribute("cntApproved", cntApproved);
        // zennnne แก้

        request.getRequestDispatcher("/submit.jsp").forward(request, response);
    }
}
// zennnne แก้
