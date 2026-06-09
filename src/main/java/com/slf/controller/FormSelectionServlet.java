package com.slf.controller;

import com.slf.form.FormRegistry;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

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

        String position = (String) session.getAttribute("position");
        request.setAttribute("formTypes", FormRegistry.findVisibleFor(position));
        request.getRequestDispatcher("/form-selection.jsp").forward(request, response);
    }
}
