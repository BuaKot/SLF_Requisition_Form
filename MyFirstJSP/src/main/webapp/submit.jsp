<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Submit Requisition Form</title>
    <!-- Flaticon -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flaticon@3/flaticon.css">
    <!-- Base CSS (from index) -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <!-- Submit CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/submit.css">
    <link rel='stylesheet' href='https://cdn-uicons.flaticon.com/4.0.0/uicons-regular-rounded/css/uicons-regular-rounded.css'>
    <link rel='stylesheet' href='https://cdn-uicons.flaticon.com/4.0.0/uicons-regular-rounded/css/uicons-regular-rounded.css'>
    <link rel='stylesheet' href='https://cdn-uicons.flaticon.com/4.0.0/uicons-bold-straight/css/uicons-bold-straight.css'>
    <link rel='stylesheet' href='https://cdn-uicons.flaticon.com/4.0.0/uicons-regular-straight/css/uicons-regular-straight.css'>
    <link rel='stylesheet' href='https://cdn-uicons.flaticon.com/4.0.0/uicons-solid-rounded/css/uicons-solid-rounded.css'>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel='stylesheet' href='https://cdn-uicons.flaticon.com/4.0.0/uicons-solid-rounded/css/uicons-solid-rounded.css'>
</head>

<!-- The Sidebar -->
<div id="mySidebar" class="sidebar">
  <a href="javascript:void(0)" class="closebtn" onclick="toggleNav()">&times;</a>
  <a href="#">Home</a>
  <a href="#">Services</a>
  <a href="#">Contact</a>
  <a href='#' class='admin-tab'><i class='fa fa-circle-user' style='font-size:36px;padding-left:0px;padding-right:25%'></i>Admin</a>
</div>

<div id='main'>
<!-- Sticky Bar (Header) -->
<div class='sticky-bar'>
    <i id="menuBtn" class="fa fa-bars" onclick="toggleNav()" style="font-size:36px; cursor:pointer; padding-left:5px; padding-right:5px;"></i>
    <img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF Logo" style="height: 48px; padding-left: 10px; padding-right: 5px">
    <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo" style="height: 48px; padding-left: 5px; padding-right: 5px">
    <div style="margin-left:auto;display:flex;align-items:center">
        <i class='fa fa-circle-user' style='font-size:24px;padding-left:10px;padding-right:0px'></i>
        <p style='margin-left: 5px;margin-right: 15px'>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
    </div>
</div>

<div class ='blue-title'>
    <h1 style='margin-block-start: 0.1em; margin-block-end: 0.1em;'>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินกู้ยืมเพื่อการศึกษา</h1>
    <h2 style='margin-block-start: 0.1em; margin-block-end: 0.1em;'>ใบขอให้ดำเนินการ / Requisition Form</h2>
</div>

    <!-- Progress Header -->
    <section class="progress-header">
    <div class="header-item">
        <i class="fi fi-rr-form"></i>
        <span>จำนวนใบขอให้ดำเนินการทั้งหมด</span>
    </div>

    <div class="header-item">
        <i class="fi fi-bs-user"></i>
        <span>ผู้อำนวยการฝ่าย</span>
    </div>

    <div class="header-item">
        <i class="fi fi-rr-it-alt"></i>
        <span>ความเห็นและการอนุมัติเชิงเทคนิค</span>
    </div>

    <div class="header-item">
        <i class="fi fi-bs-user"></i>
        <span>ผู้อำนวยการฝ่าย</span>
    </div>

    <div class="header-item">
        <i class="fa-solid fa-gears"></i>
        <span>ขั้นตอนการดำเนินการ</span>
    </div>

    <div class="header-item">
        <i class="fi fi-rr-confirmed-user"></i>
        <span>ผลตรวจรับ</span>
    </div>
