package com.slf.controller;

import com.slf.dao.ThirdPartyRequestDAO;
import com.slf.model.ThirdPartyRequest;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/thirdParty/request/link")
public class ThirdPartyRequestLinkServlet extends HttpServlet {
    private final ThirdPartyRequestDAO requestDAO = new ThirdPartyRequestDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        loadAndForward(request, response);
    }

    private void loadAndForward(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ThirdPartyRequest thirdPartyRequest = loadRequest(request, response);
        if (thirdPartyRequest == null) {
            return;
        }
        request.setAttribute("thirdPartyRequest", thirdPartyRequest);
        request.setAttribute("publicLink", publicLinkForRequest(request, thirdPartyRequest));
        RequestDispatcher dispatcher = request.getRequestDispatcher("/third-party-request-link.jsp");
        dispatcher.forward(request, response);
    }

    private ThirdPartyRequest loadRequest(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        Integer ownerEmpId = loggedInEmpId(request);
        if (ownerEmpId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        try {
            long requestId = parseLong(request.getParameter("requestId"));
            ThirdPartyRequest thirdPartyRequest = requestDAO.findByIdForOwner(requestId, ownerEmpId.intValue());
            if (thirdPartyRequest == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return null;
            }
            return thirdPartyRequest;
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return null;
        } catch (SQLException e) {
            throw new ServletException("Unable to load third-party request", e);
        }
    }

    private static String publicLinkForRequest(HttpServletRequest request, ThirdPartyRequest thirdPartyRequest) {
        Object remembered = request.getSession(true).getAttribute("thirdPartyGeneratedLink_" + thirdPartyRequest.getRequestId());
        if (remembered instanceof String) {
            return (String) remembered;
        }
        if (!"ACTIVE".equals(thirdPartyRequest.getLinkStatus()) || thirdPartyRequest.getRawToken() == null) {
            return null;
        }
        return ThirdPartyLinksServlet.buildPublicLink(request, thirdPartyRequest.getRawToken());
    }

    private static long parseLong(String value) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException("Missing id.");
        }
        long id = Long.parseLong(value.trim());
        if (id <= 0) {
            throw new IllegalArgumentException("Invalid id.");
        }
        return id;
    }

    private static Integer loggedInEmpId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object value = session == null ? null : session.getAttribute("loggedInEmpId");
        if (value == null && session != null) {
            value = session.getAttribute("empid");
        }
        return value == null ? null : Integer.valueOf(value.toString());
    }
}
