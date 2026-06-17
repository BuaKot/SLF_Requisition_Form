package com.slf.controller;

import com.slf.util.ThirdPartyAccessPolicy;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet({"/newForm", "/formSelection"})
public class FormSelectionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInEmpId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.setAttribute("canCreateThirdPartyLinks",
            Boolean.valueOf(ThirdPartyAccessPolicy.canCreateOwnLinks(
                ThirdPartyAccessPolicy.sessionEmpId(session))));
        request.getRequestDispatcher("/WEB-INF/views/FormSelection.jsp").forward(request, response);
    }
}
