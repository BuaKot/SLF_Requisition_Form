package com.slf.controller;

import com.slf.dao.DBConnection;
import com.slf.notification.ApprovalNotificationService;

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
    private final ApprovalNotificationService approvalNotificationService = new ApprovalNotificationService();

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        Integer reviewerEmpId = getReviewerEmpId(session);
        if (reviewerEmpId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String formIdStr    = request.getParameter("formId");
        String action       = request.getParameter("action");
        String expectedStepStr = request.getParameter("expectedStep");
        String comment      = request.getParameter("comment");
        String devEmpIdStr  = request.getParameter("devEmpId");
        String redirectPage = request.getParameter("redirectPage");

        if (formIdStr == null || action == null || redirectPage == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing parameters");
            return;
        }

        int formId;
        try {
            formId = Integer.parseInt(formIdStr.trim());
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

            int currentStep = getCurrentStep(conn, formId);
            if (currentStep == Integer.MIN_VALUE) {
                response.sendRedirect(request.getContextPath() + "/" + redirectPage + "?error=not_found");
                return;
            }

            if (isStaleApprovalRequest(currentStep, expectedStep)) {
                response.sendRedirect(request.getContextPath() + "/" + redirectPage + "?error=stale_state");
                return;
            }

            if (currentStep < 0) {
                response.sendRedirect(request.getContextPath() + "/" + redirectPage + "?error=already_rejected");
                return;
            }
            if (currentStep >= 5) {
                response.sendRedirect(request.getContextPath() + "/" + redirectPage + "?error=already_completed");
                return;
            }

            String authError = assertAuthorized(conn, formId, currentStep, reviewerEmpId);
            if (authError != null) {
                if (authError.equals("not_found")) {
                    response.sendRedirect(request.getContextPath() + "/" + redirectPage + "?error=not_found");
                } else {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, authError);
                }
                return;
            }

            boolean technicalRequired = isTechnicalApprovalRequired(conn, formId);
            int newStep = calcNewStepWithFlag(action, currentStep, technicalRequired);
            if (newStep == Integer.MIN_VALUE) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action or step logic");
                return;
            }

            boolean requireDevAssignment = requiresAssignedDeveloper(currentStep, action, technicalRequired);
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

            insertApprovalRow(conn, formId, reviewerEmpId, devEmpId, comment, newStep);
            approvalNotificationService.notifyApprovalTransition(formId, reviewerEmpId, newStep, devEmpId, comment);

            response.sendRedirect(request.getContextPath() + "/" + redirectPage + "?success=" + action);

        } catch (SQLException e) {
            throw new ServletException("Database error processing approval", e);
        }
    }

    // ------------------------------------------------------------------
    //  Helper methods
    // ------------------------------------------------------------------

    private Integer getReviewerEmpId(HttpSession session) {
        Object empObj = session.getAttribute("loggedInEmpId");
        if (empObj == null) empObj = session.getAttribute("empid");
        if (empObj == null) return null;
        return Integer.parseInt(empObj.toString());
    }

    private int getCurrentStep(Connection conn, int formId) throws SQLException {
        String sql = "SELECT STATE_STEP FROM APPROVALINFO WHERE FORMID = ? ORDER BY APPROVALID DESC FETCH FIRST 1 ROWS ONLY";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, formId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("STATE_STEP");
            }
        }
        return Integer.MIN_VALUE;
    }

    private boolean isTechnicalApprovalRequired(Connection conn, int formId) throws SQLException {
        String sql = "SELECT NVL(TECHNICAL_APPROVAL_REQUIRED, 0) FROM REQUISITIONFORM WHERE FORMID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, formId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) == 1;
            }
        }
        return false;
    }

    private int calcNewStepWithFlag(String action, int currentStep, boolean technicalRequired) {
        if ("reject".equalsIgnoreCase(action)) {
            return (currentStep + 1) * -1;
        }
        if (!"approve".equalsIgnoreCase(action)) {
            return Integer.MIN_VALUE;
        }
        if (currentStep == 0) {
            return technicalRequired ? 1 : 2;
        }
        if (currentStep == 1 || currentStep == 2 || currentStep == 3) {
            return currentStep + 1;
        }
        if (currentStep == 4) {
            return 5;
        }
        return Integer.MIN_VALUE;
    }

    static boolean requiresAssignedDeveloper(int currentStep, String action, boolean technicalRequired) {
        return currentStep == 1 && "approve".equalsIgnoreCase(action) && technicalRequired;
    }

    private void insertApprovalRow(Connection conn, int formId, int reviewerEmpId,
                                   Integer devEmpId, String comment, int newStep) throws SQLException {
        String insertSql = "INSERT INTO APPROVALINFO (STATE_STEP, FORMID, REVIEWER_EMPID, DEV_EMPID, IT_COMMENT, APPROVED_DATE) VALUES (?, ?, ?, ?, ?, SYSTIMESTAMP)";
        try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
            ps.setInt(1, newStep);
            ps.setInt(2, formId);
            ps.setInt(3, reviewerEmpId);
            if (devEmpId != null) ps.setInt(4, devEmpId);
            else ps.setNull(4, java.sql.Types.INTEGER);
            if (comment != null && !comment.trim().isEmpty()) ps.setString(5, comment.trim());
            else ps.setNull(5, java.sql.Types.VARCHAR);
            ps.executeUpdate();
        }
    }

    private String assertAuthorized(Connection conn, int formId, int currentStep, int reviewerEmpId) throws SQLException {
        if (currentStep == 0) {
            String sql = "SELECT d.DEPTHEAD_EMPID FROM REQUISITIONFORM r JOIN EMPLOYEE e ON r.EMPID = e.EMPID JOIN SECTION s ON e.SECID = s.SECID JOIN DEPARTMENT d ON s.DEPTID = d.DEPTID WHERE r.FORMID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, formId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) return "not_found";
                    if (!matchesReviewer(rs.getString("DEPTHEAD_EMPID"), reviewerEmpId))
                        return "Only the department director can approve this step";
                }
            }
        }
        if (currentStep == 1) {
            String sql = "SELECT s.SECTIONHEAD_EMPID FROM REQUISITIONFORM r JOIN SECTION s ON r.ASSIGN_SECID = s.SECID WHERE r.FORMID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, formId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) return "not_found";
                    if (!matchesReviewer(rs.getString("SECTIONHEAD_EMPID"), reviewerEmpId))
                        return "Only the assigned section head can approve this step";
                }
            }
        }
        if (currentStep == 2) {
            String sql = "SELECT d.DEPTHEAD_EMPID FROM REQUISITIONFORM r JOIN SECTION s ON r.ASSIGN_SECID = s.SECID JOIN DEPARTMENT d ON s.DEPTID = d.DEPTID WHERE r.FORMID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, formId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) return "not_found";
                    if (!matchesReviewer(rs.getString("DEPTHEAD_EMPID"), reviewerEmpId))
                        return "Only the assigned department director can approve this step";
                }
            }
        }
        if (currentStep == 3) {
            Integer devId = getLatestAssignedDeveloperId(conn, formId);
            if (devId == null) return "not_found";
            if (devId != reviewerEmpId) return "Only the assigned developer can approve this step";
        }
        if (currentStep == 4) {
            Integer requesterId = getRequesterEmpId(conn, formId);
            if (requesterId == null) return "not_found";
            if (requesterId != reviewerEmpId) return "Only the requester can confirm this step";
        }
        return null;
    }

    // ------------------------------------------------------------------
    //  Static helpers (including the one used by tests)
    // ------------------------------------------------------------------
    static Integer parseExpectedStep(String value) {
        if (value == null || value.trim().isEmpty()) return null;
        return Integer.parseInt(value.trim());
    }

    static boolean isStaleApprovalRequest(int currentStep, Integer expectedStep) {
        return expectedStep == null || expectedStep != currentStep;
    }

    static String sanitizeRedirectPage(String redirectPage) {
        final java.util.Set<String> ALLOWED = new java.util.HashSet<>(java.util.Arrays.asList(
            "directorApprove", "itDirectorApprove", "technicalApprove", "process", "submit"
        ));
        return ALLOWED.contains(redirectPage) ? redirectPage : "directorApprove";
    }

    static Integer parseAssignedDeveloperId(String value, boolean required) {
        if (value == null || value.trim().isEmpty()) {
            if (required) throw new IllegalArgumentException("Please select an assigned developer");
            return null;
        }
        int id = Integer.parseInt(value.trim());
        if (id <= 0) throw new NumberFormatException("devEmpId must be positive");
        return id;
    }

    static boolean matchesReviewer(String expectedEmpId, int reviewerEmpId) {
        return expectedEmpId != null && expectedEmpId.trim().equals(String.valueOf(reviewerEmpId));
    }

    // ADDED: for test compatibility
    static boolean matchesRequester(int requesterEmpId, int reviewerEmpId) {
        return requesterEmpId == reviewerEmpId;
    }

    private Integer getRequesterEmpId(Connection conn, int formId) throws SQLException {
        String sql = "SELECT EMPID FROM REQUISITIONFORM WHERE FORMID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, formId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("EMPID");
            }
        }
        return null;
    }

    private boolean isDeveloperInAssignedSection(Connection conn, int formId, int devEmpId) throws SQLException {
        String sql = "SELECT 1 FROM REQUISITIONFORM r JOIN EMPLOYEE e ON e.SECID = r.ASSIGN_SECID WHERE r.FORMID = ? AND e.EMPID = ? FETCH FIRST 1 ROWS ONLY";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, formId);
            ps.setInt(2, devEmpId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private Integer getLatestAssignedDeveloperId(Connection conn, int formId) throws SQLException {
        String sql = "SELECT DEV_EMPID FROM APPROVALINFO WHERE FORMID = ? AND DEV_EMPID IS NOT NULL ORDER BY APPROVALID DESC FETCH FIRST 1 ROWS ONLY";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, formId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("DEV_EMPID");
            }
        }
        return null;
    }
}