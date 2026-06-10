<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.slf.model.ThirdPartyRequest" %>
<%@ page import="com.slf.util.ThirdPartyAccessPolicy" %>
<%!
    private String h(Object input) {
        if (input == null) return "";
        return String.valueOf(input)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }

    private String linkStatusText(String status) {
        if ("ACTIVE".equals(status)) return "ใช้งานได้";
        if ("USED".equals(status)) return "ใช้แล้ว";
        if ("EXPIRED".equals(status)) return "หมดอายุ";
        if ("REVOKED".equals(status)) return "ยกเลิก";
        return status == null ? "-" : status;
    }
%>
<%
    if (!ThirdPartyAccessPolicy.canCreateOwnLinks(ThirdPartyAccessPolicy.sessionEmpId(session))) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }
    ThirdPartyRequest thirdPartyRequest = (ThirdPartyRequest) request.getAttribute("thirdPartyRequest");
    String publicLink = (String) request.getAttribute("publicLink");
    SimpleDateFormat dateTime = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ลิงก์แบบฟอร์มผู้ให้บริการภายนอก</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body>
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
<div id="main">
    <%@ include file="/WEB-INF/jspf/topbar.jspf" %>

    <main class="third-party-request-page">
        <section class="third-party-page-head">
            <div>
                <p class="eyebrow">ลิงก์แบบฟอร์ม</p>
                <h1>คำขอ #<%= thirdPartyRequest.getRequestId() %></h1>
                <p>หน้านี้ใช้แสดงลิงก์เดี่ยวเท่านั้น การติดตามสถานะรวมให้กลับไปที่หน้าจัดการลิงก์</p>
            </div>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/thirdParty/request/new">
                <i class="fa-solid fa-list"></i> กลับหน้าจัดการลิงก์
            </a>
        </section>

        <section class="third-party-panel">
            <div class="generated-link-layout">
                <div>
                    <div class="form-section-title">ลิงก์สำหรับผู้ให้บริการภายนอก</div>
                    <% if (publicLink == null) { %>
                        <p class="muted-text">ลิงก์นี้ไม่อยู่ในสถานะที่สามารถคัดลอกได้แล้ว อาจถูกใช้ หมดอายุ หรือถูกยกเลิก</p>
                    <% } else { %>
                        <div class="copy-row">
                            <input id="generatedThirdPartyLink" type="text" readonly value="<%= h(publicLink) %>">
                            <button class="btn btn-primary" type="button" onclick="copyGeneratedLink()">
                                <i class="fa-solid fa-copy"></i> คัดลอกลิงก์
                            </button>
                        </div>
                    <% } %>
                </div>
                <div class="status-box">
                    <div class="status-line"><span>สถานะลิงก์</span><strong><%= h(linkStatusText(thirdPartyRequest.getLinkStatus())) %></strong></div>
                    <div class="status-line"><span>หมดอายุ</span><strong><%= thirdPartyRequest.getLinkExpiresAt() == null ? "-" : dateTime.format(thirdPartyRequest.getLinkExpiresAt()) %></strong></div>
                </div>
            </div>
        </section>
    </main>
</div>
<script>
function copyGeneratedLink() {
    var input = document.getElementById("generatedThirdPartyLink");
    if (!input) return;
    input.select();
    input.setSelectionRange(0, input.value.length);
    if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(input.value);
    } else {
        document.execCommand("copy");
    }
}
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

