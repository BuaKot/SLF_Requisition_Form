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

@WebServlet({"/emailNotifications", "/EmailNotificationSettings.jsp"})
public class EmailNotificationSettingsServlet extends HttpServlet {
    private final MemberDAO memberDAO = new MemberDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        setNoCacheHeaders(response);
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
            HttpSession session = request.getSession(false);
            request.setAttribute("message", consumeFlash(session, "emailNotificationMessage"));
            request.setAttribute("error", consumeFlash(session, "emailNotificationError"));
            RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/views/EmailNotificationSettings.jsp");
            dispatcher.forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to load email notification settings", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        setNoCacheHeaders(response);
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
        HttpSession session = request.getSession(true);
        if (message != null) {
            session.setAttribute("emailNotificationMessage", message);
        } else if (error != null) {
            session.setAttribute("emailNotificationError", error);
        }
        response.sendRedirect(request.getContextPath() + "/emailNotifications?status=" + (message != null ? "saved" : "error"));
    }

    private static String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    private static Object consumeFlash(HttpSession session, String name) {
        if (session == null) {
            return null;
        }
        Object value = session.getAttribute(name);
        session.removeAttribute(name);
        return value;
    }

    private static void setNoCacheHeaders(HttpServletResponse response) {
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
    }
}
