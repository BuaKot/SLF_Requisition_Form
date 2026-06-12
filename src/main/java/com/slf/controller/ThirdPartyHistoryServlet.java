package com.slf.controller;

import com.slf.dao.ThirdPartyRequestDAO;
import com.slf.model.ThirdPartyRequest;
import com.slf.util.AuthUtil;
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

@WebServlet("/thirdParty/history")
public class ThirdPartyHistoryServlet extends HttpServlet {
    private static final int LIST_LIMIT = 500;
    private final ThirdPartyRequestDAO requestDAO = new ThirdPartyRequestDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String position = session == null ? null : (String) session.getAttribute("position");
        Integer empId = ThirdPartyAccessPolicy.sessionEmpId(session);
        if (!ThirdPartyAccessPolicy.canViewHistory(position, empId)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        boolean adminView = AuthUtil.isAllowedForPage(position, "thirdPartyHistory");
        try {
            List<ThirdPartyRequest> requests =
                requestDAO.findHistory(adminView ? null : empId, LIST_LIMIT);
            request.setAttribute("thirdPartyRequests", requests);
            request.setAttribute("thirdPartyHistoryAdminView", Boolean.valueOf(adminView));
            request.getRequestDispatcher("/third-party-history.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to load third-party history", e);
        }
    }
}
