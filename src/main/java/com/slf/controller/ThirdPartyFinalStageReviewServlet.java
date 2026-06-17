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

abstract class ThirdPartyFinalStageReviewServlet extends HttpServlet {
    private static final SecureRandom RANDOM = new SecureRandom();
    private final ThirdPartyRequestDAO requestDAO = new ThirdPartyRequestDAO();
    private final ThirdPartyFormSubmissionDAO submissionDAO = new ThirdPartyFormSubmissionDAO();
    private final ThirdPartyWorkflowDAO workflowDAO = new ThirdPartyWorkflowDAO();
    private final ThirdPartyAcceptanceDAO acceptanceDAO = new ThirdPartyAcceptanceDAO();
    private final ThirdPartyNotificationService notificationService = new ThirdPartyNotificationService();

    protected abstract boolean authorized(HttpSession session);
    protected abstract String expectedStatus();
    protected abstract String pageRole();
    protected abstract String pageTitle();
    protected abstract String servletPath();
    protected abstract String inboxPath();
    protected abstract boolean showReportField();
    protected abstract boolean submit(long requestId, int actorEmpId, String report) throws SQLException;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        loadAndForward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!isAuthorized(request.getSession(false))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        if (!isValidCsrf(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid CSRF token");
            return;
        }
        try {
            long requestId = parsePositiveLong(request.getParameter("requestId"));
            String report = showReportField() ? requireReport(request.getParameter("summaryReport")) : null;
            int actorEmpId = ThirdPartyAccessPolicy.sessionEmpId(request.getSession(false)).intValue();
            if (!submit(requestId, actorEmpId, report)) {
                response.sendError(HttpServletResponse.SC_CONFLICT, "คำขอนี้ไม่ได้อยู่ในขั้นตอนที่กำหนด");
                return;
            }
            if (showReportField()) {
                notificationService.notifySectionHeadReported(requestId, actorEmpId, report);
            } else {
                notificationService.notifyFinalCertified(requestId, actorEmpId);
            }
            response.sendRedirect(request.getContextPath() + inboxPath());
        } catch (IllegalArgumentException e) {
            request.setAttribute("formError", e.getMessage());
            loadAndForward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to submit final-stage third-party work", e);
        }
    }

    private void loadAndForward(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ThirdPartyOperatorInboxServlet.disableCaching(response);
        if (!isAuthorized(request.getSession(false))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        try {
            long requestId = parsePositiveLong(firstNonBlank(
                request.getParameter("id"), request.getParameter("requestId")));
            ThirdPartyRequest thirdPartyRequest = requestDAO.findById(requestId);
            if (thirdPartyRequest == null || thirdPartyRequest.getSubmissionId() == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            if (!expectedStatus().equals(thirdPartyRequest.getStatus())) {
                response.sendRedirect(request.getContextPath() + inboxPath());
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
            request.setAttribute("assignments", workflowDAO.findAssignments(requestId));
            request.setAttribute("acceptanceResult", acceptanceDAO.findByRequestId(requestId));
            setComment(request, requestId, "sectionHeadComment", "SECTION_HEAD_SUBMITTED");
            setComment(request, requestId, "itDirectorComment", "IT_DIRECTOR_APPROVED");
            setComment(request, requestId, "operatorComment", "OPERATOR_COMPLETED");
            setComment(request, requestId, "revokerComment", "REVOKER_COMPLETED");
            setComment(request, requestId, "reviewerComment", "REVOKE_REVIEWER_APPROVED");
            setComment(request, requestId, "sectionHeadReport", "SECTION_HEAD_REPORTED");
            request.setAttribute("pageRole", pageRole());
            request.setAttribute("pageTitle", pageTitle());
            request.setAttribute("formAction", servletPath());
            request.setAttribute("inboxPath", inboxPath());
            request.setAttribute("showReportField", showReportField());
            request.setAttribute("csrfToken", ensureCsrfToken(request));
            request.getRequestDispatcher("/WEB-INF/views/ThirdPartyFinalStageReview.jsp")
                .forward(request, response);
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (SQLException e) {
            throw new ServletException("Unable to load final-stage third-party work", e);
        }
    }

    private void setComment(HttpServletRequest request, long requestId, String attribute, String action)
            throws SQLException {
        request.setAttribute(attribute, workflowDAO.findLatestActionComment(requestId, action));
    }

    static String requireReport(String value) {
        String report = value == null ? "" : value.trim();
        if (report.isEmpty()) throw new IllegalArgumentException("กรุณากรอกรายงานสรุป");
        if (report.length() > 4000) throw new IllegalArgumentException("รายงานสรุปต้องไม่เกิน 4,000 ตัวอักษร");
        return report;
    }

    private boolean isAuthorized(HttpSession session) {
        return authorized(session) && ThirdPartyAccessPolicy.sessionEmpId(session) != null;
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
