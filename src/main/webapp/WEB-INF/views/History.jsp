<%@ include file="/WEB-INF/checkAuth.jsp" %>
<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, com.slf.dao.DBConnection, java.text.SimpleDateFormat, com.slf.util.NavigationUtil" %>

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

    // zennnne แก้
    String showParam = request.getParameter("show");
    if (showParam == null || showParam.trim().isEmpty()) showParam = "rejected,approved";
    String sortParam = request.getParameter("sort");
    if (!"desc".equals(sortParam)) sortParam = "asc";
    String backParam = request.getParameter("back");
    Set<String> allowedBackPaths = new HashSet<>(Arrays.asList(
        "/directorApprove", "/technicalApprove", "/itDirectorApprove", "/process", "/it-requisition-form-detail.jsp"
    ));
    boolean legacyAllowedBackPath = allowedBackPaths.contains(backParam);
    String historyBackPath = NavigationUtil.historyBackPath(backParam);
    NavigationUtil.BackLink historyBackLink = NavigationUtil.historyBack(request.getContextPath(), backParam);
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
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/images/cropped-logo-192x192.png">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>

<body class="view-history">

<!-- ===============================
     SIDEBAR
================================ -->
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>

<div id="main">

    <!-- STICKY BAR -->
    <%@ include file="/WEB-INF/jspf/topbar.jspf" %>

    <main class="work-queue-page history-work-queue">

    <!-- PAGE HEADER -->
    <section class="queue-page-header">
        <div>
            <h1>ประวัติรายการที่ฉันอนุมัติ / Approval History</h1>
            <p>ดูรายการที่จบกระบวนการแล้ว พร้อมค้นหาและจัดเรียงเพื่อย้อนตรวจสอบได้รวดเร็ว</p>
        </div>
    </section>

    <!-- zennnne แก้ -->
    <!-- FILTER BAR -->
    <section class="filter-bar queue-toolbar" aria-label="ตัวกรองและการเรียงลำดับ">
        <a class="history-home-button detail-back-button" href="<%= historyBackLink.getHref() %>">
            <i class="fa-solid fa-arrow-left"></i> <%= historyBackLink.getLabel() %>
        </a>
        <span class="filter-separator" aria-hidden="true"></span>
        <div class="filter-checkboxes" aria-label="ตัวกรองสถานะ">
            <label class="filter-label rejected-label">
                <input type="checkbox" value="rejected" checked> ไม่ผ่านการอนุมัติ
            </label>
            <label class="filter-label approved-label">
                <input type="checkbox" value="approved" checked> อนุมัติแล้ว
            </label>
        </div>
        <!-- zennnne แก้ — search box -->
        <div class="search-wrap" id="searchWrap">
            <i class="fa-solid fa-magnifying-glass"></i>
            <input type="text" id="searchInput" class="search-input" placeholder="ค้นหาชื่อฟอร์ม / ชื่อผู้ขอ..." autocomplete="off" aria-label="ค้นหาประวัติฟอร์ม">
            <button type="button" class="search-clear" id="searchClear" title="ล้าง" aria-label="ล้างคำค้นหา">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <!-- zennnne แก้ -->

        <div class="sort-controls">
            <span class="sort-label">เรียงตาม Deadline</span>
            <button id="sortAscBtn"  class="sort-btn active" onclick="setSortOrder('deadline','asc')"  title="น้อยไปมาก" aria-label="เรียง Deadline น้อยไปมาก">
                <i class="fa-solid fa-arrow-up"></i>
            </button>
            <button id="sortDescBtn" class="sort-btn"        onclick="setSortOrder('deadline','desc')" title="มากไปน้อย" aria-label="เรียง Deadline มากไปน้อย">
                <i class="fa-solid fa-arrow-down"></i>
            </button>
            <!-- zennnne แก้ -->
            <span class="sort-label sort-label-secondary">เรียงตาม วันกรอก</span>
            <button id="sortIdAscBtn"  class="sort-btn" onclick="setSortOrder('formid','asc')"  title="เก่าสุดก่อน" aria-label="เรียงวันกรอกเก่าสุดก่อน">
                <i class="fa-solid fa-arrow-up"></i>
            </button>
            <button id="sortIdDescBtn" class="sort-btn" onclick="setSortOrder('formid','desc')" title="ใหม่สุดก่อน" aria-label="เรียงวันกรอกใหม่สุดก่อน">
                <i class="fa-solid fa-arrow-down"></i>
            </button>
            <!-- zennnne แก้ -->
        </div>
    </section>
    <!-- zennnne แก้ -->

    <!-- HISTORY LIST -->
    <section class="history-list">

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
            "AND EXISTS ( " +
            "    SELECT 1 FROM APPROVALINFO MY_AI " +
            "    WHERE MY_AI.FORMID = RF.FORMID " +
            "    AND MY_AI.REVIEWER_EMPID = ? " +
            "    AND ABS(MY_AI.STATE_STEP) BETWEEN 1 AND 4 " +
            ") " +
            "ORDER BY RF.DEADLINE " + orderDir + ", RF.FORMID DESC " +
            "OFFSET ? ROWS FETCH FIRST ? ROWS ONLY";
        // zennnne แก้

        pstmt = conn.prepareStatement(sql);
        int pi = 1;
        pstmt.setInt(pi++, empid);
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
             data-title="<%= titleForm  != null ? titleForm.replace("\"","&quot;")  : "" %>"
             data-empname="<%= empName != null ? empName.replace("\"","&quot;") : "" %>"
             onclick="location.href='detail.jsp?id=<%= formId %>&from=history'">

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
            <div class="history-card-status">
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
            ยังไม่มีประวัติรายการที่คุณอนุมัติและจบกระบวนการแล้ว
        </div>
