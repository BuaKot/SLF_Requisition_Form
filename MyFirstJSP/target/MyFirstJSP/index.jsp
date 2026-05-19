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
    .modal-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.5);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 2000;  /* higher than the sidebar (1001) */
    }
    .modal-box {
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
</style>
</head>
<body>
<%
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

<div id="mySidebar" class="sidebar">
    <a href="javascript:void(0)" class="closebtn" onclick="toggleNav()">&times;</a>
    <a href="${pageContext.request.contextPath}">หน้าหลัก</a>
    <a href="${pageContext.request.contextPath}/submit.jsp">ฟอร์มที่ส่งแล้ว</a>
    <a href="${pageContext.request.contextPath}/newForm">สร้างฟอร์มใหม่</a>
    <a href="${pageContext.request.contextPath}/Admin.jsp" class="admin-tab">
        <i class="fa-solid fa-circle-user"></i>Admin
    </a>
</div>

<div id="main">
    
    <div class="sticky-bar">
        <i id="menuBtn" class="fa-solid fa-bars" onclick="toggleNav()"></i>
        <img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF Logo">
        <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo">
        
        <div class="contact-info">
            <i class="fa-solid fa-circle-info"></i>
            <p>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
        </div>
    </div>

    <div class="blue-title">
        <h1>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</h1>
        <h2>ใบขอให้ดำเนินการ / Requisition Form</h2>
    </div>

    <div class="options-div">
        
        <a href="${pageContext.request.contextPath}/newForm" class="option-box option-box-link">
            <div class="option-pic">
                <i class="fa-solid fa-plus"></i>
            </div>
            <h1>สร้างฟอร์มใหม่</h1>
        </a>

        <a href="${pageContext.request.contextPath}/submit.jsp" class="option-box option-box-link">
            <div class="option-pic">
                <i class="fa-solid fa-paper-plane"></i>
            </div>
            <h1>ฟอร์มที่ส่งแล้ว</h1>
        </a>

    </div>

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