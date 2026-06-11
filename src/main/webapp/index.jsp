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
%>
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
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>

<div id="main" class="enterprise-index-shell">
    <%@ include file="/WEB-INF/jspf/topbar.jspf" %>

    <%
        String _indexDeniedMessage = (String) session.getAttribute("formDeniedMessage");
        if (_indexDeniedMessage != null) {
            session.removeAttribute("formDeniedMessage");
    %>
    <div id="formDeniedModal" class="modal-overlay" role="dialog" aria-modal="true">
        <div class="modal-box">
            <span class="modal-close" onclick="closeDeniedModal()">&times;</span>
            <p><%= _indexDeniedMessage %></p>
            <button class="modal-ok-btn" type="button" onclick="closeDeniedModal()">ตกลง</button>
        </div>
    </div>
    <% } %>

    <%
        String _indexAccessDeniedMessage = (String) session.getAttribute("accessDeniedMessage");
        if (_indexAccessDeniedMessage != null) {
            session.removeAttribute("accessDeniedMessage");
    %>
    <div id="accessDeniedModal" class="modal-overlay" role="dialog" aria-modal="true">
        <div class="modal-box">
            <span class="modal-close" onclick="closeAccessDeniedModal()">&times;</span>
            <p><%= _indexAccessDeniedMessage %></p>
            <button class="modal-ok-btn" type="button" onclick="closeAccessDeniedModal()">ตกลง</button>
        </div>
    </div>
    <% } %>

    <main class="enterprise-index-main">
        <section class="enterprise-hero index-banner" aria-labelledby="indexHeroTitle">
            <div class="enterprise-hero-copy index-banner-inner">
                <p class="enterprise-eyebrow">ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</p>
                <h1 id="indexHeroTitle">ระบบใบขอให้ดำเนินการด้านเทคโนโลยีสารสนเทศ</h1>
                <p class="enterprise-hero-lead">
                    ศูนย์กลางสำหรับสร้างคำขอ ติดตามรายการที่ส่งแล้ว และดำเนินงานตามบทบาทของผู้ใช้งานภายในระบบ
                </p>
            </div>
            <div class="enterprise-hero-meta" aria-label="สถานะผู้ใช้งาน">
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
                <a class="history-link-card index-history-fab" href="${pageContext.request.contextPath}/history.jsp">
                    <i class="fa-solid fa-clock-rotate-left"></i>
                    <span>ประวัติรายการ</span>
                </a>
                <% } %>
            </div>

            <div class="enterprise-action-grid<%= approvalOnlyRole ? " approval-only-actions" : "" %>">
                <% if (approvalOnlyRole && approvalPage != null) { %>
                <a class="enterprise-action-card primary" href="${pageContext.request.contextPath}<%= approvalPage %>">
                    <span class="enterprise-card-icon"><i class="fa-solid fa-file-signature"></i></span>
                    <span class="enterprise-card-content">
                        <strong><%= approvalLabel %></strong>
                        <small>ไปยังรายการรออนุมัติตามสิทธิ์และบทบาทของผู้ใช้งาน</small>
                    </span>
                    <span class="enterprise-card-arrow" aria-hidden="true"><i class="fa-solid fa-arrow-right"></i></span>
                </a>
                <% } else { %>
                <a class="enterprise-action-card primary" href="${pageContext.request.contextPath}/newForm">
                    <span class="enterprise-card-icon"><i class="fa-solid fa-plus"></i></span>
                    <span class="enterprise-card-content">
                        <strong>สร้างฟอร์มใหม่</strong>
                        <small>เลือกประเภทแบบฟอร์มและเริ่มสร้างคำขอตามขั้นตอนของระบบ</small>
                    </span>
                    <span class="enterprise-card-arrow" aria-hidden="true"><i class="fa-solid fa-arrow-right"></i></span>
                </a>

                <a class="enterprise-action-card" href="${pageContext.request.contextPath}/submit">
                    <span class="enterprise-card-icon"><i class="fa-solid fa-paper-plane"></i></span>
                    <span class="enterprise-card-content">
                        <strong>ฟอร์มที่ส่งแล้ว</strong>
                        <small>ตรวจสอบคำขอที่ส่งไปแล้วและติดตามสถานะล่าสุด</small>
                    </span>
                    <span class="enterprise-card-arrow" aria-hidden="true"><i class="fa-solid fa-arrow-right"></i></span>
                </a>

                <% if (showTechnicalWork) { %>
                <a class="enterprise-action-card" href="${pageContext.request.contextPath}/technicalApprove">
                    <span class="enterprise-card-icon"><i class="fa-solid fa-screwdriver-wrench"></i></span>
                    <span class="enterprise-card-content">
                        <strong>ตรวจสอบเชิงเทคนิค</strong>
                        <small>ตรวจสอบรายละเอียดทางเทคนิคก่อนเข้าสู่ขั้นตอนดำเนินงาน</small>
                    </span>
                    <span class="enterprise-card-arrow" aria-hidden="true"><i class="fa-solid fa-arrow-right"></i></span>
                </a>
                <% } %>

                <% if (showProcessWork) { %>
                <a class="enterprise-action-card" href="${pageContext.request.contextPath}/process">
                    <span class="enterprise-card-icon"><i class="fa-solid fa-bars-progress"></i></span>
                    <span class="enterprise-card-content">
                        <strong>รายการรอดำเนินการ</strong>
                        <small>ดูและจัดการคำขอที่เข้าสู่คิวการดำเนินงานของฝ่ายที่เกี่ยวข้อง</small>
                    </span>
                    <span class="enterprise-card-arrow" aria-hidden="true"><i class="fa-solid fa-arrow-right"></i></span>
                </a>
                <% } %>
                <% } %>
            </div>
        </section>
    </main>
    <%@ include file="/WEB-INF/jspf/footer.jspf" %>
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

function closeDeniedModal() {
  var modal = document.getElementById("formDeniedModal");
  if (modal) modal.style.display = "none";
}

function closeAccessDeniedModal() {
  var modal = document.getElementById("accessDeniedModal");
  if (modal) modal.style.display = "none";
}
</script>
</body>
</html>



