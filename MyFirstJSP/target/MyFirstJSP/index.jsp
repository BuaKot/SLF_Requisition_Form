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
  <a href="#" style='font-size:20px'>ใบขอการดำเนินการ</a>
  <a href='#' class='admin-tab'><i class='fa fa-circle-user' style='font-size:36px;padding-left:0px;padding-right:25%'></i>Admin</a>
</div>

<div id='main'>
<div class='sticky-bar'>
    <i id="menuBtn" class="fa fa-bars" onclick="toggleNav()" style="font-size:36px; cursor:pointer; padding-left:5px; padding-right:5px;"></i>
    </i><img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF Logo" style="height: 48px; padding-left: 10px; padding-right: 5px">
    </i><img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo" style="height: 48px; padding-left: 5px; padding-right: 5px">
    <div style="margin-left:auto;display:flex;align-items:center">
        <i class='fa fa-circle-user' style='font-size:24px;padding-left:10px;padding-right:0px'></i>
        <p style='margin-left: 5px;margin-right: 15px'>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
    </div>
</div>


<div class ='blue-title'>
    <h1 style='margin-block-start: 0.1em; margin-block-end: 0.1em;'>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินกู้ยืมเพื่อการศึกษา</h1>
    <h2 style='margin-block-start: 0.1em; margin-block-end: 0.1em;'>ใบขอให้ดำเนินการ / Requisition Form</h2>
</div>


<div class="options-div">

    <a href="${pageContext.request.contextPath}/form.jsp" class="option-box option-box-link">
    <div class="option-pic">
        <i class="fa fa-plus"></i>
    </div>
    <h1>New Form</h1>
</a>

    <div class='option-box'>
        <div class='option-pic'>
            <i class="fa fa-paper-plane"></i>
        </div>
        <h1>Submit</h1>
    </div>

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