<%@ page pageEncoding="UTF-8" %>
<header class="sticky-bar index-topbar">
    <div class="index-topbar-left">
        <button id="menuBtn" class="index-menu-button" type="button" onclick="toggleNav()" aria-label="เปิดเมนู">
            <i class="fa-solid fa-bars"></i>
        </button>
        <div class="index-brand-lockup">
            <img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF Logo">
            <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo">
            <div>
                <span class="brand-kicker">Student Loan Fund</span>
                <strong>ระบบ Requisition Form</strong>
            </div>
        </div>
    </div>

    <div class="index-topbar-right">
        <div class="user-info index-info-pill">
            <i class="fa fa-circle-user"></i>
            <p>${sessionScope.loggedInEmpName} | ID: ${sessionScope.loggedInEmpId}</p>
        </div>
        <div class="contact-info index-info-pill">
            <i class="fa-solid fa-circle-info"></i>
            <p>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
        </div>
    </div>
</header>
