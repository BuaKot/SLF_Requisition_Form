package com.slf.controller;

import com.slf.dao.LookupDAO;
import com.slf.model.Employee;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/processLogin")
public class LoginProcessorServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String empIdStr = request.getParameter("empId");
        if (empIdStr == null || empIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        int empId = Integer.parseInt(empIdStr.trim());
        LookupDAO dao = new LookupDAO();
        try {
            Employee emp = dao.findEmployeeById(empId); // we need this method
            if (emp != null) {
                HttpSession session = request.getSession();
                session.setAttribute("loggedInEmpId", emp.getEmpId());
                session.setAttribute("loggedInEmpName", emp.getEmpName());
                // Redirect to the main page (the dashboard or new form)
                response.sendRedirect(request.getContextPath());
            } else {
                // Employee not found, redirect back to login
                response.sendRedirect(request.getContextPath() + "/login?error=1");
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}