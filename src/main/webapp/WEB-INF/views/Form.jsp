<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.slf.util.SecurityUtil, com.slf.util.NavigationUtil" %>
<%
    String csrfToken = SecurityUtil.ensureCsrfToken(request);
    NavigationUtil.BackLink formBackLink = NavigationUtil.itRequisitionDetailBack(request.getContextPath());
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ใบขอให้ดำเนินการ</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/images/cropped-logo-192x192.png">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>

<body>

<!-- Sidebar with icons -->
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>

<div id="main">
    <!-- Sticky Bar with user info -->
    <%@ include file="/WEB-INF/jspf/topbar.jspf" %>

    <header class="form-page-header page-header" aria-labelledby="itRequestFormTitle">
        <div class="form-hero-content">
            <h1 class="page-title" id="itRequestFormTitle">ใบขอให้ดำเนินการด้านเทคโนโลยีสารสนเทศ</h1>
            <p class="page-subtitle">กรอกข้อมูลคำขอใหม่ ตรวจสอบรายละเอียด และส่งเข้าสู่กระบวนการอนุมัติ</p>
        </div>
    </header>

    <main class="it-request-form-page form-container">
        <c:if test="${not empty error}">
            <div class="form-error-message alert alert-error"><c:out value="${error}" /></div>
        </c:if>
        <form action="${pageContext.request.contextPath}/submitRequest" method="post" novalidate>
            <input type="hidden" name="csrfToken" value="<%= SecurityUtil.escapeHtml(csrfToken) %>">
            <c:if test="${not empty editedFormId}">
                <input type="hidden" name="editedFormId" value="${editedFormId}">
            </c:if>

            <section class="form-section applicant-information panel" aria-labelledby="applicantInfoTitle">
                <div class="section-heading">
                    <div class="section-title-block">
                        <span class="section-icon" aria-hidden="true"><i class="fa-solid fa-user-check"></i></span>
                        <div class="section-heading-copy">
                            <h2 id="applicantInfoTitle">ข้อมูลผู้ขอ</h2>
                            <p>ข้อมูลผู้ใช้ถูกดึงจากระบบและล็อกไว้เพื่อป้องกันการส่งคำขอผิดหน่วยงาน</p>
                        </div>
                    </div>
                </div>

                <div class="form-grid">
                    <div class="form-group readonly-field">
                        <label for="name" class="field-required">ชื่อ-นามสกุล</label>
                        <input type="text" id="name" name="name" value="${fn:escapeXml(loggedInEmployee.empName)}" readonly required aria-describedby="nameHelp">
                        <span class="field-hint" id="nameHelp">ข้อมูลจากบัญชีผู้ใช้งานปัจจุบัน</span>
                    </div>

                    <div class="form-group readonly-field">
                        <label for="departmentDisplay" class="field-required">ฝ่าย</label>
                        <input type="text" id="departmentDisplay" value="${fn:escapeXml(empDeptName)}" readonly required aria-describedby="departmentHelp">
                        <span class="field-hint" id="departmentHelp">ใช้เป็นข้อมูลส่งต่อ workflow ภายใน</span>
                        <input type="hidden" id="department" name="department" value="${empDeptId}">
                    </div>

                    <div class="form-group readonly-field">
                        <label for="sectionDisplay">ส่วน</label>
                        <input type="text" id="sectionDisplay" value="${fn:escapeXml(empSectionName)}" readonly aria-describedby="sectionHelp">
                        <span class="field-hint" id="sectionHelp">แสดงส่วนงานตามบัญชีพนักงาน</span>
                        <input type="hidden" id="section" name="section" value="${empSectionId}">
                    </div>

                    <div class="form-group readonly-field">
                        <label for="phone" class="field-required">เบอร์ต่อ</label>
                        <input type="text" id="phone" name="phone" value="${fn:escapeXml(loggedInEmployee.phone)}" readonly required aria-describedby="phoneHelp">
                        <span class="field-hint" id="phoneHelp">ใช้สำหรับติดต่อกลับกรณีต้องสอบถามเพิ่มเติม</span>
                    </div>

                    <div class="form-group readonly-field">
                        <label for="date" class="field-required">วันที่</label>
                        <input type="text" id="date" name="dateDisplay" readonly required aria-describedby="dateHelp">
                        <span class="field-hint" id="dateHelp">ระบบกำหนดวันที่ส่งคำขอให้อัตโนมัติ</span>
                        <input type="hidden" id="dateIso" name="date">
                    </div>
                </div>
            </section>

            <section class="form-section request-information panel" aria-labelledby="requestInfoTitle">
                <div class="section-heading">
                    <div class="section-title-block">
                        <span class="section-icon" aria-hidden="true"><i class="fa-solid fa-clipboard-list"></i></span>
                        <div class="section-heading-copy">
                            <h2 id="requestInfoTitle">ข้อมูลคำขอ</h2>
                            <p>ระบุหัวข้อและกำหนดวันที่ต้องการใช้งาน เพื่อช่วยให้ทีม IT จัดลำดับงานได้ถูกต้อง</p>
                        </div>
                    </div>
                </div>

                <div class="form-grid">
                    <div class="form-group">
                        <label for="deadlineText" class="field-required">Deadline</label>
                        <div class="date-input-wrapper">
                            <input type="text" id="deadlineText" name="deadlineDisplay" placeholder="dd/mm/yyyy" inputmode="numeric" maxlength="10" autocomplete="off" required aria-describedby="deadlineHelp">
                            <button type="button" class="calendar-btn" id="calendarBtn" aria-label="เลือก Deadline"><i class="fa-regular fa-calendar"></i></button>
                            <input type="date" id="deadlinePicker" class="hidden-date-picker" tabindex="-1" aria-hidden="true">
                            <input type="hidden" id="deadlineIso" name="deadline">
                        </div>
                        <span class="field-hint" id="deadlineHelp">รูปแบบวันที่ dd/mm/yyyy และต้องไม่ย้อนหลังจากวันที่ปัจจุบัน</span>
                    </div>

                    <div class="form-group full-width">
                        <label for="requestTopic" class="field-required">ชื่อหัวข้อความต้องการ</label>
                        <input type="text" id="requestTopic" name="requestTopic" placeholder="เช่น ขอสิทธิ์เข้าใช้งานระบบ / ขอปรับปรุงรายงาน" required data-maxbytes="255" aria-describedby="requestTopicHelp">
                        <span class="field-hint" id="requestTopicHelp">สรุปคำขอให้สั้นและชัดเจน เพื่อค้นหาและติดตามภายหลังได้ง่าย</span>
                    </div>
                </div>
            </section>

            <section class="form-section requested-items panel" aria-labelledby="requestedItemsTitle">
                <div class="section-heading">
                    <div class="section-title-block">
                        <span class="section-icon" aria-hidden="true"><i class="fa-solid fa-layer-group"></i></span>
                        <div class="section-heading-copy">
                            <h2 id="requestedItemsTitle">รายการคำขอ</h2>
                            <p>เพิ่มรายการได้มากกว่าหนึ่งรายการ โดยควรอยู่ในกลุ่มผู้รับผิดชอบเดียวกัน</p>
                        </div>
                    </div>
                </div>

                <div class="request-page full-width">
                    <div id="requestsContainer">
                        <div class="request-item request-item-card">
                            <div class="request-item-header">
                                <h2>คำขอที่ 1</h2>
                                <div class="request-item-actions">
                                    <button type="button" class="request-delete-btn" disabled aria-label="ลบคำขอนี้" title="ลบคำขอนี้"><i class="fa-regular fa-trash-can"></i></button>
                                </div>
                            </div>

                            <div class="form-group request-type-field">
                                <label class="field-required">ประเภทคำขอ</label>
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
                                <label class="field-required">ชื่อโปรแกรม</label>
                                <input type="text" name="programName[]" required data-maxbytes="500">
                            </div>

                            <div class="form-group full-width server-permission-box request-item-subsection technical-information">
                                <div class="subsection-heading">
                                    <p class="section-kicker">Server Permission / Technical Information</p>
                                    <h3 class="server-permission-title">กรณีขอใช้สิทธิ์เก็บข้อมูลใน Server</h3>
                                </div>
                                <div class="server-input-row">
                                    <label class="field-required">Server</label>
                                    <input type="text" name="serverName[]" placeholder="โปรดระบุ Server" required data-maxbytes="500">
                                </div>
                                <div class="server-input-row">
                                    <label class="field-required">Folder</label>
                                    <input type="text" name="serverFolder[]" placeholder="โปรดระบุ Folder" required data-maxbytes="500">
                                </div>
                                <p class="field-hint permission-hint">เลือกสิทธิ์ที่ต้องการสำหรับ Folder หลัก</p>
                                <div class="permission-checkbox-row permission-group">
                                    <label><input type="checkbox" name="folderPermission[]" value="Full control"> Full control</label>
                                    <label><input type="checkbox" name="folderPermission[]" value="Modify"> Modify</label>
                                    <label><input type="checkbox" name="folderPermission[]" value="Read & Execute"> Read & Execute</label>
                                    <label><input type="checkbox" name="folderPermission[]" value="Read"> Read</label>
                                    <label><input type="checkbox" name="folderPermission[]" value="Write"> Write</label>
                                </div>
                                <div class="server-input-row sub-folder-row">
                                    <label>Sub Folder :</label>
                                    <input type="text" name="subFolder[]" placeholder="โปรดระบุ Sub Folder" data-maxbytes="500">
                                </div>
                                <p class="field-hint permission-hint">กรอก Sub Folder เฉพาะกรณีต้องการสิทธิ์แยกจาก Folder หลัก</p>
                                <div class="permission-checkbox-row permission-group sub-folder-permission-group">
                                    <label><input type="checkbox" name="subFolderPermission[]" value="Full control"> Full control</label>
                                    <label><input type="checkbox" name="subFolderPermission[]" value="Modify"> Modify</label>
                                    <label><input type="checkbox" name="subFolderPermission[]" value="Read & Execute"> Read & Execute</label>
                                    <label><input type="checkbox" name="subFolderPermission[]" value="Read"> Read</label>
                                    <label><input type="checkbox" name="subFolderPermission[]" value="Write"> Write</label>
                                </div>
                            </div>

                            <div class="form-group full-width other-request-box">
                                <label class="field-required">โปรดระบุ</label>
                                <input type="text" name="otherRequest[]" placeholder="โปรดระบุประเภทคำขอ" required data-maxbytes="500">
                            </div>

                            <div class="request-item-subsection additional-information">
                                <div class="subsection-heading">
                                    <p class="section-kicker">Additional Information</p>
                                    <h3>รายละเอียดประกอบคำขอ</h3>
                                </div>

                                <div class="form-group full-width">
                                    <label class="field-required">วัตถุประสงค์ / ความต้องการ</label>
                                    <textarea name="objective[]" placeholder="อธิบายผลลัพธ์ที่ต้องการหรือปัญหาที่ต้องการให้ดำเนินการ" required data-maxbytes="1000"></textarea>
                                </div>

                                <div class="form-group full-width">
                                    <label>วิธีการเดิมในปัจจุบัน</label>
                                    <textarea name="currentMethod[]" placeholder="ระบุขั้นตอนเดิมหรือวิธีที่ใช้อยู่ หากมี" data-maxbytes="1000"></textarea>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="add-request-wrap action-row">
                        <button type="button" class="btn btn-add-request" id="addRequestBtn"><i class="fa-solid fa-plus" aria-hidden="true"></i> เพิ่มช่องคำขอ</button>
                    </div>
                </div>
            </section>

            <div class="form-action-bar action-row panel">
                <a class="btn btn-reject detail-back-button" href="<%= SecurityUtil.escapeHtml(formBackLink.getHref()) %>">
                    <i class="fa-solid fa-arrow-left"></i> <%= SecurityUtil.escapeHtml(formBackLink.getLabel()) %>
                </a>
                <button type="submit" class="btn btn-approve" id="submitBtn">ยืนยันการส่งคำขอ</button>
            </div>
        </form>
    </main>
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
        var parent = el.parentNode;
        if (parent) {
            parent.classList.add("has-byte-counter");
        }
        var max = parseInt(el.dataset.maxbytes);
        var counter = document.createElement("span");
        counter.className = "byte-counter";
        parent.insertBefore(counter, el.nextSibling);
        function update() {
            var used = getByteLength(el.value);
            counter.textContent = used + " / " + max + " bytes";
            if (used > max) {
                counter.classList.add("over-limit");
                el.classList.add("input-over-limit");
                el.setCustomValidity("ข้อมูลเกิน " + max + " bytes");
            } else {
                counter.classList.remove("over-limit");
                el.classList.remove("input-over-limit");
                el.setCustomValidity("");
            }
        }
        el.addEventListener("input", update);
        el.addEventListener("input", function () { clearFieldError(el); });
        update();
    });
}

