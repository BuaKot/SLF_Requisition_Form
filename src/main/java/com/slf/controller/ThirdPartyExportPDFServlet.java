package com.slf.controller;

import com.slf.dao.ThirdPartyAcceptanceDAO;
import com.slf.dao.ThirdPartyFormSubmissionDAO;
import com.slf.dao.ThirdPartyRequestDAO;
import com.slf.dao.ThirdPartyWorkflowDAO;
import com.slf.model.ThirdPartyFormSubmission;
import com.slf.model.ThirdPartyRequest;
import com.slf.model.ThirdPartyWorkflowActionEntry;
import com.slf.util.ThirdPartyAccessPolicy;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/thirdParty/exportPdf")
public class ThirdPartyExportPDFServlet extends HttpServlet {
    private final ThirdPartyAcceptanceDAO acceptanceDAO = new ThirdPartyAcceptanceDAO();
    private final ThirdPartyFormSubmissionDAO submissionDAO = new ThirdPartyFormSubmissionDAO();
    private final ThirdPartyRequestDAO requestDAO = new ThirdPartyRequestDAO();
    private final ThirdPartyWorkflowDAO workflowDAO = new ThirdPartyWorkflowDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        long submissionId;
        try {
            submissionId = parseSubmissionId(request.getParameter("submissionId"));
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
            return;
        }

        HttpSession session = request.getSession(false);
        Integer empId = ThirdPartyAccessPolicy.sessionEmpId(session);
        String position = session == null ? null : (String) session.getAttribute("position");
        if (empId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            ThirdPartyFormSubmission submission = submissionDAO.findById(submissionId);
            if (submission == null || submission.getRequestId() == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            if (!ThirdPartyAccessPolicy.canViewSubmission(position, empId, submission.getInternalOwnerEmpId())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            ThirdPartyRequest thirdPartyRequest = requestDAO.findById(submission.getRequestId().longValue());
            List<ThirdPartyWorkflowActionEntry> workflow =
                workflowDAO.findActionHistory(submission.getRequestId().longValue());
            if (thirdPartyRequest == null || (!"COMPLETED".equals(thirdPartyRequest.getStatus())
                    && !hasFinalCertification(workflow))) {
                response.sendError(HttpServletResponse.SC_CONFLICT, "PDF export is available after completion only.");
                return;
            }

            Integer acceptanceScore = hasExternalAcceptance(workflow)
                ? acceptanceDAO.findSatisfactionLevelByRequestId(submission.getRequestId().longValue())
                : null;
            request.setAttribute("submission", submission);
            request.setAttribute("thirdPartyRequest", thirdPartyRequest);
            request.setAttribute("approvalHistory", workflow);
            request.setAttribute("acceptanceScore", acceptanceScore);
            request.getRequestDispatcher("/third-party-pdf.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to export third-party submission PDF", e);
        }
    }

    static long parseSubmissionId(String value) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException("Missing submissionId.");
        }
        long id = Long.parseLong(value.trim());
        if (id <= 0) {
            throw new IllegalArgumentException("Invalid submissionId.");
        }
        return id;
    }

    private static boolean hasFinalCertification(List<ThirdPartyWorkflowActionEntry> workflow) {
        for (ThirdPartyWorkflowActionEntry action : workflow) {
            if ("FINAL_CERTIFIED".equals(action.getActionType())) return true;
        }
        return false;
    }

    private static boolean hasExternalAcceptance(List<ThirdPartyWorkflowActionEntry> workflow) {
        for (ThirdPartyWorkflowActionEntry action : workflow) {
            if ("EXTERNAL_ACCEPTED".equals(action.getActionType())) return true;
        }
        return false;
    }
}
