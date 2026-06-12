package com.slf.controller;

import com.slf.dao.DBConnection;
import com.slf.util.AuthUtil;
import com.slf.util.SecurityUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/ExtendDeadlineServlet")
public class ExtendDeadlineServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Object empObj = session.getAttribute("loggedInEmpId");
        if (empObj == null) empObj = session.getAttribute("empid");
        if (empObj == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (!SecurityUtil.isValidCsrfToken(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid CSRF token");
            return;
        }
        if (AuthUtil.isApprovalOnlyRole((String) session.getAttribute("position"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "This role cannot extend requisition deadlines");
            return;
        }
        int empId = Integer.parseInt(empObj.toString());

        String formIdStr   = request.getParameter("formId");
        String newDeadlineStr = request.getParameter("newDeadline"); // "YYYY-MM-DD"

        if (formIdStr == null || newDeadlineStr == null || newDeadlineStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/submit.jsp?error=missing_params");
            return;
        }

        // zennnne แก้
        int formId;
        try {
            formId = Integer.parseInt(formIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/submit.jsp?error=invalid_id");
            return;
        }
        // zennnne แก้
        Date newDeadline;
        try {
            newDeadline = Date.valueOf(newDeadlineStr.trim());
        } catch (IllegalArgumentException e) {
            response.sendRedirect(request.getContextPath() + "/submit.jsp?error=invalid_date");
            return;
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "UPDATE REQUISITIONFORM SET DEADLINE = ? WHERE FORMID = ? AND EMPID = ?")) {

            ps.setDate(1, newDeadline);
            ps.setInt(2, formId);
            ps.setInt(3, empId);
            int updated = ps.executeUpdate();
            if (updated == 0) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "You cannot update this requisition form");
                return;
            }

        } catch (SQLException e) {
            throw new ServletException("Database error extending deadline", e);
        }

        response.sendRedirect(request.getContextPath() + "/submit.jsp?success=deadline_extended");
    }
}
