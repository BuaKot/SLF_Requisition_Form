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

            </form>
        </div>
    </div>
<!-- Form section2 -->
<div class="request-page">

    <div id="requestsContainer">

        <div class="request-item">

    <div class="request-header-box">

    <div class="request-header-left">
        <div class="request-title-row">
            <label>ชื่อความต้องการ :</label>
            <input type="text" name="requestTitle">
            <button type="button" class="request-delete-btn" disabled>
            <i class="fa-regular fa-trash-can"></i>
        </button>
        </div>

        <div class="request-date-row">
            <label>ภายในวันที่ :</label>
            <input type="date" name="dueDate">
            <button type="button" class="request-zoom-btn">
                <i class="fa-solid fa-expand expand-icon"></i>
            </button>
            
        </div>
        <div class="request-empty-space"></div>
    </div>


</div>

    <div class="request-grid">

        <div class="request-inline-group">
            <label>ประเภทคำขอ</label>
            <select name="requestType" class="select-placeholder request-type-select">
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

        <div class="request-inline-group program-name-box">
            <label>ชื่อโปรแกรม :</label>
            <input type="text" name="programName">
        </div>

        <div class="request-empty-space"></div>

    </div>

    <div class="request-full-width other-request-box">
        <label>โปรดระบุ</label>
        <input 
            type="text" 
            name="otherRequest"
            placeholder="โปรดระบุประเภทคำขอ"
        >
    </div>

    <div class="server-permission-box">

        <h3 class="server-permission-title">กรณีขอใช้สิทธิ์เก็บข้อมูลใน Server</h3>

        <div class="server-input-row">
            <input 
                type="text" 
                name="serverName"
                placeholder="โปรดระบุ Server"
            >
        </div>

        <div class="server-input-row">
            <label>Folder :</label>
            <input 
                type="text" 
                name="serverFolder"
                placeholder="โปรดระบุ Folder"
            >
        </div>

        <div class="permission-checkbox-row">
            <label>
                <input type="checkbox" name="folderPermission" value="Full control">
                Full control
            </label>

            <label>
                <input type="checkbox" name="folderPermission" value="Modify">
                Modify
            </label>

            <label>
                <input type="checkbox" name="folderPermission" value="Read & Execute">
                Read & Execute
            </label>

            <label>
                <input type="checkbox" name="folderPermission" value="Read">
                Read
            </label>

            <label>
                <input type="checkbox" name="folderPermission" value="Write">
                Write
            </label>
        </div>

        <div class="server-input-row sub-folder-row">
            <label>Sub Folder :</label>
            <input 
                type="text" 
                name="subFolder"
                placeholder="โปรดระบุ Sub Folder"
            >
        </div>

        <div class="permission-checkbox-row">
            <label>
                <input type="checkbox" name="subFolderPermission" value="Full control">
                Full control
            </label>

            <label>
                <input type="checkbox" name="subFolderPermission" value="Modify">
                Modify
            </label>

            <label>
                <input type="checkbox" name="subFolderPermission" value="Read & Execute">
                Read & Execute
            </label>

            <label>
                <input type="checkbox" name="subFolderPermission" value="Read">
                Read
            </label>

            <label>
                <input type="checkbox" name="subFolderPermission" value="Write">
                Write
            </label>
        </div>

    </div>

    <div class="request-full-width">
        <label>วัตถุประสงค์ / ความต้องการ</label>
        <textarea 
            name="objective" 
            placeholder="โปรดระบุความต้องการ"
        ></textarea>
    </div>

    <div class="request-full-width">
        <label>วิธีการเดิมในปัจจุบัน</label>
        <textarea 
            name="currentMethod" 
            placeholder="โปรดระบุวิธีการเดิมในปัจจุบัน"
        ></textarea>
    </div>

</div>

    </div>

    <div class="add-request-wrap">
        <button type="button" class="add-request-btn" id="addRequestBtn">
            <i class="fa-solid fa-plus"></i>
            เพิ่มความต้องการ
        </button>
    </div>

</div>

<div class="bottom-form-actions">
    <a href="${pageContext.request.contextPath}/index.jsp" class="btn-secondary">ย้อนกลับ</a>
    <button type="submit" class="btn-primary">ยืนยันการส่ง</button>
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

window.addEventListener("load", function () {
    setTodayDate();
    initPlaceholderSelects();
    initAllRequestTypeDisplays();
    updateDeleteButtons();
});

function setTodayDate() {
    const today = new Date();
    const yyyy = today.getFullYear();
    const mm = String(today.getMonth() + 1).padStart(2, "0");
    const dd = String(today.getDate()).padStart(2, "0");
    const todayFormatted = yyyy + "-" + mm + "-" + dd;

    const dateInput = document.getElementById("date");
    if (dateInput) {
        dateInput.value = todayFormatted;
    }
}

/* ทำให้ select เป็นสีเทาตอน placeholder และเป็นสีดำตอนเลือกแล้ว */
function initPlaceholderSelects() {
    document.querySelectorAll(".select-placeholder").forEach(function (select) {
        updateSelectColor(select);

        select.addEventListener("change", function () {
            updateSelectColor(this);
        });
    });
}

function updateSelectColor(select) {
    select.style.color = select.value === "" ? "#777" : "black";
}

