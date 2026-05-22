<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    //ดักจับพวกพิมพ์ URL เข้ามาตรงๆ
    String requestURI = request.getRequestURI();
    if (requestURI.endsWith("checkAuth.jsp")) {
        response.sendError(HttpServletResponse.SC_NOT_FOUND); // ส่ง Error 404 (หาหน้าเว็บไม่เจอ) แกล้งว่าไม่มีไฟล์นี้
        return;
    }

    //โค้ดตรวจสิทธิ์เดิมของคุณ
    String currentRole = (session.getAttribute("position") != null) ? (String)session.getAttribute("position") : "Guest";
    if (currentRole.equals("Guest") || (!currentRole.equalsIgnoreCase("Admin") && !currentRole.equalsIgnoreCase("Director"))) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }
%>