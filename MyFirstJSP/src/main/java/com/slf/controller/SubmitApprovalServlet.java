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

    // zennnne แก้
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Identify the reviewer from the session
        HttpSession session = request.getSession();
        Integer reviewerEmpId = getReviewerEmpId(session);
        if (reviewerEmpId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2. Read and validate parameters
        String formIdStr    = request.getParameter("formId");
        String action       = request.getParameter("action");        // "approve" or "reject"
        String expectedStepStr = request.getParameter("expectedStep");
        String comment      = request.getParameter("comment");
        String devEmpIdStr  = request.getParameter("devEmpId");
        String redirectPage = request.getParameter("redirectPage");  // e.g., "DirectorApprove.jsp"

        if (formIdStr == null || action == null || redirectPage == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing formId, action, or redirectPage");
            return;
        }

        int formId;
        try {
            formId = parseFormId(formIdStr);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid formId");
            return;
        }

        Integer expectedStep;
        try {
            expectedStep = parseExpectedStep(expectedStepStr);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid expectedStep");
            return;
        }

        redirectPage = sanitizeRedirectPage(redirectPage);

        try (Connection conn = DBConnection.getConnection()) {

            // 3. Load current step from DB
            int currentStep = getCurrentStep(conn, formId);
            if (currentStep == Integer.MIN_VALUE) {
                // No approval row at all — can't process
                response.sendRedirect(request.getContextPath() + "/" + redirectPage + "?error=not_found");
                return;
            }

            if (isStaleApprovalRequest(currentStep, expectedStep)) {
                response.sendRedirect(request.getContextPath() + "/" + redirectPage + "?error=stale_state");
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

            // 4b. Authorization check for this step
            String authError = assertAuthorized(conn, formId, currentStep, reviewerEmpId);
            if (authError != null) {
                if (authError.equals("not_found")) {
                    response.sendRedirect(request.getContextPath() + "/" + redirectPage + "?error=not_found");
                } else {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, authError);
                }
                return;
            }

            // 5. Calculate the new state step
            int newStep = calcNewStep(action, currentStep);
            if (newStep == Integer.MIN_VALUE) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
                return;
            }

            // 5b. Developer assignment
            boolean requireDevAssignment = requiresAssignedDeveloper(currentStep, action);
            Integer devEmpId;
            try {
                devEmpId = requireDevAssignment ? parseAssignedDeveloperId(devEmpIdStr, true) : null;
            } catch (IllegalArgumentException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
                return;
            }

            if (devEmpId == null) {
                devEmpId = getLatestAssignedDeveloperId(conn, formId);
            }

            if (devEmpId != null && !isDeveloperInAssignedSection(conn, formId, devEmpId)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Selected developer is not in the assigned section");
                return;
            }

            // 6. Insert the new approval row
            insertApprovalRow(conn, formId, reviewerEmpId, devEmpId, comment, newStep);

            // 7. Go back to the calling page with a success flag
            response.sendRedirect(request.getContextPath() + "/" + redirectPage + "?success=" + action);

        } catch (SQLException e) {
            throw new ServletException("Database error processing approval", e);
        }
    }
    // zennnne แก้

    // ─────────────────────────────────────────────────────────────────
    //  Private helper methods (zennnne แก้)
    // ─────────────────────────────────────────────────────────────────

    // zennnne แก้
    /** Returns the logged-in employee ID from the session, or null if not authenticated. */
    private Integer getReviewerEmpId(HttpSession session) {
        Object empObj = session.getAttribute("loggedInEmpId");
        if (empObj == null) {
            empObj = session.getAttribute("empid");
        }
        if (empObj == null) {
            return null;
        }
        return Integer.parseInt(empObj.toString());
    }
    // zennnne แก้

    // zennnne แก้
    /** Parses and validates the formId string. Throws NumberFormatException on invalid input. */
    private int parseFormId(String formIdStr) throws NumberFormatException {
        return Integer.parseInt(formIdStr.trim());
    }
    // zennnne แก้

    // zennnne แก้
    /**
     * Returns redirectPage if it is in the allowed whitelist, otherwise falls back to
     * "DirectorApprove.jsp" to prevent open-redirect attacks.
     */
    static String sanitizeRedirectPage(String redirectPage) {
        final java.util.Set<String> ALLOWED_REDIRECTS = new java.util.HashSet<>(java.util.Arrays.asList(
            "Process.jsp", "DirectorApprove.jsp", "directorApprove", "ITDirectorApprove.jsp", "TechnicalApprove.jsp", "submit.jsp"
        ));
        return ALLOWED_REDIRECTS.contains(redirectPage) ? redirectPage : "DirectorApprove.jsp";
    }
    // zennnne แก้

    // zennnne แก้
    /**
     * Queries the latest STATE_STEP for the given form.
     * Returns Integer.MIN_VALUE if no approval row exists yet.
     */
    private int getCurrentStep(Connection conn, int formId) throws SQLException {
        String sql = "SELECT STATE_STEP FROM APPROVALINFO " +
                     "WHERE FORMID = ? ORDER BY APPROVALID DESC FETCH FIRST 1 ROWS ONLY";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, formId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("STATE_STEP");
                }
            }
        }
        return Integer.MIN_VALUE;
    }
    // zennnne แก้

    // zennnne แก้
    /**
     * Checks whether the reviewer is authorised to act on the current step.
     * Returns null when authorised.
     * Returns "not_found" when the required role record is missing in the DB.
     * Returns a human-readable error message when the reviewer is the wrong person.
     */
    private String assertAuthorized(Connection conn, int formId, int currentStep, int reviewerEmpId)
            throws SQLException {

        if (currentStep == 0) {
            String directorSql =
                "SELECT d.DEPTHEAD_EMPID " +
                "FROM REQUISITIONFORM r " +
                "JOIN EMPLOYEE e ON r.EMPID = e.EMPID " +
                "JOIN SECTION s ON e.SECID = s.SECID " +
                "JOIN DEPARTMENT d ON s.DEPTID = d.DEPTID " +
                "WHERE r.FORMID = ?";
            try (PreparedStatement ps = conn.prepareStatement(directorSql)) {
                ps.setInt(1, formId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        return "not_found";
                    }
                    String deptHeadEmpId = rs.getString("DEPTHEAD_EMPID");
                    if (!matchesReviewer(deptHeadEmpId, reviewerEmpId)) {
                        return "Only the department director can approve this step";
                    }
                }
            }
        }

        if (currentStep == 1) {
            String sectionHeadSql =
                "SELECT s.SECTIONHEAD_EMPID " +
                "FROM REQUISITIONFORM r " +
                "JOIN SECTION s ON r.ASSIGN_SECID = s.SECID " +
                "WHERE r.FORMID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sectionHeadSql)) {
                ps.setInt(1, formId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        return "not_found";
                    }
                    String sectionHeadEmpId = rs.getString("SECTIONHEAD_EMPID");
                    if (!matchesReviewer(sectionHeadEmpId, reviewerEmpId)) {
                        return "Only the assigned section head can approve this step";
                    }
                }
            }
        }

        if (currentStep == 2) {
            String assignedDeptHeadSql =
                "SELECT d.DEPTHEAD_EMPID " +
                "FROM REQUISITIONFORM r " +
                "JOIN SECTION s ON r.ASSIGN_SECID = s.SECID " +
                "JOIN DEPARTMENT d ON s.DEPTID = d.DEPTID " +
                "WHERE r.FORMID = ?";
            try (PreparedStatement ps = conn.prepareStatement(assignedDeptHeadSql)) {
                ps.setInt(1, formId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        return "not_found";
                    }
                    String deptHeadEmpId = rs.getString("DEPTHEAD_EMPID");
                    if (!matchesReviewer(deptHeadEmpId, reviewerEmpId)) {
                        return "Only the assigned department director can approve this step";
                    }
                }
            }
        }

        if (currentStep == 3) {
            Integer assignedDeveloperId = getLatestAssignedDeveloperId(conn, formId);
            if (assignedDeveloperId == null) {
                return "not_found";
            }
            if (assignedDeveloperId.intValue() != reviewerEmpId) {
                return "Only the assigned developer can approve this step";
            }
        }

        return null; // authorised
    }
    // zennnne แก้

    // zennnne แก้
    /**
     * Calculates the new STATE_STEP value from the current step and action.
     * "approve" → currentStep + 1 (moves forward).
     * "reject"  → (currentStep + 1) * -1  (e.g. step 0 → -1, step 1 → -2).
     * Returns Integer.MIN_VALUE for any unrecognised action.
     */
    private int calcNewStep(String action, int currentStep) {
        if ("approve".equalsIgnoreCase(action)) {
            return currentStep + 1;
        } else if ("reject".equalsIgnoreCase(action)) {
            return (currentStep + 1) * -1;
        }
        return Integer.MIN_VALUE;
    }
    // zennnne แก้

    // zennnne แก้
    /**
     * Inserts a new APPROVALINFO row for the given form, reviewer, optional developer,
     * optional comment, and computed newStep.
     */
    private void insertApprovalRow(Connection conn, int formId, int reviewerEmpId,
                                   Integer devEmpId, String comment, int newStep)
            throws SQLException {
        String insertSql = "INSERT INTO APPROVALINFO " +
                           "(STATE_STEP, FORMID, REVIEWER_EMPID, DEV_EMPID, IT_COMMENT, APPROVED_DATE) " +
                           "VALUES (?, ?, ?, ?, ?, SYSTIMESTAMP)";
        try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
            ps.setInt(1, newStep);
            ps.setInt(2, formId);
            ps.setInt(3, reviewerEmpId);
            if (devEmpId != null) {
                ps.setInt(4, devEmpId);
            } else {
                ps.setNull(4, java.sql.Types.INTEGER);
            }
            if (comment != null && !comment.trim().isEmpty()) {
                ps.setString(5, comment.trim());
            } else {
                ps.setNull(5, java.sql.Types.VARCHAR);
            }
            ps.executeUpdate();
        }
    }
    // zennnne แก้

    // ─────────────────────────────────────────────────────────────────
    //  Existing static / package helpers (unchanged)
    // ─────────────────────────────────────────────────────────────────

    static boolean requiresAssignedDeveloper(int currentStep, String action) {
        return currentStep == 1 && "approve".equalsIgnoreCase(action);
    }

    static Integer parseExpectedStep(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        return Integer.valueOf(Integer.parseInt(value.trim()));
    }

    static boolean isStaleApprovalRequest(int currentStep, Integer expectedStep) {
        return expectedStep == null || expectedStep.intValue() != currentStep;
    }

    static Integer parseAssignedDeveloperId(String value, boolean required) {
        if (value == null || value.trim().isEmpty()) {
            if (required) {
                throw new IllegalArgumentException("Please select an assigned developer");
            }
            return null;
        }
        int devEmpId = Integer.parseInt(value.trim());
        if (devEmpId <= 0) {
            throw new NumberFormatException("devEmpId must be positive");
        }
        return Integer.valueOf(devEmpId);
    }

    static boolean matchesReviewer(String expectedEmpId, int reviewerEmpId) {
        return expectedEmpId != null && expectedEmpId.trim().equals(String.valueOf(reviewerEmpId));
    }

    private boolean isDeveloperInAssignedSection(Connection conn, int formId, int devEmpId) throws SQLException {
        String sql =
            "SELECT 1 " +
            "FROM REQUISITIONFORM r " +
            "JOIN EMPLOYEE e ON e.SECID = r.ASSIGN_SECID " +
            "WHERE r.FORMID = ? " +
            "AND e.EMPID = ? " +
            "FETCH FIRST 1 ROWS ONLY";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, formId);
            ps.setInt(2, devEmpId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private Integer getLatestAssignedDeveloperId(Connection conn, int formId) throws SQLException {
        String sql =
            "SELECT DEV_EMPID " +
            "FROM APPROVALINFO " +
            "WHERE FORMID = ? " +
            "AND DEV_EMPID IS NOT NULL " +
            "ORDER BY APPROVALID DESC " +
            "FETCH FIRST 1 ROWS ONLY";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, formId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Integer.valueOf(rs.getInt("DEV_EMPID"));
                }
            }
        }
        return null;
    }
}
