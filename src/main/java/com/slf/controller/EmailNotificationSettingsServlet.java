package com.slf.controller;

import com.slf.dao.MemberDAO;
import com.slf.model.MemberProfile;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/emailNotifications")
public class EmailNotificationSettingsServlet extends HttpServlet {
    private final MemberDAO memberDAO = new MemberDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Integer empId = getLoggedInEmpId(request);
        if (empId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            MemberProfile member = memberDAO.findMemberById(empId);
            if (member == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Member profile not found");
                return;
            }
            request.setAttribute("member", member);
            request.setAttribute("message", request.getParameter("message"));
            request.setAttribute("error", request.getParameter("error"));
            RequestDispatcher dispatcher = request.getRequestDispatcher("/EmailNotificationSettings.jsp");
            dispatcher.forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to load email notification settings", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Integer empId = getLoggedInEmpId(request);
        if (empId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String email = trimToEmpty(request.getParameter("email"));
        boolean enabled = "on".equalsIgnoreCase(request.getParameter("emailNotificationEnabled"));

        try {
            memberDAO.updateEmailNotificationSettings(empId, email, enabled);
            redirect(response, request, "บันทึกการตั้งค่าแจ้งเตือนเรียบร้อยแล้ว", null);
        } catch (SQLException e) {
            redirect(response, request, null, e.getMessage());
        }
    }

    private static Integer getLoggedInEmpId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        Object empObj = session.getAttribute("loggedInEmpId");
        if (empObj == null) {
            empObj = session.getAttribute("empid");
        }
        if (empObj == null) {
            return null;
        }
        return Integer.valueOf(empObj.toString());
    }

    private void redirect(HttpServletResponse response, HttpServletRequest request, String message, String error)
            throws IOException {
        StringBuilder url = new StringBuilder(request.getContextPath()).append("/emailNotifications");
        if (message != null) {
            url.append("?message=").append(java.net.URLEncoder.encode(message, "UTF-8"));
        } else if (error != null) {
            url.append("?error=").append(java.net.URLEncoder.encode(error, "UTF-8"));
        }
        response.sendRedirect(url.toString());
    }

    private static String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }
}
