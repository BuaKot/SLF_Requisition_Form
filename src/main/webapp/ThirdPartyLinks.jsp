<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%@ page import="com.slf.model.ThirdPartyFormLink" %>
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
    if (!AuthUtil.isAllowedForPage(currentRole, "thirdPartyLinks")) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }

    List<ThirdPartyFormLink> links = (List<ThirdPartyFormLink>) request.getAttribute("links");
    if (links == null) links = Collections.emptyList();
    Map<Long, String> generatedLinks = (Map<Long, String>) request.getAttribute("generatedLinks");
    if (generatedLinks == null) generatedLinks = Collections.emptyMap();
    String csrfToken = (String) request.getAttribute("csrfToken");
    String generatedLink = (String) request.getAttribute("generatedLink");
    String message = (String) request.getAttribute("message");
    String error = (String) request.getAttribute("error");
    String status = (String) request.getAttribute("status");
    String generatedLinkId = request.getParameter("linkId");
    String publicBaseUrl = (String) request.getAttribute("publicBaseUrl");
    SimpleDateFormat dateTime = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Third-party Form Links</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; background: #f4f8fc; color: #102a43; font-family: 'Sarabun', sans-serif; }
        .page { max-width: 1400px; margin: 0 auto; padding: 26px 28px 44px; }
        .page-head { display: flex; justify-content: space-between; align-items: flex-start; gap: 18px; margin-bottom: 18px; }
        .page-title h1 { margin: 0; color: #003366; font-size: 28px; }
        .page-title p { margin: 6px 0 0; color: #5b6f82; }
        .panel { background: #fff; border: 1px solid #d9e6f2; border-radius: 10px; box-shadow: 0 8px 22px rgba(0, 51, 102, 0.08); }
        .generate-panel { padding: 18px; margin-bottom: 18px; }
        .form-grid { display: grid; grid-template-columns: minmax(240px, 1fr) auto; gap: 12px; align-items: end; }
        label { display: block; color: #003366; font-weight: 800; margin-bottom: 6px; }
        input[type="text"] { width: 100%; min-height: 40px; border: 1px solid #c7d7e6; border-radius: 7px; padding: 0 10px; font-family: inherit; }
        .btn { border: 0; border-radius: 7px; min-height: 40px; padding: 0 16px; display: inline-flex; align-items: center; justify-content: center; gap: 8px; font-family: inherit; font-weight: 800; cursor: pointer; text-decoration: none; white-space: nowrap; }
        .btn-primary { background: #003366; color: #fff; }
        .btn-secondary { background: #e8f2fb; color: #003366; }
        .btn-danger { background: #fdecec; color: #b42318; }
        .btn:disabled { opacity: 0.55; cursor: not-allowed; }
        .notice { margin-bottom: 18px; padding: 13px 15px; border-radius: 8px; font-weight: 800; }
        .notice-success { background: #e7f7ee; color: #137a42; border: 1px solid #bde7cc; }
        .notice-error { background: #fdecec; color: #b42318; border: 1px solid #f4b8b8; }
        .generated-box { margin-top: 16px; padding: 14px; background: #f0f6fc; border: 1px solid #cfe0ef; border-radius: 8px; }
        .generated-row { display: grid; grid-template-columns: minmax(0, 1fr) auto; gap: 10px; align-items: center; }
        .generated-link { width: 100%; min-height: 42px; background: #fff; color: #003366; font-weight: 700; }
        .hint { color: #64748b; font-size: 13px; margin-top: 8px; }
        .table-wrap { overflow-x: auto; }
        table { width: 100%; min-width: 1100px; border-collapse: collapse; }
        th, td { padding: 12px; border-bottom: 1px solid #e5eef6; text-align: left; vertical-align: top; }
        th { background: #f0f6fc; color: #003366; font-size: 13px; white-space: nowrap; }
        td { font-size: 14px; }
        .status { display: inline-flex; align-items: center; border-radius: 999px; padding: 4px 10px; font-weight: 900; font-size: 12px; }
        .status-ACTIVE { background: #e7f7ee; color: #137a42; }
        .status-USED { background: #e8f2fb; color: #00509e; }
        .status-EXPIRED { background: #fff4d6; color: #8a5a00; }
        .status-REVOKED { background: #fdecec; color: #b42318; }
        .hash { max-width: 190px; overflow-wrap: anywhere; color: #64748b; font-size: 12px; }
        .empty { padding: 30px; text-align: center; color: #60758a; font-weight: 800; }
        .muted { color: #64748b; font-size: 12px; margin-top: 3px; }
        @media (max-width: 900px) {
            .page { padding: 18px 14px 34px; }
            .page-head { flex-direction: column; }
            .form-grid, .generated-row { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/sidebar.jsp" %>
<div id="main">
    <div class="sticky-bar">
        <i id="menuBtn" class="fa-solid fa-bars" onclick="toggleNav()"></i>
        <img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF Logo">
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

    <main class="page">
        <div class="page-head">
            <div class="page-title">
                <h1><i class="fa-solid fa-link"></i> Third-party Form Links</h1>
                <p>สร้างลิงก์ฟอร์มสำหรับบุคคลภายนอก อายุ 24 ชั่วโมง และส่งได้ครั้งเดียว</p>
            </div>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/Admin.jsp">
                <i class="fa-solid fa-arrow-left"></i> กลับหน้า Admin
            </a>
        </div>

        <% if (message != null) { %>
            <div class="notice notice-success"><%= h(message) %></div>
        <% } %>
        <% if (error != null) { %>
            <div class="notice notice-error"><%= h(error) %></div>
        <% } %>
        <% if ("revoked".equals(status)) { %>
            <div class="notice notice-success">ยกเลิกลิงก์เรียบร้อยแล้ว</div>
        <% } else if ("generated".equals(status)) { %>
            <div class="notice notice-success">สร้างลิงก์เรียบร้อยแล้ว<%= generatedLinkId == null ? "" : " (Link #" + h(generatedLinkId) + ")" %></div>
        <% } else if ("not_revoked".equals(status)) { %>
            <div class="notice notice-error">ไม่สามารถยกเลิกลิงก์นี้ได้ อาจถูกใช้ไปแล้วหรือหมดอายุ</div>
        <% } %>

        <section class="panel generate-panel">
            <form method="post" action="${pageContext.request.contextPath}/thirdPartyLinks">
                <input type="hidden" name="csrfToken" value="<%= h(csrfToken) %>">
                <input type="hidden" name="action" value="generate">
                <div class="form-grid">
                    <div>
                        <label for="note">หมายเหตุของลิงก์</label>
                        <input id="note" name="note" type="text" maxlength="500" placeholder="เช่น บริษัท/โครงการ/ผู้ประสานงาน">
                    </div>
                    <button class="btn btn-primary" type="submit">
                        <i class="fa-solid fa-key"></i> Generate Token
                    </button>
                </div>
            </form>

            <% if (generatedLink != null) { %>
                <div class="generated-box">
                    <label for="generatedLink">ลิงก์ที่สร้างล่าสุด</label>
                    <div class="generated-row">
                        <input id="generatedLink" class="generated-link" type="text" value="<%= h(generatedLink) %>" readonly>
                        <button class="btn btn-primary" type="button" onclick="copyGeneratedLink()">
                            <i class="fa-solid fa-copy"></i> Copy
                        </button>
                    </div>
                    <div class="hint">ระบบจะแสดง raw token เฉพาะตอนสร้างเท่านั้น หลังจากออกจากหน้านี้จะไม่สามารถดู token เดิมซ้ำได้</div>
                </div>
            <% } %>
        </section>

        <section class="panel table-wrap">
            <% if (links.isEmpty()) { %>
                <div class="empty">ยังไม่มีลิงก์สำหรับบุคคลภายนอก</div>
            <% } else { %>
                <table>
                    <thead>
                        <tr>
                            <th>สถานะ</th>
                            <th>Link ID</th>
                            <th>ลิงก์</th>
                            <th>Token Hash</th>
                            <th>Submit</th>
                            <th>เวลา</th>
                            <th>Submission</th>
                            <th>หมายเหตุ</th>
                            <th>จัดการ</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (ThirdPartyFormLink link : links) { %>
                        <tr>
                            <td><span class="status status-<%= h(link.getStatus()) %>"><%= h(link.getStatus()) %></span></td>
                            <td>#<%= link.getLinkId() %></td>
                            <td>
                                <%
                                    String rawToken = link.getRawToken();
                                    String rememberedLink = rawToken == null ? generatedLinks.get(Long.valueOf(link.getLinkId())) : publicBaseUrl + rawToken;
                                    boolean canCopyLink = "ACTIVE".equals(link.getStatus()) && rememberedLink != null;
                                    if (!canCopyLink) {
                                %>
                                    <span class="muted"><%= "ACTIVE".equals(link.getStatus()) ? "ไม่พบ token สำหรับคัดลอก" : "คัดลอกได้เฉพาะลิงก์ ACTIVE" %></span>
                                <% } else { %>
                                    <input id="copyLink_<%= link.getLinkId() %>" type="text" value="<%= h(rememberedLink) %>" readonly style="position:absolute; left:-9999px;">
                                    <button class="btn btn-secondary" type="button" onclick="copyInputValue('copyLink_<%= link.getLinkId() %>')">
                                        <i class="fa-solid fa-copy"></i> Copy
                                    </button>
                                <% } %>
                            </td>
                            <td class="hash"><%= display(link.getTokenHash()) %></td>
                            <td><%= link.getSubmitCount() %> / <%= link.getMaxSubmitCount() %></td>
                            <td>
                                <div>สร้าง: <%= link.getCreatedAt() == null ? "-" : dateTime.format(link.getCreatedAt()) %></div>
                                <div class="muted">หมดอายุ: <%= link.getExpiresAt() == null ? "-" : dateTime.format(link.getExpiresAt()) %></div>
                                <% if (link.getUsedAt() != null) { %>
                                    <div class="muted">ใช้แล้ว: <%= dateTime.format(link.getUsedAt()) %></div>
                                <% } %>
                                <% if (link.getRevokedAt() != null) { %>
                                    <div class="muted">ยกเลิก: <%= dateTime.format(link.getRevokedAt()) %></div>
                                <% } %>
                            </td>
                            <td>
                                <% if (link.getSubmissionId() == null) { %>
                                    -
                                <% } else { %>
                                    <div>
                                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/thirdPartySubmission?id=<%= link.getSubmissionId() %>">
                                            <i class="fa-solid fa-eye"></i> View #<%= link.getSubmissionId() %>
                                        </a>
                                    </div>
                                    <div class="muted"><%= display(link.getSubmissionStatus()) %></div>
                                    <div class="muted"><%= link.getSubmittedAt() == null ? "-" : dateTime.format(link.getSubmittedAt()) %></div>
                                <% } %>
                            </td>
                            <td><%= display(link.getNote()) %></td>
                            <td>
                                <form method="post" action="${pageContext.request.contextPath}/thirdPartyLinks" style="margin:0;">
                                    <input type="hidden" name="csrfToken" value="<%= h(csrfToken) %>">
                                    <input type="hidden" name="action" value="revoke">
                                    <input type="hidden" name="linkId" value="<%= link.getLinkId() %>">
                                    <button class="btn btn-danger" type="submit" <%= "ACTIVE".equals(link.getStatus()) && link.getSubmitCount() == 0 ? "" : "disabled" %>>
                                        <i class="fa-solid fa-ban"></i> Revoke
                                    </button>
                                </form>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            <% } %>
        </section>
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

function copyGeneratedLink() {
    copyInputValue("generatedLink");
}

function copyInputValue(id) {
    var input = document.getElementById(id);
    if (!input) return;
    input.select();
    input.setSelectionRange(0, input.value.length);
    if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(input.value);
    } else {
        document.execCommand("copy");
    }
}
</script>
</body>
</html>