<%
        }

    } catch (Exception e) {
%>
        <div class="queue-error-state">
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

        <!-- zennnne แก้ — empty search state -->
        <div id="emptySearch" class="empty-search">
            <i class="fa-solid fa-magnifying-glass"></i>
            ไม่พบฟอร์มที่ตรงกับคำค้นหา
        </div>
        <!-- zennnne แก้ -->
    </section><!-- /history-list -->

    <!-- PAGINATION -->
    <!-- zennnne แก้ -->
    <div class="pagination">
        <% if (currentPage > 1) { %>
            <a href="?page=<%= currentPage - 1 %>&show=<%= java.net.URLEncoder.encode(showParam, "UTF-8") %>&sort=<%= sortParam %>&back=<%= java.net.URLEncoder.encode(historyBackPath, "UTF-8") %>" class="pagination-link">
                <button type="button" class="page-btn">« ก่อนหน้า</button>
            </a>
        <% } %>
        <span class="page-num">หน้า <%= currentPage %></span>
        <% if (formList.size() == pageSize) { %>
            <a href="?page=<%= currentPage + 1 %>&show=<%= java.net.URLEncoder.encode(showParam, "UTF-8") %>&sort=<%= sortParam %>&back=<%= java.net.URLEncoder.encode(historyBackPath, "UTF-8") %>" class="pagination-link">
                <button type="button" class="page-btn">ถัดไป »</button>
            </a>
        <% } %>
    </div>
    <!-- zennnne แก้ -->

    </main>
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

    // zennnne แก้ — client-side search
    const searchInput = document.getElementById('searchInput');
    const searchWrap  = document.getElementById('searchWrap');
    const searchClear = document.getElementById('searchClear');
    const emptySearch = document.getElementById('emptySearch');

    function runSearch() {
        const q = searchInput.value.trim().toLowerCase();
        searchWrap.classList.toggle('has-text', q.length > 0);
        let visible = 0;
        document.querySelectorAll('.history-card').forEach(function(c) {
            const title   = (c.dataset.title   || '').toLowerCase();
            const empname = (c.dataset.empname || '').toLowerCase();
            const id      = (c.dataset.formid  || '').toString();
            const match = q === '' || title.includes(q) || empname.includes(q) || id.includes(q);
            c.style.display = match ? '' : 'none';
            if (match) visible++;
        });
        if (emptySearch) emptySearch.style.display = (q !== '' && visible === 0) ? 'block' : 'none';
    }

    if (searchInput) {
        searchInput.addEventListener('input', runSearch);
        searchClear.addEventListener('click', function() {
            searchInput.value = '';
            runSearch();
            searchInput.focus();
        });
    }
    // zennnne แก้
});
// zennnne แก้
</script>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>



