<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
%>

<%
    String _authCurrentRole = (String) session.getAttribute("position");


    if (_authCurrentRole == null || !AuthUtil.isAllowedForPage(_authCurrentRole, "adminPage")) {
        response.sendRedirect(request.getContextPath() + "/index.jsp?error=nopermission");
        return;
    }
%>
