<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.slf.model.MemberProfile" %>
<%@ page import="com.slf.util.NavigationUtil" %>
<%!
    public String h(Object input) {
        if (input == null) return "";
        String str = String.valueOf(input);
        return str.replace("&", "&amp;")
                  .replace("<", "&lt;")
                  .replace(">", "&gt;")
                  .replace("\"", "&quot;")
                  .replace("'", "&#x27;");
    }
%>
<%
    MemberProfile member = (MemberProfile) request.getAttribute("member");
    if (member == null) {
        response.sendRedirect(request.getContextPath() + "/emailNotifications");
        return;
    }
    String message = (String) request.getAttribute("message");
    String error = (String) request.getAttribute("error");
    NavigationUtil.BackLink listBackLink = NavigationUtil.listPageBack(request.getContextPath());
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title>Email Notifications</title>
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/images/cropped-logo-192x192.png">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="view-email-notification-settings">
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
<div id="main">
    <%@ include file="/WEB-INF/jspf/topbar.jspf" %>

    <main class="settings-page">
        <div class="page-head">
            <div class="page-title">
                <h1><i class="fa-solid fa-envelope-circle-check"></i> ตั้งค่าแจ้งเตือน Email</h1>
                <p>จัดการอีเมลสำหรับรับแจ้งเตือนสถานะใบคำขอและขั้นตอนอนุมัติ</p>
            </div>
            <a class="btn btn-secondary detail-back-button" href="<%= h(listBackLink.getHref()) %>">
                <i class="fa-solid fa-arrow-left"></i> <%= h(listBackLink.getLabel()) %>
            </a>
        </div>

        <% if (message != null && !message.trim().isEmpty()) { %>
            <div id="statusToast" class="toast toast-ok" role="status" aria-live="polite">
                <i class="fa-solid fa-circle-check"></i>
                <span><%= h(message) %></span>
            </div>
        <% } %>
        <% if (error != null && !error.trim().isEmpty()) { %>
            <div id="statusToast" class="toast toast-error" role="alert" aria-live="assertive">
                <i class="fa-solid fa-circle-exclamation"></i>
                <span><%= h(error) %></span>
            </div>
        <% } %>

        <section class="panel profile-panel">
            <div class="profile-grid">
                <div>
                    <span class="field-label">ชื่อ-นามสกุล</span>
                    <div class="readonly-value"><%= h(member.getEmpName()) %></div>
                </div>
                <div>
                    <span class="field-label">ตำแหน่ง / Role</span>
                    <div class="readonly-value"><%= h(member.getPosition()) %></div>
                </div>
                <div>
                    <span class="field-label">ฝ่าย</span>
                    <div class="readonly-value"><%= h(member.getDeptName()) %></div>
                </div>
                <div>
                    <span class="field-label">ส่วน</span>
                    <div class="readonly-value"><%= h(member.getSecName()) %></div>
                </div>
                <div>
                    <span class="field-label">เบอร์ต่อ</span>
                    <div class="readonly-value"><%= h(member.getPhone()) %></div>
                </div>
            </div>
        </section>

        <section class="panel form-panel">
            <form class="settings-form" method="post" action="${pageContext.request.contextPath}/emailNotifications">
                <div>
                    <label class="toggle-row" for="emailNotificationEnabled">
                        <input id="emailNotificationEnabled" name="emailNotificationEnabled" type="checkbox" <%= member.isEmailNotificationEnabled() ? "checked" : "" %>>
                        เปิดรับการแจ้งเตือนทาง Email
                    </label>
                    <label for="email">Email รับแจ้งเตือน</label>
                    <input id="email" name="email" type="email" maxlength="255" value="<%= h(member.getEmail()) %>" placeholder="name@example.com" required>
                </div>
                <button class="btn btn-primary" type="submit">
                    <i class="fa-solid fa-floppy-disk"></i> บันทึก
                </button>
            </form>
        </section>
    </main>
    <%@ include file="/WEB-INF/jspf/footer.jspf" %>
</div>

<script type="text/javascript">
window.toggleNav = () => {
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
};

if (window.location.search.indexOf('status=') >= 0) {
    window.history.replaceState({}, document.title, window.location.pathname);
}

const statusToast = document.getElementById('statusToast');
if (statusToast) {
    window.setTimeout(() => {
        statusToast.classList.add('is-hiding');
        window.setTimeout(() => statusToast.remove(), 220);
    }, 5000);
}
</script>
</body>
</html>


