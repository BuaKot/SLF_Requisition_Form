<!-- ================================================================= ==
     SLF Requisition Form - Landing Page (index.jsp)
     ================================================================

     This is the main landing/dashboard page for the Student Loan Fund
     (SLF) IT Department's "Requisition Form" system. It serves as a central
     hub where users can either create new requisition forms or view their
     submitted/reviewed forms.

     Architecture: JSP with JavaServer Pages, embedded CSS stylesheets,
     and client-side JavaScript for interactivity. Uses EL expressions for
     session data rendering.

     =================================================================== -->
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
<!-- ================================================================= ==
     EMBEDDED CSS STYLESHEET - Modal and Layout Components
     =========================================================

     This inline style block defines the visual styling for key UI components:

     MODAL OVERLAY (lines 26-37):
       - Full-screen backdrop with semi-transparent dark background (#000/50)
       - Flexbox centering to position modal in viewport middle
       - z-index: 2000 ensures it sits above other UI elements

     MODAL BOX (lines 38-49):
       - White card with rounded corners, padding for comfortable spacing
       - Max-width 480px prevents excessive width on large screens
       - Sarabun font family for Thai text readability
       - fadeIn animation: subtle slide-up entry effect

     MODAL CLOSE BUTTON (lines 50-61):
       - Absolute positioned top-right corner with × symbol
       - Hover color change improves UX feedback

     MODAL CONTENT STYLING (lines 60-78):
       - Paragraph text in #003366 brand color for consistency
       - OK button uses primary blue (#3272BB) with hover state to #003366

     INDEX BANNER (lines 84-113):
       - Gradient background: light cyan (#c8ecff → #eaf7ff)
       - Bottom border in brand color for visual separation
       - Responsive typography using clamp() for fluid scaling on all devices
       - Subline text constrained to max-width for readability

     MAIN CONTENT AREA (lines 115-120):
       - Centered container with max-width: 1050px
       - Generous padding for breathing room around content

     ACTION CARDS GRID (lines 121-134, lines 221-234 media query):
       - CSS Grid layout with 2 columns on desktop, single column on mobile (<760px)
       - Cards have min-height: 270px for consistent visual weight
       - Border and shadow effects create depth; hover state lifts card up

     ACTION CARD COMPONENT (lines 135-204):
       - Flexbox layout with icon + title in top section, footer at bottom
       - Primary variant uses dark background (#003366) for emphasis
       - Hover states: transform translateY(-5px), border color change

     SUPPORT STRIP (lines 205-219):
       - Bottom informational bar with contact details
       - Same styling as cards but without hover effects

     =================================================================== -->
    <style>    .modal-box {
        background: white;
        border-radius: 12px;
        padding: 30px 40px;
        max-width: 480px;
        width: 90%;
        box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        position: relative;
        text-align: center;
        font-family: 'Sarabun', sans-serif;
        animation: fadeIn 0.3s ease;
    }
    .modal-close {
        position: absolute;
        top: 10px;
        right: 15px;
        font-size: 28px;
        font-weight: bold;
        cursor: pointer;
        color: #aaa;
    }
    .modal-close:hover { color: #333; }
    .modal-box p {
        font-size: 16px;
        color: #003366;
        margin: 20px 0;
        line-height: 1.6;
    }
    .modal-ok-btn {
        background-color: #3272BB;
        color: white;
        border: none;
        padding: 10px 30px;
        border-radius: 6px;
        font-size: 16px;
        cursor: pointer;
        margin-top: 10px;
    }
    .modal-ok-btn:hover {
        background-color: #003366;
    }
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(-20px); }
        to   { opacity: 1; transform: translateY(0); }
    }

    .index-banner {
        background: linear-gradient(135deg, #c8ecff 0%, #eaf7ff 100%);
        border-bottom: 5px solid #3272BB;
        padding: 42px 20px 36px;
        text-align: center;
        color: #003366;
    }

    .index-banner h1 {
        margin: 0;
        font-size: clamp(28px, 4.5vw, 42px);
        line-height: 1.15;
        font-weight: 800;
    }

    .index-banner h2 {
        margin: 8px 0 0;
        color: #003366;
        font-size: clamp(20px, 3vw, 30px);
        line-height: 1.2;
        font-weight: 800;
    }

    .index-banner .subline {
        margin: 12px auto 0;
        max-width: 760px;
        color: #385a78;
        font-size: 18px;
        font-weight: 700;
    }

    .index-content {
        max-width: 1050px;
        margin: 0 auto;
        padding: 48px 24px 56px;
    }

    .main-actions {
        display: grid;
        grid-template-columns: repeat(2, minmax(260px, 1fr));
        gap: 28px;
    }

    .action-card {
        min-height: 270px;
        background: #ffffff;
        border: 2px solid #d2e5f6;
        border-radius: 16px;
        padding: 30px;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        text-decoration: none;
        color: #003366;
        box-shadow: 0 12px 28px rgba(0, 51, 102, 0.08);
        transition: transform 0.2s ease, border-color 0.2s ease, box-shadow 0.2s ease;
    }

    .action-card:hover {
        transform: translateY(-5px);
        border-color: #3272BB;
        box-shadow: 0 18px 36px rgba(50, 114, 187, 0.16);
    }

    .action-top {
        display: flex;
        align-items: center;
        gap: 18px;
    }

    .action-icon {
        width: 76px;
        height: 76px;
        border-radius: 18px;
        display: grid;
        place-items: center;
        background: #e8f2fb;
        color: #3272BB;
        font-size: 34px;
        flex: 0 0 auto;
    }

    .action-card.primary {
        background: #003366;
        color: #ffffff;
        border-color: #003366;
    }

    .action-card.primary .action-icon {
        background: rgba(255, 255, 255, 0.16);
        color: #ffffff;
    }

    .action-card h3 {
        margin: 0;
        font-size: 28px;
        line-height: 1.1;
        font-weight: 800;
    }

    .action-card p {
        margin: 18px 0 0;
        color: #60758a;
        font-size: 17px;
        line-height: 1.55;
        font-weight: 700;
    }

    .action-card.primary p {
        color: rgba(255, 255, 255, 0.82);
    }

    .action-footer {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        margin-top: 24px;
        font-size: 17px;
        font-weight: 800;
    }

    .support-strip {
        margin-top: 24px;
        background: #ffffff;
        border: 1px solid #d9e6f2;
        border-radius: 12px;
        padding: 16px 20px;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 10px;
        color: #003366;
        font-size: 17px;
        font-weight: 800;
        box-shadow: 0 8px 20px rgba(0, 51, 102, 0.05);
    }

    @media (max-width: 760px) {
        .main-actions {
            grid-template-columns: 1fr;
        }

        .index-content {
            padding: 34px 16px 42px;
        }

        .action-card {
            min-height: 230px;
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
    // Optional: automatically close if they click the overlay background
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
            <i class="fa fa-circle-user"></i>
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