function getActiveRequestItems() {
    return Array.prototype.filter.call(document.querySelectorAll(".request-item"), function (item) {
        return item.offsetParent !== null;
    });
}

function isVisibleElement(el) {
    return !!(el && el.offsetParent !== null);
}

function isBlankValue(el) {
    return !el || String(el.value || "").trim() === "";
}

function errorContainerFor(target) {
    if (!target) return null;
    return target.closest(".form-group, .server-input-row, .permission-group, .request-item-subsection, .request-item") || target;
}

function clearFieldError(target) {
    var container = errorContainerFor(target);
    if (!container) return;
    container.classList.remove("has-field-error");
    var message = container.querySelector(":scope > .field-error-message");
    if (message) message.remove();
    if (target && typeof target.setCustomValidity === "function") {
        target.setCustomValidity("");
    }
}

function showFieldError(target, message) {
    var container = errorContainerFor(target);
    if (!container) return;
    clearFieldError(target);
    container.classList.add("has-field-error");
    var error = document.createElement("span");
    error.className = "field-error-message";
    error.textContent = message;
    container.appendChild(error);
    if (target && typeof target.setCustomValidity === "function") {
        target.setCustomValidity(message);
    }
}

function clearAllValidationErrors() {
    document.querySelectorAll(".has-field-error").forEach(function (el) {
        el.classList.remove("has-field-error");
        var message = el.querySelector(":scope > .field-error-message");
        if (message) message.remove();
    });
    document.querySelectorAll("input, select, textarea").forEach(function (field) {
        field.setCustomValidity("");
    });
}