</section>

    <!-- Request Table -->
    <section class="request-list">

    <%
        String[][] statusData = {
    {"green","green","yellow","yellow"},
    {"green","green","green","green"},
    {"yellow","yellow","yellow","yellow"},
    {"green","yellow","yellow","yellow"},
    {"yellow","yellow","yellow","yellow"}
};

        for(int i = 0; i < statusData.length; i++) {
    %>

    <div class="request-row">

    <!-- 1) Request Button -->
    <div class="request-col">
        <button class="request-btn">
            ใบขอดำเนินการที่ <%= i + 1 %>
        </button>
    </div>

    <!-- 2) Director 1 -->
    <div class="status-col">
        <i class="<%= statusData[i][0].equals("green") 
            ? "fi fi-sr-user-trust status-green" 
            : "fi fi-sr-pending status-yellow" %>"></i>
    </div>

    <!-- 3) Technical -->
    <div class="status-col">
        <i class="<%= statusData[i][1].equals("green") 
            ? "fi fi-sr-user-trust status-green" 
            : "fi fi-sr-pending status-yellow" %>"></i>
    </div>

    <!-- 4) Director 2 -->
    <div class="status-col">
        <i class="<%= statusData[i][2].equals("green") 
            ? "fi fi-sr-user-trust status-green" 
            : "fi fi-sr-pending status-yellow" %>"></i>
    </div>

    <!-- 5) Process Step -->
    <div class="status-col">
        <i class="<%= statusData[i][3].equals("green") 
            ? "fi fi-sr-user-trust status-green" 
            : "fi fi-sr-pending status-yellow" %>"></i>
    </div>

    <!-- 6) Confirm -->
    <div class="confirm-col">
        <button class="confirm-btn">ยืนยันผล</button>
    </div>

</div>

    <% } %>

</section>


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


<!-- Confirm Popup -->
<div id="confirmPopup" class="popup-overlay">
    <div class="popup-box">
        <h3>ยืนยันผล</h3>
        <p>กรุณาระบุรายละเอียดก่อนยืนยันผลรายการนี้</p>

        <!-- ช่องกรอกรายละเอียด -->
        <textarea 
            id="popupDetail" 
            class="popup-textarea" 
            placeholder="กรอกรายละเอียด / หมายเหตุ..."
        ></textarea>

        <div class="popup-buttons">
            <button id="popupConfirm" class="popup-confirm-btn">ยืนยัน</button>
            <button onclick="closePopup()" class="popup-cancel-btn">ยกเลิก</button>
        </div>
    </div>
</div>

<script>
let currentButton = null;

/* Sidebar */
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

/* โหลดหน้า */
document.addEventListener("DOMContentLoaded", function () {

    /* ปุ่มยืนยันผล */
    document.querySelectorAll(".confirm-btn").forEach(button => {
        button.addEventListener("click", function () {

            if (this.classList.contains("confirmed")) return;

            let requestRow = this.closest(".request-row");
            let allApproved = true;

            requestRow.querySelectorAll(".status-col i").forEach(statusIcon => {
                if (!statusIcon.classList.contains("fi-sr-user-trust")) {
                    allApproved = false;
                }
            });

            if (!allApproved) {
                alert("ยังไม่สามารถยืนยันผลได้ เนื่องจากยังมีบางขั้นตอนดำเนินการไม่เสร็จ");
                return;
            }

            currentButton = this;
            document.getElementById("confirmPopup").style.display = "flex";

            setTimeout(() => {
                document.getElementById("popupDetail").focus();
            }, 100);
        });
    });

    /* ปุ่มยืนยันใน popup */
    document.getElementById("popupConfirm").addEventListener("click", function (event) {
        event.preventDefault();

        let detailBox = document.getElementById("popupDetail");
        let detail = detailBox.value.trim();

        if (detail === "") {
            alert("กรุณากรอกรายละเอียดก่อนยืนยันผล");
            detailBox.focus();
            return;
        }

        if (currentButton) {
            currentButton.innerText = "ยืนยันแล้ว";
            currentButton.classList.add("confirmed");
            currentButton.disabled = true;
            currentButton.style.cursor = "not-allowed";
            currentButton.setAttribute("data-detail", detail);
            currentButton.style.background = '#45a049'
            currentButton.style.color = 'white'
        }

        closePopup();
    });

});

/* ปิด popup */
function closePopup() {
    document.getElementById("confirmPopup").style.display = "none";

    let detailBox = document.getElementById("popupDetail");
    if (detailBox) {
        detailBox.value = "";
    }
}
</script>
</html>