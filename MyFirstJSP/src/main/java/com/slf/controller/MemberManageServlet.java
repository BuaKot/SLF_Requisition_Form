package com.slf.controller;

import com.slf.dao.MemberDAO;
import com.slf.model.MemberProfile;
import com.slf.model.Section;
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
import java.util.List;

@WebServlet("/memberManage")
public class MemberManageServlet extends HttpServlet {
    private final MemberDAO memberDAO = new MemberDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request, response)) {
            return;
        }

        String sectionId = trimToNull(request.getParameter("sectionId"));
        String position = trimToNull(request.getParameter("position"));
        String status = trimToNull(request.getParameter("status"));
        if (status == null) {
            status = "active";
        }

        try {
            List<MemberProfile> members = memberDAO.findMembers(sectionId, position, status);
            List<Section> sections = memberDAO.getSections();
            List<String> positions = memberDAO.getPositions();

            request.setAttribute("members", members);
            request.setAttribute("sections", sections);
            request.setAttribute("positions", positions);
            request.setAttribute("selectedSectionId", sectionId == null ? "" : sectionId);
            request.setAttribute("selectedPosition", position == null ? "" : position);
            request.setAttribute("selectedStatus", status);
            request.setAttribute("message", request.getParameter("message"));
            request.setAttribute("error", request.getParameter("error"));

            RequestDispatcher dispatcher = request.getRequestDispatcher("/MemberManage.jsp");
            dispatcher.forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "ไม่สามารถโหลดข้อมูลสมาชิกได้: " + e.getMessage());
            RequestDispatcher dispatcher = request.getRequestDispatcher("/MemberManage.jsp");
            dispatcher.forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request, response)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = trimToNull(request.getParameter("action"));

        try {
            if ("add".equals(action)) {
                memberDAO.addMember(
                    parseInt(request.getParameter("empId"), "รหัสพนักงาน"),
                    trimToEmpty(request.getParameter("empName")),
                    trimToEmpty(request.getParameter("position")),
                    parseInt(request.getParameter("secId"), "ส่วนงาน"),
                    trimToEmpty(request.getParameter("phone")),
                    trimToEmpty(request.getParameter("password")),
                    "active".equalsIgnoreCase(request.getParameter("status"))
                );
                redirect(response, request, "เพิ่มสมาชิกเรียบร้อยแล้ว", null);
                return;
            }

            if ("update".equals(action)) {
                memberDAO.updateMember(
                    parseInt(request.getParameter("empId"), "รหัสพนักงาน"),
                    trimToEmpty(request.getParameter("empName")),
                    trimToEmpty(request.getParameter("position")),
                    parseInt(request.getParameter("secId"), "ส่วนงาน"),
                    trimToEmpty(request.getParameter("phone")),
                    trimToEmpty(request.getParameter("password")),
                    "active".equalsIgnoreCase(request.getParameter("status"))
                );
                redirect(response, request, "บันทึกข้อมูลสมาชิกเรียบร้อยแล้ว", null);
                return;
            }

            if ("disable".equals(action) || "enable".equals(action)) {
                int empId = parseInt(request.getParameter("empId"), "รหัสพนักงาน");
                boolean active = "enable".equals(action);
                memberDAO.setActive(empId, active);
                redirect(response, request, active ? "เปิดใช้งานสมาชิกแล้ว" : "ปิดใช้งานสมาชิกแล้ว", null);
                return;
            }

            redirect(response, request, null, "ไม่พบคำสั่งที่ต้องการทำรายการ");
        } catch (SQLException e) {
            redirect(response, request, null, e.getMessage());
        } catch (IllegalArgumentException e) {
            redirect(response, request, null, e.getMessage());
        }
    }

    private boolean isAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        String position = session == null ? null : (String) session.getAttribute("position");
        if (!AuthUtil.isAllowedForPage(position, "memberManage")) {
            if (session != null) {
                session.setAttribute("accessDeniedMessage", "คุณไม่มีสิทธิ์เข้าถึงหน้าจัดการสมาชิก");
            }
            response.sendRedirect(request.getContextPath() + "/");
            return false;
        }
        return true;
    }

    private void redirect(HttpServletResponse response, HttpServletRequest request, String message, String error)
            throws IOException {
        StringBuilder url = new StringBuilder(request.getContextPath()).append("/memberManage");
        if (message != null) {
            url.append("?message=").append(java.net.URLEncoder.encode(message, "UTF-8"));
        } else if (error != null) {
            url.append("?error=").append(java.net.URLEncoder.encode(error, "UTF-8"));
        }
        response.sendRedirect(url.toString());
    }

    private static int parseInt(String value, String label) {
        try {
            return Integer.parseInt(trimToEmpty(value));
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(label + "ไม่ถูกต้อง");
        }
    }

    private static String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private static String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }
}
