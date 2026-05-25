<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.slf.util.AuthUtil" %>
<%
    // Prevent direct access to this include file
    String requestURI = request.getRequestURI();
    if (requestURI.endsWith("checkAuth.jsp")) {
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
        return;
    }

    // Basic authentication: user must have a valid role
    String _authRole = (session.getAttribute("position") != null)
                       ? (String) session.getAttribute("position")
                       : "Guest";

    if (_authRole.equals("Guest")) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=unauthorized");
        return;
    }
%>