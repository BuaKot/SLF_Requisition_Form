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
    <main class="enterprise-index-main it-requisition-detail-page">
        <section class="enterprise-hero index-banner it-requisition-banner" aria-labelledby="itRequisitionTitle">
            <div class="enterprise-hero-copy index-banner-inner">
                <p class="enterprise-eyebrow">IT Service Management Portal</p>
                <h1 id="itRequisitionTitle">ใบขอให้ดำเนินการด้านเทคโนโลยีสารสนเทศ</h1>
                <p class="enterprise-hero-lead">
                    เลือกการดำเนินการสำหรับใบ Request ฝ่ายเทคโนโลยีสารสนเทศ
                </p>
            </div>
        </section>

        <div class="detail-action-bar it-detail-back-row">
            <a class="detail-back-button" href="${pageContext.request.contextPath}/index.jsp">
                <i class="fa-solid fa-arrow-left"></i>
                <span><%= listBackLink.getLabel() %></span>
            </a>
        </div>

        <section class="enterprise-menu-section it-action-section" aria-label="รายการดำเนินการที่สามารถเลือกได้">
            <div class="enterprise-section-head">
                <div>
                    <h2>รายการดำเนินการที่สามารถเลือกได้</h2>
                </div>
            </div>

            <div class="enterprise-action-grid <%= approvalOnlyRole ? "approval-only-actions" : "" %>">
                <% if (!approvalOnlyRole) { %>
                <a class="enterprise-action-card it-action-card" href="${pageContext.request.contextPath}/forms/select?code=IT_REQUISITION_REQUEST">
                    <div class="enterprise-card-icon">
                        <i class="fa-solid fa-file-circle-plus"></i>
                    </div>
                    <div class="enterprise-card-content">
                        <strong>สร้างฟอร์มใหม่</strong>
                        <small>เริ่มสร้างใบขอให้ดำเนินการด้านเทคโนโลยีสารสนเทศ</small>
                    </div>
                    <div class="enterprise-card-arrow">
                        <i class="fa-solid fa-chevron-right"></i>
                    </div>
                </a>

                <a class="enterprise-action-card it-action-card" href="${pageContext.request.contextPath}/submit">
                    <div class="enterprise-card-icon">
                        <i class="fa-solid fa-paper-plane"></i>
                    </div>
                    <div class="enterprise-card-content">
                        <strong>ดูฟอร์มที่ส่งแล้ว</strong>
                        <small>ตรวจสอบรายละเอียดและสถานะล่าสุดของใบคำขอ</small>
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
