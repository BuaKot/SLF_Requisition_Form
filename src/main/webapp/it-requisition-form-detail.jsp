<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.slf.util.AuthUtil, com.slf.util.NavigationUtil" %>
<%
    String currentRole = (String) session.getAttribute("position");
    String employeeName = (String) session.getAttribute("loggedInEmpName");
    if (currentRole == null || employeeName == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String approvalPage = AuthUtil.approvalPageForRole(currentRole);
    if (approvalPage != null) {
        response.sendRedirect(request.getContextPath() + approvalPage);
        return;
    }
    boolean approvalOnlyRole = AuthUtil.isApprovalOnlyRole(currentRole);
    NavigationUtil.BackLink listBackLink = NavigationUtil.listPageBack(request.getContextPath());
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
        <section class="enterprise-hero index-banner it-requisition-banner">
            <div class="enterprise-hero-copy index-banner-inner">
                <h1>ใบขอให้ดำเนินการด้านเทคโนโลยีสารสนเทศ</h1>
                <p class="enterprise-hero-lead">
                    ระบบศูนย์กลางสำหรับยื่นแบบฟอร์มขอสร้างคำขอด้านระบบสารสนเทศ อุปกรณ์ฮาร์ดแวร์ สิทธิ์การใช้งานซอฟต์แวร์ และงานบริการด้านเทคนิค IT ผ่านกระบวนการ Workflow อนุมัติขององค์กร
                </p>
            </div>
        </section>

        
        <div class="detail-action-bar it-detail-back-row">
            <a class="detail-back-button" href="<%= listBackLink.getHref() %>">
                <i class="fa-solid fa-arrow-left"></i> <%= listBackLink.getLabel() %>
            </a>
        </div>

        <section class="enterprise-menu-section">
            <div class="enterprise-section-head">
                <div class="enterprise-card-content">
                    <strong style="color: var(--slf-color-primary); font-size: var(--slf-font-size-xl); font-family: var(--slf-font-family);">
                        <i class="fa-solid fa-layer-group" style="color: var(--slf-color-accent); margin-right: var(--slf-space-2);"></i> รายการดำเนินการที่สามารถเลือกได้
                    </strong>
                    <small style="color: var(--slf-color-text-muted); font-family: var(--slf-font-family);">เลือกปฏิบัติการตามสิทธิ์การใช้งานของระบบปัจจุบันของคุณ</small>
                </div>
            </div>

            <div class="enterprise-action-grid <%= approvalOnlyRole ? "approval-only-actions" : "" %>" style="margin-top: var(--slf-space-4);">
                
                <% if (!approvalOnlyRole) { %>
                <a class="enterprise-action-card primary" href="${pageContext.request.contextPath}/forms/select?code=IT_REQUISITION_REQUEST">
                    <div class="enterprise-card-icon">
                        <i class="fa-solid fa-file-circle-plus"></i>
                    </div>
                    <div class="enterprise-card-content">
                        <strong>สร้างฟอร์มใหม่</strong>
                        <small>ลงทะเบียนยื่นใบคำขอด้านเทคโนโลยีสารสนเทศชิ้นใหม่</small>
                    </div>
                    <div class="enterprise-card-arrow">
                        <i class="fa-solid fa-chevron-right"></i>
                    </div>
                </a>

                <a class="enterprise-action-card" href="${pageContext.request.contextPath}/submit">
                    <div class="enterprise-card-icon">
                        <i class="fa-solid fa-paper-plane"></i>
                    </div>
                    <div class="enterprise-card-content">
                        <strong>ดูฟอร์มที่ส่งแล้ว</strong>
                        <small>ตรวจสอบรายละเอียดและสถานะของใบคำขอล่าสุดของคุณ</small>
                    </div>
                    <div class="enterprise-card-arrow">
                        <i class="fa-solid fa-chevron-right"></i>
                    </div>
                </a>
                <% } %>

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
