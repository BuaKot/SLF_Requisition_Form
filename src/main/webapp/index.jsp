<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.slf.util.AuthUtil" %>
<%@ page import="com.slf.util.ThirdPartyAccessPolicy" %>
<%!
    private String h(Object input) {
        if (input == null) return "";
        return String.valueOf(input)
            .replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
            .replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    String currentRole = (String) session.getAttribute("position");
    String employeeName = (String) session.getAttribute("loggedInEmpName");

    if (currentRole == null || employeeName == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    boolean approvalOnlyRole = AuthUtil.isApprovalOnlyRole(currentRole);
    boolean canCreateInternalForms = !approvalOnlyRole;
    boolean canCreateThirdPartyLinks = !approvalOnlyRole
        && ThirdPartyAccessPolicy.canCreateOwnLinks(ThirdPartyAccessPolicy.sessionEmpId(session));
    boolean isDirector = "Director".equalsIgnoreCase(currentRole);
    boolean isTechnical = "Technical".equalsIgnoreCase(currentRole);
    boolean isItDirector = "ITDirector".equalsIgnoreCase(currentRole)
        || "IT Director".equalsIgnoreCase(currentRole);
    boolean isInfrastructure = "Infrastructure".equalsIgnoreCase(currentRole);
    boolean hasRoleWorkMenu = isDirector || isTechnical || isItDirector || isInfrastructure;
    String requisitionWorkUrl = isDirector ? "/directorApprove"
        : isTechnical ? "/technicalApprove"
        : isItDirector ? "/itDirectorApprove" : "/process";
    String thirdPartyCreateUrl = canCreateThirdPartyLinks
        ? "/thirdParty/request/new" : "/third-party-form-detail.jsp";
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>เลือกประเภทแบบฟอร์ม</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/images/cropped-logo-192x192.png">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body>
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>

<div id="main" class="enterprise-index-shell">
    <%@ include file="/WEB-INF/jspf/topbar.jspf" %>

    <%
        String deniedMessage = (String) session.getAttribute("formDeniedMessage");
        if (deniedMessage != null) {
            session.removeAttribute("formDeniedMessage");
    %>
    <div id="formDeniedModal" class="modal-overlay" role="dialog" aria-modal="true">
        <div class="modal-box">
            <span class="modal-close" onclick="closeDeniedModal()">&times;</span>
            <p><%= deniedMessage %></p>
            <button class="modal-ok-btn" type="button" onclick="closeDeniedModal()">ตกลง</button>
        </div>
    </div>
    <% } %>

    <%
        String accessDeniedMessage = (String) session.getAttribute("accessDeniedMessage");
        if (accessDeniedMessage != null) {
            session.removeAttribute("accessDeniedMessage");
    %>
    <div id="accessDeniedModal" class="modal-overlay" role="dialog" aria-modal="true">
        <div class="modal-box">
            <span class="modal-close" onclick="closeAccessDeniedModal()">&times;</span>
            <p><%= accessDeniedMessage %></p>
            <button class="modal-ok-btn" type="button" onclick="closeAccessDeniedModal()">ตกลง</button>
        </div>
    </div>
    <% } %>

    <main class="enterprise-index-main">
        <section class="enterprise-hero index-banner" aria-labelledby="indexHeroTitle">
            <div class="enterprise-hero-copy index-banner-inner">
                <p class="enterprise-eyebrow">ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</p>
                <h1 id="indexHeroTitle">เลือกประเภทแบบฟอร์ม</h1>
                <p class="enterprise-hero-lead">เลือกแบบฟอร์มที่ต้องการใช้งาน แล้วเข้าสู่ขั้นตอนดำเนินการตามสิทธิ์ของคุณ</p>
            </div>
        </section>

        <% if (hasRoleWorkMenu) { %>
        <section class="enterprise-menu-section" aria-label="เลือกประเภทงาน">
            <div class="enterprise-section-head">
                <div>
                    <p class="enterprise-eyebrow">Workflow Inbox</p>
                    <h2>เลือกประเภทงานที่ต้องดำเนินการ</h2>
                </div>
            </div>

            <div class="index-form-grid">
                <a class="index-form-card index-form-card-link" href="${pageContext.request.contextPath}<%= requisitionWorkUrl %>">
                    <div class="form-type-icon"><i class="fa-solid fa-file-signature"></i></div>
                    <div class="index-form-card-body">
                        <span class="form-status available">พร้อมใช้งาน</span>
                        <h3>ใบขอให้ดำเนินการด้านเทคโนโลยีสารสนเทศ</h3>
                        <p>ตรวจสอบและดำเนินการคำขอตามบทบาท <%= h(currentRole) %></p>
                    </div>
                    <span class="form-type-action secondary">เปิดรายการงาน</span>
                </a>

                <% if (isTechnical || isItDirector || isInfrastructure) { %>
                <a class="index-form-card index-form-card-link" href="${pageContext.request.contextPath}<%= isTechnical ? "/thirdParty/sectionHead" : isItDirector ? "/thirdParty/itDirector" : "/thirdParty/operator" %>">
                    <div class="form-type-icon"><i class="fa-solid fa-user-shield"></i></div>
                    <div class="index-form-card-body">
                        <span class="form-status available">พร้อมใช้งาน</span>
                        <h3>Third-party Form</h3>
                        <p>จัดการคำขอลงทะเบียนผู้ให้บริการภายนอกตามขั้นตอนอนุมัติ</p>
                    </div>
                    <span class="form-type-action secondary">เปิดรายการงาน</span>
                </a>
                <% } else { %>
                <div class="index-form-card">
                    <div class="form-type-icon"><i class="fa-solid fa-user-shield"></i></div>
                    <div class="index-form-card-body">
                        <span class="form-status">ยังไม่เปิดใช้งาน</span>
                        <h3>แบบฟอร์มผู้ให้บริการภายนอก</h3>
                        <p>ขั้นตอนสำหรับตำแหน่ง <%= h(currentRole) %> อยู่ระหว่างการพัฒนา</p>
                    </div>
                    <span class="form-type-action disabled">ยังไม่มีรายการงาน</span>
                </div>
                <% } %>
            </div>
        </section>
        <% } else { %>
        <section class="enterprise-menu-section" aria-label="เลือกประเภทแบบฟอร์ม">

            <div class="index-form-grid">
                <a class="index-form-card index-form-card-link" href="${pageContext.request.contextPath}/it-requisition-form-detail.jsp">
                    <div class="form-type-icon"><i class="fa-solid fa-file-circle-plus"></i></div>
                    <div class="index-form-card-body">
                        <span class="form-status available">พร้อมใช้งาน</span>
                        <h3>ใบขอให้ดำเนินการด้านเทคโนโลยีสารสนเทศ</h3>
                        <p>สำหรับขออุปกรณ์ สิทธิ์การใช้งาน ระบบสารสนเทศ และบริการ IT</p>
                    </div>
                    <span class="form-type-action secondary">เริ่มใช้งาน</span>
                </a>

                <a class="index-form-card index-form-card-link" href="${pageContext.request.contextPath}<%= thirdPartyCreateUrl %>">
                    <div class="form-type-icon"><i class="fa-solid fa-user-shield"></i></div>
                    <div class="index-form-card-body">
                        <span class="form-status available">พร้อมใช้งาน</span>
                        <h3>แบบฟอร์มผู้ให้บริการภายนอก</h3>
                        <p>สร้างลิงก์ Token ให้ผู้ให้บริการภายนอกกรอกข้อมูลและติดตามสถานะ</p>
                    </div>
                    <span class="form-type-action secondary">เริ่มใช้งาน</span>
                </a>
            </div>
        </section>
        <% } %>
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
