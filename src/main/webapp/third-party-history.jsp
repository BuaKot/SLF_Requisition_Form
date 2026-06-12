<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat,java.util.Collections,java.util.List" %>
<%@ page import="com.slf.model.ThirdPartyRequest" %>
<%@ page import="com.slf.util.ThirdPartyAccessPolicy" %>
<%!
    private String h(Object value) {
        if (value == null) return "";
        return String.valueOf(value).replace("&", "&amp;").replace("<", "&lt;")
            .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
    private String display(Object value) {
        return value == null || String.valueOf(value).trim().isEmpty() ? "-" : h(value);
    }
    private String statusText(String status) {
        if ("LINK_CREATED".equals(status)) return "รอผู้ขอภายนอกกรอกฟอร์ม";
        if ("PENDING_SECTION_HEAD".equals(status)) return "รอหัวหน้าส่วนพิจารณา";
        if ("PENDING_IT_DIRECTOR".equals(status)) return "รอ IT Director อนุมัติ";
        if ("PENDING_OPERATOR".equals(status)) return "รอผู้ดำเนินการ";
        if ("PENDING_EXTERNAL_ACCEPTANCE".equals(status)) return "รอผู้ขอภายนอกตรวจรับ";
        if ("PENDING_REVOKER".equals(status)) return "รอผู้ยกเลิกสิทธิ์";
        if ("PENDING_REVOKE_REVIEWER".equals(status)) return "รอผู้ตรวจทาน";
        if ("PENDING_SECTION_HEAD_REPORT".equals(status)) return "รอหัวหน้าส่วนสรุปรายงาน";
        if ("PENDING_FINAL_CERTIFICATION".equals(status)) return "รอ IT Director รับรอง";
        if ("COMPLETED".equals(status)) return "เสร็จสิ้น";
        if ("REJECTED".equals(status)) return "ไม่อนุมัติ";
        return status == null ? "-" : status;
    }
    private String category(String status) {
        if ("COMPLETED".equals(status)) return "completed";
        if ("REJECTED".equals(status)) return "rejected";
        return "waiting";
    }
%>
<%
    String position = (String) session.getAttribute("position");
    if (!ThirdPartyAccessPolicy.canViewHistory(position, ThirdPartyAccessPolicy.sessionEmpId(session))) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }
    List<ThirdPartyRequest> items = (List<ThirdPartyRequest>) request.getAttribute("thirdPartyRequests");
    if (items == null) items = Collections.emptyList();
    boolean adminView = Boolean.TRUE.equals(request.getAttribute("thirdPartyHistoryAdminView"));
    SimpleDateFormat dateTime = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ประวัติ Third-party Form</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        .history-filter-bar{display:flex;gap:10px;align-items:center;flex-wrap:wrap;margin-bottom:18px}
        .history-filter{border:2px solid #d8e2eb;border-radius:999px;background:#fff;padding:8px 14px;cursor:pointer;font:inherit;color:#52606d}
        .history-filter.selected{border-color:#3272bb;background:#eaf4ff;color:#003f73;font-weight:700}
        .history-search{flex:1;min-width:220px;border:2px solid #d8e2eb;border-radius:999px;padding:9px 15px;font:inherit}
        .history-result-count{margin-left:auto;color:#52606d}
        .third-party-history-card[hidden]{display:none}
        .history-owner{font-size:13px;color:#65758b;margin-top:5px}
    </style>
</head>
<body>
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
<div id="main">
    <%@ include file="/WEB-INF/jspf/topbar.jspf" %>
    <main class="third-party-request-page">
        <section class="third-party-page-head third-party-toolbar-head">
            <div>
                <p class="eyebrow">Third-party Forms</p>
                <h1>ประวัติคำขอผู้ให้บริการภายนอก</h1>
                <p><%= adminView ? "แสดงคำขอทั้งหมดสำหรับผู้ดูแลระบบ" : "แสดงคำขอทั้งหมดที่ดูแลโดย Employee #678" %></p>
            </div>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/<%= adminView ? "Admin.jsp" : "thirdParty/request/new" %>">
                <i class="fa-solid fa-arrow-left"></i> กลับ
            </a>
        </section>

        <section class="third-party-panel">
            <div class="history-filter-bar">
                <button class="history-filter selected" type="button" data-filter="all">ทั้งหมด</button>
                <button class="history-filter" type="button" data-filter="waiting">กำลังดำเนินการ</button>
                <button class="history-filter" type="button" data-filter="completed">เสร็จสิ้น</button>
                <button class="history-filter" type="button" data-filter="rejected">ไม่อนุมัติ</button>
                <input id="historySearch" class="history-search" type="search" placeholder="ค้นหา Request ID / ผู้ขอ / บริษัท / ระบบ">
                <span id="historyCount" class="history-result-count"><%= items.size() %> รายการ</span>
            </div>

            <% if (items.isEmpty()) { %>
                <div class="empty-link-state"><i class="fa-solid fa-clock-rotate-left"></i><h2>ยังไม่มีประวัติ Third-party Form</h2></div>
            <% } else { %>
            <div class="third-party-link-list compact-list" id="historyList">
                <% for (ThirdPartyRequest item : items) { %>
                <article class="third-party-link-card compact-card third-party-history-card"
                         data-category="<%= category(item.getStatus()) %>"
                         data-search="<%= h((item.getRequestId() + " " + display(item.getExternalContactName()) + " " + display(item.getExternalCompanyName()) + " " + display(item.getTargetSystem())).toLowerCase()) %>"
                         data-updated="<%= item.getUpdatedAt() == null ? 0 : item.getUpdatedAt().getTime() %>">
                    <div class="link-card-main">
                        <div class="link-card-title-row">
                            <div>
                                <h2>คำขอ #<%= item.getRequestId() %></h2>
                                <p class="muted-text compact-note">อัปเดตล่าสุด <%= item.getUpdatedAt() == null ? "-" : dateTime.format(item.getUpdatedAt()) %></p>
                                <% if (adminView) { %><p class="history-owner">เจ้าของภายใน Employee #<%= item.getInternalOwnerEmpId() %></p><% } %>
                            </div>
                            <span class="status-badge <%= "completed".equals(category(item.getStatus())) ? "ok" : ("rejected".equals(category(item.getStatus())) ? "danger" : "wait") %>"><%= h(statusText(item.getStatus())) %></span>
                        </div>
                        <div class="status-strip">
                            <div><span>ผู้ขอ</span><strong><%= display(item.getExternalContactName()) %></strong></div>
                            <div><span>บริษัท/หน่วยงาน</span><strong><%= display(item.getExternalCompanyName()) %></strong></div>
                            <div><span>ระบบ/โครงการ</span><strong><%= display(item.getTargetSystem()) %></strong></div>
                            <div><span>วันที่ส่งฟอร์ม</span><strong><%= item.getSubmittedAt() == null ? "-" : dateTime.format(item.getSubmittedAt()) %></strong></div>
                        </div>
                    </div>
                    <div class="link-card-actions clean-actions">
                        <% if (item.getSubmissionId() != null) { %>
                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/thirdPartySubmission?id=<%= item.getSubmissionId() %>">
                            <i class="fa-solid fa-file-lines"></i> รายละเอียด
                        </a>
                        <% } %>
                    </div>
                </article>
                <% } %>
            </div>
            <div id="historyEmpty" class="empty-link-state" hidden><i class="fa-solid fa-filter-circle-xmark"></i><h2>ไม่พบรายการที่ตรงกับตัวกรอง</h2></div>
            <% } %>
        </section>
    </main>
    <%@ include file="/WEB-INF/jspf/footer.jspf" %>
</div>
<script>
function toggleNav(){var s=document.getElementById("mySidebar"),m=document.getElementById("main"),o=s.style.width==="250px";s.style.width=o?"0":"250px";m.style.marginLeft=o?"0":"250px";m.style.width=o?"100%":"calc(100% - 250px)";}
(function(){
    var filter="all", search=document.getElementById("historySearch");
    function apply(){
        var q=(search&&search.value||"").trim().toLowerCase(), visible=0;
        document.querySelectorAll(".third-party-history-card").forEach(function(card){
            var show=(filter==="all"||card.dataset.category===filter)&&(!q||card.dataset.search.indexOf(q)>=0);
            card.hidden=!show;if(show)visible++;
        });
        var count=document.getElementById("historyCount");if(count)count.textContent=visible+" รายการ";
        var empty=document.getElementById("historyEmpty");if(empty)empty.hidden=visible!==0;
    }
    document.querySelectorAll(".history-filter").forEach(function(button){button.addEventListener("click",function(){
        filter=button.dataset.filter;document.querySelectorAll(".history-filter").forEach(function(b){b.classList.toggle("selected",b===button);});apply();
    });});
    if(search)search.addEventListener("input",apply);
}());
</script>
</body>
</html>
