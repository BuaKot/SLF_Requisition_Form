package com.slf.controller;

import com.slf.util.ThirdPartyAccessPolicy;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/forms/select")
public class FormTypeSelectionServlet extends HttpServlet {
    private static final String IT_REQUISITION = "IT_REQUISITION_REQUEST";
    private static final String THIRD_PARTY = "THIRD_PARTY_USER_REGISTRATION";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInEmpId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String code = trimToEmpty(request.getParameter("code"));
        if (IT_REQUISITION.equals(code)) {
            response.sendRedirect(request.getContextPath() + "/itRequisition/new");
            return;
        }
        if (THIRD_PARTY.equals(code)
                && ThirdPartyAccessPolicy.canCreateOwnLinks(ThirdPartyAccessPolicy.sessionEmpId(session))) {
            response.sendRedirect(request.getContextPath() + "/thirdParty/request/new");
            return;
        }
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    private static String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }
}
