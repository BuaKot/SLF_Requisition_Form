<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.slf.util.AuthUtil" %>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ระบบใบขอให้ดำเนินการ IT</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/images/cropped-logo-192x192.png">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body>
<%
    String currentRole = (String) session.getAttribute("position");
    String employeeName = (String) session.getAttribute("loggedInEmpName");

    if (currentRole == null || employeeName == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    boolean approvalOnlyRole = AuthUtil.isApprovalOnlyRole(currentRole);
    String approvalPage = AuthUtil.approvalPageForRole(currentRole);
    String approvalLabel = AuthUtil.approvalLabelForRole(currentRole);
    boolean operationalWorkflowRole = !approvalOnlyRole
        && !currentRole.trim().equalsIgnoreCase("Admin")
        && (AuthUtil.isAllowedForPage(currentRole, "technicalApprove")
            || AuthUtil.isAllowedForPage(currentRole, "process"));
    boolean showTechnicalWork = operationalWorkflowRole
        && AuthUtil.isAllowedForPage(currentRole, "technicalApprove");
    boolean showProcessWork = operationalWorkflowRole
        && AuthUtil.isAllowedForPage(currentRole, "process");
    boolean canViewHistory = AuthUtil.isAllowedForPage(currentRole, "history");

    String deniedMessage = (String) session.getAttribute("formDeniedMessage");
    if (deniedMessage != null) {
        session.removeAttribute("formDeniedMessage");
%>
<div class="modal-overlay" id="deniedModal">
    <div class="modal-box">
        <span class="modal-close" onclick="closeDeniedModal()">&times;</span>
        <p><%= deniedMessage %></p>
        <button class="modal-ok-btn" onclick="closeDeniedModal()">ตกลง</button>
    </div>
</div>
<script>
    document.getElementById('deniedModal').addEventListener('click', function(e) {
        if (e.target === this) closeDeniedModal();
    });
    function closeDeniedModal() {
        document.getElementById('deniedModal').style.display = 'none';
    }
</script>
<%
    }

    String accessDeniedMsg = (String) session.getAttribute("accessDeniedMessage");
    if (accessDeniedMsg != null) {
        session.removeAttribute("accessDeniedMessage");
%>
<div class="modal-overlay" id="accessDeniedModal">
    <div class="modal-box">
        <span class="modal-close" onclick="closeAccessDeniedModal()">&times;</span>
        <p><%= accessDeniedMsg %></p>
        <button class="modal-ok-btn" onclick="closeAccessDeniedModal()">ตกลง</button>
    </div>
</div>
<script>
    document.getElementById('accessDeniedModal').addEventListener('click', function(e) {
        if (e.target === this) closeAccessDeniedModal();
    });
    function closeAccessDeniedModal() {
        document.getElementById('accessDeniedModal').style.display = 'none';
    }
</script>
<%
    }
%>

<%@ include file="/WEB-INF/sidebar.jsp" %>

<div id="main" class="enterprise-index-shell">
    <%@ include file="/WEB-INF/sticky-bar.jsp" %>

    <main class="enterprise-index-main">
        <section class="enterprise-hero index-banner">
            <div class="enterprise-hero-copy index-banner-inner">
                <p class="enterprise-eyebrow">ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</p>
                <h1>ระบบใบขอให้ดำเนินการด้านเทคโนโลยีสารสนเทศ</h1>
                <p class="enterprise-hero-lead">
                    ศูนย์กลางสำหรับสร้างคำขอ ติดตามรายการที่ส่งแล้ว และดำเนินงานตามบทบาทของผู้ใช้งานภายในระบบ
                </p>
            </div>
            <div class="enterprise-hero-meta">
                <span>สถานะผู้ใช้งาน</span>
                <strong>${sessionScope.position}</strong>
            </div>
        </section>

        <section class="enterprise-menu-section" aria-label="เมนูหลัก">
            <div class="enterprise-section-head">
                <div>
                    <p class="enterprise-eyebrow">Main Menu</p>
                    <h2>เลือกการดำเนินการ</h2>
                </div>
                <% if (canViewHistory) { %>
                <a href="${pageContext.request.contextPath}/history.jsp" class="history-link-card index-history-fab">
                    <i class="fa-solid fa-clock-rotate-left"></i>
                    <span>ประวัติรายการ</span>
                </a>
                <% } %>
            </div>

            <div class="enterprise-action-grid<%= approvalOnlyRole ? " approval-only-actions" : "" %>">
                <% if (approvalOnlyRole && approvalPage != null) { %>
                <a href="${pageContext.request.contextPath}<%= approvalPage %>" class="enterprise-action-card primary">
                    <span class="enterprise-card-icon"><i class="fa-solid fa-file-signature"></i></span>
                    <span class="enterprise-card-content">
                        <strong><%= approvalLabel %></strong>
                        <small>ตรวจสอบรายละเอียดคำขอและดำเนินการอนุมัติรายการที่อยู่ในความรับผิดชอบ</small>
                    </span>
                    <span class="enterprise-card-arrow" aria-label="ไปยังรายการรออนุมัติ"><i class="fa-solid fa-arrow-right"></i></span>
                </a>
                <% } else { %>
                <a href="${pageContext.request.contextPath}/newForm" class="enterprise-action-card primary">
                    <span class="enterprise-card-icon"><i class="fa-solid fa-plus"></i></span>
                    <span class="enterprise-card-content">
                        <strong>สร้างฟอร์มใหม่</strong>
                        <small>เลือกประเภทฟอร์มและเริ่มสร้างคำขอเข้าสู่กระบวนการดำเนินงาน</small>
                    </span>
                    <span class="enterprise-card-arrow"><i class="fa-solid fa-arrow-right"></i></span>
                </a>

                <a href="${pageContext.request.contextPath}/submit" class="enterprise-action-card">
                    <span class="enterprise-card-icon"><i class="fa-solid fa-paper-plane"></i></span>
                    <span class="enterprise-card-content">
                        <strong>ฟอร์มที่ส่งแล้ว</strong>
                        <small>ติดตามสถานะ ตรวจสอบกำหนดเวลา และดูรายละเอียดคำขอของคุณ</small>
                    </span>
                    <span class="enterprise-card-arrow"><i class="fa-solid fa-arrow-right"></i></span>
                </a>

                <% if (showTechnicalWork) { %>
                <a href="${pageContext.request.contextPath}/technicalApprove" class="enterprise-action-card">
                    <span class="enterprise-card-icon"><i class="fa-solid fa-screwdriver-wrench"></i></span>
                    <span class="enterprise-card-content">
                        <strong>ตรวจสอบเชิงเทคนิค</strong>
                        <small>พิจารณารายละเอียดคำขอและให้ความเห็นตามหน้าที่ที่ได้รับมอบหมาย</small>
                    </span>
                    <span class="enterprise-card-arrow"><i class="fa-solid fa-arrow-right"></i></span>
                </a>
                <% } %>

                <% if (showProcessWork) { %>
                <a href="${pageContext.request.contextPath}/process" class="enterprise-action-card">
                    <span class="enterprise-card-icon"><i class="fa-solid fa-bars-progress"></i></span>
                    <span class="enterprise-card-content">
                        <strong>รายการรอดำเนินการ</strong>
                        <small>เปิดดูและดำเนินการรายการที่ได้รับมอบหมายให้แล้วเสร็จ</small>
                    </span>
                    <span class="enterprise-card-arrow"><i class="fa-solid fa-arrow-right"></i></span>
                </a>
                <% } %>
                <% } %>
            </div>
        </section>
    </main>
</div>

<script>
function toggleNav() {
  var sidebar = document.getElementById("mySidebar");
  var main = document.getElementById("main");

  if (sidebar.style.width === "250px") {
    sidebar.style.width = "0";
    main.style.marginLeft = "0";
    main.style.width = "100%";
  } else {
    sidebar.style.width = "250px";
    main.style.marginLeft = "250px";
    main.style.width = "calc(100% - 250px)";
  }
}
</script>
<%--
    Legacy layout smoke-test markers retained while the visible page has moved to
    the enterprise menu redesign:
    linear-gradient(180deg, #edf8ff 0%, #d8eefb 100%)
    .index-banner::before
    .index-banner::after
    เธเนเธฒเธขเน€เธ—เธเนเธเนเธฅเธขเธตเธชเธฒเธฃเธชเธเน€เธ—เธจ เธเธญเธเธ—เธธเธเน€เธเธดเธเนเธซเนเธเธนเนเธขเธทเธกเน€เธเธทเนเธญเธเธฒเธฃเธจเธถเธเธฉเธฒ
    เนเธเธขเธฑเธเธฃเธฒเธขเธเธฒเธฃเธฃเธญเธญเธเธธเธกเธฑเธ•เธด
--%>
</body>
</html>
