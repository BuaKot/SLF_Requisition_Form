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
        int formId = Integer.parseInt(formIdStr.trim());

        Connection conn = null;
        PreparedStatement psCheck = null;
        PreparedStatement psInsert = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();

            // 3. Get the current state
            String checkSql = "SELECT STATE_STEP FROM APPROVALINFO " +
                              "WHERE FORMID = ? ORDER BY APPROVALID DESC FETCH FIRST 1 ROWS ONLY";
            psCheck = conn.prepareStatement(checkSql);
            psCheck.setInt(1, formId);
            rs = psCheck.executeQuery();

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
                               "(STATE_STEP, FORMID, REVIEWER_EMPID, IT_COMMENT) " +
                               "VALUES (?, ?, ?, ?)";
            psInsert = conn.prepareStatement(insertSql);
            psInsert.setInt(1, newStep);
            psInsert.setInt(2, formId);
            psInsert.setInt(3, reviewerEmpId);
            if (comment != null && !comment.trim().isEmpty()) {
                psInsert.setString(4, comment.trim());
            } else {
                psInsert.setNull(4, java.sql.Types.VARCHAR);
            }
            psInsert.executeUpdate();

            // 7. Go back to the calling page with a success flag
            response.sendRedirect(request.getContextPath() + "/" + redirectPage + "?success=" + action);

        } catch (SQLException e) {
            throw new ServletException("Database error processing approval", e);
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
            try { if (psCheck != null) psCheck.close(); } catch (SQLException ignored) {}
            try { if (psInsert != null) psInsert.close(); } catch (SQLException ignored) {}
            try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
        }
    }
}