package com.slf.controller;

import com.slf.form.FormRegistry;
import com.slf.model.FormType;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/forms/select")
public class FormTypeSelectionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInEmpId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String position = (String) session.getAttribute("position");
        FormType formType = FormRegistry.findByCode(request.getParameter("code"));
        if (formType == null || !formType.isVisibleFor(position)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        if (!formType.isEnabled()) {
            request.setAttribute("formType", formType);
            request.getRequestDispatcher("/form-placeholder.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + formType.getTargetUrl());
    }
}
