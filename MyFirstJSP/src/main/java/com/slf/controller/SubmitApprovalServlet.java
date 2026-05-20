package com.slf.controller;

import com.slf.dao.DBConnection;

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

@WebServlet("/SubmitApprovalServlet")
public class SubmitApprovalServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Identify the reviewer from the session
        HttpSession session = request.getSession();
        Integer reviewerEmpId = null;
        Object empObj = session.getAttribute("loggedInEmpId");
        if (empObj == null) {
            empObj = session.getAttribute("empid");
        }
        if (empObj != null) {
            reviewerEmpId = Integer.parseInt(empObj.toString());
        } else {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2. Read parameters
        String formIdStr = request.getParameter("formId");
        String action = request.getParameter("action");   // "approve" or "reject"
        String comment = request.getParameter("comment");
        String redirectPage = request.getParameter("redirectPage"); // e.g., "DirectorApprove.jsp"

        if (formIdStr == null || action == null || redirectPage == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing formId, action, or redirectPage");
            return;
        }
        // zennnne แก้
        int formId;
        try {
            formId = Integer.parseInt(formIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid formId");
            return;
        }
        // zennnne แก้

        // zennnne แก้
        final java.util.Set<String> ALLOWED_REDIRECTS = new java.util.HashSet<>(java.util.Arrays.asList(
            "Directorapprove.jsp", "DirectorApprove.jsp", "ITDirectorApprove.jsp", "TechnicalApprove.jsp"
        ));
        if (!ALLOWED_REDIRECTS.contains(redirectPage)) {
            redirectPage = "Directorapprove.jsp";
        }
        // zennnne แก้

        // zennnne แก้
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement psCheck = conn.prepareStatement("SELECT STATE_STEP FROM APPROVALINFO " +
                     "WHERE FORMID = ? ORDER BY APPROVALID DESC FETCH FIRST 1 ROWS ONLY")) {
            psCheck.setInt(1, formId);
            try (ResultSet rs = psCheck.executeQuery()) {

                int currentStep;
                if (rs.next()) {
                    currentStep = rs.getInt("STATE_STEP");
                } else {
                    // No approval row at all — can't process
                    response.sendRedirect(request.getContextPath() + "/" + redirectPage + "?error=not_found");
                    return;
                }

                // 4. Reject if the form is already in a final state (rejected or completed)
                if (currentStep < 0) {
                    response.sendRedirect(request.getContextPath() + "/" + redirectPage + "?error=already_rejected");
                    return;
                }
                if (currentStep >= 5) {
                    response.sendRedirect(request.getContextPath() + "/" + redirectPage + "?error=already_completed");
                    return;
                }

                if (currentStep == 0) {
                    String directorSql =
                        "SELECT d.DEPTHEAD_EMPID " +
                        "FROM REQUISITIONFORM r " +
                        "JOIN SECTION s ON r.ASSIGN_SECID = s.SECID " +
                        "JOIN DEPARTMENT d ON s.DEPTID = d.DEPTID " +
                        "WHERE r.FORMID = ?";
                    try (PreparedStatement psDirector = conn.prepareStatement(directorSql)) {
                        psDirector.setInt(1, formId);
                        try (ResultSet directorRs = psDirector.executeQuery()) {
                            if (!directorRs.next()) {
                                response.sendRedirect(request.getContextPath() + "/" + redirectPage + "?error=not_found");
                                return;
                            }
                            String deptHeadEmpId = directorRs.getString("DEPTHEAD_EMPID");
                            if (deptHeadEmpId == null || !deptHeadEmpId.trim().equals(String.valueOf(reviewerEmpId))) {
                                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only the department director can approve this step");
                                return;
                            }
                        }
                    }
                }

                // 5. Calculate the new state step
                int newStep;
                if ("approve".equalsIgnoreCase(action)) {
                    newStep = currentStep + 1;   // moves forward
                } else if ("reject".equalsIgnoreCase(action)) {
                    newStep = (currentStep + 1) * -1;   // e.g., step 0 → -1, step 1 → -2, etc.
                } else {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
                    return;
                }

                // 6. Insert the new approval row
                String insertSql = "INSERT INTO APPROVALINFO " +
                                   "(STATE_STEP, FORMID, REVIEWER_EMPID, IT_COMMENT, APPROVED_DATE) " +
                                   "VALUES (?, ?, ?, ?, SYSTIMESTAMP)";
                try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                    psInsert.setInt(1, newStep);
                    psInsert.setInt(2, formId);
                    psInsert.setInt(3, reviewerEmpId);
                    if (comment != null && !comment.trim().isEmpty()) {
                        psInsert.setString(4, comment.trim());
                    } else {
                        psInsert.setNull(4, java.sql.Types.VARCHAR);
                    }
                    psInsert.executeUpdate();
                }
            }

            // 7. Go back to the calling page with a success flag
            response.sendRedirect(request.getContextPath() + "/" + redirectPage + "?success=" + action);

        } catch (SQLException e) {
            throw new ServletException("Database error processing approval", e);
        }
        // zennnne แก้
    }
}
