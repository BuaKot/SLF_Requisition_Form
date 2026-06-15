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
    <style>
        body { margin: 0; background: var(--slf-color-bg); color: var(--slf-color-text); font-family: var(--slf-font-family); }
        .settings-page { max-width: 1040px; margin: 0 auto; padding: 26px 28px 44px; }
        .page-head { display: flex; justify-content: space-between; align-items: flex-start; gap: 18px; margin-bottom: 18px; }
        .page-title h1 { margin: 0; color: var(--slf-color-primary); font-size: 28px; line-height: 1.2; }
        .page-title p { margin: 6px 0 0; color: var(--slf-color-text-muted); font-size: 15px; }
        .panel { background: var(--slf-color-surface); border: 1px solid var(--slf-color-border); border-radius: var(--slf-radius-md); box-shadow: var(--slf-shadow-md); }
        .profile-panel { padding: 18px; margin-bottom: 18px; }
        .profile-grid { display: grid; grid-template-columns: repeat(2, minmax(220px, 1fr)); gap: 14px; }
        .field-label { display: block; font-weight: 700; color: var(--slf-color-primary); margin-bottom: 6px; font-size: 14px; }
        .readonly-value { min-height: 40px; border: 1px solid var(--slf-color-border); border-radius: var(--slf-radius-sm); padding: 9px 10px; background: var(--slf-color-surface-muted); color: var(--slf-color-text); }
        .form-panel { padding: 18px; }
        .settings-form { display: grid; grid-template-columns: 1fr auto; gap: 14px; align-items: end; }
        label { display: block; font-weight: 700; color: var(--slf-color-primary); margin-bottom: 6px; font-size: 14px; }
        input { width: 100%; height: 40px; border: 1px solid var(--slf-color-border); border-radius: var(--slf-radius-sm); padding: 0 10px; font-family: inherit; font-size: 15px; background: var(--slf-color-surface); color: var(--slf-color-text); }
        input:focus { outline: none; border-color: var(--slf-color-accent); box-shadow: var(--slf-focus-ring); }
        .toggle-row { display: flex; align-items: center; gap: 10px; margin-bottom: 14px; color: var(--slf-color-primary); font-weight: 800; }
        .toggle-row input { width: 18px; height: 18px; }
        .btn { border: 0; border-radius: var(--slf-radius-sm); min-height: 40px; padding: 0 16px; display: inline-flex; align-items: center; justify-content: center; gap: 8px; font-family: inherit; font-weight: 700; cursor: pointer; text-decoration: none; transition: background-color 0.2s ease; }
        .btn-primary { background: var(--slf-color-primary); color: #fff; }
        .btn-primary:hover { background: var(--slf-color-primary-600); }
        .btn-secondary { background: var(--slf-color-accent-100); color: var(--slf-color-primary); }
        .btn-secondary:hover { background: var(--slf-color-border); }
        .toast {
            position: fixed;
            top: 88px;
            left: 50%;
            z-index: 1000;
            min-width: 280px;
            max-width: min(420px, calc(100vw - 32px));
            border-radius: var(--slf-radius-sm);
            padding: 12px 16px;
            display: flex;
            align-items: center;
            gap: 10px;
            font-weight: 800;
            box-shadow: var(--slf-shadow-lg);
            transition: opacity 180ms ease, transform 180ms ease;
            transform: translateX(-50%);
        }
        .toast-ok { background: var(--slf-color-success-bg); color: var(--slf-color-success); border: 1px solid var(--slf-color-success-bg); }
        .toast-error { background: var(--slf-color-danger-bg); color: var(--slf-color-danger); border: 1px solid var(--slf-color-danger-bg); }
        .toast.is-hiding { opacity: 0; transform: translate(-50%, -8px); }
        @media (max-width: 760px) {
            .settings-page { padding: 18px 14px 34px; }
            .page-head { flex-direction: column; }
            .profile-grid, .settings-form { grid-template-columns: 1fr; }
            .btn { width: 100%; }
            .toast { top: 76px; left: 50%; width: calc(100vw - 32px); }
        }
    </style>
</head>
<body>
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


