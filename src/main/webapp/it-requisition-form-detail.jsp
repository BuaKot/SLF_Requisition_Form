<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.slf.util.AuthUtil" %>
<%
    String currentRole = (String) session.getAttribute("position");
    String employeeName = (String) session.getAttribute("loggedInEmpName");
    if (currentRole == null || employeeName == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    boolean approvalOnlyRole = AuthUtil.isApprovalOnlyRole(currentRole);
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ใบขอให้ดำเนินการด้านเทคโนโลยีสารสนเทศ</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/images/cropped-logo-192x192.png">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body>
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
<div id="main" class="enterprise-index-shell">
    <%@ include file="/WEB-INF/jspf/topbar.jspf" %>
    <main class="enterprise-index-main">
        <section class="enterprise-menu-section form-action-panel">
            <p class="enterprise-eyebrow">Form Detail</p>
            <h2>ใบขอให้ดำเนินการด้านเทคโนโลยีสารสนเทศ</h2>
            <p>แบบฟอร์มสำหรับสร้างคำขอด้านระบบสารสนเทศ อุปกรณ์ สิทธิ์การใช้งาน และงานบริการ IT ผ่าน workflow เดิมของระบบ</p>
            <div class="index-form-actions">
                <% if (!approvalOnlyRole) { %>
                <a class="form-type-action" href="${pageContext.request.contextPath}/forms/select?code=IT_REQUISITION_REQUEST">สร้างฟอร์มใหม่</a>
                <a class="form-type-action secondary" href="${pageContext.request.contextPath}/submit">ดูฟอร์มที่ส่งแล้ว</a>
                <% } %>
                <a class="form-type-action secondary" href="${pageContext.request.contextPath}/history.jsp">ประวัติ/ติดตามสถานะ</a>
                <a class="form-type-action secondary" href="${pageContext.request.contextPath}/">กลับหน้าเลือกฟอร์ม</a>
            </div>
        </section>
    </main>
    <%@ include file="/WEB-INF/jspf/footer.jspf" %>
</div>
<script>
function toggleNav(){var s=document.getElementById("mySidebar"),m=document.getElementById("main");if(s.style.width==="250px"){s.style.width="0";m.style.marginLeft="0";m.style.width="100%";}else{s.style.width="250px";m.style.marginLeft="250px";m.style.width="calc(100% - 250px)";}}
</script>
</body>
</html>
