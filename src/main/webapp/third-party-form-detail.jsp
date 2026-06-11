<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.slf.util.AuthUtil" %>
<%@ page import="com.slf.util.ThirdPartyAccessPolicy" %>
<%
    String currentRole = (String) session.getAttribute("position");
    String employeeName = (String) session.getAttribute("loggedInEmpName");
    if (currentRole == null || employeeName == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    boolean approvalOnlyRole = AuthUtil.isApprovalOnlyRole(currentRole);
    boolean canCreateThirdPartyLinks = !approvalOnlyRole
        && ThirdPartyAccessPolicy.canCreateOwnLinks(ThirdPartyAccessPolicy.sessionEmpId(session));
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>แบบฟอร์มลงทะเบียนผู้ให้บริการภายนอก</title>
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
            <h2>แบบฟอร์มการขอลงทะเบียนผู้ใช้ระบบงานสารสนเทศ สำหรับผู้ให้บริการภายนอก</h2>
            <p>แบบฟอร์มสำหรับสร้างลิงก์ให้ผู้ให้บริการภายนอกกรอกข้อมูล โดยใช้ token และ external link flow เดิมของระบบ</p>
            <div class="index-form-actions">
                <% if (canCreateThirdPartyLinks) { %>
                <a class="form-type-action" href="${pageContext.request.contextPath}/forms/select?code=THIRD_PARTY_USER_REGISTRATION">สร้างฟอร์มใหม่</a>
                <% } else { %>
                <span class="form-type-action disabled" aria-disabled="true">ไม่มีสิทธิ์เข้าถึงฟอร์มนี้</span>
                <% } %>
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
