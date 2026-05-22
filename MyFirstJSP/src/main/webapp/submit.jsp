<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>

<%
    // zennnne แก้
    if (session.getAttribute("loggedInEmpId") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> formList = (List<Map<String, Object>>) request.getAttribute("formList");
    if (formList == null) formList = new ArrayList<>();

    int currentPage = request.getAttribute("currentPage") != null ? (Integer) request.getAttribute("currentPage") : 1;
    int pageSize    = request.getAttribute("pageSize")    != null ? (Integer) request.getAttribute("pageSize")    : 50;
    String showParam = request.getAttribute("showParam")  != null ? (String) request.getAttribute("showParam")   : "pending";
    String sortParam = request.getAttribute("sortParam")  != null ? (String) request.getAttribute("sortParam")   : "asc";
    boolean hasData  = !formList.isEmpty();
    // zennnne แก้
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Submitted Requisition Form</title>

    <!-- CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/submit.css">

    <!-- ICON -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flaticon@3/flaticon.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/4.0.0/uicons-regular-rounded/css/uicons-regular-rounded.css">
    <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/4.0.0/uicons-bold-straight/css/uicons-bold-straight.css">
    <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/4.0.0/uicons-regular-straight/css/uicons-regular-straight.css">
    <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/4.0.0/uicons-solid-rounded/css/uicons-solid-rounded.css">
</head>

<body>

<!-- ===============================
     SIDEBAR
================================ -->
<%@ include file="/WEB-INF/sidebar.jsp" %>

<div id="main">

    <!-- HEADER -->
    <div class="sticky-bar">
        <i id="menuBtn" class="fa-solid fa-bars" onclick="toggleNav()"></i>
        <img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF Logo">
        <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo">

        <div class="user-info">
            <i class="fa fa-circle-user"></i>
            <p>
                ${sessionScope.loggedInEmpName} | ID: ${sessionScope.loggedInEmpId}
            </p>
        </div>
        <div class="contact-info">
            <i class="fa-solid fa-circle-info"></i>
            <p>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
        </div>
    </div>

    <!-- TITLE -->
    <div class="blue-title">
        <h1 style="margin-block-start:0.1em; margin-block-end:0.1em;color:#003366">
            ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินกู้ยืมเพื่อการศึกษา
        </h1>

        <h2 style="margin-block-start:0.1em; margin-block-end:0.1em;color:#003366">
            ใบขอให้ดำเนินการ / Requisition Form
        </h2>
    </div>

    <!-- zennnne แก้ — SUMMARY DASHBOARD + SEARCH -->
    <div class="summary-wrap">
        <div class="summary-cards">
            <div class="summary-card sc-total" data-filter="all" title="แสดงทั้งหมด">
                <div class="sc-label"><i class="fa-solid fa-clipboard-list"></i> ทั้งหมด</div>
                <div class="sc-count" id="cnt-total">0</div>
            </div>
            <div class="summary-card sc-pending" data-filter="pending" title="คลิกเพื่อ filter เฉพาะรอดำเนินการ">
                <div class="sc-label"><i class="fa-solid fa-hourglass-half"></i> รอดำเนินการ</div>
                <div class="sc-count" id="cnt-pending">0</div>
            </div>
            <div class="summary-card sc-overdue" data-filter="overdue" title="คลิกเพื่อ filter เฉพาะหมดเขต">
                <div class="sc-label"><i class="fa-solid fa-triangle-exclamation"></i> หมดเขต</div>
                <div class="sc-count" id="cnt-overdue">0</div>
            </div>
            <div class="summary-card sc-rejected" data-filter="rejected" title="คลิกเพื่อ filter เฉพาะไม่ผ่าน">
                <div class="sc-label"><i class="fa-solid fa-circle-xmark"></i> ไม่ผ่าน</div>
                <div class="sc-count" id="cnt-rejected">0</div>
            </div>
            <div class="summary-card sc-approved" data-filter="approved" title="คลิกเพื่อ filter เฉพาะอนุมัติแล้ว">
                <div class="sc-label"><i class="fa-solid fa-circle-check"></i> ผ่าน</div>
                <div class="sc-count" id="cnt-approved">0</div>
            </div>
        </div>

        <div class="search-wrap" id="searchWrap">
            <i class="fa-solid fa-magnifying-glass"></i>
            <input type="text" id="searchInput" class="search-input" placeholder="ค้นหาฟอร์ม..." autocomplete="off">
            <button type="button" class="search-clear" id="searchClear" title="ล้าง">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
    </div>
    <div class="summary-hint">* จำนวนนับเฉพาะหน้าปัจจุบัน — กดที่ card เพื่อ filter ดูทั้งหมด</div>
    <!-- zennnne แก้ -->

    <!-- HEADER TABLE (legacy hidden — kept for backward compat) -->
    <section class="progress-header">
        <div class="header-item"><i class="fi fi-rr-form"></i><span>จำนวนใบขอให้ดำเนินการทั้งหมด</span></div>
        <div class="header-item"><i class="fi fi-bs-user"></i><span>ผู้อำนวยการฝ่าย</span></div>
        <div class="header-item"><i class="fi fi-rr-it-alt"></i><span>ความเห็นและการอนุมัติเชิงเทคนิค</span></div>
        <div class="header-item"><i class="fi fi-bs-user"></i><span>ผู้อำนวยการฝ่ายเทคโนโลยีสารสนเทศ</span></div>
        <div class="header-item"><i class="fa-solid fa-gears"></i><span>ขั้นตอนการดำเนินการ</span></div>
        <div class="header-item"><i class="fi fi-rr-confirmed-user"></i><span>ผลตรวจรับ</span></div>
    </section>

    <!-- zennnne แก้ -->
    <!-- FILTER BAR -->
    <div class="filter-bar">
        <div class="filter-checkboxes">
            <label class="filter-label pending-label">
                <input type="checkbox" value="pending" checked> รอดำเนินการ
            </label>
            <label class="filter-label overdue-label">
                <input type="checkbox" value="overdue"> หมดเขต
            </label>
            <label class="filter-label rejected-label">
                <input type="checkbox" value="rejected"> ไม่ผ่านการอนุมัติ
            </label>
            <label class="filter-label approved-label">
                <input type="checkbox" value="approved"> อนุมัติแล้ว
            </label>
        </div>
        <div class="sort-controls">
            <span class="sort-label">เรียงตาม Deadline</span>
            <button id="sortAscBtn" class="sort-btn active" onclick="setSortOrder('deadline','asc')" title="น้อยไปมาก">
                <i class="fa-solid fa-arrow-up"></i>
            </button>
            <button id="sortDescBtn" class="sort-btn" onclick="setSortOrder('deadline','desc')" title="มากไปน้อย">
                <i class="fa-solid fa-arrow-down"></i>
            </button>
            <!-- zennnne แก้ -->
            <span class="sort-label" style="margin-left:12px;">เรียงตาม วันกรอก</span>
            <button id="sortIdAscBtn" class="sort-btn" onclick="setSortOrder('formid','asc')" title="เก่าสุดก่อน">
                <i class="fa-solid fa-arrow-up"></i>
            </button>
            <button id="sortIdDescBtn" class="sort-btn" onclick="setSortOrder('formid','desc')" title="ใหม่สุดก่อน">
                <i class="fa-solid fa-arrow-down"></i>
            </button>
            <!-- zennnne แก้ -->
        </div>
    </div>
    <!-- zennnne แก้ -->

    <!-- REQUEST LIST -->
    <section class="request-list">

<%
    // zennnne แก้ — labels for timeline steps
    String[] stepLabels = { "ผอ.ฝ่าย", "เทคนิค", "ผอ.IT", "ดำเนินการ" };

    for (Map<String, Object> row : formList) {
        int formId    = (Integer) row.get("FORMID");
        String title  = (String)  row.get("TITLEFORM");
        int stateStep = (Integer) row.get("STATE_STEP");
        boolean isEdited = (Integer) row.get("IS_EDITED") == 1;

        java.sql.Date deadlineDate = (java.sql.Date) row.get("DEADLINE");
        java.time.LocalDate today = java.time.LocalDate.now();
        boolean isOverdue = (deadlineDate != null &&
            deadlineDate.toLocalDate().isBefore(today));

        boolean[] done   = new boolean[4]; // director1, technical, director2, process
        boolean[] reject = new boolean[4];

        if (stateStep >= 0) {
            done[0] = stateStep >= 1;
            done[1] = stateStep >= 2;
            done[2] = stateStep >= 3;
            done[3] = stateStep >= 4;
        }

        if (stateStep == -1) {
            reject[0] = true; reject[1] = true; reject[2] = true; reject[3] = true;
        } else if (stateStep == -2) {
            done[0] = true;  reject[1] = true; reject[2] = true; reject[3] = true;
        } else if (stateStep == -3) {
            done[0] = true;  done[1] = true;  reject[2] = true; reject[3] = true;
        } else if (stateStep == -4) {
            done[0] = true;  done[1] = true;  done[2] = true;  reject[3] = true;
        }

        boolean canConfirm = (stateStep == 4);
        boolean isConfirmed = (stateStep >= 5);

        String rowStatus;
        String rowStatusLabel;
        if      (stateStep < 0) { rowStatus = "rejected"; rowStatusLabel = "ไม่ผ่านการอนุมัติ"; }
        else if (isConfirmed)   { rowStatus = "approved"; rowStatusLabel = "ยืนยันผลแล้ว"; }
        else if (isOverdue)     { rowStatus = "overdue";  rowStatusLabel = "หมดเขต"; }
        else                    { rowStatus = "pending";  rowStatusLabel = "รอดำเนินการ"; }

        String rowDeadline = (deadlineDate != null) ? deadlineDate.toString() : "9999-12-31";
        String deadlineDisplay = "-";
        if (deadlineDate != null) {
            java.time.LocalDate dl = deadlineDate.toLocalDate();
            deadlineDisplay = String.format("%02d/%02d/%d",
                dl.getDayOfMonth(), dl.getMonthValue(), dl.getYear() + 543);
        }
        // zennnne แก้
%>

        <!-- zennnne แก้ -->
        <div class="request-card"
             data-status="<%= rowStatus %>"
             data-deadline="<%= rowDeadline %>"
             data-formid="<%= formId %>"
             data-title="<%= title %>">

            <div class="card-header">
                <div class="card-title-wrap">
                    <span class="card-formid">#<%= formId %></span>
                    <a href="detail.jsp?id=<%= formId %>" class="card-title" title="<%= title %>">
                        <%= title %>
                    </a>
                </div>
                <span class="card-status-badge <%= rowStatus %>"><%= rowStatusLabel %></span>
            </div>

            <div class="progress-timeline">
<%
                for (int i = 0; i < 4; i++) {
                    String stepClass = reject[i] ? "reject" : (done[i] ? "done" : "pending");
                    String iconCls   = reject[i] ? "fa-solid fa-xmark"
                                                 : (done[i] ? "fa-solid fa-check" : "fa-solid fa-clock");
%>
                <div class="tl-step <%= stepClass %>">
                    <span class="tl-dot"><i class="<%= iconCls %>"></i></span>
                    <span class="tl-label"><%= stepLabels[i] %></span>
                </div>
<%
                }
%>
            </div>

            <div class="card-footer">
                <span class="deadline-tag <%= rowStatus %>">
                    <i class="fa-regular fa-calendar-days"></i> Deadline: <%= deadlineDisplay %>
                </span>
                <div>
<%
                if (stateStep < 0) {
                    if (!isEdited) {
%>
                    <a href="${pageContext.request.contextPath}/editForm?formId=<%= formId %>" style="text-decoration:none;">
                        <button type="button" class="confirm-btn edit-btn">แก้ไขฟอร์ม</button>
                    </a>
<%
                    } else {
%>
                    <button type="button" class="confirm-btn edit-btn" disabled
                            style="background:#dc2626; border-color:#dc2626; color:white; cursor:not-allowed; opacity:1;">
                        ไม่ผ่านการอนุมัติ
                    </button>
<%
                    }
                } else if (isConfirmed) {
%>
                    <button class="confirm-btn confirmed" disabled>ยืนยันผลแล้ว</button>
<%
                } else if (isOverdue) {
%>
                    <button class="overdue-btn" data-formid="<%= formId %>">
                        <span class="overdue-label-normal">หมดเขต</span>
                        <span class="overdue-label-hover">ยืดเวลาหมดเขต</span>
                    </button>
<%
                } else {
%>
                    <button class="confirm-btn"
                            data-formid="<%= formId %>"
                            data-expectedstep="<%= stateStep %>"
                            <% if (!canConfirm) { %> disabled style="cursor:not-allowed;" <% } %>>
                        <%= canConfirm ? "ยืนยันผลตรวจรับ" : "รอดำเนินการ" %>
                    </button>
<%
                }
%>
                </div>
            </div>
        </div>
        <!-- zennnne แก้ -->

<%
    } // END FOR

    if (!hasData) {
%>
        <!-- zennnne แก้ — empty state ใหม่ -->
        <div class="empty-state">
            <div class="empty-state-icon"><i class="fa-solid fa-folder-open"></i></div>
            <h3>ยังไม่มีฟอร์มคำร้องของคุณ</h3>
            <p>ยังไม่มีรายการในหมวดที่เลือก ลองปรับ filter ด้านบน หรือสร้างฟอร์มใหม่เพื่อเริ่มต้น</p>
            <a href="${pageContext.request.contextPath}/newForm" class="empty-state-btn">
                <i class="fa-solid fa-plus"></i> สร้างฟอร์มใหม่
            </a>
        </div>
        <!-- zennnne แก้ -->
<%
    }
%>
        <!-- zennnne แก้ — empty search state -->
        <div class="empty-search" id="emptySearch">
            <i class="fa-solid fa-magnifying-glass" style="font-size:32px; color:#ccc; display:block; margin-bottom:10px;"></i>
            ไม่พบฟอร์มที่ตรงกับคำค้นหา
        </div>
        <!-- zennnne แก้ -->
    </section>

    <!-- zennnne แก้ -->
    <!-- Pagination -->
    <div class="pagination">
        <% if (currentPage > 1) { %>
            <a href="?page=<%= currentPage - 1 %>&show=<%= java.net.URLEncoder.encode(showParam, "UTF-8") %>&sort=<%= sortParam %>" style="text-decoration:none;">
                <button type="button" class="page-btn">« ก่อนหน้า</button>
            </a>
        <% } %>
        <span class="page-num">หน้า <%= currentPage %></span>
        <% if (formList.size() == pageSize) { %>
            <a href="?page=<%= currentPage + 1 %>&show=<%= java.net.URLEncoder.encode(showParam, "UTF-8") %>&sort=<%= sortParam %>" style="text-decoration:none;">
                <button type="button" class="page-btn">ถัดไป »</button>
            </a>
        <% } %>
    </div>
    <!-- zennnne แก้ -->
</div>

<!-- CONFIRM POPUP -->
<div id="confirmPopup" class="popup-overlay">
    <div class="popup-box">
        <h3>ยืนยันผล</h3>
        <p>กรุณาระบุรายละเอียดก่อนยืนยันผลรายการนี้</p>
        <textarea id="popupDetail" class="popup-textarea" placeholder="กรอกรายละเอียด / หมายเหตุ..."></textarea>
        <div class="popup-buttons">
            <button id="popupConfirm" class="popup-confirm-btn">ยืนยัน</button>
            <button onclick="closePopup()" class="popup-cancel-btn">ยกเลิก</button>
        </div>
    </div>
</div>

<!-- DEADLINE POPUP -->
<div id="deadlinePopup" class="popup-overlay">
    <div class="popup-box">
        <h3>ยืดเวลาหมดเขต</h3>
        <p>กรุณาเลือก Deadline ใหม่สำหรับรายการนี้</p>
        <input type="date" id="popupNewDeadline" class="popup-date-input">
        <div class="popup-buttons">
            <button id="deadlineConfirm" class="popup-confirm-btn">ยืนยัน</button>
            <button onclick="closeDeadlinePopup()" class="popup-cancel-btn">ยกเลิก</button>
        </div>
    </div>
</div>

<script>
let currentButton = null;
let currentOverdueButton = null;
const contextPath = "<%= request.getContextPath() %>";

// zennnne แก้
let sortOrder = (new URLSearchParams(window.location.search).get('sort') || 'asc');
let sortField = (new URLSearchParams(window.location.search).get('sortby') || 'deadline');

function applySort() {
    const list = document.querySelector('.request-list');
    const cards = Array.from(list.querySelectorAll('.request-card'));
    cards.sort(function(a, b) {
        if (sortField === 'formid') {
            const ia = parseInt(a.dataset.formid) || 0;
            const ib = parseInt(b.dataset.formid) || 0;
            return sortOrder === 'asc' ? ia - ib : ib - ia;
        } else {
            const da = a.dataset.deadline || '9999-12-31';
            const db = b.dataset.deadline || '9999-12-31';
            if (sortOrder === 'asc') return da < db ? -1 : da > db ? 1 : 0;
            return da > db ? -1 : da < db ? 1 : 0;
        }
    });
    cards.forEach(function(c) { list.insertBefore(c, list.querySelector('#emptySearch')); });
}

function updateSortButtons() {
    document.getElementById('sortAscBtn').classList.toggle('active',    sortField === 'deadline' && sortOrder === 'asc');
    document.getElementById('sortDescBtn').classList.toggle('active',   sortField === 'deadline' && sortOrder === 'desc');
    document.getElementById('sortIdAscBtn').classList.toggle('active',  sortField === 'formid'   && sortOrder === 'asc');
    document.getElementById('sortIdDescBtn').classList.toggle('active', sortField === 'formid'   && sortOrder === 'desc');
}

function setSortOrder(field, order) {
    sortField = field;
    sortOrder = order;
    updateSortButtons();
    const sp = new URLSearchParams(window.location.search);
    sp.set('sort', order);
    sp.set('sortby', field);
    history.replaceState(null, '', '?' + sp.toString());
    applySort();
}
// zennnne แก้

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

document.addEventListener("DOMContentLoaded", function () {
    // zennnne แก้ — summary cards: count per status
    const allCards = document.querySelectorAll('.request-card');
    const counts = { all: allCards.length, pending: 0, overdue: 0, rejected: 0, approved: 0 };
    allCards.forEach(function(c) {
        const s = c.dataset.status;
        if (counts[s] !== undefined) counts[s]++;
    });
    document.getElementById('cnt-total').textContent    = counts.all;
    document.getElementById('cnt-pending').textContent  = counts.pending;
    document.getElementById('cnt-overdue').textContent  = counts.overdue;
    document.getElementById('cnt-rejected').textContent = counts.rejected;
    document.getElementById('cnt-approved').textContent = counts.approved;

    // highlight active summary card based on current filter
    const initParams = new URLSearchParams(window.location.search);
    const initShow   = (initParams.get('show') || 'pending').split(',').map(function(s) { return s.trim(); });
    document.querySelectorAll('.summary-card').forEach(function(card) {
        const f = card.dataset.filter;
        if (f === 'all') {
            if (initShow.length === 4) card.classList.add('active');
        } else if (initShow.length === 1 && initShow[0] === f) {
            card.classList.add('active');
        }
    });

    // summary card click → set filter (reload with new show=)
    document.querySelectorAll('.summary-card').forEach(function(card) {
        card.addEventListener('click', function() {
            const f = this.dataset.filter;
            const sp = new URLSearchParams(window.location.search);
            if (f === 'all') {
                sp.set('show', 'pending,overdue,rejected,approved');
            } else {
                sp.set('show', f);
            }
            sp.set('page', '1');
            window.location.href = '?' + sp.toString();
        });
    });

    // search input — client-side filter on visible cards
    const searchInput = document.getElementById('searchInput');
    const searchWrap  = document.getElementById('searchWrap');
    const searchClear = document.getElementById('searchClear');
    const emptySearch = document.getElementById('emptySearch');

    function runSearch() {
        const q = searchInput.value.trim().toLowerCase();
        searchWrap.classList.toggle('has-text', q.length > 0);
        let visible = 0;
        document.querySelectorAll('.request-card').forEach(function(c) {
            const t = (c.dataset.title || '').toLowerCase();
            const id = (c.dataset.formid || '').toString();
            const match = q === '' || t.includes(q) || id.includes(q);
            c.style.display = match ? '' : 'none';
            if (match) visible++;
        });
        emptySearch.style.display = (q !== '' && visible === 0) ? 'block' : 'none';
    }

    searchInput.addEventListener('input', runSearch);
    searchClear.addEventListener('click', function() {
        searchInput.value = '';
        runSearch();
        searchInput.focus();
    });
    // zennnne แก้

    document.querySelectorAll(".confirm-btn").forEach(button => {
        if (button.closest("a")) return;
        button.addEventListener("click", function () {
            if (this.disabled) {
                alert("ยังไม่สามารถยืนยันผลได้ เนื่องจากขั้นตอนยังไม่เสร็จ");
                return;
            }
            currentButton = this;
            document.getElementById("confirmPopup").style.display = "flex";
        });
    });

    document.getElementById("popupConfirm").addEventListener("click", function () {
        let detail = document.getElementById("popupDetail").value.trim();
        if (detail === "") {
            alert("กรุณากรอกรายละเอียดก่อนยืนยันผล");
            return;
        }
        if (currentButton) {
            const form = document.createElement("form");
            form.method = "POST";
            form.action = contextPath + "/SubmitApprovalServlet";
            // zennnne แก้
            const fields = {
                formId: currentButton.dataset.formid,
                action: "approve",
                expectedStep: currentButton.dataset.expectedstep,
                redirectPage: "submit",
                comment: detail
            };
            // zennnne แก้
            Object.keys(fields).forEach(function (name) {
                const input = document.createElement("input");
                input.type = "hidden";
                input.name = name;
                input.value = fields[name];
                form.appendChild(input);
            });
            document.body.appendChild(form);
            form.submit();
        }
    });

    document.querySelectorAll(".overdue-btn").forEach(function (btn) {
        btn.addEventListener("click", function () {
            currentOverdueButton = this;
            const today = new Date().toISOString().split("T")[0];
            const input = document.getElementById("popupNewDeadline");
            input.min = today;
            input.value = "";
            document.getElementById("deadlinePopup").style.display = "flex";
        });
    });

    document.getElementById("deadlineConfirm").addEventListener("click", function () {
        const newDeadline = document.getElementById("popupNewDeadline").value;
        if (!newDeadline) {
            alert("กรุณาเลือก Deadline ใหม่");
            return;
        }
        if (currentOverdueButton) {
            const form = document.createElement("form");
            form.method = "POST";
            form.action = contextPath + "/ExtendDeadlineServlet";
            const fields = {
                formId: currentOverdueButton.dataset.formid,
                newDeadline: newDeadline
            };
            Object.keys(fields).forEach(function (name) {
                const input = document.createElement("input");
                input.type = "hidden";
                input.name = name;
                input.value = fields[name];
                form.appendChild(input);
            });
            document.body.appendChild(form);
            form.submit();
        }
    });

    // zennnne แก้
    document.querySelectorAll('.filter-checkboxes input').forEach(function(cb) {
        cb.checked = initShow.includes(cb.value);
    });
    updateSortButtons();
    applySort();

    document.querySelectorAll('.filter-checkboxes input').forEach(function(cb) {
        cb.addEventListener('change', function() {
            const checked = Array.from(document.querySelectorAll('.filter-checkboxes input:checked'))
                .map(function(c) { return c.value; });
            const sp = new URLSearchParams(window.location.search);
            sp.set('show', checked.length > 0 ? checked.join(',') : 'none');
            sp.set('page', '1');
            window.location.href = '?' + sp.toString();
        });
    });
    // zennnne แก้
});

function closePopup() {
    document.getElementById("confirmPopup").style.display = "none";
    document.getElementById("popupDetail").value = "";
}

function closeDeadlinePopup() {
    document.getElementById("deadlinePopup").style.display = "none";
    document.getElementById("popupNewDeadline").value = "";
}
</script>

</body>
</html>
