<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.slf.model.EmailNotificationLogEntry" %>
<%@ page import="com.slf.util.AuthUtil" %>
<%@ page import="com.slf.util.NavigationUtil" %>
<%!
    public String h(Object input) {
        if (input == null) return "";
        return String.valueOf(input)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#x27;");
    }

    public String display(Object input) {
        if (input == null || String.valueOf(input).trim().isEmpty()) return "-";
        return h(input);
    }

    public String displayFormReference(EmailNotificationLogEntry log) {
        if (log == null) return "-";
        String formType = log.getFormType() == null ? "REQUISITION" : log.getFormType();
        if ("THIRD_PARTY".equals(formType)) {
            Long referenceId = log.getReferenceId();
            return "Third Party #" + (referenceId == null ? log.getFormId() : referenceId.longValue());
        }
        return "Requisition #" + log.getFormId();
    }
%>
<%
    String currentRole = (String) session.getAttribute("position");
    if (!AuthUtil.isAllowedForPage(currentRole, "mailLog")) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }

    List<EmailNotificationLogEntry> logs =
        (List<EmailNotificationLogEntry>) request.getAttribute("logs");
    Map<String, Integer> statusCounts =
        (Map<String, Integer>) request.getAttribute("statusCounts");
    if (logs == null) logs = Collections.emptyList();
    if (statusCounts == null) statusCounts = Collections.emptyMap();

    String selectedStatus = (String) request.getAttribute("selectedStatus");
    String selectedFormType = (String) request.getAttribute("selectedFormType");
    if (selectedFormType == null) selectedFormType = "";
    int currentPage = request.getAttribute("currentPage") == null
        ? 1 : ((Integer) request.getAttribute("currentPage")).intValue();
    int pageSize = request.getAttribute("pageSize") == null
        ? 50 : ((Integer) request.getAttribute("pageSize")).intValue();
    int totalRows = request.getAttribute("totalRows") == null
        ? 0 : ((Integer) request.getAttribute("totalRows")).intValue();
    int totalPages = Math.max(1, (int) Math.ceil(totalRows / (double) pageSize));
    SimpleDateFormat dateTime = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
    NavigationUtil.BackLink adminBackLink = NavigationUtil.adminListPageBack(request.getContextPath());
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>mailLog</title>
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/images/cropped-logo-192x192.png">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; background: var(--slf-color-bg); color: var(--slf-color-text); font-family: var(--slf-font-family); }
        .mail-log-page { max-width: 1500px; margin: 0 auto; padding: 26px 28px 44px; }
        .page-head { display: flex; justify-content: space-between; align-items: flex-start; gap: 18px; margin-bottom: 18px; }
        .page-title h1 { margin: 0; color: var(--slf-color-primary); font-size: 28px; }
        .page-title p { margin: 6px 0 0; color: var(--slf-color-text-muted); }
        .panel { background: var(--slf-color-surface); border: 1px solid var(--slf-color-border); border-radius: var(--slf-radius-md); box-shadow: var(--slf-shadow-md); }
        .summary-grid { display: grid; grid-template-columns: repeat(5, minmax(130px, 1fr)); gap: 12px; margin-bottom: 18px; }
        .summary-card { padding: 16px; text-decoration: none; color: inherit; }
        .summary-card strong { display: block; color: var(--slf-color-primary); font-size: 24px; margin-top: 5px; }
        .filter-panel { padding: 16px; margin-bottom: 18px; }
        .filter-form { display: flex; align-items: end; gap: 12px; flex-wrap: wrap; }
        label { display: block; color: var(--slf-color-primary); font-weight: 800; margin-bottom: 6px; }
        select { min-width: 200px; height: 40px; border: 1px solid var(--slf-color-border); border-radius: var(--slf-radius-sm); padding: 0 10px; font-family: inherit; background: var(--slf-color-surface); color: var(--slf-color-text); }
        select:focus { outline: none; border-color: var(--slf-color-accent); box-shadow: var(--slf-focus-ring); }
        .btn { border: 0; border-radius: var(--slf-radius-sm); min-height: 40px; padding: 0 16px; display: inline-flex; align-items: center; justify-content: center; gap: 8px; font-family: inherit; font-weight: 700; cursor: pointer; text-decoration: none; transition: background-color 0.2s ease; }
        .btn-primary { background: var(--slf-color-primary); color: #fff; }
        .btn-primary:hover { background: var(--slf-color-primary-600); }
        .btn-secondary { background: var(--slf-color-accent-100); color: var(--slf-color-primary); }
        .btn-secondary:hover { background: var(--slf-color-border); }
        .table-wrap { overflow-x: auto; }
        table { width: 100%; min-width: 1380px; border-collapse: collapse; }
        th, td { padding: 11px 12px; border-bottom: 1px solid var(--slf-color-border); text-align: left; vertical-align: top; }
        th { background: var(--slf-color-surface-muted); color: var(--slf-color-primary); font-size: 13px; white-space: nowrap; }
        td { font-size: 14px; color: var(--slf-color-text); }
        .status { display: inline-flex; align-items: center; border-radius: var(--slf-radius-pill); padding: 4px 10px; font-weight: 800; font-size: 12px; }
        .status-PENDING { background: var(--slf-color-warning-bg); color: var(--slf-color-warning); }
        .status-READY { background: var(--slf-color-warning-bg); color: var(--slf-color-warning); }
        .status-SENDING { background: var(--slf-color-info-bg); color: var(--slf-color-info); }
        .status-SENT { background: var(--slf-color-success-bg); color: var(--slf-color-success); }
        .status-FAILED { background: var(--slf-color-danger-bg); color: var(--slf-color-danger); }
        .status-SKIPPED { background: var(--slf-color-surface-muted); color: var(--slf-color-text-muted); }
        .recipient-name { color: var(--slf-color-primary); font-weight: 800; }
        .muted { color: #64748b; font-size: 12px; margin-top: 3px; }
        .error { max-width: 280px; color: #b42318; white-space: pre-wrap; overflow-wrap: anywhere; }
        .subject { max-width: 300px; overflow-wrap: anywhere; }
        .empty { padding: 30px; text-align: center; color: #60758a; font-weight: 700; }
        .pagination { display: flex; justify-content: center; align-items: center; gap: 12px; margin-top: 18px; }
        @media (max-width: 900px) {
            .mail-log-page { padding: 18px 14px 34px; }
            .page-head { flex-direction: column; }
            .summary-grid { grid-template-columns: repeat(2, 1fr); }
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
<div id="main">
    <%@ include file="/WEB-INF/jspf/topbar.jspf" %>

    <main class="mail-log-page">
        <div class="page-head">
            <div class="page-title">
                <h1><i class="fa-solid fa-envelope-open-text"></i> mailLog</h1>
                <p>ตรวจสอบคิว สถานะการส่ง ปลายทาง และข้อผิดพลาดของอีเมลแจ้งเตือน</p>
            </div>
            <a class="btn btn-secondary detail-back-button" href="<%= h(adminBackLink.getHref()) %>">
                <i class="fa-solid fa-arrow-left"></i> <%= h(adminBackLink.getLabel()) %>
            </a>
        </div>

        <section class="summary-grid">
            <% String[] summaryStatuses = {"READY", "PENDING", "SENDING", "SENT", "FAILED", "SKIPPED"};
               for (String summaryStatus : summaryStatuses) { %>
                <a class="panel summary-card" href="${pageContext.request.contextPath}/mailLog?status=<%= summaryStatus %>&formType=<%= h(selectedFormType) %>">
                    <span><%= summaryStatus %></span>
                    <strong><%= statusCounts.get(summaryStatus) == null ? 0 : statusCounts.get(summaryStatus) %></strong>
                </a>
            <% } %>
        </section>

        <section class="panel filter-panel">
            <form class="filter-form" method="get" action="${pageContext.request.contextPath}/mailLog">
                <div>
                    <label for="status">สถานะการส่ง</label>
                    <select id="status" name="status">
                        <option value="">ทั้งหมด</option>
                        <% for (String status : summaryStatuses) { %>
                            <option value="<%= status %>" <%= status.equals(selectedStatus) ? "selected" : "" %>><%= status %></option>
                        <% } %>
                    </select>
                </div>
                <div>
                    <label for="formType">ประเภทฟอร์ม</label>
                    <select id="formType" name="formType">
                        <option value="">ทั้งหมด</option>
                        <option value="REQUISITION" <%= "REQUISITION".equals(selectedFormType) ? "selected" : "" %>>Requisition</option>
                        <option value="THIRD_PARTY" <%= "THIRD_PARTY".equals(selectedFormType) ? "selected" : "" %>>Third Party</option>
                    </select>
                </div>
                <button class="btn btn-primary" type="submit"><i class="fa-solid fa-filter"></i> กรอง</button>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/mailLog">ล้าง</a>
            </form>
        </section>

        <section class="panel table-wrap">
            <% if (logs.isEmpty()) { %>
                <div class="empty">ไม่พบข้อมูล mail log ตามเงื่อนไขที่เลือก</div>
            <% } else { %>
                <table>
                    <thead>
                        <tr>
                            <th>สถานะ</th>
                            <th>Form Type / Event</th>
                            <th>ปลายทางเมล</th>
                            <th>ชื่อ-นามสกุล</th>
                            <th>ตำแหน่ง</th>
                            <th>ส่วนงาน</th>
                            <th>เบอร์ต่อ</th>
                            <th>หัวข้อเมล</th>
                            <th>ลองส่ง</th>
                            <th>เวลา</th>
                            <th>Error ล่าสุด</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (EmailNotificationLogEntry log : logs) { %>
                        <tr>
                            <td><span class="status status-<%= h(log.getStatus()) %>"><%= h(log.getStatus()) %></span></td>
                            <td>
                                <div class="recipient-name"><%= h(displayFormReference(log)) %></div>
                                <div class="muted"><%= display(log.getEventType()) %></div>
                            </td>
                            <td><%= display(log.getRecipientEmail()) %></td>
                            <td><%= display(log.getRecipientName()) %></td>
                            <td><%= display(log.getRecipientPosition()) %></td>
                            <td><%= display(log.getRecipientSection()) %></td>
                            <td><%= display(log.getRecipientPhone()) %></td>
                            <td class="subject"><%= display(log.getSubject()) %></td>
                            <td><%= log.getSendAttempt() %></td>
                            <td>
                                <div>สร้าง: <%= log.getCreatedAt() == null ? "-" : dateTime.format(log.getCreatedAt()) %></div>
                                <div class="muted">ล่าสุด: <%= log.getLastAttemptAt() == null ? "-" : dateTime.format(log.getLastAttemptAt()) %></div>
                                <div class="muted">ส่งสำเร็จ: <%= log.getSentAt() == null ? "-" : dateTime.format(log.getSentAt()) %></div>
                            </td>
                            <td class="error"><%= display(log.getErrorMessage()) %></td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            <% } %>
        </section>

        <div class="pagination">
            <% if (currentPage > 1) { %>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/mailLog?page=<%= currentPage - 1 %>&status=<%= h(selectedStatus) %>&formType=<%= h(selectedFormType) %>">ก่อนหน้า</a>
            <% } %>
            <strong>หน้า <%= currentPage %> / <%= totalPages %></strong>
            <% if (currentPage < totalPages) { %>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/mailLog?page=<%= currentPage + 1 %>&status=<%= h(selectedStatus) %>&formType=<%= h(selectedFormType) %>">ถัดไป</a>
            <% } %>
        </div>
    </main>
    <%@ include file="/WEB-INF/jspf/footer.jspf" %>
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
</script>
</body>
</html>


