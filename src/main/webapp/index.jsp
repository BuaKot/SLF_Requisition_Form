<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ระบบใบขอให้ดำเนินการ IT</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
    /* ==========================================================================
       Contextual Modernization Override Blocks
       ========================================================================== */
    .modal-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 33, 102, 0.4); /* Softer brand-tinted overlay */
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 2000; 
    }
    
    .modal-box {
        background: var(--color-bg-card, #ffffff);
        border-radius: var(--radius-md, 12px);
        padding: 30px 40px;
        max-width: 480px;
        width: 90%;
        box-shadow: 0 20px 40px rgba(0, 51, 102, 0.16);
        position: relative;
        text-align: center;
        font-family: 'Sarabun', sans-serif;
        /* Replaced quick fade with formal, smoother cubic-bezier easing */
        animation: fadeInUp 0.4s cubic-bezier(0.4, 0.0, 0.2, 1) both;
    }
    
    .modal-close {
        position: absolute;
        top: 12px;
        right: 18px;
        font-size: 28px;
        font-weight: 400;
        cursor: pointer;
        color: #aaa;
        transition: color 0.2s ease;
    }
    
    .modal-close:hover { 
        color: var(--color-primary-dark, #003366); 
    }
    
    .modal-close:focus-visible {
        outline: 2px solid var(--color-brand-blue, #3272BB);
        border-radius: 4px;
    }
    
    .modal-box p {
        font-size: 16px;
        color: var(--color-primary-dark, #003366);
        margin: 20px 0;
        line-height: 1.6;
        font-weight: 400;
    }
    
    .modal-ok-btn {
        background-color: var(--color-brand-blue, #3272BB);
        color: white;
        border: none;
        padding: 10px 30px;
        border-radius: var(--radius-sm, 6px);
        font-size: 16px;
        font-weight: 500;
        cursor: pointer;
        margin-top: 10px;
        transition: var(--transition-smooth, all 0.3s ease);
    }
    
    .modal-ok-btn:hover {
        background-color: var(--color-primary-dark, #003366);
    }
    
    .modal-ok-btn:focus-visible {
        outline: 2px solid var(--color-primary-dark, #003366);
        outline-offset: 3px;
    }

    /* Modal Animation Keyframe System */
    @keyframes fadeInUp {
        from { 
            opacity: 0; 
            transform: translateY(12px) scale(0.98); 
        }
        to   { 
            opacity: 1; 
            transform: translateY(0) scale(1); 
        }
    }
</style>
</head>
<body>
<%
    String currentRole = (String) session.getAttribute("position");
    String employeeName = (String) session.getAttribute("loggedInEmpName");

    if (currentRole == null || employeeName == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

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
%>
<%
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

<div id="main">
    
    <div class="sticky-bar">
        <i id="menuBtn" class="fa-solid fa-bars" onclick="toggleNav()"></i>
        <img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF Logo">
        <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo">
        
        <div class="user-info">
            <i class="fa var(--color-primary-dark) fa-circle-user"></i>
            <p>
                ${sessionScope.loggedInEmpName} | ID: ${sessionScope.loggedInEmpId} | POS: ${sessionScope.position}
            </p>
        </div>
        <div class="contact-info">
            <i class="fa-solid fa-circle-info"></i>
            <p>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
        </div>
        
    </div>

    <div class="index-banner">
        <h1>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</h1>
        <h2>ใบขอให้ดำเนินการ / Requisition Form</h2>
        <p class="subline">เลือกเมนูหลักเพื่อสร้างคำขอใหม่ หรือติดตามรายการที่ส่งเข้าสู่ระบบแล้ว</p>
    </div>

    <main class="index-content">
        <div class="main-actions">
            <a href="${pageContext.request.contextPath}/newForm" class="action-card primary">
                <div>
                    <div class="action-top">
                        <div class="action-icon"><i class="fa-solid fa-plus"></i></div>
                        <h3>สร้างฟอร์มใหม่</h3>
                    </div>
                    <p>เปิดใบคำขอใหม่ ระบุรายละเอียดงาน แนบรายการ และส่งเข้าสู่กระบวนการอนุมัติ</p>
                </div>
                <div class="action-footer">เริ่มสร้างคำขอ <i class="fa-solid fa-arrow-right"></i></div>
            </a>

            <a href="${pageContext.request.contextPath}/submit" class="action-card">
                <div>
                    <div class="action-top">
                        <div class="action-icon"><i class="fa-solid fa-paper-plane"></i></div>
                        <h3>ฟอร์มที่ส่งแล้ว</h3>
                    </div>
                    <p>ตรวจสอบสถานะ ติดตาม deadline และเปิดดูรายละเอียดของคำขอที่เคยส่งไว้</p>
                </div>
                <div class="action-footer">ดูรายการของฉัน <i class="fa-solid fa-arrow-right"></i></div>
            </a>
        </div>
        
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