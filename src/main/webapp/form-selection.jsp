<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    Boolean canCreateThirdPartyLinks = (Boolean) request.getAttribute("canCreateThirdPartyLinks");
    if (canCreateThirdPartyLinks == null) {
        response.sendRedirect(request.getContextPath() + "/newForm");
        return;
    }
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>เลือกประเภทแบบฟอร์ม</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body>
<%@ include file="/WEB-INF/sidebar.jsp" %>
<div id="main">
    <div class="sticky-bar">
        <i id="menuBtn" class="fa-solid fa-bars" onclick="toggleNav()"></i>
        <img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF Logo">
        <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo">
        <div class="user-info">
            <i class="fa fa-circle-user"></i>
            <p>${sessionScope.loggedInEmpName} | ID: ${sessionScope.loggedInEmpId}</p>
        </div>
        <div class="contact-info">
            <i class="fa-solid fa-circle-info"></i>
            <p>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
        </div>
    </div>

    <main class="form-selection-page">
        <section class="form-selection-hero">
            <div>
                <p class="eyebrow">ศูนย์รวมแบบฟอร์ม</p>
                <h1>เลือกประเภทแบบฟอร์ม</h1>
                <p>เลือกแบบฟอร์มที่ต้องการสร้าง</p>
            </div>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/">
                <i class="fa-solid fa-arrow-left"></i> กลับหน้าหลัก
            </a>
        </section>

        <section class="form-type-grid">
            <article class="form-type-card">
                <div class="form-type-icon"><i class="fa-solid fa-file-circle-plus"></i></div>
                <div class="form-type-body">
                    <div class="form-type-title-row">
                        <h2>ใบคำขอฝ่ายเทคโนโลยีสารสนเทศ</h2>
                        <span class="form-status available">เปิดใช้งาน</span>
                    </div>
                    <p>สร้างคำขอด้านเทคโนโลยีสารสนเทศผ่านกระบวนการอนุมัติหลักของระบบ</p>
                </div>
                <a class="form-type-action" href="${pageContext.request.contextPath}/forms/select?code=IT_REQUISITION_REQUEST">
                    สร้างแบบฟอร์ม <i class="fa-solid fa-arrow-right"></i>
                </a>
            </article>

            <% if (canCreateThirdPartyLinks.booleanValue()) { %>
            <article class="form-type-card">
                <div class="form-type-icon"><i class="fa-solid fa-user-shield"></i></div>
                <div class="form-type-body">
                    <div class="form-type-title-row">
                        <h2>แบบฟอร์มสำหรับผู้ให้บริการภายนอก</h2>
                        <span class="form-status available">เปิดใช้งาน</span>
                    </div>
                    <p>สร้างลิงก์สำหรับส่งให้บุคคลภายนอกกรอกข้อมูล โดยลิงก์หมดอายุภายใน 24 ชั่วโมงและส่งได้ครั้งเดียว</p>
                </div>
                <a class="form-type-action" href="${pageContext.request.contextPath}/forms/select?code=THIRD_PARTY_USER_REGISTRATION">
                    จัดการลิงก์ Third-party <i class="fa-solid fa-arrow-right"></i>
                </a>
            </article>
            <% } %>
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
</body>
</html>
