<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.slf.model.EmailNotificationLogEntry" %>
<%@ page import="com.slf.util.AuthUtil" %>
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
    int currentPage = request.getAttribute("currentPage") == null
        ? 1 : ((Integer) request.getAttribute("currentPage")).intValue();
    int pageSize = request.getAttribute("pageSize") == null
        ? 50 : ((Integer) request.getAttribute("pageSize")).intValue();
    int totalRows = request.getAttribute("totalRows") == null
        ? 0 : ((Integer) request.getAttribute("totalRows")).intValue();
    int totalPages = Math.max(1, (int) Math.ceil(totalRows / (double) pageSize));
    SimpleDateFormat dateTime = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
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
        body { margin: 0; background: #f4f8fc; color: #102a43; font-family: 'Sarabun', sans-serif; }
        .mail-log-page { max-width: 1500px; margin: 0 auto; padding: 26px 28px 44px; }
        .page-head { display: flex; justify-content: space-between; align-items: flex-start; gap: 18px; margin-bottom: 18px; }
        .page-title h1 { margin: 0; color: #003366; font-size: 28px; }
        .page-title p { margin: 6px 0 0; color: #5b6f82; }
        .panel { background: #fff; border: 1px solid #d9e6f2; border-radius: 10px; box-shadow: 0 8px 22px rgba(0, 51, 102, 0.08); }
        .summary-grid { display: grid; grid-template-columns: repeat(5, minmax(130px, 1fr)); gap: 12px; margin-bottom: 18px; }
        .summary-card { padding: 16px; text-decoration: none; color: inherit; }
        .summary-card strong { display: block; color: #003366; font-size: 24px; margin-top: 5px; }
        .filter-panel { padding: 16px; margin-bottom: 18px; }
        .filter-form { display: flex; align-items: end; gap: 12px; flex-wrap: wrap; }
        label { display: block; color: #003366; font-weight: 800; margin-bottom: 6px; }
        select { min-width: 200px; height: 40px; border: 1px solid #c7d7e6; border-radius: 7px; padding: 0 10px; font-family: inherit; }
        .btn { border: 0; border-radius: 7px; min-height: 40px; padding: 0 16px; display: inline-flex; align-items: center; justify-content: center; gap: 8px; font-family: inherit; font-weight: 700; cursor: pointer; text-decoration: none; }
        .btn-primary { background: #003366; color: #fff; }
        .btn-secondary { background: #e8f2fb; color: #003366; }
        .table-wrap { overflow-x: auto; }
        table { width: 100%; min-width: 1380px; border-collapse: collapse; }
        th, td { padding: 11px 12px; border-bottom: 1px solid #e5eef6; text-align: left; vertical-align: top; }
        th { background: #f0f6fc; color: #003366; font-size: 13px; white-space: nowrap; }
        td { font-size: 14px; }
        .status { display: inline-flex; align-items: center; border-radius: 999px; padding: 4px 10px; font-weight: 800; font-size: 12px; }
        .status-PENDING { background: #fff4d6; color: #8a5a00; }
        .status-READY { background: #fff4d6; color: #8a5a00; }
        .status-SENDING { background: #e8f2fb; color: #00509e; }
        .status-SENT { background: #e7f7ee; color: #137a42; }
        .status-FAILED { background: #fdecec; color: #b42318; }
        .status-SKIPPED { background: #f1f5f9; color: #64748b; }
        .recipient-name { color: #003366; font-weight: 800; }
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
<%@ include file="/WEB-INF/sidebar.jsp" %>
<div id="main">
    <%@ include file="/WEB-INF/sticky-bar.jsp" %>

    <main class="mail-log-page">
        <div class="page-head">
            <div class="page-title">
                <h1><i class="fa-solid fa-envelope-open-text"></i> mailLog</h1>
                <p>ตรวจสอบคิว สถานะการส่ง ปลายทาง และข้อผิดพลาดของอีเมลแจ้งเตือน</p>
            </div>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/Admin.jsp">
                <i class="fa-solid fa-arrow-left"></i> กลับหน้า Admin
            </a>
        </div>

        <section class="summary-grid">
            <% String[] summaryStatuses = {"READY", "PENDING", "SENDING", "SENT", "FAILED", "SKIPPED"};
               for (String summaryStatus : summaryStatuses) { %>
                <a class="panel summary-card" href="${pageContext.request.contextPath}/mailLog?status=<%= summaryStatus %>">
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
                            <th>Form / Event</th>
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
                                <div class="recipient-name">#<%= log.getFormId() %></div>
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
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/mailLog?page=<%= currentPage - 1 %>&status=<%= h(selectedStatus) %>">ก่อนหน้า</a>
            <% } %>
            <strong>หน้า <%= currentPage %> / <%= totalPages %></strong>
            <% if (currentPage < totalPages) { %>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/mailLog?page=<%= currentPage + 1 %>&status=<%= h(selectedStatus) %>">ถัดไป</a>
            <% } %>
        </div>
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
</script>
</body>
</html>
