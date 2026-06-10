<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.slf.model.MemberProfile" %>
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
        body { margin: 0; background: #f4f8fc; color: #102a43; font-family: 'Sarabun', sans-serif; }
        .settings-page { max-width: 1040px; margin: 0 auto; padding: 26px 28px 44px; }
        .page-head { display: flex; justify-content: space-between; align-items: flex-start; gap: 18px; margin-bottom: 18px; }
        .page-title h1 { margin: 0; color: #003366; font-size: 28px; line-height: 1.2; }
        .page-title p { margin: 6px 0 0; color: #5b6f82; font-size: 15px; }
        .panel { background: #fff; border: 1px solid #d9e6f2; border-radius: 10px; box-shadow: 0 8px 22px rgba(0, 51, 102, 0.08); }
        .profile-panel { padding: 18px; margin-bottom: 18px; }
        .profile-grid { display: grid; grid-template-columns: repeat(2, minmax(220px, 1fr)); gap: 14px; }
        .field-label { display: block; font-weight: 700; color: #003366; margin-bottom: 6px; font-size: 14px; }
        .readonly-value { min-height: 40px; border: 1px solid #d9e6f2; border-radius: 7px; padding: 9px 10px; background: #f8fbfe; color: #102a43; }
        .form-panel { padding: 18px; }
        .settings-form { display: grid; grid-template-columns: 1fr auto; gap: 14px; align-items: end; }
        label { display: block; font-weight: 700; color: #003366; margin-bottom: 6px; font-size: 14px; }
        input { width: 100%; height: 40px; border: 1px solid #c7d7e6; border-radius: 7px; padding: 0 10px; font-family: inherit; font-size: 15px; background: #fff; }
        input:focus { outline: 2px solid rgba(50, 114, 187, 0.2); border-color: #3272BB; }
        .toggle-row { display: flex; align-items: center; gap: 10px; margin-bottom: 14px; color: #003366; font-weight: 800; }
        .toggle-row input { width: 18px; height: 18px; }
        .btn { border: 0; border-radius: 7px; min-height: 40px; padding: 0 16px; display: inline-flex; align-items: center; justify-content: center; gap: 8px; font-family: inherit; font-weight: 700; cursor: pointer; text-decoration: none; }
        .btn-primary { background: #003366; color: #fff; }
        .btn-secondary { background: #e8f2fb; color: #003366; }
        .toast {
            position: fixed;
            top: 88px;
            left: 50%;
            z-index: 1000;
            min-width: 280px;
            max-width: min(420px, calc(100vw - 32px));
            border-radius: 8px;
            padding: 12px 16px;
            display: flex;
            align-items: center;
            gap: 10px;
            font-weight: 800;
            box-shadow: 0 12px 28px rgba(0, 51, 102, 0.18);
            transition: opacity 180ms ease, transform 180ms ease;
            transform: translateX(-50%);
        }
        .toast-ok { background: #e7f7ee; color: #137a42; border: 1px solid #bde8ce; }
        .toast-error { background: #fdecec; color: #b42318; border: 1px solid #f5c2c2; }
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
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/">
                <i class="fa-solid fa-arrow-left"></i> กลับหน้าหลัก
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

