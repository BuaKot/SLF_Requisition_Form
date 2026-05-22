<%@ page pageEncoding="UTF-8" %>
<%@ page import="com.slf.util.AuthUtil" %>
<%
    String position = (String) session.getAttribute("position");
    boolean showAdmin = AuthUtil.isAdmin(position);
%>
<div id="mySidebar" class="sidebar">
    <a href="javascript:void(0)" class="closebtn" onclick="toggleNav()">&times;</a>
    <a href="${pageContext.request.contextPath}"><i class="fa-solid fa-house" style='margin-right: 10px'></i>หน้าหลัก</a>
    <a href="${pageContext.request.contextPath}/newForm"><i class="fa-solid fa-plus" style='margin-right: 10px'></i>สร้างฟอร์มใหม่</a>
    <a href="${pageContext.request.contextPath}/submit.jsp"><i class="fa-solid fa-paper-plane" style='margin-right: 10px'></i>ฟอร์มที่ส่งแล้ว</a>
    <a href="${pageContext.request.contextPath}/logout"><i class="fa-solid fa-arrow-right-from-bracket" style='margin-right: 10px'></i>ออกจากระบบ</a>
    <% if (showAdmin) { %>
    <a href="${pageContext.request.contextPath}/Admin.jsp" class="admin-tab">
        <i class="fa-solid fa-circle-user"></i>Admin
    </a>
    <% } %>
</div>