function firstFocusableIn(target) {
    if (!target) return null;
    if (typeof target.focus === "function" && target.matches && target.matches("input, select, textarea, button")) {
        return target;
    }
    return target.querySelector("input, select, textarea, button");
}

function focusFirstInvalidField(target) {
    var field = firstFocusableIn(target);
    if (!field) return;
    field.focus({ preventScroll: true });
    field.scrollIntoView({ behavior: "smooth", block: "center" });
    if (typeof field.reportValidity === "function") {
        field.reportValidity();
    }
}

function addValidationError(errors, target, message) {
    if (!target) return;
    showFieldError(target, message);
    errors.push({ target: target, message: message });
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

function normalizeRequestTypeName(value) {
    return (value || "").replace(/\s*\([^)]*\)\s*$/g, "").trim();
}

function isProgramRequestType(typeName) {
    var normalizedName = normalizeRequestTypeName(typeName);
    return normalizedName === "ขอติดตั้งโปรแกรม" || normalizedName === "ขอให้พัฒนาโปรแกรม";
}

function isServerPermissionRequestType(typeName) {
    return normalizeRequestTypeName(typeName) === "ขอใช้สิทธิ์เก็บข้อมูล";
}

function isOtherRequestType(typeName) {
    return normalizeRequestTypeName(typeName) === "อื่นๆ";
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
        if (isProgramRequestType(selectedText)) {
            programNameBox.style.display = "flex";
            programNameInput.required = true;
        } else {
            programNameBox.style.display = "none";
            programNameInput.required = false;
            programNameInput.value = "";
            clearFieldError(programNameInput);
        }
    }
    if (otherRequestBox && otherRequestInput) {
        if (isOtherRequestType(selectedText)) {
            otherRequestBox.style.display = "flex";
            otherRequestInput.required = true;
        } else {
            otherRequestBox.style.display = "none";
            otherRequestInput.required = false;
            otherRequestInput.value = "";
            clearFieldError(otherRequestInput);
        }
    }
    if (serverPermissionBox && serverNameInput && serverFolderInput && subFolderInput) {
        if (isServerPermissionRequestType(selectedText)) {
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
            clearFieldError(serverNameInput);
            clearFieldError(serverFolderInput);
            clearFieldError(subFolderInput);
            clearFieldError(item.querySelector(".permission-group"));
            clearFieldError(item.querySelector(".sub-folder-permission-group"));
        }
    }
}

