<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <style>
        .byte-counter { font-size: 0.75rem; color: #888; display: block; text-align: right; margin-top: 2px; width: 100%; order: 999; flex-basis: 100%; }
        .byte-counter.over-limit { color: #cc0000; font-weight: bold; }
        .input-over-limit { border-color: #cc0000 !important; outline: 1px solid #cc0000; }
        .field-hint { display: block; font-size: 0.85rem; color: #555; margin-top: 2px; }
        .request-section-hint { display: none; }
        .date-input-wrapper { position: relative; }
        .calendar-btn { position: absolute; right: 5px; top: 50%; transform: translateY(-50%); background: none; border: none; cursor: pointer; }
        .hidden-date-picker { position: absolute; opacity: 0; width: 0; height: 0; }
    </style>
</head>

<body>

<!-- Sidebar with icons -->
<%@ include file="/WEB-INF/sidebar.jsp" %>

<div id="main">
    <!-- Sticky Bar with user info -->
    <div class="sticky-bar">
        <i id="menuBtn" class="fa-solid fa-bars" onclick="toggleNav()"></i>
        <img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF Logo">
        <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo">
        <div class="user-info">
            <i class="fa fa-circle-user"></i>
            <p>${sessionScope.loggedInEmpName} | ID: ${sessionScope.loggedInEmpId}</p>
        </div>
        <div class="contact-info">
            <i class="fa-solid fa-circle-info"></i>
            <p>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
        </div>
    </div>

    <div class="banner">
        <h1>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</h1>
        <h2>ใบขอให้ดำเนินการ / Requisition Form</h2>
    </div>

    <div class="form-container">
        <form action="${pageContext.request.contextPath}/submitRequest" method="post">
            <c:if test="${not empty editedFormId}">
                <input type="hidden" name="editedFormId" value="${editedFormId}">
            </c:if>
            <div class="form-grid">
                <!-- Name (auto‑filled, readonly) -->
                <div class="form-group">
                    <label for="name">ชื่อ-นามสกุล</label>
                    <input type="text" id="name" name="name" value="${loggedInEmployee.empName}" readonly required>
                </div>

                <!-- Department (auto‑filled, locked) -->
                <div class="form-group">
                    <label for="departmentDisplay">ฝ่าย</label>
                    <input type="text" id="departmentDisplay" value="${empDeptName}" readonly required>
                    <input type="hidden" id="department" name="department" value="${empDeptId}">
                </div>

                <!-- Section (auto‑filled, locked) -->
                <div class="form-group">
                    <label for="sectionDisplay">ส่วน</label>
                    <input type="text" id="sectionDisplay" value="${empSectionName}" readonly>
                    <input type="hidden" id="section" name="section" value="${empSectionId}">
                </div>

                <!-- Phone (auto‑filled) -->
                <div class="form-group">
                    <label for="phone">เบอร์ต่อ</label>
                    <input type="text" id="phone" name="phone" value="${loggedInEmployee.phone}" readonly required>
                </div>

                <!-- Date (today, readonly) -->
                <div class="form-group">
                    <label for="date">วันที่ </label>
                    <input type="text" id="date" name="dateDisplay" readonly required>
                    <input type="hidden" id="dateIso" name="date">
                </div>

                <!-- Deadline (custom input) -->
                <div class="form-group">
                    <label for="deadlineText">Deadline <span class="required-star">*</span></label>
                    <div class="date-input-wrapper">
                        <input type="text" id="deadlineText" name="deadlineDisplay" placeholder="dd/mm/yyyy" inputmode="numeric" maxlength="10" autocomplete="off" required>
                        <button type="button" class="calendar-btn" id="calendarBtn" aria-label="เลือก Deadline"><i class="fa-regular fa-calendar"></i></button>
                        <input type="date" id="deadlinePicker" class="hidden-date-picker" tabindex="-1" aria-hidden="true">
                        <input type="hidden" id="deadlineIso" name="deadline">
                    </div>
                </div>

                <!-- Request Topic -->
                <div class="form-group full-width">
                    <label for="requestTopic">ชื่อหัวข้อความต้องการ : <span class="required-star">*</span></label>
                    <input type="text" id="requestTopic" name="requestTopic" placeholder="โปรดระบุชื่อหัวข้อความต้องการ" required data-maxbytes="255">
                </div>

                <!-- Request items container -->
                <div class="request-page full-width">
                    <div id="requestsContainer">
                        <div class="request-item">
                            <div class="request-item-header">
                                <h2>คำขอที่ 1</h2>
                                <div style="margin-left:auto">
                                    <button type="button" class="request-delete-btn" disabled><i class="fa-regular fa-trash-can"></i></button>
                                </div>
                            </div>

                            <div class="form-group">
                                <label>ประเภทคำขอ <span class="required-star">*</span></label>
                                <span class="field-hint">หากเพิ่มมากกว่า 1 คำขอ กรุณาเลือกประเภทคำขอที่อยู่ในส่วนผู้รับผิดชอบเดียวกัน</span>
                                <span class="field-hint request-section-hint"></span>
                                <select name="requestType[]" class="select-placeholder request-type-select" required>
                                    <option value="" disabled selected hidden>Please select</option>
                                    <c:forEach var="type" items="${requestTypes}">
                                        <option value="${type.typeId}"
                                                data-type-name="${fn:escapeXml(type.typeName)}"
                                                data-sec-id="${type.secId}"
                                                data-sec-name="${fn:escapeXml(type.secName)}">
                                            <c:out value="${type.typeName}" />
                                            <c:if test="${not empty type.secName}"> (<c:out value="${type.secName}" />)</c:if>
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="form-group program-name-box">
                                <label>ชื่อโปรแกรม : <span class="required-star">*</span></label>
                                <input type="text" name="programName[]" required data-maxbytes="500">
                            </div>

                            <div class="form-group full-width server-permission-box">
                                <h3 class="server-permission-title">กรณีขอใช้สิทธิ์เก็บข้อมูลใน Server</h3>
                                <div class="server-input-row">
                                    <label>Server : <span class="required-star">*</span></label>
                                    <input type="text" name="serverName[]" placeholder="โปรดระบุ Server" required data-maxbytes="500">
                                </div>
                                <div class="server-input-row">
                                    <label>Folder : <span class="required-star">*</span></label>
                                    <input type="text" name="serverFolder[]" placeholder="โปรดระบุ Folder" required data-maxbytes="500">
                                </div>
                                <div class="permission-checkbox-row">
                                    <label><input type="checkbox" name="folderPermission[]" value="Full control"> Full control</label>
                                    <label><input type="checkbox" name="folderPermission[]" value="Modify"> Modify</label>
                                    <label><input type="checkbox" name="folderPermission[]" value="Read & Execute"> Read & Execute</label>
                                    <label><input type="checkbox" name="folderPermission[]" value="Read"> Read</label>
                                    <label><input type="checkbox" name="folderPermission[]" value="Write"> Write</label>
                                </div>
                                <div class="server-input-row sub-folder-row">
                                    <label>Sub Folder :</label>
                                    <input type="text" name="subFolder[]" placeholder="โปรดระบุ Sub Folder" required data-maxbytes="500">
                                </div>
                                <div class="permission-checkbox-row">
                                    <label><input type="checkbox" name="subFolderPermission[]" value="Full control"> Full control</label>
                                    <label><input type="checkbox" name="subFolderPermission[]" value="Modify"> Modify</label>
                                    <label><input type="checkbox" name="subFolderPermission[]" value="Read & Execute"> Read & Execute</label>
                                    <label><input type="checkbox" name="subFolderPermission[]" value="Read"> Read</label>
                                    <label><input type="checkbox" name="subFolderPermission[]" value="Write"> Write</label>
                                </div>
                            </div>

                            <div class="form-group full-width other-request-box">
                                <label>โปรดระบุ <span class="required-star">*</span></label>
                                <input type="text" name="otherRequest[]" placeholder="โปรดระบุประเภทคำขอ" required data-maxbytes="500">
                            </div>

                            <div class="form-group full-width">
                                <label>วัตถุประสงค์ / ความต้องการ <span class="required-star">*</span></label>
                                <textarea name="objective[]" placeholder="โปรดระบุความต้องการ" required data-maxbytes="1000"></textarea>
                            </div>

                            <div class="form-group full-width">
                                <label>วิธีการเดิมในปัจจุบัน</label>
                                <textarea name="currentMethod[]" placeholder="โปรดระบุวิธีการเดิมในปัจจุบัน" data-maxbytes="1000"></textarea>
                            </div>
                        </div>
                    </div>

                    <div class="add-request-wrap">
                        <button type="button" class="btn btn-add-request" id="addRequestBtn">เพิ่มช่องคำขอ</button>
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

<!-- Custom modal for cross‑section validation -->
<div class="request-alert-overlay" id="requestTypeAlert" aria-hidden="true" style="display:none; position:fixed; inset:0; z-index:2000; align-items:center; justify-content:center; padding:20px; background:rgba(0,0,0,0.28);">
    <div class="request-alert-box" role="alertdialog" aria-modal="true" aria-labelledby="requestTypeAlertTitle" style="width:min(420px,100%); padding:22px 24px; border-radius:8px; background:#fff; box-shadow:0 14px 38px rgba(0,0,0,0.24); text-align:left;">
        <h3 id="requestTypeAlertTitle" style="margin:0 0 10px; font-size:1.15rem; color:#111827;">กรุณาตรวจสอบประเภทคำขอ</h3>
        <p id="requestTypeAlertMessage" style="margin:0 0 20px; color:#1f2937; line-height:1.5; white-space:pre-line;"></p>
        <div style="display:flex; justify-content:flex-end;">
            <button type="button" class="request-alert-btn" id="requestTypeAlertClose">ตกลง</button>
        </div>
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

function updateRequestHeaders() {
    const items = document.querySelectorAll(".request-item");
    items.forEach(function (item, index) {
        const h2 = item.querySelector(".request-item-header h2");
        if (h2) {
            h2.textContent = "คำขอที่ " + (index + 1);
        }
    });
    syncPermissionNamesByRequestItem();
}

// ---------- Byte counters ----------
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

// ---------- Deadline helpers ----------
function parseDisplayDate(value) {
    var match = /^(\d{2})\/(\d{2})\/(\d{4})$/.exec((value || "").trim());
    if (!match) return null;
    var day = parseInt(match[1], 10);
    var month = parseInt(match[2], 10);
    var year = parseInt(match[3], 10);
    var date = new Date(year, month - 1, day);
    if (date.getFullYear() !== year || date.getMonth() !== month - 1 || date.getDate() !== day) return null;
    return {
        iso: year + "-" + String(month).padStart(2, "0") + "-" + String(day).padStart(2, "0"),
        date: date
    };
}

function formatDeadlineInput(input) {
    var digits = input.value.replace(/\D/g, "").slice(0, 8);
    var parts = [];
    if (digits.length > 0) parts.push(digits.slice(0, 2));
    if (digits.length > 2) parts.push(digits.slice(2, 4));
    if (digits.length > 4) parts.push(digits.slice(4));
    input.value = parts.join("/");
}

// ---------- Select helpers ----------
function updateSelectColor(select) {
    select.style.color = select.value === "" ? "#777" : "black";
}

function initPlaceholderSelects() {
    document.querySelectorAll(".select-placeholder").forEach(function (select) {
        updateSelectColor(select);
        select.addEventListener("change", function () { updateSelectColor(this); });
    });
}

function updateDeleteButtons() {
    const items = document.querySelectorAll(".request-item");
    const buttons = document.querySelectorAll(".request-delete-btn");
    buttons.forEach(function (btn) {
        btn.disabled = items.length <= 1;
    });
}

function resetRequestItem(item) {
    item.querySelectorAll(".byte-counter").forEach(function (c) { c.remove(); });
    item.querySelectorAll("[data-counter-attached]").forEach(function (el) { el.removeAttribute("data-counter-attached"); });
    item.querySelectorAll("input").forEach(function (input) {
        if (input.type === "checkbox") input.checked = false;
        else input.value = "";
        input.required = false;
    });
    item.querySelectorAll("textarea").forEach(function (ta) { ta.value = ""; });
    item.querySelectorAll("select").forEach(function (select) {
        select.selectedIndex = 0;
        updateSelectColor(select);
    });
    item.querySelectorAll(".other-request-box, .server-permission-box, .program-name-box").forEach(function (box) {
        box.style.display = "none";
    });
    item.querySelectorAll(".request-section-hint").forEach(function (hint) {
        hint.textContent = "";
        hint.style.display = "none";
    });
}

// ---------- Request type dynamic fields ----------
function handleRequestTypeChange(select) {
    const item = select.closest(".request-item");
    if (!item) return;
    var selectedOption = select.options[select.selectedIndex];
    var selectedText = selectedOption ? (selectedOption.dataset.typeName || selectedOption.text) : "";
    var selectedSectionName = selectedOption ? selectedOption.dataset.secName : "";
    var sectionHint = item.querySelector(".request-section-hint");

    const otherRequestBox = item.querySelector(".other-request-box");
    const otherRequestInput = item.querySelector('input[name="otherRequest[]"]');
    const serverPermissionBox = item.querySelector(".server-permission-box");
    const serverNameInput = item.querySelector('input[name="serverName[]"]');
    const serverFolderInput = item.querySelector('input[name="serverFolder[]"]');
    const subFolderInput = item.querySelector('input[name="subFolder[]"]');
    const programNameBox = item.querySelector(".program-name-box");
    const programNameInput = item.querySelector('input[name="programName[]"]');

    updateSelectColor(select);
    if (sectionHint) {
        if (selectedSectionName) {
            sectionHint.textContent = "กรุณาเลือกประเภทคำขอในกลุ่มเดียวกัน: " + selectedSectionName;
            sectionHint.style.display = "block";
        } else {
            sectionHint.textContent = "";
            sectionHint.style.display = "none";
        }
    }

    if (programNameBox && programNameInput) {
        if (selectedText === "ขอติดตั้งโปรแกรม" || selectedText === "ขอให้พัฒนาโปรแกรม") {
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
            // subFolderInput.required = true; // Sub Folder ไม่บังคับใส่
        } else {
            serverPermissionBox.style.display = "none";
            serverNameInput.required = false;
            serverFolderInput.required = false;
            subFolderInput.required = false;
            serverNameInput.value = "";
            serverFolderInput.value = "";
            subFolderInput.value = "";
            item.querySelectorAll('input[name^="folderPermission"]').forEach(function (cb) { cb.checked = false; });
            item.querySelectorAll('input[name^="subFolderPermission"]').forEach(function (cb) { cb.checked = false; });
        }
    }
}

// ---------- Same‑section validation ----------
function getSelectedRequestSection(select) {
    if (!select || !select.value) return null;
    var option = select.options[select.selectedIndex];
    if (!option) return null;
    return { id: option.dataset.secId || "", name: option.dataset.secName || "" };
}

function showRequestTypeAlert(message, title) {
    var overlay = document.getElementById("requestTypeAlert");
    var titleEl = document.getElementById("requestTypeAlertTitle");
    var messageEl = document.getElementById("requestTypeAlertMessage");
    if (!overlay || !messageEl) {
        alert(message);
        return;
    }
    if (titleEl) titleEl.textContent = title || "กรุณาตรวจสอบประเภทคำขอ";
    messageEl.textContent = message;
    overlay.classList.add("is-open");
    overlay.style.display = "flex";
    overlay.setAttribute("aria-hidden", "false");
    document.getElementById("requestTypeAlertClose").focus();
}

function closeRequestTypeAlert() {
    var overlay = document.getElementById("requestTypeAlert");
    if (!overlay) return;
    overlay.classList.remove("is-open");
    overlay.style.display = "none";
    overlay.setAttribute("aria-hidden", "true");
}

function hasCheckedPermission(item, selector) {
    return Array.prototype.some.call(item.querySelectorAll(selector), function (checkbox) {
        return checkbox.checked;
    });
}

function validateSameRequestSection(showAlert, changedSelect) {
    var baseSection = null;
    var invalidTypeName = "";
    var invalidSectionName = "";
    var selects = document.querySelectorAll('select[name="requestType[]"]');
    selects.forEach(function (select, index) {
        var section = getSelectedRequestSection(select);
        if (!section || !section.id) return;
        if (!baseSection) {
            baseSection = section;
            return;
        }
        if (section.id !== baseSection.id && invalidTypeName === "") {
            var selectedOption = select.options[select.selectedIndex];
            invalidTypeName = selectedOption ? (selectedOption.dataset.typeName || selectedOption.text) : "";
            invalidSectionName = section.name || section.id;
        }
    });
    if (invalidTypeName) {
        if (changedSelect) {
            changedSelect.selectedIndex = 0;
            updateSelectColor(changedSelect);
            handleRequestTypeChange(changedSelect);
        }
        if (showAlert) {
            showRequestTypeAlert(invalidTypeName + " เป็นของกลุ่ม " + invalidSectionName);
        }
        return false;
    }
    return true;
}

// ---------- Permission checkbox name sync ----------
function syncPermissionNamesByRequestItem() {
    document.querySelectorAll(".request-item").forEach(function (item, index) {
        item.querySelectorAll('input[name^="folderPermission"]').forEach(function (cb) {
            cb.name = "folderPermission_" + index + "[]";
        });
        item.querySelectorAll('input[name^="subFolderPermission"]').forEach(function (cb) {
            cb.name = "subFolderPermission_" + index + "[]";
        });
    });
}

// ---------- Lock department/section fields ----------
function lockAutofillSelects() {
    var deptDisplay = document.getElementById("departmentDisplay");
    var secDisplay = document.getElementById("sectionDisplay");
    if (deptDisplay) deptDisplay.readOnly = true;
    if (secDisplay) secDisplay.readOnly = true;
}

// ---------- Page initialisation ----------
window.addEventListener("load", function () {
    // Set today's date
    const today = new Date();
    const yyyy = today.getFullYear();
    const mm = String(today.getMonth() + 1).padStart(2, "0");
    const dd = String(today.getDate()).padStart(2, "0");
    const todayIso = yyyy + "-" + mm + "-" + dd;
    const todayDisplay = dd + "/" + mm + "/" + yyyy;
    document.getElementById("date").value = todayDisplay;
    document.getElementById("dateIso").value = todayIso;
    document.getElementById("deadlineText").dataset.minIso = todayIso;
    document.getElementById("deadlinePicker").min = todayIso;

    initPlaceholderSelects();
    initAllRequestTypeDisplays();
    updateDeleteButtons();
    updateRequestHeaders();
    attachCounters();
    lockAutofillSelects();  // department/section are already locked
});

function initAllRequestTypeDisplays() {
    document.querySelectorAll(".request-item").forEach(function (item) {
        const select = item.querySelector('select[name="requestType[]"]');
        if (select) handleRequestTypeChange(select);
    });
}

// ---------- Add / delete request items ----------
const addRequestBtn = document.getElementById("addRequestBtn");
const requestsContainer = document.getElementById("requestsContainer");

if (addRequestBtn && requestsContainer) {
    addRequestBtn.addEventListener("click", function () {
        const firstItem = document.querySelector(".request-item");
        if (!firstItem) return;
        const newItem = firstItem.cloneNode(true);
        resetRequestItem(newItem);
        requestsContainer.appendChild(newItem);
        attachCounters(newItem);
        updateDeleteButtons();
        updateRequestHeaders();
        validateSameRequestSection(false, null);
    });

    requestsContainer.addEventListener("click", function (event) {
        const deleteButton = event.target.closest(".request-delete-btn");
        if (!deleteButton || deleteButton.disabled) return;
        const items = document.querySelectorAll(".request-item");
        if (items.length <= 1) return;
        const item = deleteButton.closest(".request-item");
        if (item) {
            item.remove();
        }
        updateDeleteButtons();
        updateRequestHeaders();
        validateSameRequestSection(false, null);
    });

    requestsContainer.addEventListener("change", function (event) {
        if (event.target.matches('select[name="requestType[]"]')) {
            handleRequestTypeChange(event.target);
            validateSameRequestSection(true, event.target);
        }
        if (event.target.classList.contains("select-placeholder")) {
            updateSelectColor(event.target);
        }
    });
}

// ---------- Calendar button ----------
const calendarBtn = document.getElementById("calendarBtn");
if (calendarBtn) {
    calendarBtn.addEventListener("click", function () {
        const deadlineInput = document.getElementById("deadlineText");
        const deadlinePicker = document.getElementById("deadlinePicker");
        if (deadlineInput) {
            var parsed = parseDisplayDate(deadlineInput.value);
            if (parsed && deadlinePicker) deadlinePicker.value = parsed.iso;
        }
        if (deadlinePicker && deadlinePicker.showPicker) {
            deadlinePicker.showPicker();
        } else if (deadlinePicker) {
            deadlinePicker.click();
        } else if (deadlineInput) {
            deadlineInput.focus();
        }
    });
}

const deadlineDisplayInput = document.getElementById("deadlineText");
if (deadlineDisplayInput) {
    deadlineDisplayInput.addEventListener("input", function () { formatDeadlineInput(this); });
}

const deadlinePickerInput = document.getElementById("deadlinePicker");
if (deadlinePickerInput) {
    deadlinePickerInput.addEventListener("change", function () {
        const deadlineInput = document.getElementById("deadlineText");
        if (!deadlineInput || !this.value) return;
        var parts = this.value.split("-");
        if (parts.length === 3) {
            deadlineInput.value = parts[2] + "/" + parts[1] + "/" + parts[0];
        }
    });
}

// ---------- Modal dismiss ----------
document.getElementById("requestTypeAlertClose").addEventListener("click", closeRequestTypeAlert);
document.getElementById("requestTypeAlert").addEventListener("click", function (e) {
    if (e.target === this) closeRequestTypeAlert();
});
document.addEventListener("keydown", function (e) {
    if (e.key === "Escape") closeRequestTypeAlert();
});

// ---------- Form submission validation ----------
const requisitionForm = document.querySelector("form");
if (requisitionForm) {
    requisitionForm.setAttribute("novalidate", "novalidate");
    requisitionForm.addEventListener("submit", function (event) {
        const missingFields = [];

        const nameInput = document.getElementById("name");
        const departmentInput = document.getElementById("department");  // hidden, but we can still check value
        const phoneInput = document.getElementById("phone");
        const deadlineText = document.getElementById("deadlineText");
        const requestTopicInput = document.getElementById("requestTopic");

        if (!nameInput || nameInput.value.trim() === "") missingFields.push("ชื่อ-นามสกุล");
        if (!departmentInput || departmentInput.value.trim() === "") missingFields.push("ฝ่าย");
        if (!phoneInput || phoneInput.value.trim() === "") missingFields.push("เบอร์ต่อ");
        if (!deadlineText || deadlineText.value.trim() === "") missingFields.push("Deadline");
        if (!requestTopicInput || requestTopicInput.value.trim() === "") missingFields.push("ชื่อหัวข้อความต้องการ");

        document.querySelectorAll(".request-item").forEach(function (item, index) {
            const requestNumber = index + 1;
            const requestTypeInput = item.querySelector('select[name="requestType[]"]');
            const objectiveInput = item.querySelector('textarea[name="objective[]"]');
            const programNameInput = item.querySelector('input[name="programName[]"]');
            const otherRequestInput = item.querySelector('input[name="otherRequest[]"]');
            const serverPermissionBox = item.querySelector(".server-permission-box");
            const serverNameInput = item.querySelector('input[name="serverName[]"]');
            const serverFolderInput = item.querySelector('input[name="serverFolder[]"]');
            const subFolderInput = item.querySelector('input[name="subFolder[]"]');
            if (!requestTypeInput || requestTypeInput.value.trim() === "") missingFields.push("ประเภทคำขอ ช่องคำขอที่ " + requestNumber);
            if (!objectiveInput || objectiveInput.value.trim() === "") missingFields.push("วัตถุประสงค์ / ความต้องการ ช่องคำขอที่ " + requestNumber);
            if (programNameInput && programNameInput.required && programNameInput.value.trim() === "") missingFields.push("ชื่อโปรแกรม ช่องคำขอที่ " + requestNumber);
            if (otherRequestInput && otherRequestInput.required && otherRequestInput.value.trim() === "") missingFields.push("โปรดระบุ ช่องคำขอที่ " + requestNumber);
            if (serverPermissionBox && serverPermissionBox.style.display !== "none") {
                if (!serverNameInput || serverNameInput.value.trim() === "") missingFields.push("Server ช่องคำขอที่ " + requestNumber);
                if (!serverFolderInput || serverFolderInput.value.trim() === "") missingFields.push("Folder ช่องคำขอที่ " + requestNumber);
                if (!hasCheckedPermission(item, 'input[name^="folderPermission"]')) missingFields.push("สิทธิ์ Folder ช่องคำขอที่ " + requestNumber);
//                if (!hasCheckedPermission(item, 'input[name^="subFolderPermission"]')) missingFields.push("สิทธิ์ Sub Folder ช่องคำขอที่ " + requestNumber); // Sub Folder ไม่บังคับเลือกสิทธิ์
            }
        });

        if (missingFields.length > 0) {
            event.preventDefault();
            showRequestTypeAlert("กรุณากรอกข้อมูลในช่อง :\n- " + missingFields.join("\n- "), "กรุณากรอกข้อมูลให้ครบถ้วน");
            return;
        }

        // Deadline validation
        var parsedDeadline = parseDisplayDate(deadlineText.value);
        if (!parsedDeadline) {
            event.preventDefault();
            showRequestTypeAlert("กรุณากรอก Deadline เป็นรูปแบบ dd/mm/yyyy");
            return;
        }
        var minIso = deadlineText.dataset.minIso;
        if (minIso && parsedDeadline.iso < minIso) {
            event.preventDefault();
            showRequestTypeAlert("Deadline ต้องไม่ย้อนหลังจากวันที่ปัจจุบัน");
            return;
        }
        document.getElementById("deadlineIso").value = parsedDeadline.iso;

        // Cross‑section check
        if (!validateSameRequestSection(true, null)) {
            event.preventDefault();
            return;
        }

        // Byte limit check
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
            showRequestTypeAlert("ข้อมูลเกินขนาดที่กำหนด :\n- " + overLimitFields.join("\n- "), "กรุณาตรวจสอบข้อมูล");
            return;
        }

        // Ensure permission checkboxes have indexed names before submit
        syncPermissionNamesByRequestItem();
    });
}
</script>

<!-- Pre‑fill block for editing a rejected form (preserves employee’s own department/section) -->
<c:if test="${not empty prefillJson}">
<script>
(function () {
    function applyPrefill(data) {
        // Request topic
        var rt = document.getElementById("requestTopic");
        if (rt && data.titleForm) rt.value = data.titleForm;

        // Deadline (convert ISO to dd/mm/yyyy)
        var dl = document.getElementById("deadlineText");
        if (dl && data.deadline) {
            var parts = data.deadline.split("-");
            dl.value = parts.length === 3 ? parts[2] + "/" + parts[1] + "/" + parts[0] : data.deadline;
        }

        // Department & section are intentionally NOT overwritten — they come from the current employee profile.

        // Items
        if (!data.items || data.items.length === 0) return;
        var container = document.getElementById("requestsContainer");
        if (!container) return;
        var firstItem = container.querySelector(".request-item");
        if (!firstItem) return;

        data.items.forEach(function (itemData, idx) {
            var el;
            if (idx === 0) {
                el = firstItem;
            } else {
                el = firstItem.cloneNode(true);
                if (typeof resetRequestItem === "function") resetRequestItem(el);
                container.appendChild(el);
                if (typeof attachCounters === "function") attachCounters(el);
            }
            fillRequestItem(el, itemData);
        });

        if (typeof updateDeleteButtons === "function") updateDeleteButtons();
        if (typeof updateRequestHeaders === "function") updateRequestHeaders();
    }

    function fillRequestItem(el, data) {
        var typeSelect = el.querySelector('select[name="requestType[]"]');
        if (typeSelect) {
            typeSelect.value = data.typeId;
            if (typeof handleRequestTypeChange === "function") handleRequestTypeChange(typeSelect);
            if (typeof updateSelectColor === "function") updateSelectColor(typeSelect);
        }

        var progInput = el.querySelector('input[name="programName[]"]');
        if (progInput) progInput.value = data.programOrOther || "";

        var otherInput = el.querySelector('input[name="otherRequest[]"]');
        if (otherInput) otherInput.value = data.programOrOther || "";

        var objTA = el.querySelector('textarea[name="objective[]"]');
        if (objTA) objTA.value = data.objective || "";

        var cmTA = el.querySelector('textarea[name="currentMethod[]"]');
        if (cmTA) cmTA.value = data.currentMethod || "";

        var snInput = el.querySelector('input[name="serverName[]"]');
        if (snInput) snInput.value = data.serverName || "";

        var sfInput = el.querySelector('input[name="serverFolder[]"]');
        if (sfInput) sfInput.value = data.serverFolder || "";

        var subInput = el.querySelector('input[name="subFolder[]"]');
        if (subInput) subInput.value = data.subFolder || "";

        if (data.folderPerms) {
            el.querySelectorAll('input[name^="folderPermission"]').forEach(function (cb) {
                cb.checked = data.folderPerms.indexOf(cb.value) >= 0;
            });
        }
        if (data.subFolderPerms) {
            el.querySelectorAll('input[name^="subFolderPermission"]').forEach(function (cb) {
                cb.checked = data.subFolderPerms.indexOf(cb.value) >= 0;
            });
        }

        el.querySelectorAll("[data-maxbytes]").forEach(function (input) {
            input.dispatchEvent(new Event("input"));
        });
    }

    window.addEventListener("load", function () {
        applyPrefill(${prefillJson});
    });
}());
</script>
</c:if>

</body>
</html>
