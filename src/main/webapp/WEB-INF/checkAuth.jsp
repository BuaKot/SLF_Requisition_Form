<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="javax.servlet.http.HttpServletResponse" %>
<%@ page import="com.slf.util.AuthUtil" %>
<%
    String requestURI = request.getRequestURI();
    if (requestURI.endsWith("checkAuth.jsp")) {
        response.sendError(HttpServletResponse.SC_NOT_FOUND); 
        return;
    }

    String _authRole = (session.getAttribute("position") != null) ? (String)session.getAttribute("position") : "Guest";
    
    if (_authRole.equals("Guest")) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
        return;
    }

    String _authCurrentRole = _authRole;
%>
