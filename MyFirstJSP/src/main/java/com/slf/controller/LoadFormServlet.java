package com.slf.controller;

import com.slf.dao.LookupDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
// import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/newForm")
public class LoadFormServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Check login — we'll do a basic session check
        //HttpSession session = request.getSession();
        //if (session.getAttribute("loggedInRequestorId") == null) {
        //    response.sendRedirect(request.getContextPath() + "/login.jsp");
        //    return;
        //}

        // 2. Fetch lookup data
        LookupDAO dao = new LookupDAO();
        try {
            request.setAttribute("requestTypes", dao.getAllRequestTypes());
            request.setAttribute("departments", dao.getAllDepartments());
            request.setAttribute("allSections", dao.getAllSections());
        } catch (SQLException e) {
            throw new ServletException("Cannot load form lookups", e);
        }

        // 3. Forward to the JSP
        request.getRequestDispatcher("/form.jsp").forward(request, response);
    }
}