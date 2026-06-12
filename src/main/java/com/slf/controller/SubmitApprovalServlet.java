package com.slf.controller;

import com.slf.dao.DBConnection;
import com.slf.notification.ApprovalNotificationService;
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
        if (!SecurityUtil.isValidCsrfToken(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid CSRF token");
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
        if (!isRoleAllowedForApprovalAction((String) session.getAttribute("position"), redirectPage)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "This role cannot perform this approval action");
            return;
        }

        int newStep;
        Integer devEmpId;
        String notificationComment;

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            try {
                if (!lockFormForApproval(conn, formId)) {
                    conn.rollback();
                    response.sendRedirect(request.getContextPath() + "/" + redirectPage + "?error=not_found");
                    return;
                }

                int currentStep = getCurrentStep(conn, formId);
                if (currentStep == Integer.MIN_VALUE) {
                    conn.rollback();
                    response.sendRedirect(request.getContextPath() + "/" + redirectPage + "?error=not_found");
                    return;
                }

                if (isStaleApprovalRequest(currentStep, expectedStep)) {
                    conn.rollback();
                    response.sendRedirect(request.getContextPath() + "/" + redirectPage + "?error=already_processed");
                    return;
                }

                if (currentStep < 0) {
                    conn.rollback();
                    response.sendRedirect(request.getContextPath() + "/" + redirectPage + "?error=already_processed");
                    return;
                }
                if (currentStep >= 5) {
                    conn.rollback();
                    response.sendRedirect(request.getContextPath() + "/" + redirectPage + "?error=already_processed");
                    return;
                }

                String authError = assertAuthorized(conn, formId, currentStep, reviewerEmpId);
                if (authError != null) {
                    conn.rollback();
                    if (authError.equals("not_found")) {
                        response.sendRedirect(request.getContextPath() + "/" + redirectPage + "?error=not_found");
                    } else {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN, authError);
                    }
                    return;
                }

                boolean technicalRequired = isTechnicalApprovalRequired(conn, formId);
                newStep = calcNewStepWithFlag(action, currentStep, technicalRequired);
                if (newStep == Integer.MIN_VALUE) {
                    conn.rollback();
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action or step logic");
                    return;
                }

                boolean requireDevAssignment = requiresAssignedDeveloper(currentStep, action, technicalRequired);
                try {
                    devEmpId = requireDevAssignment ? parseAssignedDeveloperId(devEmpIdStr, true) : null;
                } catch (IllegalArgumentException e) {
                    conn.rollback();
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
                    return;
                }

                if (devEmpId == null) {
                    devEmpId = getLatestAssignedDeveloperId(conn, formId);
                }

                if (devEmpId != null && !isDeveloperInAssignedSection(conn, formId, devEmpId)) {
                    conn.rollback();
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Selected developer is not in the assigned section");
                    return;
                }

                notificationComment = comment;
                insertApprovalRow(conn, formId, reviewerEmpId, devEmpId, comment, newStep);
                conn.commit();
            } catch (SQLException | RuntimeException e) {
                conn.rollback();
                throw e;
            }

        } catch (SQLException e) {
            throw new ServletException("Database error processing approval", e);
        }

        approvalNotificationService.notifyApprovalTransition(formId, reviewerEmpId, newStep, devEmpId, notificationComment);
        response.sendRedirect(request.getContextPath() + "/" + redirectPage + "?success=" + action);
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

    private boolean lockFormForApproval(Connection conn, int formId) throws SQLException {
        String sql = "SELECT FORMID FROM REQUISITIONFORM WHERE FORMID = ? FOR UPDATE";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, formId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private boolean isTechnicalApprovalRequired(Connection conn, int formId) throws SQLException {
        // The current IT requisition workflow always requires the Technical step.
        // Some legacy schemas have TECHNICAL_APPROVAL_REQUIRED defaulting to 0,
        // which caused Director approval to skip directly to IT Director.
        String sql = "SELECT TECHNICAL_APPROVAL_REQUIRED FROM REQUISITIONFORM WHERE FORMID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, formId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return true;
            }
        } catch (SQLException e) {
            if (isMissingColumn(e)) {
                return true;
            }
            throw e;
        }
        return true;
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

    static boolean isRoleAllowedForApprovalAction(String position, String redirectPage) {
        if ("submit".equals(redirectPage)) {
            return position != null && !position.trim().isEmpty();
        }
        return AuthUtil.isAllowedForPage(position, redirectPage);
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

    static boolean isMissingColumn(SQLException e) {
        String message = e.getMessage();
        return e.getErrorCode() == 904
            || (message != null && message.toUpperCase(java.util.Locale.ROOT).contains("INVALID IDENTIFIER"));
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
