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

    int currentPage  = request.getAttribute("currentPage") != null ? (Integer) request.getAttribute("currentPage") : 1;
    int pageSize     = request.getAttribute("pageSize")    != null ? (Integer) request.getAttribute("pageSize")    : 50;
    String showParam = request.getAttribute("showParam")   != null ? (String)  request.getAttribute("showParam")   : "all";
    String sortParam = request.getAttribute("sortParam")   != null ? (String)  request.getAttribute("sortParam")   : "asc";
    boolean hasData  = !formList.isEmpty();
    // zennnne แก้
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Submitted Requisition Form</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/submit.css">

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flaticon@3/flaticon.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/4.0.0/uicons-regular-rounded/css/uicons-regular-rounded.css">
    <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/4.0.0/uicons-bold-straight/css/uicons-bold-straight.css">
    <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/4.0.0/uicons-regular-straight/css/uicons-regular-straight.css">
    <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/4.0.0/uicons-solid-rounded/css/uicons-solid-rounded.css">
</head>

<body>

<!-- SIDEBAR -->
<div id="mySidebar" class="sidebar">
    <a href="javascript:void(0)" class="closebtn" onclick="toggleNav()">&times;</a>
    <a href="${pageContext.request.contextPath}"><i class="fa-solid fa-house" style="margin-right:10px"></i>หน้าหลัก</a>
    <a href="${pageContext.request.contextPath}/newForm"><i class="fa-solid fa-plus" style="margin-right:10px"></i>สร้างฟอร์มใหม่</a>
    <a href="${pageContext.request.contextPath}/submit"><i class="fa-solid fa-paper-plane" style="margin-right:10px"></i>ฟอร์มที่ส่งแล้ว</a><!-- zennnne แก้ -->
    <a href="${pageContext.request.contextPath}/logout"><i class="fa-solid fa-arrow-right-from-bracket" style="margin-right:10px"></i>ออกจากระบบ</a>
    <a href="${pageContext.request.contextPath}/Admin.jsp" class="admin-tab">
        <i class="fa-solid fa-circle-user"></i>Admin
    </a>
</div>

<div id="main">

    <!-- HEADER -->
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

    <!-- TITLE -->
    <div class="blue-title">
        <h1 style="margin-block-start:0.1em; margin-block-end:0.1em; color:#003366">
            ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินกู้ยืมเพื่อการศึกษา
        </h1>
        <h2 style="margin-block-start:0.1em; margin-block-end:0.1em; color:#003366">
            ใบขอให้ดำเนินการ / Requisition Form
        </h2>
    </div>

    <!-- zennnne แก้ -->
    <!-- FILTER BAR -->
    <div class="filter-bar">
        <div class="filter-tabs">
            <button class="filter-tab" data-filter="all">ทั้งหมด</button>
            <button class="filter-tab" data-filter="pending">รอดำเนินการ</button>
            <button class="filter-tab" data-filter="ready">พร้อมยืนยัน</button>
            <button class="filter-tab" data-filter="approved">อนุมัติแล้ว</button>
            <button class="filter-tab" data-filter="rejected">ปฏิเสธ</button>
            <button class="filter-tab" data-filter="overdue">เกินกำหนด</button>
        </div>
        <div class="sort-controls">
            <span class="sort-label">เรียงตาม Deadline</span>
            <button id="sortAscBtn"  class="sort-btn active" onclick="setSortOrder('deadline','asc')"  title="น้อยไปมาก"><i class="fa-solid fa-arrow-up"></i></button>
            <button id="sortDescBtn" class="sort-btn"        onclick="setSortOrder('deadline','desc')" title="มากไปน้อย"><i class="fa-solid fa-arrow-down"></i></button>
            <!-- zennnne แก้ -->
            <span class="sort-label" style="margin-left:12px">เรียงตาม วันกรอก</span>
            <button id="sortIdAscBtn"  class="sort-btn" onclick="setSortOrder('formid','asc')"  title="เก่าสุดก่อน"><i class="fa-solid fa-arrow-up"></i></button>
            <button id="sortIdDescBtn" class="sort-btn" onclick="setSortOrder('formid','desc')" title="ใหม่สุดก่อน"><i class="fa-solid fa-arrow-down"></i></button>
            <!-- zennnne แก้ -->
        </div>
    </div>
    <!-- zennnne แก้ -->

    <!-- REQUEST LIST -->
    <section class="request-list">

