package com.slf.controller;

import com.slf.dao.ThirdPartyAcceptanceDAO;
import com.slf.dao.ThirdPartyFormSubmissionDAO;
import com.slf.dao.ThirdPartyRequestDAO;
import com.slf.dao.ThirdPartyWorkflowDAO;
import com.slf.model.ThirdPartyFormSubmission;
import com.slf.model.ThirdPartyRequest;
import com.slf.notification.ThirdPartyNotificationService;
import com.slf.util.ThirdPartyAccessPolicy;
import java.io.IOException;
import java.security.SecureRandom;
import java.sql.SQLException;
import java.util.Base64;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

abstract class ThirdPartyAssignedCompletionReviewServlet extends HttpServlet {
    private static final SecureRandom RANDOM = new SecureRandom();
    private final ThirdPartyRequestDAO requestDAO = new ThirdPartyRequestDAO();
    private final ThirdPartyFormSubmissionDAO submissionDAO = new ThirdPartyFormSubmissionDAO();
    private final ThirdPartyWorkflowDAO workflowDAO = new ThirdPartyWorkflowDAO();
    private final ThirdPartyAcceptanceDAO acceptanceDAO = new ThirdPartyAcceptanceDAO();
    private final ThirdPartyNotificationService notificationService = new ThirdPartyNotificationService();

    protected abstract String expectedStatus();
    protected abstract String assignmentRole();
    protected abstract String pageRole();
    protected abstract String pageTitle();
    protected abstract String detailLabel();
    protected abstract String detailParameter();
    protected abstract String servletPath();
    protected abstract boolean submit(long requestId, int actorEmpId, String detail) throws SQLException;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        loadAndForward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!ThirdPartyOperatorInboxServlet.isInfrastructure(request.getSession(false))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        if (!isValidCsrf(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid CSRF token");
            return;
        }
        try {
            long requestId = parsePositiveLong(request.getParameter("requestId"));
            String detail = requireDetail(request.getParameter(detailParameter()));
            int actorEmpId = ThirdPartyAccessPolicy.sessionEmpId(request.getSession(false)).intValue();
            if (!submit(requestId, actorEmpId, detail)) {
                response.sendError(HttpServletResponse.SC_CONFLICT,
                    "คำขอนี้ไม่ได้อยู่ในขั้นตอนที่กำหนด หรือไม่ได้มอบหมายให้ผู้ใช้นี้");
                return;
            }
            if ("REVOKE_OPERATOR".equals(assignmentRole())) {
                notificationService.notifyRevokerCompleted(requestId, actorEmpId, detail);
            } else if ("REVOKE_REVIEWER".equals(assignmentRole())) {
                notificationService.notifyRevokeReviewerCompleted(requestId, actorEmpId, detail);
            }
            response.sendRedirect(request.getContextPath() + "/thirdParty/operator");
        } catch (IllegalArgumentException e) {
            request.setAttribute("formError", e.getMessage());
            loadAndForward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to submit assigned third-party work", e);
        }
    }

    private void loadAndForward(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ThirdPartyOperatorInboxServlet.disableCaching(response);
        if (!ThirdPartyOperatorInboxServlet.isInfrastructure(request.getSession(false))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        try {
            long requestId = parsePositiveLong(firstNonBlank(
                request.getParameter("id"), request.getParameter("requestId")));
            int actorEmpId = ThirdPartyAccessPolicy.sessionEmpId(request.getSession(false)).intValue();
            ThirdPartyRequest thirdPartyRequest = requestDAO.findById(requestId);
            if (thirdPartyRequest == null || thirdPartyRequest.getSubmissionId() == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            if (!expectedStatus().equals(thirdPartyRequest.getStatus())
                    || !workflowDAO.isAssigned(requestId, assignmentRole(), actorEmpId)) {
                response.sendRedirect(request.getContextPath() + "/thirdParty/operator");
                return;
            }
            ThirdPartyFormSubmission submission =
                submissionDAO.findById(thirdPartyRequest.getSubmissionId().longValue());
            if (submission == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            request.setAttribute("thirdPartyRequest", thirdPartyRequest);
            request.setAttribute("submission", submission);
            request.setAttribute("sectionHeadComment", comment(requestId, "SECTION_HEAD_SUBMITTED"));
            request.setAttribute("itDirectorComment", comment(requestId, "IT_DIRECTOR_APPROVED"));
            request.setAttribute("operatorComment", comment(requestId, "OPERATOR_COMPLETED"));
            request.setAttribute("revokerComment", comment(requestId, "REVOKER_COMPLETED"));
            request.setAttribute("acceptanceResult", acceptanceDAO.findByRequestId(requestId));
            request.setAttribute("pageRole", pageRole());
            request.setAttribute("pageTitle", pageTitle());
            request.setAttribute("detailLabel", detailLabel());
            request.setAttribute("detailParameter", detailParameter());
            request.setAttribute("formAction", servletPath());
            request.setAttribute("showRevokerComment", "REVOKE_REVIEWER".equals(assignmentRole()));
            request.setAttribute("csrfToken", ensureCsrfToken(request));
            request.getRequestDispatcher("/WEB-INF/third-party-assigned-completion-review.jsp")
                .forward(request, response);
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (SQLException e) {
            throw new ServletException("Unable to load assigned third-party work", e);
        }
    }

    private String comment(long requestId, String actionType) throws SQLException {
        return workflowDAO.findLatestActionComment(requestId, actionType);
    }

    static String requireDetail(String value) {
        String detail = value == null ? "" : value.trim();
        if (detail.isEmpty()) throw new IllegalArgumentException("กรุณากรอกรายละเอียดการดำเนินการ");
        if (detail.length() > 4000) throw new IllegalArgumentException("รายละเอียดต้องไม่เกิน 4,000 ตัวอักษร");
        return detail;
    }

    private String ensureCsrfToken(HttpServletRequest request) {
        HttpSession session = request.getSession(true);
        String key = getClass().getName() + ".csrfToken";
        Object existing = session.getAttribute(key);
        if (existing instanceof String && !((String) existing).isEmpty()) return (String) existing;
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        session.setAttribute(key, token);
        return token;
    }

    private boolean isValidCsrf(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object expected = session == null ? null : session.getAttribute(getClass().getName() + ".csrfToken");
        return expected instanceof String && expected.equals(request.getParameter("csrfToken"));
    }

    private static long parsePositiveLong(String value) {
        long parsed = Long.parseLong(value == null ? "" : value.trim());
        if (parsed <= 0) throw new IllegalArgumentException("Invalid request id.");
        return parsed;
    }

    private static String firstNonBlank(String first, String second) {
        return first != null && !first.trim().isEmpty() ? first : second;
    }
}
