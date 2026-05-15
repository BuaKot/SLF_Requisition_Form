<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>

<!-- The Sidebar -->
<div id="mySidebar" class="sidebar">
  <a href="javascript:void(0)" class="closebtn" onclick="toggleNav()">&times;</a>
  <a href="${pageContext.request.contextPath}" style='font-size:20px'>หน้าหลัก</a>
  <a href="${pageContext.request.contextPath}/submit.jsp" style='font-size:20px'>ฟอร์มที่ส่งแล้ว</a>
  <a href="${pageContext.request.contextPath}/newForm" style='font-size:20px'>สร้างฟอร์มใหม่</a>
  <a href='${pageContext.request.contextPath}/Admin.jsp' class='admin-tab'><i class='fa fa-circle-user' style='font-size:36px;padding-left:0px;padding-right:25%'></i>Admin</a>
</div>

<div id='main'>
<div class='sticky-bar'>
    <i id="menuBtn" class="fa fa-bars" onclick="toggleNav()" style="font-size:36px; cursor:pointer; padding-left:5px; padding-right:5px;"></i>
    </i><img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF Logo" style="height: 48px; padding-left: 10px; padding-right: 5px">
    </i><img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo" style="height: 48px; padding-left: 5px; padding-right: 5px">
    <div class="contact-info" style="margin-left:auto; display:flex; align-items:center">
                    <i class='fa fa-circle-user' style='font-size:1.4rem; color:#333;'></i>
                    <p>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
    </div>
</div>


<div class ='blue-title'>
    <h1 style='margin-block-start: 0.1em; margin-block-end: 0.1em;color:#003366;'>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินกู้ยืมเพื่อการศึกษา</h1>
    <h2 style='margin-block-start: 0.1em; margin-block-end: 0.1em;color:#003366;'>ใบขอให้ดำเนินการ / Requisition Form</h2>
</div>


<div class="options-div">

    <a href="${pageContext.request.contextPath}/newForm" class="option-box option-box-link">
    <div class="option-pic">
        <i class="fa fa-plus" style ='color:#3272BB'></i>
    </div>
    <h1>สร้างฟอร์มใหม่</h1>
</a>
    <a href="${pageContext.request.contextPath}/submit.jsp" class="option-box option-box-link">
    
        <div class='option-pic'>
            <i class="fa fa-paper-plane" style ='color:#3272BB'></i>
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
    // Return to normal
    sidebar.style.width = "0";
    main.style.marginLeft = "0";
    main.style.width = "100%";
  } else {
    // Shrink the main area
    sidebar.style.width = "250px";
    main.style.marginLeft = "250px";
    // This is the magic line:
    main.style.width = "calc(100% - 250px)"; 
  }
}
</script>
</html>