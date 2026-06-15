<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%!
    private String approvalEscapeHtml(Object value) {
        if (value == null) return "-";
        return value.toString().replace("&", "&amp;").replace("<", "&lt;")
            .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    @SuppressWarnings("unchecked")
    List<Map<String, Object>> approvalFormList = (List<Map<String, Object>>) request.getAttribute("formList");
    if (approvalFormList == null) approvalFormList = new ArrayList<>();
    String approvalTitle = approvalEscapeHtml(request.getAttribute("approvalTitle"));
    String approvalSubtitle = approvalEscapeHtml(request.getAttribute("approvalSubtitle"));
    String approvalDetailPage = request.getAttribute("approvalDetailPage") != null
        ? request.getAttribute("approvalDetailPage").toString() : "/";
    String approvalHistoryBackPage = request.getAttribute("approvalHistoryBackPage") != null
        ? request.getAttribute("approvalHistoryBackPage").toString() : "/";
    boolean approvalAlreadyProcessed = "already_processed".equals(request.getParameter("error"));
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= approvalTitle %></title>
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/images/cropped-logo-192x192.png">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/submit.css">
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; background: var(--slf-color-bg); color: var(--slf-color-text); font-family: var(--slf-font-family); }
        .approval-main { min-height: 100vh; }
        .approval-header { border-bottom: 1px solid var(--slf-color-border); background: var(--slf-color-accent-100); padding: 30px 24px; }
        .approval-header-inner, .approval-list { width: min(1360px, calc(100% - 40px)); margin: 0 auto; }
        .approval-header-inner { display: flex; align-items: center; justify-content: space-between; gap: 24px; }
        .approval-title { display: flex; align-items: center; gap: 16px; }
        .approval-title-icon { width: 58px; height: 58px; display: grid; place-items: center; border: 1px solid var(--slf-color-border); border-radius: var(--slf-radius-md); background: var(--slf-color-surface); color: var(--slf-color-primary); font-size: 25px; }
        .approval-title h1 { margin: 0; color: var(--slf-color-primary); font-size: var(--slf-font-size-2xl); line-height: 1.2; }
        .approval-title p { margin: 5px 0 0; color: var(--slf-color-text-muted); font-size: var(--slf-font-size-sm); }
        .header-actions { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
        .page-button { min-height: 42px; display: inline-flex; align-items: center; justify-content: center; gap: 8px; padding: 9px 15px; border: 1px solid var(--slf-color-border-strong); border-radius: var(--slf-radius-sm); background: var(--slf-color-surface); color: var(--slf-color-primary); text-decoration: none; font-size: 16px; font-weight: 800; transition: .2s ease; }
        .page-button:hover { background: var(--slf-color-surface-muted); border-color: var(--slf-color-accent); }
        .count-badge { min-width: 42px; min-height: 42px; display: grid; place-items: center; border-radius: var(--slf-radius-sm); background: var(--slf-color-primary); color: #fff; font-size: 18px; font-weight: 800; }
        .approval-list { padding: 24px 0 48px; }
        .requisition-card { display: flex; align-items: center; gap: 20px; margin-bottom: 12px; padding: 16px 20px; border: 1px solid var(--slf-color-border); border-left: 4px solid var(--slf-color-accent); border-radius: var(--slf-radius-md); background: var(--slf-color-surface); color: inherit; text-decoration: none; box-shadow: var(--slf-shadow-sm); transition: .2s ease; }
        .requisition-card:hover { border-color: var(--slf-color-accent); box-shadow: var(--slf-shadow-md); transform: translateY(-2px); }
        .card-id-box { min-width: 174px; padding: 9px 12px; border: 1px solid var(--slf-color-border); border-radius: var(--slf-radius-sm); background: var(--slf-color-surface-muted); color: var(--slf-color-primary); text-align: center; font-size: 16px; font-weight: 800; }
        .card-info { flex: 1; min-width: 0; }
        .info-row { display: grid; grid-template-columns: repeat(3,minmax(145px,1fr)); gap: 8px 18px; margin-bottom: 8px; font-size: 16px; }
        .info-item, .detail-line { overflow-wrap: anywhere; }
        .info-item b, .detail-line b { color: var(--slf-color-primary-600); }
        .detail-line { color: var(--slf-color-text-muted); font-size: 16px; }
        .status-section { min-width: 170px; display: flex; align-items: center; justify-content: flex-end; gap: 12px; color: #8599aa; }
        .pending-group { display: flex; flex-direction: column; align-items: flex-end; gap: 7px; }
        .status-label { display: inline-flex; align-items: center; gap: 6px; color: var(--slf-color-warning); font-size: 14px; font-weight: 800; }
        .deadline-tag { display: inline-flex; align-items: center; gap: 6px; padding: 4px 10px; border: 1px solid; border-radius: 6px; white-space: nowrap; font-size: 13px; }
        .deadline-tag.normal { color: var(--slf-color-success); background: var(--slf-color-success-bg); border-color: #77bc63; }
        .deadline-tag.soon { color: var(--slf-color-warning); background: var(--slf-color-warning-bg); border-color: #e2b943; }
        .deadline-tag.urgent { color: var(--slf-color-danger); background: var(--slf-color-danger-bg); border-color: #e58c85; }
        .deadline-tag.overdue { color: var(--slf-color-danger); background: var(--slf-color-danger-bg); border-color: #e58c85; }
        .empty-state { padding: 62px 24px; border: 1px dashed var(--slf-color-border-strong); border-radius: var(--slf-radius-md); background: var(--slf-color-surface); color: var(--slf-color-text-muted); text-align: center; }
        .empty-state i { display: block; margin-bottom: 14px; color: var(--slf-color-accent); font-size: 42px; }
        .empty-state h2 { margin: 0 0 6px; color: var(--slf-color-primary); font-size: 23px; }
        .empty-state p { margin: 0; font-size: 16px; }
        .approval-alert { width: min(1360px, calc(100% - 40px)); margin: 16px auto 0; padding: 12px 16px; border: 1px solid var(--slf-color-warning); border-radius: var(--slf-radius-md); background: var(--slf-color-warning-bg); color: var(--slf-color-warning); font-size: 16px; font-weight: 800; }
        @media (max-width: 900px) {
            .approval-header-inner, .requisition-card { align-items: flex-start; flex-direction: column; }
            .header-actions { width: 100%; }
            .info-row { grid-template-columns: 1fr; }
            .card-id-box, .status-section { width: 100%; }
            .status-section { justify-content: space-between; }
            .pending-group { align-items: flex-start; }
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
<div id="main" class="approval-main work-queue-page approval-work-queue">
    <%@ include file="/WEB-INF/jspf/topbar.jspf" %>
    <header class="queue-page-header approval-header">
        <div class="approval-header-inner">
            <div class="approval-title"><div class="approval-title-icon"><i class="fa-solid fa-file-signature"></i></div><div><h1><%= approvalTitle %></h1><p><%= approvalSubtitle %></p></div></div>
            <div class="header-actions queue-summary">
                <span class="count-badge" title="จำนวนรายการ" aria-label="จำนวนรายการรอดำเนินการ"><%= approvalFormList.size() %></span>
                <a class="page-button" href="${pageContext.request.contextPath}/history.jsp?back=<%= java.net.URLEncoder.encode(approvalHistoryBackPage, "UTF-8") %>"><i class="fa-solid fa-clock-rotate-left"></i> ประวัติ</a>
                <a class="page-button" href="${pageContext.request.contextPath}/"><i class="fa-solid fa-house"></i> หน้าหลัก</a>
            </div>
        </div>
        <% if (approvalAlreadyProcessed) { %>
        <div class="approval-alert"><i class="fa-solid fa-circle-info"></i> ใบขอนี้ถูกดำเนินการแล้ว</div>
        <% } %>
    </header>
    <main class="approval-list">
        <% if (approvalFormList.isEmpty()) { %>
        <div class="empty-state"><i class="fa-regular fa-circle-check"></i><h2>ไม่มีรายการรอดำเนินการ</h2><p>รายการใหม่ที่อยู่ในความรับผิดชอบจะแสดงในหน้านี้</p></div>
        <% } %>
        <% for (Map<String, Object> row : approvalFormList) {
            String formId = row.get("FORMID") != null ? row.get("FORMID").toString().trim() : "";
            String departmentName = approvalEscapeHtml(row.get("DEPARTMENT_NAME"));
            String empName = approvalEscapeHtml(row.get("EMPNAME"));
            String sectionName = approvalEscapeHtml(row.get("SECTION_NAME"));
            String deadline = approvalEscapeHtml(row.get("DEADLINE_DISPLAY"));
            String titleForm = approvalEscapeHtml(row.get("TITLEFORM"));
            String rawTag = row.get("DEADLINE_TAG") != null ? row.get("DEADLINE_TAG").toString() : "normal";
            String deadlineTagClass = Arrays.asList("normal","soon","urgent","overdue").contains(rawTag) ? rawTag : "normal";
            boolean isOverdue = "overdue".equals(deadlineTagClass);
        %>
        <a class="requisition-card" href="${pageContext.request.contextPath}<%= approvalDetailPage %>?id=<%= approvalEscapeHtml(formId) %>">
            <div class="card-id-box">ใบขอเลขที่ <%= approvalEscapeHtml(formId) %></div>
            <div class="card-info"><div class="info-row"><div class="info-item"><b>ชื่อ:</b> <%= empName %></div><div class="info-item"><b>ฝ่าย:</b> <%= departmentName %></div><div class="info-item"><b>ส่วนงาน:</b> <%= sectionName %></div></div><div class="detail-line"><b>รายละเอียด:</b> <%= titleForm %></div></div>
            <div class="status-section"><div class="pending-group"><span class="status-label"><i class="fa-solid fa-clock"></i> <%= isOverdue ? "เลยกำหนด" : "รอดำเนินการ" %></span><span class="deadline-tag <%= deadlineTagClass %>"><i class="fa-regular fa-calendar-days"></i> <%= deadline %></span></div><i class="fa-solid fa-chevron-right"></i></div>
        </a>
        <% } %>
    </main>
    <%@ include file="/WEB-INF/jspf/footer.jspf" %>
</div>
<script>
function toggleNav() {
    var sidebar = document.getElementById("mySidebar"), main = document.getElementById("main");
    if (sidebar.style.width === "250px") {
        sidebar.style.width = "0"; main.style.marginLeft = "0"; main.style.width = "100%";
    } else {
        sidebar.style.width = "250px"; main.style.marginLeft = "250px"; main.style.width = "calc(100% - 250px)";
    }
}
</script>
</body>
</html>


