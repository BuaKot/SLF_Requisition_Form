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

@WebServlet("/thirdParty/itDirector")
public class ThirdPartyItDirectorInboxServlet extends HttpServlet {
    private final ThirdPartyRequestDAO requestDAO = new ThirdPartyRequestDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        disableCaching(response);
        if (!isItDirector(request.getSession(false))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        try {
            request.setAttribute("approvalRequests",
                requestDAO.findByStatus("PENDING_IT_DIRECTOR", 100));
            request.setAttribute("certificationRequests",
                requestDAO.findByStatus("PENDING_FINAL_CERTIFICATION", 100));
            request.getRequestDispatcher("/WEB-INF/third-party-it-director-inbox.jsp")
                .forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to load third-party IT Director inbox", e);
        }
    }

    static boolean isItDirector(HttpSession session) {
        return session != null && isItDirectorPosition((String) session.getAttribute("position"));
    }

    static boolean isItDirectorPosition(String position) {
        return position != null && "ITDIRECTOR".equalsIgnoreCase(
            position.trim().replace(" ", ""));
    }

    static void disableCaching(HttpServletResponse response) {
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
    }
}
