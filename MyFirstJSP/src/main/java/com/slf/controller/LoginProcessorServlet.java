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
        String passwordStr = request.getParameter("PASSWORD");

        if (empIdStr == null || passwordStr == null || empIdStr.trim().isEmpty() || passwordStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=1");
            return;
        }

        try {
            int empId = Integer.parseInt(empIdStr.trim());
            String password = passwordStr.trim();

            LookupDAO dao = new LookupDAO();
            Employee emp = dao.findEmployeeByEmpIdAndPassword(empId, password);

            if (emp != null) {
                HttpSession session = request.getSession(false);
                if (session != null) {
                    session.invalidate();
                }
                HttpSession newSession = request.getSession(true);
                
                newSession.setAttribute("loggedInEmpId", emp.getEmpId());
                newSession.setAttribute("loggedInEmpName", emp.getEmpName());
                newSession.setAttribute("empName", emp.getEmpName());
                newSession.setAttribute("position", emp.getPosition());
                newSession.setAttribute("empid", emp.getEmpId());
                
                response.sendRedirect(request.getContextPath() + "/index.jsp");
            } else {
                response.sendRedirect(request.getContextPath() + "/login.jsp?error=1");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=1");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
