package com.slf.controller;

import com.slf.dao.ThirdPartyRequestDAO;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/thirdParty/sectionHead")
public class ThirdPartySectionHeadInboxServlet extends HttpServlet {
    private final ThirdPartyRequestDAO requestDAO = new ThirdPartyRequestDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
        if (!isTechnical(request.getSession(false))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            request.setAttribute("reviewRequests",
                requestDAO.findByStatus("PENDING_SECTION_HEAD", 100));
            request.setAttribute("reportRequests",
                requestDAO.findByStatus("PENDING_SECTION_HEAD_REPORT", 100));
            request.getRequestDispatcher("/WEB-INF/third-party-section-head-inbox.jsp")
                .forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to load third-party section-head inbox", e);
        }
    }

    static boolean isTechnical(HttpSession session) {
        return session != null && ThirdPartySectionHeadReviewServlet.isTechnicalPosition(
            (String) session.getAttribute("position"));
    }
}
