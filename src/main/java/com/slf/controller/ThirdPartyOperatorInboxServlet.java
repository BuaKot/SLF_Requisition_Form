package com.slf.controller;

import com.slf.dao.ThirdPartyRequestDAO;
import com.slf.util.ThirdPartyAccessPolicy;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/thirdParty/operator")
public class ThirdPartyOperatorInboxServlet extends HttpServlet {
    private final ThirdPartyRequestDAO requestDAO = new ThirdPartyRequestDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        disableCaching(response);
        if (!isInfrastructure(request.getSession(false))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        try {
            int empId = ThirdPartyAccessPolicy.sessionEmpId(request.getSession(false)).intValue();
            request.setAttribute("grantOperatorRequests",
                requestDAO.findAssignedByStatus("PENDING_OPERATOR", "GRANT_OPERATOR", empId, 100));
            request.setAttribute("revokeOperatorRequests",
                requestDAO.findAssignedByStatus("PENDING_REVOKER", "REVOKE_OPERATOR", empId, 100));
            request.setAttribute("revokeReviewerRequests",
                requestDAO.findAssignedByStatus("PENDING_REVOKE_REVIEWER", "REVOKE_REVIEWER", empId, 100));
            request.getRequestDispatcher("/WEB-INF/third-party-operator-inbox.jsp")
                .forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to load third-party operator inbox", e);
        }
    }

    static boolean isInfrastructure(HttpSession session) {
        return session != null && isInfrastructurePosition((String) session.getAttribute("position"))
            && ThirdPartyAccessPolicy.sessionEmpId(session) != null;
    }

    static boolean isInfrastructurePosition(String position) {
        return position != null && "Infrastructure".equalsIgnoreCase(position.trim());
    }

    static void disableCaching(HttpServletResponse response) {
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
    }
}
