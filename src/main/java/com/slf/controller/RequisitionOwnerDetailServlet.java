package com.slf.controller;

import com.slf.dao.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/detail.jsp")
public class RequisitionOwnerDetailServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer viewerEmpId = sessionEmpId(session);
        if (viewerEmpId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int formId;
        try {
            formId = parseFormId(request.getParameter("id"));
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
            return;
        }

        try {
            if (!isAuthorizedViewer(formId, viewerEmpId.intValue())) {
                // Use 404 so callers cannot distinguish an unrelated form from a missing id.
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
        } catch (SQLException e) {
            throw new ServletException("Unable to authorize requisition detail", e);
        }

        request.setAttribute("requisitionDetailAuthorized", Boolean.TRUE);
        request.getRequestDispatcher("/WEB-INF/views/Detail.jsp").forward(request, response);
    }

    static int parseFormId(String value) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException("Missing form id.");
        }
        try {
            int formId = Integer.parseInt(value.trim());
            if (formId <= 0) throw new IllegalArgumentException("Invalid form id.");
            return formId;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Invalid form id.");
        }
    }

    private boolean isAuthorizedViewer(int formId, int viewerEmpId) throws SQLException {
        String sql =
            "SELECT 1 FROM REQUISITIONFORM rf " +
            "WHERE rf.FORMID = ? AND (rf.EMPID = ? OR EXISTS (" +
            "SELECT 1 FROM APPROVALINFO ai " +
            "WHERE ai.FORMID = rf.FORMID AND ai.REVIEWER_EMPID = ?" +
            ")) FETCH FIRST 1 ROW ONLY";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, formId);
            ps.setInt(2, viewerEmpId);
            ps.setInt(3, viewerEmpId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private static Integer sessionEmpId(HttpSession session) {
        if (session == null) return null;
        Object value = session.getAttribute("loggedInEmpId");
        if (value == null) value = session.getAttribute("empid");
        if (value == null) return null;
        try {
            return Integer.valueOf(value.toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
