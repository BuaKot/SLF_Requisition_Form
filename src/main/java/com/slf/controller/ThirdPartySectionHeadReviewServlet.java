package com.slf.controller;

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
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/thirdParty/sectionHead/review")
public class ThirdPartySectionHeadReviewServlet extends HttpServlet {
    private static final String CSRF_SESSION_KEY = "thirdPartySectionHeadReviewCsrfToken";
    private static final SecureRandom RANDOM = new SecureRandom();
    private final ThirdPartyRequestDAO requestDAO = new ThirdPartyRequestDAO();
    private final ThirdPartyFormSubmissionDAO submissionDAO = new ThirdPartyFormSubmissionDAO();
    private final ThirdPartyWorkflowDAO workflowDAO = new ThirdPartyWorkflowDAO();
    private final ThirdPartyNotificationService notificationService = new ThirdPartyNotificationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        loadAndForward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!isTechnical(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        if (!isValidCsrf(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid CSRF token");
            return;
        }

        try {
            long requestId = parsePositiveLong(request.getParameter("requestId"));
            String comment = requireComment(request.getParameter("comment"));
            int grantOperator = parsePositiveInt(request.getParameter("grantOperatorEmpId"));
            int revokeOperator = request.getParameter("separateRevoker") == null
                ? grantOperator
                : parsePositiveInt(request.getParameter("revokeOperatorEmpId"));
            int revokeReviewer = parsePositiveInt(request.getParameter("revokeReviewerEmpId"));
            validateReviewerAssignments(grantOperator, revokeOperator, revokeReviewer);
            int actorEmpId = ThirdPartyAccessPolicy.sessionEmpId(request.getSession(false)).intValue();

            boolean submitted = workflowDAO.submitSectionHeadReview(
                requestId, actorEmpId, comment, grantOperator, revokeOperator, revokeReviewer);
            if (!submitted) {
                response.sendError(HttpServletResponse.SC_CONFLICT,
                    "คำขอนี้ไม่ได้อยู่ในขั้นตอนรอหัวหน้าส่วนพิจารณาแล้ว");
                return;
            }
            notificationService.notifySectionHeadSubmitted(requestId, actorEmpId, comment);
            response.sendRedirect(request.getContextPath() + "/thirdParty/sectionHead");
        } catch (IllegalArgumentException e) {
            request.setAttribute("formError", e.getMessage());
            loadAndForward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to submit third-party section-head review", e);
        }
    }

    private void loadAndForward(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        disableCaching(response);
        if (!isTechnical(request)) {
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
            if (!"PENDING_SECTION_HEAD".equals(thirdPartyRequest.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/thirdParty/sectionHead");
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
            request.setAttribute("infrastructureEmployees", workflowDAO.findActiveInfrastructureEmployees());
            request.setAttribute("csrfToken", ensureCsrfToken(request));
            request.getRequestDispatcher("/WEB-INF/third-party-section-head-review.jsp")
                .forward(request, response);
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (SQLException e) {
            throw new ServletException("Unable to load third-party section-head review", e);
        }
    }

    static boolean isTechnicalPosition(String position) {
        return position != null && "Technical".equalsIgnoreCase(position.trim());
    }

    static void validateReviewerAssignments(int grantOperator, int revokeOperator, int reviewer) {
        if (reviewer == grantOperator || reviewer == revokeOperator) {
            throw new IllegalArgumentException("ผู้ตรวจทานต้องไม่ใช่ผู้ดำเนินการหรือผู้ยกเลิกสิทธิ์");
        }
    }

    private static boolean isTechnical(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null
            && ThirdPartyAccessPolicy.sessionEmpId(session) != null
            && isTechnicalPosition((String) session.getAttribute("position"));
    }

    private static String ensureCsrfToken(HttpServletRequest request) {
        HttpSession session = request.getSession(true);
        Object existing = session.getAttribute(CSRF_SESSION_KEY);
        if (existing instanceof String && !((String) existing).isEmpty()) {
            return (String) existing;
        }
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        session.setAttribute(CSRF_SESSION_KEY, token);
        return token;
    }

    private static boolean isValidCsrf(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object expected = session == null ? null : session.getAttribute(CSRF_SESSION_KEY);
        return expected instanceof String && expected.equals(request.getParameter("csrfToken"));
    }

    private static String requireComment(String value) {
        String comment = value == null ? "" : value.trim();
        if (comment.isEmpty()) {
            throw new IllegalArgumentException("กรุณากรอกความเห็นของหัวหน้าส่วน");
        }
        if (comment.length() > 4000) {
            throw new IllegalArgumentException("ความเห็นต้องไม่เกิน 4,000 ตัวอักษร");
        }
        return comment;
    }

    private static long parsePositiveLong(String value) {
        long parsed = Long.parseLong(value == null ? "" : value.trim());
        if (parsed <= 0) throw new IllegalArgumentException("Invalid request id.");
        return parsed;
    }

    private static int parsePositiveInt(String value) {
        int parsed = Integer.parseInt(value == null ? "" : value.trim());
        if (parsed <= 0) throw new IllegalArgumentException("กรุณาเลือกผู้รับผิดชอบให้ครบ");
        return parsed;
    }

    private static String firstNonBlank(String first, String second) {
        return first != null && !first.trim().isEmpty() ? first : second;
    }

    private static void disableCaching(HttpServletResponse response) {
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
    }
}
