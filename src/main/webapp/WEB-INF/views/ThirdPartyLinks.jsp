<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%@ page import="com.slf.model.ThirdPartyFormLink" %>
<%@ page import="com.slf.util.AuthUtil" %>
<%@ page import="com.slf.util.NavigationUtil" %>
<%!
    public String h(Object input) {
        if (input == null) return "";
        return String.valueOf(input)
            .replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
            .replace("\"", "&quot;").replace("'", "&#x27;");
    }

    public String display(Object input) {
        return input == null || String.valueOf(input).trim().isEmpty() ? "-" : h(input);
    }

    public String statusText(String status) {
        if ("ACTIVE".equals(status)) return "ใช้งานได้";
        if ("USED".equals(status)) return "ส่งข้อมูลแล้ว";
        if ("EXPIRED".equals(status)) return "หมดอายุ";
        if ("REVOKED".equals(status)) return "ยกเลิกแล้ว";
        return status == null ? "-" : status;
    }

    public String badgeClass(String status) {
        if ("ACTIVE".equals(status)) return "ok";
        if ("USED".equals(status)) return "info";
        return "danger";
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
    String status = (String) request.getAttribute("status");
    String publicBaseUrl = (String) request.getAttribute("publicBaseUrl");
    SimpleDateFormat dateTime = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
    NavigationUtil.BackLink adminBackLink = NavigationUtil.adminListPageBack(request.getContextPath());

    int activeCount = 0, usedCount = 0, expiredCount = 0, revokedCount = 0;
    for (ThirdPartyFormLink link : links) {
        if ("ACTIVE".equals(link.getStatus())) activeCount++;
        else if ("USED".equals(link.getStatus())) usedCount++;
        else if ("EXPIRED".equals(link.getStatus())) expiredCount++;
        else if ("REVOKED".equals(link.getStatus())) revokedCount++;
    }
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>จัดการ Third-party Form Links</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/images/cropped-logo-192x192.png">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body>
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
<div id="main">
    <%@ include file="/WEB-INF/jspf/topbar.jspf" %>

    <main class="third-party-request-page admin-third-party-page">
        <section class="third-party-page-head third-party-toolbar-head">
            <div>
                <p class="eyebrow">Admin · Third-party Forms</p>
                <h1>จัดการลิงก์สำหรับผู้ให้บริการภายนอก</h1>
                <p>สร้างและติดตามลิงก์ทั้งหมด ตรวจสอบ Submission และจัดการลิงก์ที่ยังไม่ถูกใช้งาน</p>
            </div>
            <div class="page-head-actions">
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/thirdParty/history">
                    <i class="fa-solid fa-clock-rotate-left"></i> ประวัติคำขอ
                </a>
                <a class="btn btn-secondary detail-back-button" href="<%= h(adminBackLink.getHref()) %>">
                    <i class="fa-solid fa-arrow-left"></i> <%= h(adminBackLink.getLabel()) %>
                </a>
            </div>
        </section>

        <section class="admin-link-summary" aria-label="สรุปสถานะลิงก์">
            <button class="admin-summary-item selected" type="button" data-filter="ALL" onclick="filterLinks(this)">
                <span>ทั้งหมด</span><strong><%= links.size() %></strong>
            </button>
            <button class="admin-summary-item active" type="button" data-filter="ACTIVE" onclick="filterLinks(this)">
                <span>ใช้งานได้</span><strong><%= activeCount %></strong>
            </button>
            <button class="admin-summary-item used" type="button" data-filter="USED" onclick="filterLinks(this)">
                <span>ส่งข้อมูลแล้ว</span><strong><%= usedCount %></strong>
            </button>
            <button class="admin-summary-item expired" type="button" data-filter="EXPIRED" onclick="filterLinks(this)">
                <span>หมดอายุ</span><strong><%= expiredCount %></strong>
            </button>
            <button class="admin-summary-item revoked" type="button" data-filter="REVOKED" onclick="filterLinks(this)">
                <span>ยกเลิกแล้ว</span><strong><%= revokedCount %></strong>
            </button>
        </section>

        <% if ("revoked".equals(status)) { %>
            <div class="form-alert neutral">ยกเลิกลิงก์เรียบร้อยแล้ว</div>
        <% } else if ("generated".equals(status)) { %>
            <div class="form-alert neutral">สร้างลิงก์ใหม่เรียบร้อยแล้ว พร้อมคัดลอกจากรายการด้านล่าง</div>
        <% } else if ("not_revoked".equals(status)) { %>
            <div class="form-alert">ไม่สามารถยกเลิกลิงก์นี้ได้ ลิงก์อาจถูกใช้หรือหมดอายุแล้ว</div>
        <% } %>

        <section class="third-party-panel admin-generate-panel">
            <div class="admin-panel-heading">
                <div>
                    <div class="form-section-title">สร้างลิงก์ใหม่</div>
                    <p class="muted-text">ลิงก์มีอายุ 24 ชั่วโมง ส่งข้อมูลได้ครั้งเดียว และบันทึกผู้สร้างอัตโนมัติ</p>
                </div>
                <span class="admin-badge"><i class="fa-solid fa-shield-halved"></i> Admin</span>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/thirdPartyLinks">
                <input type="hidden" name="csrfToken" value="<%= h(csrfToken) %>">
                <input type="hidden" name="action" value="generate">
                <div class="admin-generate-row">
                    <div class="form-field">
                        <label for="note">หมายเหตุของลิงก์</label>
                        <input id="note" name="note" type="text" maxlength="500" placeholder="เช่น บริษัท / โครงการ / ผู้ประสานงาน">
                    </div>
                    <button class="btn btn-primary primary-action" type="submit">
                        <i class="fa-solid fa-plus"></i> สร้างลิงก์ใหม่
                    </button>
                </div>
            </form>
        </section>

        <section class="third-party-panel">
            <div class="third-party-list-head">
                <div>
                    <div class="form-section-title">รายการลิงก์ทั้งหมด</div>
                    <p class="muted-text">รวมลิงก์ที่สร้างโดย Admin และผู้ใช้งานภายในที่ได้รับสิทธิ์</p>
                </div>
                <span id="visibleLinkCount" class="third-party-count"><%= links.size() %> รายการ</span>
            </div>

            <% if (links.isEmpty()) { %>
                <div class="empty-link-state"><i class="fa-solid fa-link"></i><h2>ยังไม่มีลิงก์ Third-party</h2></div>
            <% } else { %>
                <div class="third-party-link-list compact-list">
                <% for (ThirdPartyFormLink link : links) {
                    String rawToken = link.getRawToken();
                    String publicLink = rawToken == null ? generatedLinks.get(Long.valueOf(link.getLinkId())) : publicBaseUrl + rawToken;
                    boolean canCopy = "ACTIVE".equals(link.getStatus()) && publicLink != null;
                    boolean canRevoke = "ACTIVE".equals(link.getStatus()) && link.getSubmitCount() == 0;
                %>
                    <article class="third-party-link-card admin-link-card" data-status="<%= h(link.getStatus()) %>">
                        <div class="link-card-main">
                            <div class="link-card-title-row">
                                <div>
                                    <h2>Link #<%= link.getLinkId() %></h2>
                                    <p class="muted-text compact-note"><%= display(link.getNote()) %></p>
                                </div>
                                <div class="link-card-badges">
                                    <span class="status-badge <%= badgeClass(link.getStatus()) %>"><%= h(statusText(link.getStatus())) %></span>
                                    <% if (link.getSubmissionId() != null) { %>
                                        <span class="status-badge info">Submission #<%= link.getSubmissionId() %></span>
                                    <% } %>
                                </div>
                            </div>

                            <div class="admin-link-meta">
                                <div><span>สร้างโดย</span><strong>Employee #<%= display(link.getCreatedByEmpId() == null ? link.getCreatedBy() : link.getCreatedByEmpId()) %></strong></div>
                                <div><span>Request ID</span><strong><%= link.getRequestId() == null ? "Admin direct link" : "#" + link.getRequestId() %></strong></div>
                                <div><span>สร้างเมื่อ</span><strong><%= link.getCreatedAt() == null ? "-" : dateTime.format(link.getCreatedAt()) %></strong></div>
                                <div><span>หมดอายุ</span><strong><%= link.getExpiresAt() == null ? "-" : dateTime.format(link.getExpiresAt()) %></strong></div>
                                <div><span>Submit</span><strong><%= link.getSubmitCount() %> / <%= link.getMaxSubmitCount() %></strong></div>
                            </div>
                        </div>

                        <div class="link-card-actions clean-actions admin-card-actions">
                            <% if (canCopy) { %>
                                <input id="adminCopyLink_<%= link.getLinkId() %>" type="text" value="<%= h(publicLink) %>" readonly hidden>
                                <button class="btn btn-secondary" type="button" onclick="copyInputValue('adminCopyLink_<%= link.getLinkId() %>', this)">
                                    <i class="fa-solid fa-copy"></i> คัดลอกลิงก์
                                </button>
                            <% } %>
                            <% if (link.getSubmissionId() != null) { %>
                                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/thirdPartySubmission?id=<%= link.getSubmissionId() %>">
                                    <i class="fa-solid fa-file-lines"></i> รายละเอียด
                                </a>
                            <% } %>
                            <% if (canRevoke) { %>
                                <form method="post" action="${pageContext.request.contextPath}/thirdPartyLinks" onsubmit="return confirmAdminRevoke();">
                                    <input type="hidden" name="csrfToken" value="<%= h(csrfToken) %>">
                                    <input type="hidden" name="action" value="revoke">
                                    <input type="hidden" name="linkId" value="<%= link.getLinkId() %>">
                                    <button class="btn btn-danger-soft" type="submit"><i class="fa-solid fa-ban"></i> ยกเลิกลิงก์</button>
                                </form>
                            <% } %>
                        </div>
                    </article>
                <% } %>
                </div>
                <div id="filteredEmptyState" class="empty-link-state" hidden>
                    <i class="fa-solid fa-filter-circle-xmark"></i><h2>ไม่พบลิงก์ในสถานะนี้</h2>
                </div>
            <% } %>
        </section>
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

function filterLinks(button) {
    document.querySelectorAll(".admin-summary-item").forEach(function (item) {
        item.classList.toggle("selected", item === button);
    });
    var filter = button.getAttribute("data-filter");
    var visible = 0;
    document.querySelectorAll(".admin-link-card").forEach(function (card) {
        var show = filter === "ALL" || card.getAttribute("data-status") === filter;
        card.hidden = !show;
        if (show) visible++;
    });
    var count = document.getElementById("visibleLinkCount");
    if (count) count.textContent = visible + " รายการ";
    var empty = document.getElementById("filteredEmptyState");
    if (empty) empty.hidden = visible !== 0;
}

function copyInputValue(id, button) {
    var input = document.getElementById(id);
    if (!input) return;
    var done = function () {
        var original = button.innerHTML;
        button.innerHTML = '<i class="fa-solid fa-check"></i> คัดลอกแล้ว';
        window.setTimeout(function () { button.innerHTML = original; }, 1400);
    };
    if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(input.value).then(done);
    } else {
        input.hidden = false; input.select(); document.execCommand("copy"); input.hidden = true; done();
    }
}

function confirmAdminRevoke() {
    return window.confirm("ยืนยันยกเลิกลิงก์นี้หรือไม่? ผู้รับลิงก์จะไม่สามารถเปิดหรือส่งแบบฟอร์มได้อีก");
}
</script>
</body>
</html>