/* อัปเดตถังขยะ: มี 1 กล่อง = กดไม่ได้, มากกว่า 1 = กดได้ */
function updateDeleteButtons() {
    const requestItems = document.querySelectorAll(".request-item");
    const deleteButtons = document.querySelectorAll(".request-delete-btn");

    deleteButtons.forEach(function (button) {
        button.disabled = requestItems.length <= 1;
    });
}

/* เคลียร์ข้อมูลในกล่องที่ clone มาใหม่ */
function resetRequestItem(item) {
    item.querySelectorAll("input").forEach(function (input) {
        if (input.type === "checkbox") {
            input.checked = false;
        } else {
            input.value = "";
        }

        input.required = false;
    });

    item.querySelectorAll("textarea").forEach(function (textarea) {
        textarea.value = "";
    });

    item.querySelectorAll("select").forEach(function (select) {
        select.selectedIndex = 0;
        updateSelectColor(select);
    });

    item.querySelectorAll(".other-request-box").forEach(function (box) {
        box.style.display = "none";
    });

    item.querySelectorAll(".server-permission-box").forEach(function (box) {
        box.style.display = "none";
    });
    item.querySelectorAll(".program-name-box").forEach(function (box) {
    box.style.display = "none";
});
}

/* ตอนโหลดหน้า ให้เช็ก dropdown ประเภทคำขอทุกกล่อง */
function initAllRequestTypeDisplays() {
    document.querySelectorAll(".request-item").forEach(function (item) {
        const select = item.querySelector('select[name="requestType"]');

        if (select) {
            handleRequestTypeChange(select);
        }
    });
}

/* จัดการ dropdown ประเภทคำขอ */
function handleRequestTypeChange(select) {
    const item = select.closest(".request-item");
    if (!item) return;

    const otherRequestBox = item.querySelector(".other-request-box");
    const otherRequestInput = item.querySelector('input[name="otherRequest"]');

    const serverPermissionBox = item.querySelector(".server-permission-box");
    const serverNameInput = item.querySelector('input[name="serverName"]');
    const serverFolderInput = item.querySelector('input[name="serverFolder"]');
    const subFolderInput = item.querySelector('input[name="subFolder"]');

    const programNameBox = item.querySelector(".program-name-box");
    const programNameInput = item.querySelector('input[name="programName"]');

    updateSelectColor(select);

    if (programNameBox && programNameInput) {
        if (
            select.value === "ขอติดตั้งโปรแกรม" ||
            select.value === "ขอให้พัฒนาโปรแกรม"
        ) {
            programNameBox.style.display = "flex";
            programNameInput.required = true;
        } else {
            programNameBox.style.display = "none";
            programNameInput.required = false;
            programNameInput.value = "";
        }
    }

    if (otherRequestBox && otherRequestInput) {
        if (select.value === "อื่น ๆ") {
            otherRequestBox.style.display = "block";
            otherRequestInput.required = true;
        } else {
            otherRequestBox.style.display = "none";
            otherRequestInput.required = false;
            otherRequestInput.value = "";
        }
    }

    if (serverPermissionBox && serverNameInput && serverFolderInput && subFolderInput) {
        if (select.value === "ขอใช้สิทธิ์เก็บข้อมูล") {
            serverPermissionBox.style.display = "block";
            serverNameInput.required = true;
            serverFolderInput.required = true;
        } else {
            serverPermissionBox.style.display = "none";

            serverNameInput.required = false;
            serverFolderInput.required = false;
            subFolderInput.required = false;

            serverNameInput.value = "";
            serverFolderInput.value = "";
            subFolderInput.value = "";

            item.querySelectorAll('input[name="folderPermission"]').forEach(function (checkbox) {
                checkbox.checked = false;
            });

            item.querySelectorAll('input[name="subFolderPermission"]').forEach(function (checkbox) {
                checkbox.checked = false;
            });
        }
    }
}

const addRequestBtn = document.getElementById("addRequestBtn");
const requestsContainer = document.getElementById("requestsContainer");

/* เพิ่มกล่องความต้องการ */
if (addRequestBtn && requestsContainer) {
    addRequestBtn.addEventListener("click", function () {
        const firstItem = document.querySelector(".request-item");

        if (!firstItem) return;

        const newItem = firstItem.cloneNode(true);

        resetRequestItem(newItem);

        requestsContainer.appendChild(newItem);
        updateDeleteButtons();
    });

    /* ลบกล่องความต้องการ */
    requestsContainer.addEventListener("click", function (event) {
        const deleteButton = event.target.closest(".request-delete-btn");

        if (!deleteButton) return;
        if (deleteButton.disabled) return;

        const requestItems = document.querySelectorAll(".request-item");

        if (requestItems.length <= 1) return;

        const item = deleteButton.closest(".request-item");

        if (item) {
            item.remove();
        }

        updateDeleteButtons();
    });

    /* จัดการ select ภายใน request-item */
    requestsContainer.addEventListener("change", function (event) {
        if (event.target.matches('select[name="requestType"]')) {
            handleRequestTypeChange(event.target);
        }

        if (event.target.classList.contains("select-placeholder")) {
            updateSelectColor(event.target);
        }
    });
}
</script>
</html>