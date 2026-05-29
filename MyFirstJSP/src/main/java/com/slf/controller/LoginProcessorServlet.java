package com.slf.controller;

import com.slf.dao.LookupDAO;
import com.slf.model.Employee;
import com.slf.security.LoginAttemptService;
import com.slf.security.RustCaptchaClient;
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
    private final LoginAttemptService loginAttempts = LoginAttemptService.getInstance();
    private final RustCaptchaClient captchaClient = new RustCaptchaClient();

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String empIdStr = request.getParameter("EMPID");
        String passwordStr = request.getParameter("PASSWORD");
        String clientIp = clientIp(request);

        if (empIdStr == null || passwordStr == null || empIdStr.trim().isEmpty() || passwordStr.trim().isEmpty()) {
            loginAttempts.recordFailure(clientIp, empIdStr);
            redirectLogin(request, response, true);
            return;
        }

        if (!captchaClient.verify(request.getParameter("captchaToken"), request.getParameter("captchaAnswer"))) {
            loginAttempts.recordFailure(clientIp, empIdStr);
            redirectLogin(request, response, true);
            return;
        }

        if (loginAttempts.isBlocked(clientIp, empIdStr)) {
            redirectLogin(request, response, true);
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
                
                loginAttempts.recordSuccess(clientIp, empIdStr);
                response.sendRedirect(request.getContextPath() + "/index.jsp");
            } else {
                loginAttempts.recordFailure(clientIp, empIdStr);
                redirectLogin(request, response, true);
            }
        } catch (NumberFormatException e) {
            loginAttempts.recordFailure(clientIp, empIdStr);
            redirectLogin(request, response, true);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private static void redirectLogin(HttpServletRequest request, HttpServletResponse response,
                                      boolean error) throws IOException {
        StringBuilder target = new StringBuilder(request.getContextPath()).append("/login.jsp");
        if (error) {
            target.append("?error=1");
        }
        response.sendRedirect(target.toString());
    }

    private static String clientIp(HttpServletRequest request) {
        String forwardedFor = request.getHeader("X-Forwarded-For");
        if (forwardedFor != null && forwardedFor.trim().length() > 0) {
            return forwardedFor.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