// ---------- Same-section validation ----------
function getSelectedRequestSection(select) {
    if (!select || !select.value) return null;
    var option = select.options[select.selectedIndex];
    if (!option) return null;
    return { id: option.dataset.secId || "", name: option.dataset.secName || "" };
}

function hasCheckedPermission(item, selector) {
    return Array.prototype.some.call(item.querySelectorAll(selector), function (checkbox) {
        return isVisibleElement(checkbox) && checkbox.checked;
    });
}

function validateSameRequestSection(showAlert, changedSelect) {
    var baseSection = null;
    var invalidTypeName = "";
    var invalidSectionName = "";
    var invalidSelect = null;
    var selects = document.querySelectorAll('select[name="requestType[]"]');
    selects.forEach(function (select, index) {
        select.setCustomValidity("");
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
            invalidSelect = select;
        }
    });
    if (invalidTypeName) {
        var message = invalidTypeName + " เป็นของกลุ่ม " + invalidSectionName + " กรุณาเลือกประเภทคำขอที่อยู่ในกลุ่มเดียวกัน";
        var targetSelect = changedSelect || invalidSelect;
        if (targetSelect) {
            targetSelect.setCustomValidity(message);
            showFieldError(targetSelect, message);
        }
        if (changedSelect) {
            changedSelect.selectedIndex = 0;
            updateSelectColor(changedSelect);
            handleRequestTypeChange(changedSelect);
            changedSelect.setCustomValidity("");
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

function validateRequiredField(errors, field, message) {
    if (isVisibleElement(field) && isBlankValue(field)) {
        addValidationError(errors, field, message);
    }
}

function validateByteLimits(errors, root) {
    (root || document).querySelectorAll("[data-maxbytes]").forEach(function (el) {
        if (!isVisibleElement(el)) return;
        var max = parseInt(el.dataset.maxbytes);
        if (getByteLength(el.value) > max) {
            addValidationError(errors, el, "ข้อมูลเกิน " + max + " bytes");
        }
    });
}

function validateDeadline(errors) {
    var deadlineText = document.getElementById("deadlineText");
    validateRequiredField(errors, deadlineText, "กรุณาระบุ Deadline");
    if (!deadlineText || isBlankValue(deadlineText)) return;

    var parsedDeadline = parseDisplayDate(deadlineText.value);
    if (!parsedDeadline) {
        addValidationError(errors, deadlineText, "กรุณากรอก Deadline เป็นรูปแบบ dd/mm/yyyy");
        return;
    }
    var minIso = deadlineText.dataset.minIso;
    if (minIso && parsedDeadline.iso < minIso) {
        addValidationError(errors, deadlineText, "Deadline ต้องไม่ย้อนหลังจากวันที่ปัจจุบัน");
        return;
    }
    document.getElementById("deadlineIso").value = parsedDeadline.iso;
}

function validateRequestItem(item, index, errors) {
    var itemNumber = index + 1;
    var typeSelect = item.querySelector('select[name="requestType[]"]');
    var objective = item.querySelector('textarea[name="objective[]"]');
    var currentMethod = item.querySelector('textarea[name="currentMethod[]"]');
    var programNameInput = item.querySelector('input[name="programName[]"]');
    var otherRequestInput = item.querySelector('input[name="otherRequest[]"]');
    var serverPermissionBox = item.querySelector(".server-permission-box");
    var serverNameInput = item.querySelector('input[name="serverName[]"]');
    var serverFolderInput = item.querySelector('input[name="serverFolder[]"]');
    var subFolderInput = item.querySelector('input[name="subFolder[]"]');
    var folderPermissionGroup = item.querySelector(".permission-group");
    var subFolderPermissionGroup = item.querySelector(".sub-folder-permission-group");

    validateRequiredField(errors, typeSelect, "กรุณาเลือกประเภทคำขอ รายการที่ " + itemNumber);
    validateRequiredField(errors, objective, "กรุณาระบุวัตถุประสงค์ / ความต้องการ รายการที่ " + itemNumber);

    if (isVisibleElement(programNameInput)) {
        validateRequiredField(errors, programNameInput, "กรุณาระบุชื่อโปรแกรม รายการที่ " + itemNumber);
    }
    if (isVisibleElement(otherRequestInput)) {
        validateRequiredField(errors, otherRequestInput, "กรุณาระบุรายละเอียดคำขอ รายการที่ " + itemNumber);
    }

    if (isVisibleElement(serverPermissionBox)) {
        validateRequiredField(errors, serverNameInput, "กรุณาระบุ Server รายการที่ " + itemNumber);
        validateRequiredField(errors, serverFolderInput, "กรุณาระบุ Folder รายการที่ " + itemNumber);
        if (!hasCheckedPermission(item, 'input[name^="folderPermission"]')) {
            addValidationError(errors, folderPermissionGroup || serverFolderInput, "กรุณาเลือกสิทธิ์ Folder อย่างน้อย 1 รายการ");
        }

        var hasSubFolderName = !isBlankValue(subFolderInput);
        var hasSubFolderPermission = hasCheckedPermission(item, 'input[name^="subFolderPermission"]');
        if (hasSubFolderName && !hasSubFolderPermission) {
            addValidationError(errors, subFolderPermissionGroup || subFolderInput, "กรุณาเลือกสิทธิ์ Sub Folder อย่างน้อย 1 รายการ หรือเว้น Sub Folder ว่างไว้");
        }
        if (!hasSubFolderName && hasSubFolderPermission) {
            addValidationError(errors, subFolderInput, "กรุณาระบุชื่อ Sub Folder หรือยกเลิกการเลือกสิทธิ์ Sub Folder");
        }
    }

    validateByteLimits(errors, item);
    if (currentMethod && !isVisibleElement(currentMethod)) {
        clearFieldError(currentMethod);
    }
}

function validateFormClientSide() {
    var errors = [];
    clearAllValidationErrors();
    validateRequiredField(errors, document.getElementById("requestTopic"), "กรุณาระบุชื่อหัวข้อความต้องการ");
    validateDeadline(errors);

    var items = getActiveRequestItems();
    if (items.length === 0) {
        addValidationError(errors, requestsContainer, "กรุณาเพิ่มรายการคำขออย่างน้อย 1 รายการ");
    }
    items.forEach(function (item, index) {
        validateRequestItem(item, index, errors);
    });

    validateByteLimits(errors, document);
    if (!validateSameRequestSection(false, null)) {
        var invalidSelect = document.querySelector('select[name="requestType[]"]:invalid');
        if (invalidSelect) errors.push({ target: invalidSelect });
    }
    return errors;
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
            clearFieldError(event.target);
            handleRequestTypeChange(event.target);
            validateSameRequestSection(true, event.target);
        }
        if (event.target.classList.contains("select-placeholder")) {
            updateSelectColor(event.target);
        }
    });

    requestsContainer.addEventListener("input", function (event) {
        if (event.target.matches("input, textarea, select")) {
            clearFieldError(event.target);
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
    deadlineDisplayInput.addEventListener("input", function () {
        clearFieldError(this);
        formatDeadlineInput(this);
    });
}

const deadlinePickerInput = document.getElementById("deadlinePicker");
if (deadlinePickerInput) {
    deadlinePickerInput.addEventListener("change", function () {
        const deadlineInput = document.getElementById("deadlineText");
        if (!deadlineInput || !this.value) return;
        var parts = this.value.split("-");
        if (parts.length === 3) {
            deadlineInput.value = parts[2] + "/" + parts[1] + "/" + parts[0];
            clearFieldError(deadlineInput);
        }
    });
}

// ---------- Form submission validation ----------
const requisitionForm = document.querySelector("form");
if (requisitionForm) {
    requisitionForm.addEventListener("submit", function (event) {
        var validationErrors = validateFormClientSide();
        if (validationErrors.length > 0) {
            event.preventDefault();
            focusFirstInvalidField(validationErrors[0].target);
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

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>



