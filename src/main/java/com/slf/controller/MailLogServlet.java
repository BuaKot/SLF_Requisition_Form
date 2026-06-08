package com.slf.controller;

import com.slf.notification.EmailNotificationLogDAO;
import com.slf.util.AuthUtil;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/mailLog")
public class MailLogServlet extends HttpServlet {
    private static final int PAGE_SIZE = 50;
    private final EmailNotificationLogDAO logDAO = new EmailNotificationLogDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String position = session == null ? null : (String) session.getAttribute("position");
        if (!AuthUtil.isAllowedForPage(position, "mailLog")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String status = normalizeStatus(request.getParameter("status"));
        int page = parsePage(request.getParameter("page"));
        try {
            request.setAttribute("logs", logDAO.findLogs(status, page, PAGE_SIZE));
            request.setAttribute("statusCounts", logDAO.countByStatus());
            request.setAttribute("selectedStatus", status == null ? "" : status);
            request.setAttribute("currentPage", Integer.valueOf(page));
            request.setAttribute("pageSize", Integer.valueOf(PAGE_SIZE));
            request.setAttribute("totalRows", Integer.valueOf(logDAO.countLogs(status)));
            RequestDispatcher dispatcher = request.getRequestDispatcher("/MailLog.jsp");
            dispatcher.forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to load email notification log", e);
        }
    }

    static String normalizeStatus(String value) {
        if (value == null || value.trim().isEmpty() || "ALL".equalsIgnoreCase(value.trim())) {
            return null;
        }
        String normalized = value.trim().toUpperCase();
        if ("PENDING".equals(normalized) || "SENDING".equals(normalized) || "SENT".equals(normalized)
                || "FAILED".equals(normalized) || "SKIPPED".equals(normalized)) {
            return normalized;
        }
        return null;
    }

    static int parsePage(String value) {
        try {
            return Math.max(1, Integer.parseInt(value));
        } catch (Exception e) {
            return 1;
        }
    }
}
