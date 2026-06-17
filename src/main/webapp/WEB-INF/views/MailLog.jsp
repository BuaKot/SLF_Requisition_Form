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
</head>
<body class="view-mail-log">
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


