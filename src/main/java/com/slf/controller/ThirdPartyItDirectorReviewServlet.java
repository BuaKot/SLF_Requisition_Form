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

@WebServlet("/thirdParty/itDirector/review")
public class ThirdPartyItDirectorReviewServlet extends HttpServlet {
    private static final String CSRF_SESSION_KEY = "thirdPartyItDirectorReviewCsrfToken";
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
        if (!ThirdPartyItDirectorInboxServlet.isItDirector(request.getSession(false))) {
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
            String decision = request.getParameter("decision");
            if (!"approve".equals(decision) && !"reject".equals(decision)) {
                throw new IllegalArgumentException("กรุณาเลือกอนุมัติหรือไม่อนุมัติ");
            }
            int actorEmpId = ThirdPartyAccessPolicy.sessionEmpId(request.getSession(false)).intValue();
            boolean submitted = workflowDAO.submitItDirectorDecision(
                requestId, actorEmpId, comment, "approve".equals(decision));
            if (!submitted) {
                response.sendError(HttpServletResponse.SC_CONFLICT,
                    "คำขอนี้ไม่ได้อยู่ในขั้นตอนรอ IT Director พิจารณาแล้ว");
                return;
            }
            notificationService.notifyItDirectorDecision(requestId, actorEmpId, "approve".equals(decision), comment);
            response.sendRedirect(request.getContextPath() + "/thirdParty/itDirector");
        } catch (IllegalArgumentException e) {
            request.setAttribute("formError", e.getMessage());
            loadAndForward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to submit third-party IT Director decision", e);
        }
    }

    private void loadAndForward(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ThirdPartyItDirectorInboxServlet.disableCaching(response);
        if (!ThirdPartyItDirectorInboxServlet.isItDirector(request.getSession(false))) {
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
            if (!"PENDING_IT_DIRECTOR".equals(thirdPartyRequest.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/thirdParty/itDirector");
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
            request.setAttribute("sectionHeadComment",
                workflowDAO.findLatestActionComment(requestId, "SECTION_HEAD_SUBMITTED"));
            request.setAttribute("csrfToken", ensureCsrfToken(request));
            request.getRequestDispatcher("/WEB-INF/views/ThirdPartyItDirectorReview.jsp")
                .forward(request, response);
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (SQLException e) {
            throw new ServletException("Unable to load third-party IT Director review", e);
        }
    }

    static String requireComment(String value) {
        String comment = value == null ? "" : value.trim();
        if (comment.isEmpty()) throw new IllegalArgumentException("กรุณากรอกความเห็นของ IT Director");
        if (comment.length() > 4000) throw new IllegalArgumentException("ความเห็นต้องไม่เกิน 4,000 ตัวอักษร");
        return comment;
    }

    private static String ensureCsrfToken(HttpServletRequest request) {
        HttpSession session = request.getSession(true);
        Object existing = session.getAttribute(CSRF_SESSION_KEY);
        if (existing instanceof String && !((String) existing).isEmpty()) return (String) existing;
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

    private static long parsePositiveLong(String value) {
        long parsed = Long.parseLong(value == null ? "" : value.trim());
        if (parsed <= 0) throw new IllegalArgumentException("Invalid request id.");
        return parsed;
    }

    private static String firstNonBlank(String first, String second) {
        return first != null && !first.trim().isEmpty() ? first : second;
    }
}
