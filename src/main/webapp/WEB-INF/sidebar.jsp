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
    <% if (showDashboard) { %>
    <a href="${pageContext.request.contextPath}/Dashboard.jsp"><i class="fa-solid fa-chart-line" style="margin-right: 10px"></i>Dashboard</a>
    <a href="${pageContext.request.contextPath}/memberManage"><i class="fa-solid fa-users-gear" style="margin-right: 10px"></i>จัดการสมาชิก</a>
    <% } %>
    <a href="${pageContext.request.contextPath}/logout"><i class="fa-solid fa-arrow-right-from-bracket" style="margin-right: 10px"></i>ออกจากระบบ</a>
    <% if (showAdmin) { %>
    <a href="${pageContext.request.contextPath}/Admin.jsp" class="admin-tab">
        <i class="fa-solid fa-circle-user"></i>Admin
    </a>
    <% } %>
</div>
