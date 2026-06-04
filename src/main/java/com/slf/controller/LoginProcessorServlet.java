package com.slf.controller;

import com.slf.dao.LookupDAO;
import com.slf.model.Employee;
import com.slf.security.JavaCaptchaService;
import com.slf.security.LoginAttemptService;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

public class LoginProcessorServlet extends HttpServlet {
    private final LoginAttemptService attemptService = LoginAttemptService.getInstance();

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String empIdStr = request.getParameter("EMPID");
        String passwordStr = request.getParameter("PASSWORD");
        String clientIp = getClientIp(request);
        String empIdKey = empIdStr == null ? "" : empIdStr.trim();

        if (empIdStr == null || passwordStr == null || empIdStr.trim().isEmpty() || passwordStr.trim().isEmpty()) {
            attemptService.recordFailure(clientIp, empIdKey);
            redirectToLogin(request, response, attemptService.isCaptchaRequired(clientIp, empIdKey));
            return;
        }

        try {
            int empId = Integer.parseInt(empIdStr.trim());
            String password = passwordStr.trim();

            int remainingDelaySeconds = attemptService.getRemainingDelaySeconds(clientIp, empIdKey);
            if (remainingDelaySeconds > 0) {
                redirectToLogin(request, response, true, remainingDelaySeconds);
                return;
            }

            if (attemptService.isCaptchaRequired(clientIp, empIdKey)
                    && !JavaCaptchaService.verify(
                        request,
                        request.getParameter("captchaToken"),
                        request.getParameter("captchaAnswer"))) {
                attemptService.recordFailure(clientIp, empIdKey);
                redirectToLogin(request, response, true, attemptService.getRemainingDelaySeconds(clientIp, empIdKey));
                return;
            }

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
                attemptService.recordSuccess(clientIp, empIdKey);
                
                response.sendRedirect(request.getContextPath() + "/index.jsp");
            } else {
                attemptService.recordFailure(clientIp, empIdKey);
                redirectToLogin(
                    request,
                    response,
                    attemptService.isCaptchaRequired(clientIp, empIdKey),
                    attemptService.getRemainingDelaySeconds(clientIp, empIdKey)
                );
            }
        } catch (NumberFormatException e) {
            attemptService.recordFailure(clientIp, empIdKey);
            redirectToLogin(
                request,
                response,
                attemptService.isCaptchaRequired(clientIp, empIdKey),
                attemptService.getRemainingDelaySeconds(clientIp, empIdKey)
            );
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private void redirectToLogin(HttpServletRequest request, HttpServletResponse response, boolean captchaRequired)
            throws IOException {
        redirectToLogin(request, response, captchaRequired, 0);
    }

    private void redirectToLogin(
            HttpServletRequest request,
            HttpServletResponse response,
            boolean captchaRequired,
            int waitSeconds) throws IOException {
        if (captchaRequired) {
            request.getSession(true).setAttribute("captchaRequired", Boolean.TRUE);
        }
        if (waitSeconds > 0) {
            long expiry = System.currentTimeMillis() + (waitSeconds * 1000L);
            request.getSession(true).setAttribute("loginWaitSeconds", waitSeconds);
            request.getSession(true).setAttribute("loginWaitExpiry", expiry);
        } else {
            request.getSession(true).removeAttribute("loginWaitSeconds");
            request.getSession(true).removeAttribute("loginWaitExpiry");
        }

        String redirect = request.getContextPath() + "/login?error=1";
        if (captchaRequired) {
            redirect += "&captchaRequired=1";
        }
        // ⚠️ Do NOT add waitSeconds to the URL
        response.sendRedirect(redirect);
    }

    private String getClientIp(HttpServletRequest request) {
        String forwardedFor = request.getHeader("X-Forwarded-For");
        if (forwardedFor != null && forwardedFor.trim().length() > 0) {
            return forwardedFor.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}