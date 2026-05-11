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
  <a href="#">Home</a>
  <a href="#">Services</a>
  <a href="#">Contact</a>
  <a href='#' class='admin-tab'><i class='fa fa-circle-user' style='font-size:36px;padding-left:0px;padding-right:25%'></i>Admin</a>
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

<!-- Form section1 -->
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
<!-- Form section2 -->
<div class="request-page">

    <div class="request-header-box">
        <div class="request-header-left">
            <div class="request-title-row">
                <label for="requestTitle">ชื่อความต้องการ :</label>
                <input type="text" id="requestTitle" name="requestTitle">
            </div>

            <div class="request-date-row">
                <span>ภายในวันที่ :</span>
                <span>8/9/2569 ( x วัน )</span>
            </div>
        </div>

        <div class="request-header-icons">
            <i class="fa-regular fa-trash-can delete-icon"></i>
            <i class="fa-solid fa-expand expand-icon"></i>
        </div>
    </div>

    <div class="request-detail-box">

        <div class="request-grid">

            <div class="request-inline-group">
                <label for="requestType">ประเภทคำขอ</label>
                <select id="requestType" name="requestType" class="select-placeholder">
                    <option value="" disabled selected hidden>Please select</option>
                    <option value="ขอติดตั้งโปรแกรม">ขอติดตั้งโปรแกรม</option>
                    <option value="ขอสิทธิ์ใช้อินเตอร์เน็ต">ขอสิทธิ์ใช้อินเตอร์เน็ต</option>
                    <option value="ขอใช้สิทธิ์เก็บข้อมูล">ขอใช้สิทธิ์เก็บข้อมูล</option>
                    <option value="ขอเปลี่ยน Password">ขอเปลี่ยน Password</option>
                    <option value="แจ้งปัญหาการใช้งาน">แจ้งปัญหาการใช้งาน</option>
                    <option value="ขอให้พัฒนาโปรแกรม">ขอให้พัฒนาโปรแกรม</option>
                    <option value="ขอให้จัดหลักสูตร">ขอให้จัดหลักสูตร</option>
                    <option value="ขอยืมอุปกรณ์ไอที">ขอยืมอุปกรณ์ไอที</option>
                    <option value="อื่น ๆ">อื่น ๆ</option>
                </select>
            </div>

            <div class="request-inline-group">
                <label for="programName">ชื่อโปรแกรม :</label>
                <input type="text" id="programName" name="programName">
            </div>

            <div class="request-empty-space"></div>

            <div class="request-inline-group">
                <label for="requestDate">ภายในวันที่ :</label>
                <input type="text" id="requestDate" name="requestDate">
            </div>

        </div>

        <div class="request-full-width">
            <label for="objective">วัตถุประสงค์ / ความต้องการ</label>
            <textarea 
                id="objective" 
                name="objective" 
                placeholder="โปรดระบุความต้องการ"
            ></textarea>
        </div>

        <div class="request-full-width">
            <label for="currentMethod">วิธีการเดิมในปัจจุบัน</label>
            <textarea 
                id="currentMethod" 
                name="currentMethod" 
                placeholder="โปรดระบุวิธีการเดิมในปัจจุบัน"
            ></textarea>
        </div>

        <div class="request-save-actions">
            <button type="button" class="btn-cancel-small">Cancel</button>
            <button type="button" class="btn-save-small">Save</button>
        </div>

    </div>

    <div class="add-request-wrap">
        <button type="button" class="add-request-btn">
            <i class="fa-solid fa-plus"></i>
            เพิ่มความต้องการ
        </button>
    </div>

</div>

<div class="bottom-form-actions">
    <a href="${pageContext.request.contextPath}/form.jsp" class="btn-secondary">Cancel</a>
    <button type="submit" class="btn-primary">Continue</button>
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