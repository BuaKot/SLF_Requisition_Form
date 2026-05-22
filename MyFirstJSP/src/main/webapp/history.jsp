<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, com.slf.dao.DBConnection, java.text.SimpleDateFormat" %>

<%
    /* ===============================
       SESSION CHECK
    =============================== */
    Object empObj = session.getAttribute("empid");
    if (empObj == null) empObj = session.getAttribute("loggedInEmpId");
    if (empObj == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    int empid = Integer.parseInt(empObj.toString());

    String currentRole = (String) session.getAttribute("position");
    if (currentRole == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    /* ===============================
       PAGINATION
    =============================== */
    int currentPage = 1;
    String pageParam = request.getParameter("page");
    if (pageParam != null) {
        try { currentPage = Math.max(1, Integer.parseInt(pageParam)); }
        catch (NumberFormatException ignored) {}
    }
    int pageSize = 50;
    int offset   = (currentPage - 1) * pageSize;

    /* ===============================
       ROLE-BASED SQL FILTER
    =============================== */
    // zennnne แก้
    String roleWhere    = "";
    boolean needsEmpParam = false;

    if (currentRole.equalsIgnoreCase("Director")) {
        roleWhere     = "AND D.DEPTHEAD_EMPID = ? ";
        needsEmpParam = true;
    } else if (
        currentRole.equalsIgnoreCase("Technical")       ||
        currentRole.equalsIgnoreCase("Development")     ||
        currentRole.equalsIgnoreCase("Data")            ||
        currentRole.equalsIgnoreCase("Infrastructure")  ||
        currentRole.equalsIgnoreCase("Cyber Security")  ||
        currentRole.equalsIgnoreCase("Reseach")         ||
        currentRole.equalsIgnoreCase("IT Planning")
    ) {
        roleWhere     = "AND RF.ASSIGN_SECID = (SELECT SECID FROM EMPLOYEE WHERE EMPID = ?) ";
        needsEmpParam = true;
    }
    // Admin, ITDirector → no additional filter (see all completed forms)
    // zennnne แก้

    // zennnne แก้
    String showParam = request.getParameter("show");
    if (showParam == null || showParam.trim().isEmpty()) showParam = "rejected,approved";
    String sortParam = request.getParameter("sort");
    if (!"desc".equals(sortParam)) sortParam = "asc";
    List<String> statusConds = new ArrayList<>();
    for (String s : showParam.split(",")) {
        switch (s.trim().toLowerCase()) {
            case "rejected": statusConds.add("ls.STATE_STEP < 0");  break;
            case "approved": statusConds.add("ls.STATE_STEP >= 5"); break;
        }
    }
    String histStatusWhere = statusConds.isEmpty() ? "1=0"
        : "(" + String.join(" OR ", statusConds) + ")";
    String orderDir = "desc".equals(sortParam) ? "DESC" : "ASC";
    // zennnne แก้

    List<Map<String, Object>> formList = new ArrayList<>();
    boolean hasData = false;
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
%>

<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ประวัติใบขอให้ดำเนินการ</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            background: #f2f2f2;
            font-family: 'DB Helvethaica X 55 Regular', 'DBHelvethaica', 'Sarabun', sans-serif;
        }

        /* ─── BLUE TITLE ─── */
        .blue-title {
            background: #d9ebf5;
            text-align: center;
            padding: 18px;
        }
        .blue-title h1 {
            font-size: clamp(18px, 3vw, 28px);
            color: #003366;
            margin-block-start: 0.1em;
            margin-block-end: 0.1em;
        }
        .blue-title h2 {
            font-size: clamp(14px, 2.5vw, 22px);
            color: #003366;
            margin-block-start: 0.1em;
            margin-block-end: 0.1em;
        }

        /* ─── FILTER BAR ─── */
        .filter-bar {
            display: flex;
            align-items: center;
            padding: 14px 24px;
            background: #fff;
            border-bottom: 2px solid #e0e0e0;
            box-shadow: 0 3px 8px rgba(0,0,0,0.06);
            gap: 10px;
            flex-wrap: wrap;
        }

        .filter-checkboxes {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            align-items: center;
        }

        .filter-label {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 15px;
            font-family: inherit;
            cursor: pointer;
            padding: 7px 16px 7px 12px;
            border-radius: 999px;
            border: 2px solid #ddd;
            background: #f5f5f5;
            color: #888;
            transition: all 0.18s ease;
            user-select: none;
            white-space: nowrap;
        }

        .filter-label::before {
            content: '';
            width: 10px; height: 10px;
            border-radius: 50%;
            border: 2px solid #bbb;
            display: inline-block;
            flex-shrink: 0;
            transition: all 0.18s ease;
        }

        .filter-label input[type="checkbox"] { display: none; }

        /* rejected (dark red) */
        .rejected-label:hover               { border-color: #b71c1c; color: #b71c1c; }
        .rejected-label:hover::before       { border-color: #b71c1c; }
        .rejected-label:has(input:checked)  { border-color: #b71c1c; background: #fce8e8; color: #7f1414; }
        .rejected-label:has(input:checked)::before { border-color: #b71c1c; background: #b71c1c; }

        /* approved (green) */
        .approved-label:hover               { border-color: #2dbb00; color: #1e8000; }
        .approved-label:hover::before       { border-color: #2dbb00; }
        .approved-label:has(input:checked)  { border-color: #2dbb00; background: #f0fce8; color: #1e8000; }
        .approved-label:has(input:checked)::before { border-color: #2dbb00; background: #2dbb00; }

        /* sort controls */
        .sort-controls {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-left: auto;
            flex-shrink: 0;
        }

        .sort-label {
            font-size: 15px;
            font-family: inherit;
            color: #555;
            white-space: nowrap;
        }

        .sort-btn {
            background: #fff;
            border: 2px solid #ccc;
            border-radius: 8px;
            width: 36px; height: 36px;
            font-size: 14px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.18s ease;
            color: #888;
        }

        .sort-btn:hover              { border-color: #003366; color: #003366; background: #f0f4ff; }
        .sort-btn.active             { background: #003366; border-color: #003366; color: #fff; box-shadow: 0 2px 6px rgba(0,51,102,0.28); }

        /* ─── HISTORY LIST ─── */
        .history-list {
            max-width: 1360px;
            margin: 20px auto;
            padding: 0 20px;
        }

        .history-card {
            display: flex;
            align-items: center;
            background: #fff;
            border: 1px solid #ccc;
            border-radius: 12px;
            padding: 14px 20px;
            margin-bottom: 10px;
            gap: 16px;
            cursor: pointer;
            transition: all 0.2s ease;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }

        .history-card:hover {
            border-color: #3272BB;
            transform: translateY(-1px);
            box-shadow: 0 6px 16px rgba(50,114,187,0.15);
        }

        .card-id-box {
            border: 1px solid #333;
            border-radius: 8px;
            padding: 6px 14px;
            min-width: 190px;
            text-align: center;
            font-weight: bold;
            font-size: 15px;
            flex-shrink: 0;
        }

        .card-info { flex-grow: 1; min-width: 0; }

        .info-row {
            display: grid;
            grid-template-columns: minmax(140px,1fr) minmax(160px,1fr) minmax(160px,1fr) minmax(120px,auto);
            column-gap: 12px;
            row-gap: 4px;
            margin-bottom: 5px;
            font-size: 15px;
        }

        .info-item { min-width: 0; overflow-wrap: anywhere; }
        .info-item b  { color: #3272BB; }
        .detail-line  { font-size: 15px; overflow-wrap: anywhere; }
        .detail-line b { color: #3272BB; }

        .status-badge {
            flex-shrink: 0;
            padding: 6px 16px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: bold;
            white-space: nowrap;
        }

        .badge-approved { background: #f0fce8; color: #1e8000; border: 2px solid #2dbb00; }
        .badge-rejected { background: #fce8e8; color: #7f1414; border: 2px solid #b71c1c; }

        .card-arrow { color: #ccc; flex-shrink: 0; font-size: 14px; }

        /* zennnne แก้ */
        .deadline-tag {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            font-size: 13px;
            font-family: inherit;
            padding: 3px 12px;
            border-radius: 20px;
            border: 1px solid;
            white-space: nowrap;
        }
        .deadline-tag.approved { color: #1e8000; background: #f0fce8; border-color: #2dbb00; }
        .deadline-tag.rejected { color: #888;    background: #f5f5f5; border-color: #ccc; }
        /* zennnne แก้ */

        /* ─── PAGINATION ─── */
        .pagination {
            display: flex;
            gap: 16px;
            align-items: center;
            justify-content: center;
            padding: 24px 0 32px;
        }

        .page-btn {
            border: 2px solid #666;
            background: white;
            border-radius: 8px;
            padding: 10px 22px;
            font-size: 16px;
            font-family: inherit;
            cursor: pointer;
            transition: all 0.2s;
        }

        .page-btn:hover { background: #f5f5f5; }
        .page-num       { font-family: inherit; color: #003366; font-size: 16px; }

        /* ─── EMPTY STATE ─── */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #aaa;
            font-size: 18px;
        }

        .empty-state i { font-size: 56px; display: block; margin-bottom: 16px; }

        /* ─── RESPONSIVE ─── */
        @media (max-width: 900px) {
            .history-card   { flex-direction: column; align-items: flex-start; }
            .card-id-box    { width: 100%; }
            .info-row       { grid-template-columns: 1fr 1fr; }
            .status-badge   { align-self: flex-end; }
        }

        @media (max-width: 540px) {
            .info-row { grid-template-columns: 1fr; }
            .filter-bar { padding: 12px 16px; }
        }
    </style>
</head>

<body>

<!-- ===============================
     SIDEBAR
================================ -->
<div id="mySidebar" class="sidebar">
    <a href="javascript:void(0)" class="closebtn" onclick="toggleNav()">&times;</a>
    <a href="${pageContext.request.contextPath}">
        <i class="fa-solid fa-house" style="margin-right:10px"></i>หน้าหลัก
    </a>
    <a href="${pageContext.request.contextPath}/newForm">
        <i class="fa-solid fa-plus" style="margin-right:10px"></i>สร้างฟอร์มใหม่
    </a>
    <a href="${pageContext.request.contextPath}/submit"><!-- zennnne แก้ -->
        <i class="fa-solid fa-paper-plane" style="margin-right:10px"></i>ฟอร์มที่ส่งแล้ว
    </a>
    <a href="${pageContext.request.contextPath}/logout">
        <i class="fa-solid fa-arrow-right-from-bracket" style="margin-right:10px"></i>ออกจากระบบ
    </a>
    <a href="${pageContext.request.contextPath}/Admin.jsp" class="admin-tab">
        <i class="fa-solid fa-circle-user"></i>Admin
    </a>
</div>

<div id="main">

    <!-- STICKY BAR -->
    <div class="sticky-bar">
        <i id="menuBtn" class="fa-solid fa-bars" onclick="toggleNav()"></i>
        <img src="${pageContext.request.contextPath}/images/MoF.png"  alt="MoF Logo">
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

    <!-- BLUE TITLE -->
    <div class="blue-title">
        <h1>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินกู้ยืมเพื่อการศึกษา</h1>
        <h2>ประวัติใบขอให้ดำเนินการ / History</h2>
    </div>

    <!-- zennnne แก้ -->
    <!-- FILTER BAR -->
    <div class="filter-bar">
        <div class="filter-checkboxes">
            <label class="filter-label rejected-label">
                <input type="checkbox" value="rejected" checked> ไม่ผ่านการอนุมัติ
            </label>
            <label class="filter-label approved-label">
                <input type="checkbox" value="approved" checked> อนุมัติแล้ว
            </label>
        </div>
        <div class="sort-controls">
            <span class="sort-label">เรียงตาม Deadline</span>
            <button id="sortAscBtn"  class="sort-btn active" onclick="setSortOrder('deadline','asc')"  title="น้อยไปมาก">
                <i class="fa-solid fa-arrow-up"></i>
            </button>
            <button id="sortDescBtn" class="sort-btn"        onclick="setSortOrder('deadline','desc')" title="มากไปน้อย">
                <i class="fa-solid fa-arrow-down"></i>
            </button>
            <!-- zennnne แก้ -->
            <span class="sort-label" style="margin-left:12px;">เรียงตาม วันกรอก</span>
            <button id="sortIdAscBtn"  class="sort-btn" onclick="setSortOrder('formid','asc')"  title="เก่าสุดก่อน">
                <i class="fa-solid fa-arrow-up"></i>
            </button>
            <button id="sortIdDescBtn" class="sort-btn" onclick="setSortOrder('formid','desc')" title="ใหม่สุดก่อน">
                <i class="fa-solid fa-arrow-down"></i>
            </button>
            <!-- zennnne แก้ -->
        </div>
    </div>
    <!-- zennnne แก้ -->

    <!-- HISTORY LIST -->
    <div class="history-list">

<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    try {
        conn = DBConnection.getConnection();

        // zennnne แก้
        String sql =
            "WITH latest_step AS ( " +
            "    SELECT FORMID, STATE_STEP, APPROVED_DATE, " +
            "           ROW_NUMBER() OVER (PARTITION BY FORMID ORDER BY APPROVALID DESC) AS RN " +
            "    FROM APPROVALINFO " +
            ") " +
            "SELECT RF.FORMID, RF.TITLEFORM, RF.DEADLINE, " +
            "       NVL(E.EMPNAME,  '-') AS EMPNAME, " +
            "       NVL(S.SECNAME,  '-') AS SECNAME, " +
            "       NVL(D.DEPTNAME, '-') AS DEPTNAME, " +
            "       ls.STATE_STEP, ls.APPROVED_DATE " +
            "FROM REQUISITIONFORM RF " +
            "JOIN latest_step ls ON ls.FORMID = RF.FORMID AND ls.RN = 1 " +
            "LEFT JOIN EMPLOYEE   E ON RF.EMPID  = E.EMPID " +
            "LEFT JOIN SECTION    S ON E.SECID   = S.SECID " +
            "LEFT JOIN DEPARTMENT D ON S.DEPTID  = D.DEPTID " +
            "WHERE " + histStatusWhere + " " +
            roleWhere +
            "ORDER BY RF.DEADLINE " + orderDir + ", RF.FORMID DESC " +
            "OFFSET ? ROWS FETCH FIRST ? ROWS ONLY";
        // zennnne แก้

        pstmt = conn.prepareStatement(sql);
        int pi = 1;
        if (needsEmpParam) pstmt.setInt(pi++, empid);
        pstmt.setInt(pi++, offset);
        pstmt.setInt(pi,   pageSize);
        rs = pstmt.executeQuery();

        while (rs.next()) {
            hasData = true;

            int    formId    = rs.getInt("FORMID");
            String titleForm = rs.getString("TITLEFORM");
            java.sql.Date ddl = rs.getDate("DEADLINE");
            String empName   = rs.getString("EMPNAME");
            String secName   = rs.getString("SECNAME");
            String deptName  = rs.getString("DEPTNAME");
            int    stateStep = rs.getInt("STATE_STEP");
            // zennnne แก้
            java.sql.Timestamp approvedTs = rs.getTimestamp("APPROVED_DATE");
            String approvedDisplay = (approvedTs != null)
                ? sdf.format(new java.util.Date(approvedTs.getTime())) : "-";
            // zennnne แก้

            String deadlineDisplay = (ddl != null) ? sdf.format(ddl) : "-";
            String deadlineSort    = (ddl != null) ? ddl.toString()  : "9999-12-31";
            String rowStatus       = (stateStep < 0) ? "rejected" : "approved";

            Map<String,Object> rowMap = new HashMap<>();
            rowMap.put("formId", formId);
            formList.add(rowMap);
%>
        <!-- zennnne แก้ -->
        <div class="history-card"
             data-status="<%= rowStatus %>"
             data-deadline="<%= deadlineSort %>"
             data-formid="<%= formId %>"
             onclick="location.href='detail.jsp?id=<%= formId %>'">

            <div class="card-id-box">ใบขอให้ดำเนินการที่ <%= formId %></div>

            <div class="card-info">
                <div class="info-row">
                    <div class="info-item"><b>ชื่อ :</b> <%= empName %></div>
                    <div class="info-item"><b>ฝ่าย :</b> <%= deptName %></div>
                    <div class="info-item"><b>ส่วน :</b> <%= secName %></div>
                    <div class="info-item"><b>ดำเนินการล่าสุด :</b> <%= approvedDisplay %></div><!-- zennnne แก้ -->
                </div>
                <div class="detail-line"><b>รายละเอียด :</b> <%= titleForm %></div>
            </div>

            <!-- zennnne แก้ -->
            <div style="display:flex; flex-direction:column; align-items:center; gap:6px; flex-shrink:0;">
                <span class="status-badge <%= rowStatus.equals("approved") ? "badge-approved" : "badge-rejected" %>">
                    <%= rowStatus.equals("approved") ? "อนุมัติแล้ว" : "ไม่ผ่านการอนุมัติ" %>
                </span>
                <span class="deadline-tag <%= rowStatus %>">
                    <i class="fa-regular fa-calendar-days"></i> <%= deadlineDisplay %>
                </span>
            </div>
            <!-- zennnne แก้ -->
            <i class="fa-solid fa-chevron-right card-arrow"></i>
        </div>
        <!-- zennnne แก้ -->
<%
        } // end while

        if (!hasData) {
%>
        <div class="empty-state">
            <i class="fa-solid fa-clock-rotate-left"></i>
            ยังไม่มีประวัติฟอร์มที่จบแล้ว
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
        try { if (rs    != null) rs.close();    } catch (Exception ignored) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
        try { if (conn  != null) conn.close();  } catch (Exception ignored) {}
    }
%>

    </div><!-- /history-list -->

    <!-- PAGINATION -->
    <!-- zennnne แก้ -->
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

</div><!-- /main -->

<script>
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

// zennnne แก้
let sortOrder = (new URLSearchParams(window.location.search).get('sort') || 'asc');
let sortField = (new URLSearchParams(window.location.search).get('sortby') || 'deadline');

function applySort() {
    const list  = document.querySelector('.history-list');
    const cards = Array.from(list.querySelectorAll('.history-card'));
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
    cards.forEach(function(c) { list.appendChild(c); });
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

document.addEventListener('DOMContentLoaded', function() {
    const initParams = new URLSearchParams(window.location.search);
    const initShow   = (initParams.get('show') || 'rejected,approved').split(',').map(function(s) { return s.trim(); });
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
});
// zennnne แก้
</script>

</body>
</html>