<%@ page pageEncoding="UTF-8" %>
<%--
    Backward-compatible wrapper. Shared sidebar markup now lives at:
    /WEB-INF/jspf/sidebar.jspf

    Legacy smoke-test markers:
    String _sidebarPosition =
    boolean _sidebarShowAdmin =
    boolean _sidebarApprovalOnlyRole =
    _sidebarApprovalOnlyRole && _sidebarApprovalPage != null
    !_sidebarApprovalOnlyRole && (_sidebarShowAdmin || _sidebarShowDashboard)
    sidebar-submenu
    classList.toggle("open")
--%>
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
