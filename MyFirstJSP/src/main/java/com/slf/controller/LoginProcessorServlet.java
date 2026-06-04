package com.slf.controller;

import com.slf.dao.LookupDAO;
import com.slf.model.Employee;
import com.slf.security.JavaCaptchaService;
import com.slf.security.LoginAttemptService;
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

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String empIdStr = request.getParameter("EMPID");
        String passwordStr = request.getParameter("PASSWORD");
        String clientIp = clientIp(request);

        int waitSeconds = loginAttempts.getRemainingDelaySeconds(clientIp, empIdStr);
        if (waitSeconds > 0) {
            redirectLogin(request, response, true, loginAttempts.isCaptchaRequired(clientIp, empIdStr), waitSeconds);
            return;
        }

        if (empIdStr == null || passwordStr == null || empIdStr.trim().isEmpty() || passwordStr.trim().isEmpty()) {
            loginAttempts.recordFailure(clientIp, empIdStr);
            waitSeconds = applyDelayIfNeeded(clientIp, empIdStr);
            redirectLogin(request, response, true, loginAttempts.isCaptchaRequired(clientIp, empIdStr), waitSeconds);
            return;
        }

        boolean captchaRequired = loginAttempts.isCaptchaRequired(clientIp, empIdStr);
        if (captchaRequired) {
            String captchaToken = request.getParameter("captchaToken");
            String captchaAnswer = request.getParameter("captchaAnswer");
            if (!JavaCaptchaService.verify(request, captchaToken, captchaAnswer)) {
                loginAttempts.recordFailure(clientIp, empIdStr);
                waitSeconds = applyDelayIfNeeded(clientIp, empIdStr);
                redirectLogin(request, response, true, true, waitSeconds);
                return;
            }
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
                waitSeconds = applyDelayIfNeeded(clientIp, empIdStr);
                redirectLogin(request, response, true, loginAttempts.isCaptchaRequired(clientIp, empIdStr), waitSeconds);
            }
        } catch (NumberFormatException e) {
            loginAttempts.recordFailure(clientIp, empIdStr);
            waitSeconds = applyDelayIfNeeded(clientIp, empIdStr);
            redirectLogin(request, response, true, loginAttempts.isCaptchaRequired(clientIp, empIdStr), waitSeconds);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private static void redirectLogin(HttpServletRequest request, HttpServletResponse response,
                                      boolean error, boolean captchaRequired, int waitSeconds) throws IOException {
        StringBuilder target = new StringBuilder(request.getContextPath()).append("/login.jsp");
        if (error || captchaRequired || waitSeconds > 0) {
            target.append("?");
            if (error) {
                target.append("error=1");
            }
            if (captchaRequired) {
                if (error) {
                    target.append("&");
                }
                target.append("captchaRequired=1");
            }
            if (waitSeconds > 0) {
                if (error || captchaRequired) {
                    target.append("&");
                }
                target.append("wait=").append(waitSeconds);
            }
        }
        response.sendRedirect(target.toString());
    }

    private static int applyDelayIfNeeded(String clientIp, String empId) {
        return LoginAttemptService.getInstance().getRemainingDelaySeconds(clientIp, empId);
    }

    private static String clientIp(HttpServletRequest request) {
        String forwardedFor = request.getHeader("X-Forwarded-For");
        if (forwardedFor != null && forwardedFor.trim().length() > 0) {
            return forwardedFor.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
