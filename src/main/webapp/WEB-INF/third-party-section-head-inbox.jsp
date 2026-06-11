<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page import="com.slf.model.ThirdPartyRequest" %>
<%!
    private String h(Object input) {
        if (input == null) return "";
        return String.valueOf(input)
            .replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
            .replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    List<ThirdPartyRequest> thirdPartyRequests =
        (List<ThirdPartyRequest>) request.getAttribute("thirdPartyRequests");
    if (thirdPartyRequests == null) thirdPartyRequests = Collections.emptyList();
    SimpleDateFormat dateTime = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>คำขอ Third-party รอหัวหน้าส่วนพิจารณา</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        .third-party-inbox { max-width: 1180px; margin: 0 auto; padding: 28px 28px 48px; }
        .inbox-list { display: grid; gap: 14px; margin-top: 22px; }
        .inbox-item { display: grid; grid-template-columns: 1fr auto; gap: 20px; align-items: center; padding: 20px; background: #fff; border: 1px solid #d9e6f2; border-radius: 10px; box-shadow: 0 8px 22px rgba(0,51,102,.06); }
        .inbox-item h2 { margin: 0 0 8px; color: #003366; }
        .inbox-meta { display: flex; flex-wrap: wrap; gap: 8px 20px; color: #526b80; }
        .inbox-empty { padding: 36px; text-align: center; background: #fff; border: 1px dashed #bfd0df; border-radius: 10px; color: #526b80; }
        @media (max-width: 720px) { .third-party-inbox { padding: 20px 14px 36px; } .inbox-item { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
<div id="main">
    <%@ include file="/WEB-INF/jspf/topbar.jspf" %>
    <main class="third-party-inbox">
        <section class="third-party-page-head">
            <div>
                <p class="eyebrow">Third-party Workflow · หัวหน้าส่วน</p>
                <h1>คำขอที่รอพิจารณา</h1>
                <p>ตรวจสอบข้อมูล ให้ความเห็น และมอบหมายผู้รับผิดชอบก่อนส่งต่อให้ IT Director</p>
            </div>
        </section>

        <div class="inbox-list">
            <% if (thirdPartyRequests.isEmpty()) { %>
                <div class="inbox-empty">ขณะนี้ไม่มีคำขอ Third-party ที่รอหัวหน้าส่วนพิจารณา</div>
            <% } %>
            <% for (ThirdPartyRequest item : thirdPartyRequests) { %>
                <article class="inbox-item">
                    <div>
                        <h2>คำขอ #<%= item.getRequestId() %></h2>
                        <div class="inbox-meta">
                            <span><strong>ผู้ขอ:</strong> <%= h(item.getExternalContactName()) %></span>
                            <span><strong>หน่วยงาน:</strong> <%= h(item.getExternalCompanyName()) %></span>
                            <span><strong>ส่งเมื่อ:</strong> <%= item.getSubmittedAt() == null ? "-" : dateTime.format(item.getSubmittedAt()) %></span>
                        </div>
                    </div>
                    <a class="btn btn-primary primary-action" href="${pageContext.request.contextPath}/thirdParty/sectionHead/review?id=<%= item.getRequestId() %>">
                        <i class="fa-solid fa-clipboard-check"></i> พิจารณาคำขอ
                    </a>
                </article>
            <% } %>
        </div>
    </main>
    <%@ include file="/WEB-INF/jspf/footer.jspf" %>
</div>
<script>
function toggleNav() {
    var sidebar = document.getElementById("mySidebar");
    var main = document.getElementById("main");
    var open = sidebar.style.width === "250px";
    sidebar.style.width = open ? "0" : "250px";
    main.style.marginLeft = open ? "0" : "250px";
    main.style.width = open ? "100%" : "calc(100% - 250px)";
}
</script>
</body>
</html>
