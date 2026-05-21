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
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.util.*;

// zennnne แก้
@WebServlet("/directorApprove")
public class LoadDirectorServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer empId = (Integer) session.getAttribute("loggedInEmpId");
        if (empId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String sql =
            "WITH latest_step AS ( " +
            "    SELECT FORMID, STATE_STEP, " +
            "           ROW_NUMBER() OVER (PARTITION BY FORMID ORDER BY APPROVALID DESC) AS RN " +
            "    FROM APPROVALINFO " +
            ") " +
            "SELECT r.FORMID, e.EMPNAME, r.TITLEFORM, r.DEADLINE, " +
            "s.SECNAME AS SECTION_NAME, d.DEPTNAME AS DEPARTMENT_NAME " +
            "FROM REQUISITIONFORM r " +
            "JOIN latest_step ls ON ls.FORMID = r.FORMID AND ls.RN = 1 " +
            "LEFT JOIN EMPLOYEE e ON r.EMPID = e.EMPID " +
            "LEFT JOIN SECTION s ON e.SECID = s.SECID " +
            "LEFT JOIN DEPARTMENT d ON s.DEPTID = d.DEPTID " +
            "WHERE ls.STATE_STEP = 0 " +
            "AND d.DEPTHEAD_EMPID = ? " +
            "AND r.DEADLINE >= TRUNC(SYSDATE) " +
            "ORDER BY r.FORMID DESC";

        List<Map<String, Object>> formList = new ArrayList<>();
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, empId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("FORMID",          rs.getString("FORMID") != null ? rs.getString("FORMID").trim() : "");
                    row.put("EMPNAME",         rs.getString("EMPNAME"));
                    row.put("TITLEFORM",       rs.getString("TITLEFORM"));
                    row.put("SECTION_NAME",    rs.getString("SECTION_NAME"));
                    row.put("DEPARTMENT_NAME", rs.getString("DEPARTMENT_NAME"));

                    java.sql.Date deadlineSql = rs.getDate("DEADLINE");
                    row.put("DEADLINE_DISPLAY", deadlineSql != null ? sdf.format(deadlineSql) : "-");
                    int daysLeft = 999;
                    if (deadlineSql != null)
                        daysLeft = (int)(deadlineSql.toLocalDate().toEpochDay() - LocalDate.now().toEpochDay());
                    row.put("DEADLINE_TAG", daysLeft <= 3 ? "urgent" : daysLeft <= 7 ? "soon" : "normal");

                    formList.add(row);
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Failed to load director approval list", e);
        }

        request.setAttribute("formList", formList);
        request.getRequestDispatcher("/DirectorApprove.jsp").forward(request, response); // zennnne แก้
    }
}
// zennnne แก้
