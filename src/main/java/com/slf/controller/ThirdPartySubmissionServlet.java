package com.slf.controller;

import com.slf.dao.ThirdPartyFormSubmissionDAO;
import com.slf.model.ThirdPartyFormSubmission;
import com.slf.util.AuthUtil;
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
    private final ThirdPartyFormSubmissionDAO submissionDAO = new ThirdPartyFormSubmissionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request, response)) {
            return;
        }

        long submissionId;
        try {
            submissionId = parseSubmissionId(request.getParameter("id"));
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
            return;
        }

        try {
            ThirdPartyFormSubmission submission = submissionDAO.findById(submissionId);
            if (submission == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            request.setAttribute("submission", submission);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/ThirdPartySubmission.jsp");
            dispatcher.forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to load third-party submission", e);
        }
    }

    private static boolean isAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        String position = session == null ? null : (String) session.getAttribute("position");
        if (!AuthUtil.isAllowedForPage(position, "thirdPartySubmission")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return false;
        }
        return true;
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
}
