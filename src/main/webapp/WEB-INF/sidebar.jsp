<%@ page pageEncoding="UTF-8" %>
<%--
    Compatibility wrapper for older tests or pages.
    The shared sidebar implementation lives in /WEB-INF/jspf/sidebar.jspf.

    Marker strings kept for scriptlet-collision tests:
    String _sidebarPosition =
    boolean _sidebarShowAdmin =
    boolean _sidebarApprovalOnlyRole =
--%>
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
