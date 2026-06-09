<%@ page pageEncoding="UTF-8" %>
<%@ page import="com.slf.util.AuthUtil" %>
<%
    String position = (String) session.getAttribute("position");
    boolean showAdmin = AuthUtil.isAdmin(position);
    boolean showDashboard = position != null && position.trim().equalsIgnoreCase("Admin");
%>

<div id="mySidebar" class="sidebar">
    <a href="javascript:void(0)" class="closebtn" onclick="toggleNav()">&times;</a>
    <a href="${pageContext.request.contextPath}"><i class="fa-solid fa-house" style="margin-right: 10px"></i>หน้าหลัก</a>
    <a href="${pageContext.request.contextPath}/newForm"><i class="fa-solid fa-plus" style="margin-right: 10px"></i>สร้างฟอร์มใหม่</a>
    <a href="${pageContext.request.contextPath}/submit"><i class="fa-solid fa-paper-plane" style="margin-right: 10px"></i>ฟอร์มที่ส่งแล้ว</a>
    <a href="${pageContext.request.contextPath}/emailNotifications"><i class="fa-solid fa-envelope-circle-check" style="margin-right: 10px"></i>ข้อมูลส่วนตัว</a>

    <%-- Show the Admin Sub-menu Toggle only if the user has either Admin permission --%>
    <% if (showAdmin || showDashboard) { %>
    <a href="javascript:void(0)" onclick="toggleAdminMenu()">
        <i class="fa-solid fa-user-shield" style="margin-right: 10px"></i>Admin 
        <i class="fa-solid fa-caret-down" style="float: right; margin-top: 5px;"></i>
    </a>
    
    <div id="adminSubMenu" style="display: none; background-color: white; padding-left: 15px;">
        <% if (showAdmin) { %>
        <a href="${pageContext.request.contextPath}/Admin.jsp" style="font-size: 0.9em;"><i class="fa-solid fa-circle-user" style="margin-right: 10px"></i>Admin Page</a>
        <% } %>
        <% if (showDashboard) { %>
        <a href="${pageContext.request.contextPath}/Dashboard.jsp" style="font-size: 0.9em;"><i class="fa-solid fa-chart-line" style="margin-right: 10px"></i>Dashboard</a>
        <a href="${pageContext.request.contextPath}/memberManage" style="font-size: 0.9em;"><i class="fa-solid fa-users-gear" style="margin-right: 10px"></i>จัดการสมาชิก</a>
        <a href="${pageContext.request.contextPath}/mailLog" style="font-size: 0.9em;"><i class="fa-solid fa-envelope-open-text" style="margin-right: 10px"></i>mailLog</a>
        <a href="${pageContext.request.contextPath}/thirdPartyLinks" style="font-size: 0.9em;"><i class="fa-solid fa-link" style="margin-right: 10px"></i>Third-party Links</a>
        <% } %>
    </div>
    <% } %>

    <a href="${pageContext.request.contextPath}/logout" class="admin-tab">
        <i class="fa-solid fa-arrow-right-from-bracket" style="margin-right: 10px"></i>ออกจากระบบ
    </a>
</div>

<script>
    function toggleAdminMenu() {
        var menu = document.getElementById("adminSubMenu");
        if (menu.style.display === "none" || menu.style.display === "") {
            menu.style.display = "block";
        } else {
            menu.style.display = "none";
        }
    }
</script>