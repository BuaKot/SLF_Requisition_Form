<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String _authRequestUri = request.getRequestURI();
    if (_authRequestUri.endsWith("checkAuth.jsp")) {
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
        return;
    }

    String _authRole = (String) session.getAttribute("position");
    String _authEmpName = (String) session.getAttribute("loggedInEmpName");
    if (_authRole == null || _authEmpName == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=unauthorized");
        return;
    }

    Object _requiredPageKeyObj = request.getAttribute("requiredPageKey");
    String _requiredPageKey = _requiredPageKeyObj == null ? null : String.valueOf(_requiredPageKeyObj);
    if (_requiredPageKey != null && _requiredPageKey.trim().length() > 0
            && !com.slf.util.AuthUtil.isAllowedForPage(_authRole, _requiredPageKey)) {
        session.setAttribute("accessDeniedMessage", "คุณไม่มีสิทธิ์เข้าถึงหน้านี้");
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
%>
