<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, com.slf.dao.DBConnection" %>

<%
    /* ===============================
       SESSION CHECK
    =============================== */
    Object empObj = session.getAttribute("empid");

    if (empObj == null) {
        empObj = session.getAttribute("loggedInEmpId");
    }

    if (empObj == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    int empid = Integer.parseInt(empObj.toString());

    // ---------- Pagination ----------
    int currentPage = 1;
    String pageParam = request.getParameter("page");
    if (pageParam != null) {
        try { currentPage = Math.max(1, Integer.parseInt(pageParam)); }
        catch (NumberFormatException e) {}
    }
    int pageSize = 50;
    int offset = (currentPage - 1) * pageSize;
    List<Map<String, Object>> formList = new ArrayList<>();
    // ---------- End Pagination ----------

    // zennnne แก้
    String showParam = request.getParameter("show");
    if (showParam == null || showParam.trim().isEmpty()) showParam = "pending";
    String sortParam = request.getParameter("sort");
    if (!"desc".equals(sortParam)) sortParam = "asc";
    List<String> statusConds = new ArrayList<>();
    for (String s : showParam.split(",")) {
        switch (s.trim().toLowerCase()) {
            case "pending":  statusConds.add("(NVL(ls.STATE_STEP,0) BETWEEN 0 AND 4 AND RF.DEADLINE >= TRUNC(SYSDATE))"); break;
            case "overdue":  statusConds.add("(NVL(ls.STATE_STEP,0) BETWEEN 0 AND 4 AND RF.DEADLINE < TRUNC(SYSDATE))");  break;
            case "rejected": statusConds.add("NVL(ls.STATE_STEP,0) < 0");  break;
            case "approved": statusConds.add("NVL(ls.STATE_STEP,0) >= 5"); break;
        }
    }
    String statusWhere = statusConds.isEmpty() ? "1=0"
        : "(" + String.join(" OR ", statusConds) + ")";
    String orderDir = "desc".equals(sortParam) ? "DESC" : "ASC";
    // zennnne แก้

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    boolean hasData = false;
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
<div id="mySidebar" class="sidebar">
    <a href="javascript:void(0)" class="closebtn" onclick="toggleNav()">&times;</a>
    <a href="${pageContext.request.contextPath}"><i class="fa-solid fa-house" style='margin-right: 10px'></i>หน้าหลัก</a>
    <a href="${pageContext.request.contextPath}/newForm"><i class="fa-solid fa-plus" style='margin-right: 10px'></i>สร้างฟอร์มใหม่</a>
    <a href="${pageContext.request.contextPath}/submit.jsp"><i class="fa-solid fa-paper-plane" style='margin-right: 10px'></i>ฟอร์มที่ส่งแล้ว</a>
    <a href="${pageContext.request.contextPath}/logout"><i class="fa-solid fa-arrow-right-from-bracket" style='margin-right: 10px'></i>ออกจากระบบ</a>
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

    <!-- HEADER TABLE -->
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
            <span>ผู้อำนวยการฝ่ายเทคโนโลยีสารสนเทศ</span>
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
            <button id="sortAscBtn" class="sort-btn active" onclick="setSortOrder('asc')" title="น้อยไปมาก">
                <i class="fa-solid fa-arrow-up"></i>
            </button>
            <button id="sortDescBtn" class="sort-btn" onclick="setSortOrder('desc')" title="มากไปน้อย">
                <i class="fa-solid fa-arrow-down"></i>
            </button>
        </div>
    </div>
    <!-- zennnne แก้ -->

    <!-- REQUEST LIST -->
    <section class="request-list">

<%
try {
    conn = DBConnection.getConnection();

    // zennnne แก้
    String sql =
        "WITH latest_step AS ( " +
        "    SELECT FORMID, STATE_STEP, " +
        "           ROW_NUMBER() OVER (PARTITION BY FORMID ORDER BY APPROVALID DESC) AS RN " +
        "    FROM APPROVALINFO " +
        ") " +
        "SELECT RF.FORMID, RF.TITLEFORM, RF.DEADLINE, RF.IS_EDITED, " +
        "       NVL(ls.STATE_STEP, 0) AS STATE_STEP " +
        "FROM REQUISITIONFORM RF " +
        "LEFT JOIN latest_step ls ON ls.FORMID = RF.FORMID AND ls.RN = 1 " +
        "WHERE RF.EMPID = ? " +
        "AND " + statusWhere + " " +
        "ORDER BY RF.DEADLINE " + orderDir + ", RF.FORMID DESC " +
        "OFFSET ? ROWS FETCH FIRST ? ROWS ONLY";
    // zennnne แก้

    pstmt = conn.prepareStatement(sql);
    pstmt.setInt(1, empid);
    pstmt.setInt(2, offset);
    pstmt.setInt(3, pageSize);
    rs = pstmt.executeQuery();

    while (rs.next()) {
        hasData = true;

        int formId = rs.getInt("FORMID");
        String title = rs.getString("TITLEFORM");
        int stateStep = rs.getInt("STATE_STEP");
        boolean isEdited = rs.getInt("IS_EDITED") == 1;

        // For pagination: store a dummy entry to count rows
        Map<String, Object> rowMap = new HashMap<>();
        rowMap.put("formId", formId);
        formList.add(rowMap);

        java.sql.Date deadlineDate = rs.getDate("DEADLINE");
        java.time.LocalDate today = java.time.LocalDate.now();
        boolean isOverdue = (deadlineDate != null &&
            deadlineDate.toLocalDate().isBefore(today));

        boolean director1 = false;
        boolean technical = false;
        boolean director2 = false;
        boolean process = false;

        boolean director1Reject = false;
        boolean technicalReject = false;
        boolean director2Reject = false;
        boolean processReject = false;

        if (stateStep >= 0) {
            director1 = stateStep >= 1;
            technical = stateStep >= 2;
            director2 = stateStep >= 3;
            process   = stateStep >= 4;
        }

        if (stateStep == -1) {
            director1Reject = true;
            technicalReject = true;
            director2Reject = true;
            processReject   = true;
        } else if (stateStep == -2) {
            director1 = true;
            technicalReject = true;
            director2Reject = true;
            processReject   = true;
        } else if (stateStep == -3) {
            director1 = true;
            technical = true;
            director2Reject = true;
            processReject   = true;
        } else if (stateStep == -4) {
            director1 = true;
            technical = true;
            director2 = true;
            processReject = true;
        }

        boolean canConfirm = (stateStep == 4);
        boolean isConfirmed = (stateStep >= 5);

        // zennnne แก้
        String rowStatus;
        if      (stateStep < 0) { rowStatus = "rejected"; }
        else if (isConfirmed)   { rowStatus = "approved"; }
        else if (isOverdue)     { rowStatus = "overdue";  }
        else                    { rowStatus = "pending";  }
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
        <div class="request-row" data-status="<%= rowStatus %>" data-deadline="<%= rowDeadline %>">
            <div class="request-col">
                <a href="detail.jsp?id=<%= formId %>" style="text-decoration:none;">
                    <button type="button" class="request-btn">
                        <%= title %> ที่ <%= formId %>
                    </button>
                </a>
            </div>

            <div class="status-col">
                <i class="<%=
                    director1Reject
                        ? "fi fi-sr-cross-circle status-red"
                        : director1
                            ? "fi fi-sr-user-trust status-green"
                            : "fi fi-sr-pending status-yellow"
                %>"></i>
            </div>
            <div class="status-col">
                <i class="<%=
                    technicalReject
                        ? "fi fi-sr-cross-circle status-red"
                        : technical
                            ? "fi fi-sr-user-trust status-green"
                            : "fi fi-sr-pending status-yellow"
                %>"></i>
            </div>
            <div class="status-col">
                <i class="<%=
                    director2Reject
                        ? "fi fi-sr-cross-circle status-red"
                        : director2
                            ? "fi fi-sr-user-trust status-green"
                            : "fi fi-sr-pending status-yellow"
                %>"></i>
            </div>
            <div class="status-col">
                <i class="<%=
                    processReject
                        ? "fi fi-sr-cross-circle status-red"
                        : process
                            ? "fi fi-sr-user-trust status-green"
                            : "fi fi-sr-pending status-yellow"
                %>"></i>
            </div>

            <div class="confirm-col">

                <% if (stateStep < 0) { %>

                    <% if (!isEdited) { %>
                        <a href="${pageContext.request.contextPath}/editForm?formId=<%= formId %>"
                           style="text-decoration:none;">
                            <button type="button" class="confirm-btn edit-btn">แก้ไขฟอร์ม</button>
                        </a>
                    <% } else { %>
                        <button type="button" class="confirm-btn edit-btn" disabled
                                style="background:#dc2626; border-color:#dc2626; color:white; cursor:not-allowed; opacity:1;">
                            ไม่ผ่านการอนุมัติ
                        </button>
                    <% } %>
                    <!-- zennnne แก้ -->
                    <span class="deadline-tag rejected">
                        <i class="fa-regular fa-calendar-days"></i> <%= deadlineDisplay %>
                    </span>
                    <!-- zennnne แก้ -->

                <% } else if (isConfirmed) { %>
                    <button class="confirm-btn confirmed" disabled>ยืนยันผลแล้ว</button>
                    <!-- zennnne แก้ -->
                    <span class="deadline-tag approved">
                        <i class="fa-regular fa-calendar-days"></i> <%= deadlineDisplay %>
                    </span>
                    <!-- zennnne แก้ -->

                <% } else if (isOverdue) { %>
                    <button class="overdue-btn" data-formid="<%= formId %>">
                        <span class="overdue-label-normal">หมดเขต</span>
                        <span class="overdue-label-hover">ยืดเวลาหมดเขต</span>
                    </button>
                    <!-- zennnne แก้ -->
                    <span class="deadline-tag overdue">
                        <i class="fa-regular fa-calendar-days"></i> <%= deadlineDisplay %>
                    </span>
                    <!-- zennnne แก้ -->

                <% } else { %>
                    <button class="confirm-btn<%= canConfirm ? "" : "" %>"
                            data-formid="<%= formId %>"
                            <% if (!canConfirm) { %>
                                disabled
                                style="cursor:not-allowed;"
                            <% } %>>
                        <%= canConfirm ? "ยืนยันผลตรวจรับ" : "รอดำเนินการ" %>
                    </button>
                    <!-- zennnne แก้ -->
                    <span class="deadline-tag <%= canConfirm ? "ready" : "pending" %>">
                        <i class="fa-regular fa-calendar-days"></i> <%= deadlineDisplay %>
                    </span>
                    <!-- zennnne แก้ -->

                <% } %>

            </div>
        </div>

<%
    } // END WHILE

    if (!hasData) {
%>
        <div style="text-align:center; padding:40px;">
            <h3>ยังไม่มีฟอร์มคำร้องของคุณ</h3>
            <a href="${pageContext.request.contextPath}/newForm">
                <button class="request-btn">+ สร้างฟอร์มใหม่</button>
            </a>
        </div>
<%
    }
} catch (Exception e) {
%>
        <div style="color:red; text-align:center; padding:20px;">
            <h3>เกิดข้อผิดพลาด</h3>
            <p><%= e.getMessage() %></p>
        </div>
<%
    e.printStackTrace();
} finally {
    try { if (rs != null) rs.close(); } catch (Exception ignored) {}
    try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
    try { if (conn != null) conn.close(); } catch (Exception ignored) {}
}
%>
    </section>

    <!-- zennnne แก้ -->
    <!-- Pagination -->
    <div class="pagination" style="display:flex; gap:16px; align-items:center; justify-content:center; padding:20px 0;">
        <% if (currentPage > 1) { %>
            <a href="?page=<%= currentPage - 1 %>&show=<%= java.net.URLEncoder.encode(showParam, "UTF-8") %>&sort=<%= sortParam %>" style="text-decoration:none;">
                <button type="button" class="request-btn">« ก่อนหน้า</button>
            </a>
        <% } %>
        <span style="font-family:'DB Helvethaica X 55 Regular',sans-serif; color:#003366;">หน้า <%= currentPage %></span>
        <% if (formList.size() == pageSize) { %>
            <a href="?page=<%= currentPage + 1 %>&show=<%= java.net.URLEncoder.encode(showParam, "UTF-8") %>&sort=<%= sortParam %>" style="text-decoration:none;">
                <button type="button" class="request-btn">ถัดไป »</button>
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

function applySort() {
    const list = document.querySelector('.request-list');
    const rows = Array.from(list.querySelectorAll('.request-row'));
    rows.sort(function(a, b) {
        const da = a.dataset.deadline || '9999-12-31';
        const db = b.dataset.deadline || '9999-12-31';
        if (sortOrder === 'asc') return da < db ? -1 : da > db ? 1 : 0;
        return da > db ? -1 : da < db ? 1 : 0;
    });
    rows.forEach(function(row) { list.appendChild(row); });
}

function setSortOrder(order) {
    sortOrder = order;
    document.getElementById('sortAscBtn').classList.toggle('active',  order === 'asc');
    document.getElementById('sortDescBtn').classList.toggle('active', order === 'desc');
    const sp = new URLSearchParams(window.location.search);
    sp.set('sort', order);
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
            const fields = {
                formId: currentButton.dataset.formid,
                action: "approve",
                redirectPage: "submit.jsp",
                comment: detail
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
    const initParams = new URLSearchParams(window.location.search);
    const initShow   = (initParams.get('show') || 'pending').split(',').map(function(s) { return s.trim(); });
    document.querySelectorAll('.filter-checkboxes input').forEach(function(cb) {
        cb.checked = initShow.includes(cb.value);
    });
    document.getElementById('sortAscBtn').classList.toggle('active',  sortOrder === 'asc');
    document.getElementById('sortDescBtn').classList.toggle('active', sortOrder === 'desc');
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