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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css?v=20260618-2">
</head>
<body class="view-approval-list">
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


