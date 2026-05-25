<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String requestURI = request.getRequestURI();
    if (requestURI.endsWith("checkAuth.jsp")) {
        response.sendError(HttpServletResponse.SC_NOT_FOUND); // ส่ง Error 404 
        return;
    }

    String currentRole = (session.getAttribute("position") != null) ? (String)session.getAttribute("position") : "Guest";
    if (currentRole.equals("Guest") || (!currentRole.equalsIgnoreCase("Admin") && !currentRole.equalsIgnoreCase("Director"))) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }
%>