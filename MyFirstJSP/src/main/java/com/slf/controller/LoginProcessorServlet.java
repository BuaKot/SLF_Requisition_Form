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
        String empIdStr = request.getParameter("EMPID");
        String secIdStr = request.getParameter("SECID");

        if (empIdStr == null || secIdStr == null || empIdStr.trim().isEmpty() || secIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/login?error=1");
            return;
        }

        try {
            int empId = Integer.parseInt(empIdStr.trim());
            int secId = Integer.parseInt(secIdStr.trim());

            LookupDAO dao = new LookupDAO();
            Employee emp = dao.findEmployeeByEmpIdAndSecId(empId, secId);

            if (emp != null) {
                HttpSession session = request.getSession();
                // Standard session keys used by the filter and your other pages
                session.setAttribute("loggedInEmpId", emp.getEmpId());
                session.setAttribute("loggedInEmpName", emp.getEmpName());
                // Backwards compatibility for pages that check "empid" or "emp_id"
                session.setAttribute("empid", emp.getEmpId());
                response.sendRedirect(request.getContextPath() + "/");
            } else {
                response.sendRedirect(request.getContextPath() + "/login?error=1");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/login?error=1");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}