<%
    // zennnne แก้
    for (Map<String, Object> row : formList) {
        int formId    = (Integer) row.get("FORMID");
        String title  = (String)  row.get("TITLEFORM");
        int stateStep = (Integer) row.get("STATE_STEP");
        boolean isEdited = (Integer) row.get("IS_EDITED") == 1;

        java.sql.Date deadlineDate = (java.sql.Date) row.get("DEADLINE");
        java.time.LocalDate today  = java.time.LocalDate.now();
        boolean isOverdue = (deadlineDate != null && deadlineDate.toLocalDate().isBefore(today));

        boolean director1 = false, technical = false, director2 = false, process = false;
        boolean director1Reject = false, technicalReject = false, director2Reject = false, processReject = false;

        if (stateStep >= 0) {
            director1 = stateStep >= 1;
            technical = stateStep >= 2;
            director2 = stateStep >= 3;
            process   = stateStep >= 4;
        }
        if      (stateStep == -1) { director1Reject = true; technicalReject = true; director2Reject = true; processReject = true; }
        else if (stateStep == -2) { director1 = true; technicalReject = true; director2Reject = true; processReject = true; }
        else if (stateStep == -3) { director1 = true; technical = true; director2Reject = true; processReject = true; }
        else if (stateStep == -4) { director1 = true; technical = true; director2 = true; processReject = true; }

        boolean canConfirm  = (stateStep == 4);
        boolean isConfirmed = (stateStep >= 5);

        // zennnne แก้
        String rowStatus;
        if      (stateStep < 0) { rowStatus = "rejected"; }
        else if (isConfirmed)   { rowStatus = "approved"; }
        else if (isOverdue)     { rowStatus = "overdue";  }
        else if (canConfirm)    { rowStatus = "ready";    }
        else                    { rowStatus = "pending";  }

        String rowDeadline     = (deadlineDate != null) ? deadlineDate.toString() : "9999-12-31";
        String deadlineDisplay = "-";
        if (deadlineDate != null) {
            java.time.LocalDate dl = deadlineDate.toLocalDate();
            deadlineDisplay = String.format("%02d/%02d/%d", dl.getDayOfMonth(), dl.getMonthValue(), dl.getYear() + 543);
        }

        String d1Icon   = director1Reject ? "fi fi-sr-cross-circle status-red"   : director1 ? "fi fi-sr-user-trust status-green" : "fi fi-sr-pending status-yellow";
        String techIcon = technicalReject  ? "fi fi-sr-cross-circle status-red"   : technical  ? "fi fi-sr-user-trust status-green" : "fi fi-sr-pending status-yellow";
        String d2Icon   = director2Reject ? "fi fi-sr-cross-circle status-red"   : director2 ? "fi fi-sr-user-trust status-green" : "fi fi-sr-pending status-yellow";
        String procIcon = processReject    ? "fi fi-sr-cross-circle status-red"   : process    ? "fi fi-sr-user-trust status-green" : "fi fi-sr-pending status-yellow";
        // zennnne แก้
%>

        <!-- zennnne แก้ -->
        <div class="request-card" data-status="<%= rowStatus %>" data-deadline="<%= rowDeadline %>" data-formid="<%= formId %>">

            <!-- Card Header -->
            <div class="card-header">
                <div class="card-title-area">
                    <a href="detail.jsp?id=<%= formId %>" class="card-title-link">
                        <%= title %> ที่ <%= formId %>
                    </a>
                </div>
                <span class="deadline-tag <%= rowStatus %>">
                    <i class="fa-regular fa-calendar-days"></i> <%= deadlineDisplay %>
                </span>
            </div>

            <!-- Approval Stepper -->
            <div class="approval-stepper">
                <div class="step">
                    <i class="step-icon <%= d1Icon %>"></i>
                    <span class="step-label">ผู้อำนวยการฝ่าย</span>
                </div>
                <div class="step-connector"></div>
                <div class="step">
                    <i class="step-icon <%= techIcon %>"></i>
                    <span class="step-label">ความเห็นทางเทคนิค</span>
                </div>
                <div class="step-connector"></div>
                <div class="step">
                    <i class="step-icon <%= d2Icon %>"></i>
                    <span class="step-label">ผู้อำนวยการ IT</span>
                </div>
                <div class="step-connector"></div>
                <div class="step">
                    <i class="step-icon <%= procIcon %>"></i>
                    <span class="step-label">ดำเนินการ</span>
                </div>
            </div>

            <!-- Card Footer -->
            <div class="card-footer">
                <% if (stateStep < 0) { %>
                    <% if (!isEdited) { %>
                        <a href="${pageContext.request.contextPath}/editForm?formId=<%= formId %>" style="text-decoration:none;">
                            <button type="button" class="confirm-btn edit-btn">แก้ไขฟอร์ม</button>
                        </a>
                    <% } else { %>
                        <button type="button" class="confirm-btn edit-btn" disabled
                                style="background:#dc2626; border-color:#dc2626; color:white; cursor:not-allowed; opacity:1;">
                            ไม่ผ่านการอนุมัติ
                        </button>
                    <% } %>
                <% } else if (isConfirmed) { %>
                    <button class="confirm-btn confirmed" disabled>ยืนยันผลแล้ว</button>
                <% } else if (isOverdue) { %>
                    <button class="overdue-btn" data-formid="<%= formId %>">
                        <span class="overdue-label-normal">หมดเขต</span>
                        <span class="overdue-label-hover">ยืดเวลาหมดเขต</span>
                    </button>
                <% } else { %>
                    <button class="confirm-btn"
                            data-formid="<%= formId %>"
                            data-expectedstep="<%= stateStep %>"
                            <% if (!canConfirm) { %>disabled style="cursor:not-allowed;"<% } %>>
                        <%= canConfirm ? "ยืนยันผลตรวจรับ" : "รอดำเนินการ" %>
                    </button>
                <% } %>
            </div>

        </div>
        <!-- zennnne แก้ -->

<%
    } // END FOR
    // zennnne แก้

    if (!hasData) {
%>
        <div style="text-align:center; padding:40px;">
            <h3>ยังไม่มีฟอร์มคำร้องของคุณ</h3>
            <a href="${pageContext.request.contextPath}/newForm">
                <button class="confirm-btn">+ สร้างฟอร์มใหม่</button>
            </a>
        </div>
<%
    }
