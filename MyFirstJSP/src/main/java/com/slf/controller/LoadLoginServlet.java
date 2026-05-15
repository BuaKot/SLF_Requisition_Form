package com.slf.controller;

import com.slf.dao.LookupDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/login")
public class LoadLoginServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        LookupDAO dao = new LookupDAO();
        try {
            request.setAttribute("employees", dao.getAllEmployees());
        } catch (SQLException e) {
            throw new ServletException("Cannot load employee list", e);
        }
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }
}