<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>form</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/form.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>

<!-- The Sidebar -->
<div id="mySidebar" class="sidebar">
  <a href="javascript:void(0)" class="closebtn" onclick="toggleNav()">&times;</a>
  <a href="${pageContext.request.contextPath}" style='font-size:20px'>Home</a>
  <a href="${pageContext.request.contextPath}/submit.jsp" style='font-size:20px'>Submitted Forms</a>
  <a href="${pageContext.request.contextPath}/form.jsp" style='font-size:20px'>New Form</a>
  <a href='${pageContext.request.contextPath}/Admin.jsp' class='admin-tab'><i class='fa fa-circle-user' style='font-size:36px;padding-left:0px;padding-right:25%'></i>Admin</a>
</div>

<div id=main>
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

<!-- Form section -->
    <div class="form-page">
        <div class="form-card">
            <h3 class="form-title">แบบฟอร์มบันทึกข้อมูล</h3>

            <form action="${pageContext.request.contextPath}/form2.jsp" method="post">
                <div class="form-grid">

                    <div class="form-group">
                        <label for="name">ชื่อ-นามสกุล <span class="required-star">*</span></label>
                        <input 
                            type="text" 
                            id="name" 
                            name="name"
                            required
                        >
                    </div>

                    <div class="form-group">
                        <label for="section">ส่วน</label>
                        <select id="section" name="section">
                            <option value="">ไม่ระบุ</option>
                            <option value="ส่วน 1">ส่วน 1</option>
                            <option value="ส่วน 2">ส่วน 2</option>
                            <option value="ส่วน 3">ส่วน 3</option>
                            <option value="ส่วน 4">ส่วน 4</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="department">ฝ่าย <span class="required-star">*</span></label>
                        <select id="department" name="department" class="select-placeholder" required>
                            <option value="" disabled selected hidden>โปรดเลือกฝ่าย</option>
                            <option value="กู้ยืม">กู้ยืม</option>
                            <option value="บริหารหนี้ 1">บริหารหนี้ 1</option>
                            <option value="บริหารหนี้ 2">บริหารหนี้ 2</option>
                            <option value="ทรัพยากรบุคคล">ทรัพยากรบุคคล</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="phone">เบอร์ต่อ <span class="required-star">*</span></label>
                        <input 
                            type="text" 
                            id="phone" 
                            name="phone"
                            inputmode="numeric"
                            pattern="[0-9]*"
                            oninput="this.value = this.value.replace(/[^0-9]/g, '')"
                            required
                        >
                    </div>

                    <div class="form-group">
                        <label for="date">วันที่</label>
                        <div class="input-icon">
                            <input type="date" id="date" name="date" readonly>
                            <i class="fa-regular fa-calendar"></i>
                        </div>
                    </div>

                </div>

                <div class="form-actions">
                    <button type="submit" class="btn-primary">ถัดไป</button>
                    <a href="${pageContext.request.contextPath}/index.jsp" class="btn-secondary">กลับหน้าแรก</a>
                </div>
            </form>
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

window.addEventListener("load", function () {
    const today = new Date();
    const yyyy = today.getFullYear();
    const mm = String(today.getMonth() + 1).padStart(2, '0');
    const dd = String(today.getDate()).padStart(2, '0');

    const todayFormatted = yyyy + '-' + mm + '-' + dd;
    document.getElementById("date").value = todayFormatted;
});

document.querySelectorAll(".select-placeholder").forEach(function(select) {
    select.addEventListener("change", function() {
        if (this.value === "") {
            this.style.color = "#777";
        } else {
            this.style.color = "black";
        }
    });
});
</script>
</html>