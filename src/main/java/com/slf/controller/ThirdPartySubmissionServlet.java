package com.slf.controller;

import com.slf.dao.ThirdPartyAcceptanceDAO;
import com.slf.dao.ThirdPartyFormSubmissionDAO;
import com.slf.dao.ThirdPartyWorkflowDAO;
import com.slf.model.ThirdPartyFormSubmission;
import com.slf.model.ThirdPartyWorkflowActionEntry;
import com.slf.util.ThirdPartyAccessPolicy;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/thirdPartySubmission")
public class ThirdPartySubmissionServlet extends HttpServlet {
    private final ThirdPartyAcceptanceDAO acceptanceDAO = new ThirdPartyAcceptanceDAO();
    private final ThirdPartyFormSubmissionDAO submissionDAO = new ThirdPartyFormSubmissionDAO();
    private final ThirdPartyWorkflowDAO workflowDAO = new ThirdPartyWorkflowDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        long submissionId;
        try {
            submissionId = parseSubmissionId(request.getParameter("id"));
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
            return;
        }

        try {
            ThirdPartyFormSubmission submission = submissionDAO.findDetailById(submissionId);
            if (submission == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            HttpSession session = request.getSession(false);
            String position = session == null ? null : (String) session.getAttribute("position");
            Integer empId = ThirdPartyAccessPolicy.sessionEmpId(session);
            if (!ThirdPartyAccessPolicy.canViewSubmission(position, empId, submission.getInternalOwnerEmpId())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            request.setAttribute("thirdPartySubmissionAuthorized", Boolean.TRUE);
            request.setAttribute("submission", submission);
            java.util.List<ThirdPartyWorkflowActionEntry> approvalHistory =
                submission.getRequestId() == null
                    ? java.util.Collections.emptyList()
                    : workflowDAO.findActionHistory(submission.getRequestId().longValue());
            request.setAttribute("approvalHistory", approvalHistory);
            request.setAttribute("acceptanceScore",
                submission.getRequestId() != null && hasExternalAcceptance(approvalHistory)
                    ? acceptanceDAO.findSatisfactionLevelByRequestId(submission.getRequestId().longValue())
                    : null);
            boolean viewingOwnSubmission = ThirdPartyAccessPolicy.canCreateOwnLinks(empId)
                && empId.equals(submission.getInternalOwnerEmpId());
            request.setAttribute("thirdPartySubmissionBackUrl",
                request.getContextPath() + (viewingOwnSubmission
                    ? "/thirdParty/request/new"
                    : "/thirdPartyLinks"));
            RequestDispatcher dispatcher = request.getRequestDispatcher("/ThirdPartySubmission.jsp");
            dispatcher.forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to load third-party submission", e);
        }
    }

    static long parseSubmissionId(String value) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException("Missing submission id.");
        }
        long id = Long.parseLong(value.trim());
        if (id <= 0) {
            throw new IllegalArgumentException("Invalid submission id.");
        }
        return id;
    }

    private static boolean hasExternalAcceptance(
            java.util.List<ThirdPartyWorkflowActionEntry> approvalHistory) {
        for (ThirdPartyWorkflowActionEntry action : approvalHistory) {
            if ("EXTERNAL_ACCEPTED".equals(action.getActionType())) return true;
        }
        return false;
    }
}
