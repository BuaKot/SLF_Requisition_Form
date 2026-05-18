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
</head>
<body>

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