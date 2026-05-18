<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ใบขอให้ดำเนินการ</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/form.css">
    <!-- zennnne แก้ -->
    <style>
        .byte-counter { font-size: 0.75rem; color: #888; display: block; text-align: right; margin-top: 2px; width: 100%; order: 999; flex-basis: 100%; }
        .byte-counter.over-limit { color: #cc0000; font-weight: bold; }
        .input-over-limit { border-color: #cc0000 !important; outline: 1px solid #cc0000; }
    </style>
    <!-- zennnne แก้ -->

</head>

<body>

<!-- The Sidebar -->
<div id="mySidebar" class="sidebar">
  <a href="javascript:void(0)" class="closebtn" onclick="toggleNav()">&times;</a>
  <a href="${pageContext.request.contextPath}" style='font-size:20px'>หน้าหลัก</a>
  <a href="${pageContext.request.contextPath}/submit.jsp" style='font-size:20px'>ฟอร์มที่ส่งแล้ว</a>
  <a href="${pageContext.request.contextPath}/" style='font-size:20px'>สร้างฟอร์มใหม่</a>
  <a href='${pageContext.request.contextPath}/Admin.jsp' class='admin-tab'><i class='fa fa-circle-user' style='font-size:36px;padding-left:0px;padding-right:25%'></i>Admin</a>
</div>

<div id = 'main'>
<div class="sticky-bar">
    <i id="menuBtn" class="fa fa-bars" onclick="toggleNav()" style="font-size:36px; cursor:pointer; padding-left:5px; padding-right:5px;"></i>

    <img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF Logo" style="height: 48px; padding-left: 10px; padding-right: 5px">
    <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo" style="height: 48px; padding-left: 5px; padding-right: 5px">

    <div style="margin-left:auto;display:flex;align-items:center">
        <i class="fa fa-circle-user" style="font-size:24px;padding-left:10px;padding-right:0px"></i>
        <p style="font-size:0.8rem; margin-left: 10px;margin-right: 10px">สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
    </div>
</div>

<div class="banner">
    <h1>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</h1>
    <h2>ใบขอให้ดำเนินการ / Requisition Form</h2>
</div>

<div class="form-container">
    <form action="${pageContext.request.contextPath}/submitRequest" method="post">

        <div class="form-grid">

            <div class="form-group">
                <label for="name">ชื่อ-นามสกุล <span class="required-star">*</span></label>
                <input
                    type="text"
                    id="name"
                    name="name"
                    value="${loggedInEmployee.empName}"
                    readonly
                    required
                >
            </div>

            <div class="form-group">
                <label for="department">ฝ่าย <span class="required-star">*</span></label>
                <select id="department" name="department" class="select-placeholder" required>
                    <option value="" disabled selected hidden>โปรดเลือกฝ่าย</option>
                    <c:forEach var="dept" items="${departments}">
                        <option value="${dept.deptId}">${dept.deptName}</option>
                    </c:forEach>
                </select>
            </div>

            <div class="form-group">
                <label for="section">ส่วน</label>
                <select id="section" name="section">
                    <option value="">ไม่ระบุ</option>
                </select>
            </div>

            <div class="form-group">
                <label for="phone">เบอร์ต่อ <span class="required-star">*</span></label>
                <input type="text" id="phone" name="phone" value="${loggedInEmployee.phone}" readonly required>
            </div>

            <div class="form-group">
                <label for="date">วันที่ </label>
                <input type="date" id="date" name="date" readonly required>
            </div>

            <div class="form-group">
                <label for="deadline">Deadline <span class="required-star">*</span></label>
                <div class="input-icon">
                    <input type="date" id="deadline" name="deadline" required>
                    <i class="fa-regular fa-calendar"></i>
                </div>
            </div>

            <div class="form-group full-width">
                <label for="requestTopic">ชื่อหัวข้อความต้องการ :</label>
                <input
                    type="text"
                    id="requestTopic"
                    name="requestTopic"
                    value="ระบบลงทะเบียนขอผ่อนผันการชำระเงินกองทุน"
                    required
                    data-maxbytes="255"
                >
            </div>

            <div class="request-page full-width">
                <div id="requestsContainer">

                    <div class="request-item">

                        <div class="request-item-header">
                        <h2>คำขอที่ 1</h2>
                        <div style='margin-left:auto'>
                            <button type="button" class="request-delete-btn" disabled>
                                <i class="fa-regular fa-trash-can"></i>
                            </button>
                        </div>
                        </div>

                        <div class="form-group">
                            <label>ประเภทคำขอ<span class="required-star">*</span></label>
                            <select name="requestType[]" class="select-placeholder request-type-select" required>
                                <option value="" disabled selected hidden>Please select</option>
                                <c:forEach var="type" items="${requestTypes}">
                                    <option value="${type.typeId}">${type.typeName}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="form-group program-name-box">
                            <label>ชื่อโปรแกรม :<span class="required-star">*</span></label>
                            <input type="text" name="programName[]" required data-maxbytes="500">
                        </div>

                        <div class="form-group full-width server-permission-box">
                            <h3 class="server-permission-title">กรณีขอใช้สิทธิ์เก็บข้อมูลใน Server</h3>

                            <div class="server-input-row">
                                <input
                                    type="text"
                                    name="serverName[]"
                                    placeholder="โปรดระบุ Server"
                                    required
                                    data-maxbytes="500"
                                >
                            </div>

                            <div class="server-input-row">
                                <label>Folder :</label>
                                <input
                                    type="text"
                                    name="serverFolder[]"
                                    placeholder="โปรดระบุ Folder"
                                    data-maxbytes="500"
                                >
                            </div>

                            <div class="permission-checkbox-row">
                                <label>
                                    <input type="checkbox" name="folderPermission[]" value="Full control">
                                    Full control
                                </label>

                                <label>
                                    <input type="checkbox" name="folderPermission[]" value="Modify">
                                    Modify
                                </label>

                                <label>
                                    <input type="checkbox" name="folderPermission[]" value="Read & Execute">
                                    Read & Execute
                                </label>

                                <label>
                                    <input type="checkbox" name="folderPermission[]" value="Read">
                                    Read
                                </label>

                                <label>
                                    <input type="checkbox" name="folderPermission[]" value="Write">
                                    Write
                                </label>
                            </div>

                            <div class="server-input-row sub-folder-row">
                                <label>Sub Folder :</label>
                                <input
                                    type="text"
                                    name="subFolder[]"
                                    placeholder="โปรดระบุ Sub Folder"
                                    data-maxbytes="500"
                                >
                            </div>

                            <div class="permission-checkbox-row">
                                <label>
                                    <input type="checkbox" name="subFolderPermission[]" value="Full control">
                                    Full control
                                </label>

                                <label>
                                    <input type="checkbox" name="subFolderPermission[]" value="Modify">
                                    Modify
                                </label>

                                <label>
                                    <input type="checkbox" name="subFolderPermission[]" value="Read & Execute">
                                    Read & Execute
                                </label>

                                <label>
                                    <input type="checkbox" name="subFolderPermission[]" value="Read">
                                    Read
                                </label>

                                <label>
                                    <input type="checkbox" name="subFolderPermission[]" value="Write">
                                    Write
                                </label>
                            </div>
                        </div>

                        <div class="form-group full-width other-request-box">
                            <label>โปรดระบุ</label>
                            <input
                                type="text"
                                name="otherRequest[]"
                                placeholder="โปรดระบุประเภทคำขอ"
                                data-maxbytes="500"
                            >
                        </div>

                        <div class="form-group full-width">
                            <label>วัตถุประสงค์ / ความต้องการ <span class="required-star">*</span></label>
                            <textarea
                                name="objective[]"
                                placeholder="โปรดระบุความต้องการ"
                                required
                                data-maxbytes="1000"
                            ></textarea>
                        </div>

                        <div class="form-group full-width">
                            <label>วิธีการเดิมในปัจจุบัน</label>
                            <textarea
                                name="currentMethod[]"
                                placeholder="โปรดระบุวิธีการเดิมในปัจจุบัน"
                                data-maxbytes="1000"
                            ></textarea>
                        </div>

                    </div>

                </div>

                <div class="add-request-wrap">
                    <button type="button" class="btn btn-add-request" id="addRequestBtn">
                        เพิ่มช่องคำขอ
                    </button>
                </div>
            </div>

            <div class="btn-group full-width">
                <button type="button" class="btn btn-reject" onclick="history.back()">ย้อนกลับ</button>
                <button type="submit" class="btn btn-approve" id="submitBtn">ยืนยันการส่ง</button>
            </div>

        </div>

    </form>
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

function updateRequestHeaders() {
    const items = document.querySelectorAll(".request-item");
    items.forEach(function (item, index) {
        const h2 = item.querySelector(".request-item-header h2");
        if (h2) {
            h2.textContent = "คำขอที่ " + (index + 1);
        }
    });
}

// zennnne แก้
function getByteLength(str) {
    return new TextEncoder().encode(str).length;
}

function attachCounters(root) {
    (root || document).querySelectorAll("[data-maxbytes]").forEach(function (el) {
        if (el.dataset.counterAttached) return;
        el.dataset.counterAttached = "1";

        var max = parseInt(el.dataset.maxbytes);
        var counter = document.createElement("span");
        counter.className = "byte-counter";
        el.parentNode.insertBefore(counter, el.nextSibling);

        function update() {
            var used = getByteLength(el.value);
            counter.textContent = used + " / " + max + " bytes";
            if (used > max) {
                counter.classList.add("over-limit");
                el.classList.add("input-over-limit");
            } else {
                counter.classList.remove("over-limit");
                el.classList.remove("input-over-limit");
            }
        }

        el.addEventListener("input", update);
        update();
    });
}
// zennnne แก้

window.addEventListener("load", function () {
    setTodayDate();
    initPlaceholderSelects();
    initAllRequestTypeDisplays();
    updateDeleteButtons();
    updateRequestHeaders();
    attachCounters();
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

    const deadlineInput = document.getElementById("deadline");
    if (deadlineInput) {
        deadlineInput.min = todayFormatted;
    }
}

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

function updateDeleteButtons() {
    const requestItems = document.querySelectorAll(".request-item");
    const deleteButtons = document.querySelectorAll(".request-delete-btn");

    deleteButtons.forEach(function (button) {
        button.disabled = requestItems.length <= 1;
    });
}

function resetRequestItem(item) {
    // zennnne แก้
    item.querySelectorAll(".byte-counter").forEach(function (c) { c.remove(); });
    item.querySelectorAll("[data-counter-attached]").forEach(function (el) {
        el.removeAttribute("data-counter-attached");
    });
    // zennnne แก้

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

function initAllRequestTypeDisplays() {
    document.querySelectorAll(".request-item").forEach(function (item) {
        const select = item.querySelector('select[name="requestType[]"]');

        if (select) {
            handleRequestTypeChange(select);
        }
    });
}

function handleRequestTypeChange(select) {
    const item = select.closest(".request-item");
    if (!item) return;

    // Get the displayed Thai name of the selected type
    var selectedText = select.options[select.selectedIndex].text;

    const otherRequestBox = item.querySelector(".other-request-box");

    const otherRequestInput = item.querySelector('input[name="otherRequest[]"]');

    const serverPermissionBox = item.querySelector(".server-permission-box");
    const serverNameInput = item.querySelector('input[name="serverName[]"]');
    const serverFolderInput = item.querySelector('input[name="serverFolder[]"]');
    const subFolderInput = item.querySelector('input[name="subFolder[]"]');

    const programNameBox = item.querySelector(".program-name-box");
    const programNameInput = item.querySelector('input[name="programName[]"]');

    updateSelectColor(select);

    if (programNameBox && programNameInput) {
        if (selectedText === "ขอติดตั้งโปรแกรม" || selectedText === "ขอให้พัฒนาโปรแกรม") 
        {
            programNameBox.style.display = "flex";
            programNameInput.required = true;
        } else {
            programNameBox.style.display = "none";
            programNameInput.required = false;
            programNameInput.value = "";
        }
    }

    if (otherRequestBox && otherRequestInput) {
        if (selectedText === "อื่นๆ") {
            otherRequestBox.style.display = "flex";
            otherRequestInput.required = true;
        } else {
            otherRequestBox.style.display = "none";
            otherRequestInput.required = false;
            otherRequestInput.value = "";
        }
    }

    if (serverPermissionBox && serverNameInput && serverFolderInput && subFolderInput) {
        if (selectedText === "ขอใช้สิทธิ์เก็บข้อมูล") {
            serverPermissionBox.style.display = "flex";
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

            item.querySelectorAll('input[name="folderPermission[]"]').forEach(function (checkbox) {
                checkbox.checked = false;
            });

            item.querySelectorAll('input[name="subFolderPermission[]"]').forEach(function (checkbox) {
                checkbox.checked = false;
            });
        }
    }
}

const addRequestBtn = document.getElementById("addRequestBtn");
const requestsContainer = document.getElementById("requestsContainer");

if (addRequestBtn && requestsContainer) {
    addRequestBtn.addEventListener("click", function () {
        const firstItem = document.querySelector(".request-item");

        if (!firstItem) return;

        const newItem = firstItem.cloneNode(true);

        resetRequestItem(newItem);

        requestsContainer.appendChild(newItem);
        attachCounters(newItem); // zennnne แก้
        updateDeleteButtons();
        updateRequestHeaders();
    });

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
        updateRequestHeaders();
    });

    requestsContainer.addEventListener("change", function (event) {
        if (event.target.matches('select[name="requestType[]"]')) {
            handleRequestTypeChange(event.target);
        }

        if (event.target.classList.contains("select-placeholder")) {
            updateSelectColor(event.target);
        }
    });
}

const deadlineIcon = document.querySelector('#deadline + i');

if (deadlineIcon) {
    deadlineIcon.addEventListener("click", function () {
        const deadlineInput = document.getElementById("deadline");

        if (deadlineInput && deadlineInput.showPicker) {
            deadlineInput.showPicker();
        } else if (deadlineInput) {
            deadlineInput.focus();
            deadlineInput.click();
        }
    });
}

const requisitionForm = document.querySelector("form");

if (requisitionForm) {
    requisitionForm.addEventListener("submit", function (event) {
        const missingFields = [];

        const nameInput = document.getElementById("name");
        const departmentInput = document.getElementById("department");
        const phoneInput = document.getElementById("phone");
        const deadlineInput = document.getElementById("deadline");
        const requestTopicInput = document.getElementById("requestTopic");

        if (!nameInput || nameInput.value.trim() === "") {
            missingFields.push("ชื่อ-นามสกุล");
        }

        if (!departmentInput || departmentInput.value.trim() === "") {
            missingFields.push("ฝ่าย");
        }

        if (!phoneInput || phoneInput.value.trim() === "") {
            missingFields.push("เบอร์ต่อ");
        }

        if (!deadlineInput || deadlineInput.value.trim() === "") {
            missingFields.push("Deadline");
        }

        if (!requestTopicInput || requestTopicInput.value.trim() === "") {
            missingFields.push("ชื่อหัวข้อความต้องการ");
        }

        document.querySelectorAll(".request-item").forEach(function (item, index) {
            const requestNumber = index + 1;

            const requestTypeInput = item.querySelector('select[name="requestType[]"]');
            const objectiveInput = item.querySelector('textarea[name="objective[]"]');

            // Add this debug line:
            console.log("Checking Request Row: " + requestNumber, "Value is:", objectiveInput.value);

            if (!requestTypeInput || requestTypeInput.value.trim() === "") {
                missingFields.push("ประเภทคำขอ ช่องคำขอที่ " + requestNumber);
            }

            if (!objectiveInput || objectiveInput.value.trim() === "") {
                missingFields.push("วัตถุประสงค์ / ความต้องการ ช่องคำขอที่ " + requestNumber);
            }
        });

        if (missingFields.length > 0) {
            event.preventDefault();

            alert(
                "กรุณากรอกข้อมูลในช่อง :\n- " +
                missingFields.join("\n- ")
            );
            return;
        }

        // zennnne แก้
        var overLimitFields = [];
        document.querySelectorAll("[data-maxbytes]").forEach(function (el) {
            var max = parseInt(el.dataset.maxbytes);
            if (getByteLength(el.value) > max) {
                var group = el.closest(".form-group");
                var label = group && group.querySelector("label");
                overLimitFields.push(label ? label.textContent.replace(/[*]/g, "").trim() : el.name);
            }
        });

        if (overLimitFields.length > 0) {
            event.preventDefault();
            alert("ข้อมูลเกินขนาดที่กำหนด :\n- " + overLimitFields.join("\n- "));
        }
        // zennnne แก้
    });
}
</script>

<script>
// Build a map of deptId -> list of {id, name}
var sectionsByDept = {};
<c:forEach var="sec" items="${allSections}">
    if (!sectionsByDept[${sec.deptId}]) {
        sectionsByDept[${sec.deptId}] = [];
    }
    sectionsByDept[${sec.deptId}].push({id: ${sec.secId}, name: "${sec.secName}"});
</c:forEach>

var sectionSelect = document.getElementById("section");
var departmentSelect = document.getElementById("department");

function populateSections(deptId) {
    // Remove all options except the first default "ไม่ระบุ"
    sectionSelect.innerHTML = '<option value="">ไม่ระบุ</option>';
    if (deptId && sectionsByDept[deptId]) {
        sectionsByDept[deptId].forEach(function(sec) {
            var opt = document.createElement("option");
            opt.value = sec.id;
            opt.textContent = sec.name;
            sectionSelect.appendChild(opt);
        });
    }
}

// Listen for department changes
if (departmentSelect) {
    departmentSelect.addEventListener("change", function() {
        populateSections(this.value);
    });
}

// On page load, clear sections (department not yet selected)
window.addEventListener("load", function() {
    // Your existing onload stuff will run first, then this
    // Ensure the section list is empty initially
    populateSections(null);
});
</script>
<script>
    // Pre-select department and section on page load using the passed IDs
    window.addEventListener("load", function() {
        var empDeptId = ${empDeptId};   // from request attribute
        var empSecId = ${empSectionId}; // from request attribute

        if (empDeptId && departmentSelect) {
            departmentSelect.value = empDeptId; // set the dropdown value
            populateSections(empDeptId);        // fill the section dropdown
            // After sections are populated, select the right section
            sectionSelect.value = empSecId;
        }
    });
</script>

</body>
</html>