%>
    </section>

    <!-- zennnne แก้ -->
    <!-- Pagination -->
    <div class="pagination">
        <% if (currentPage > 1) { %>
            <a href="?page=<%= currentPage - 1 %>&show=<%= java.net.URLEncoder.encode(showParam, "UTF-8") %>&sort=<%= sortParam %>" style="text-decoration:none;">
                <button type="button" class="page-btn">&#171; ก่อนหน้า</button>
            </a>
        <% } %>
        <span class="page-num">หน้า <%= currentPage %></span>
        <% if (formList.size() == pageSize) { %>
            <a href="?page=<%= currentPage + 1 %>&show=<%= java.net.URLEncoder.encode(showParam, "UTF-8") %>&sort=<%= sortParam %>" style="text-decoration:none;">
                <button type="button" class="page-btn">ถัดไป &#187;</button>
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
let sortOrder = (new URLSearchParams(window.location.search).get('sort')   || 'asc');
let sortField = (new URLSearchParams(window.location.search).get('sortby') || 'deadline');

function applySort() {
    const list  = document.querySelector('.request-list');
    const cards = Array.from(list.querySelectorAll('.request-card'));
    cards.sort(function(a, b) {
        if (sortField === 'formid') {
            const ia = parseInt(a.dataset.formid) || 0;
            const ib = parseInt(b.dataset.formid) || 0;
            return sortOrder === 'asc' ? ia - ib : ib - ia;
        }
        const da = a.dataset.deadline || '9999-12-31';
        const db = b.dataset.deadline || '9999-12-31';
        if (sortOrder === 'asc') return da < db ? -1 : da > db ? 1 : 0;
        return da > db ? -1 : da < db ? 1 : 0;
    });
    cards.forEach(function(c) { list.appendChild(c); });
}

function updateSortButtons() {
    document.getElementById('sortAscBtn').classList.toggle('active',    sortField === 'deadline' && sortOrder === 'asc');
    document.getElementById('sortDescBtn').classList.toggle('active',   sortField === 'deadline' && sortOrder === 'desc');
    document.getElementById('sortIdAscBtn').classList.toggle('active',  sortField === 'formid'   && sortOrder === 'asc');
    document.getElementById('sortIdDescBtn').classList.toggle('active', sortField === 'formid'   && sortOrder === 'desc');
}

function setSortOrder(field, order) {
    sortField = field; sortOrder = order;
    updateSortButtons();
    const sp = new URLSearchParams(window.location.search);
    sp.set('sort', order); sp.set('sortby', field);
    history.replaceState(null, '', '?' + sp.toString());
    applySort();
}

function applyFilterTab(filter, reload) {
    document.querySelectorAll('.filter-tab').forEach(function(tab) {
        tab.classList.toggle('active', tab.dataset.filter === filter);
    });
    if (reload) {
        const sp = new URLSearchParams(window.location.search);
        sp.set('show', filter);
        sp.set('page', '1');
        window.location.href = '?' + sp.toString();
    }
}
// zennnne แก้

function toggleNav() {
    var sidebar = document.getElementById("mySidebar");
    var main    = document.getElementById("main");
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

    // confirm buttons
    document.querySelectorAll(".confirm-btn").forEach(function(button) {
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
        const detail = document.getElementById("popupDetail").value.trim();
        if (detail === "") { alert("กรุณากรอกรายละเอียดก่อนยืนยันผล"); return; }
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
            Object.keys(fields).forEach(function(name) {
                const input = document.createElement("input");
                input.type = "hidden"; input.name = name; input.value = fields[name];
                form.appendChild(input);
            });
            document.body.appendChild(form);
            form.submit();
        }
    });

    // overdue buttons
    document.querySelectorAll(".overdue-btn").forEach(function(btn) {
        btn.addEventListener("click", function () {
            currentOverdueButton = this;
            const today = new Date().toISOString().split("T")[0];
            const input = document.getElementById("popupNewDeadline");
            input.min = today; input.value = "";
            document.getElementById("deadlinePopup").style.display = "flex";
        });
    });

    document.getElementById("deadlineConfirm").addEventListener("click", function () {
        const newDeadline = document.getElementById("popupNewDeadline").value;
        if (!newDeadline) { alert("กรุณาเลือก Deadline ใหม่"); return; }
        if (currentOverdueButton) {
            const form = document.createElement("form");
            form.method = "POST";
            form.action = contextPath + "/ExtendDeadlineServlet";
            const fields = { formId: currentOverdueButton.dataset.formid, newDeadline: newDeadline };
            Object.keys(fields).forEach(function(name) {
                const input = document.createElement("input");
                input.type = "hidden"; input.name = name; input.value = fields[name];
                form.appendChild(input);
            });
            document.body.appendChild(form);
            form.submit();
        }
    });

    // zennnne แก้
    const initShow = new URLSearchParams(window.location.search).get('show') || 'all';
    applyFilterTab(initShow, false);
    updateSortButtons();
    applySort();

    document.querySelectorAll('.filter-tab').forEach(function(tab) {
        tab.addEventListener('click', function() {
            applyFilterTab(this.dataset.filter, true);
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
