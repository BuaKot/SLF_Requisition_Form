<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.slf.model.ThirdPartyRequest" %>
<%@ page import="com.slf.model.ThirdPartyAcceptanceToken" %>
<%@ page import="com.slf.util.NavigationUtil" %>
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

    private String requestStatusText(String status) {
        if ("LINK_CREATED".equals(status)) return "รอผู้ขอภายนอกกรอกฟอร์ม";
        if ("SUBMITTED".equals(status)) return "รอหัวหน้าส่วนพิจารณา";
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
        if ("CANCELLED".equals(status)) return "ยกเลิกแล้ว";
        return status == null ? "-" : status;
    }

    private String linkStatusText(String status) {
        if ("ACTIVE".equals(status)) return "ลิงก์ใช้งานได้";
        if ("USED".equals(status)) return "ลิงก์ถูกใช้แล้ว";
        if ("EXPIRED".equals(status)) return "ลิงก์หมดอายุ";
        if ("REVOKED".equals(status)) return "ลิงก์ถูกยกเลิก";
        return status == null ? "-" : status;
    }

    private String badgeClass(String status) {
        if ("USED".equals(status) || "COMPLETED".equals(status)) return "ok";
        if ("EXPIRED".equals(status) || "REJECTED".equals(status) || "REVOKED".equals(status) || "CANCELLED".equals(status)) return "danger";
        return "wait";
    }

    private String displayAcceptance(String value) {
        return value == null || value.trim().isEmpty() ? "-" : h(value);
    }
%>
<%
    if (!ThirdPartyAccessPolicy.canCreateOwnLinks(ThirdPartyAccessPolicy.sessionEmpId(session))) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }
    List<ThirdPartyRequest> thirdPartyRequests =
        (List<ThirdPartyRequest>) request.getAttribute("thirdPartyRequests");
    if (thirdPartyRequests == null) {
        thirdPartyRequests = Collections.emptyList();
    }
    List<ThirdPartyAcceptanceToken> acceptanceTokens =
        (List<ThirdPartyAcceptanceToken>) request.getAttribute("acceptanceTokens");
    if (acceptanceTokens == null) acceptanceTokens = Collections.emptyList();
    Map<Long, ThirdPartyAcceptanceToken> acceptanceTokensByRequestId =
        (Map<Long, ThirdPartyAcceptanceToken>) request.getAttribute("acceptanceTokensByRequestId");
    if (acceptanceTokensByRequestId == null) acceptanceTokensByRequestId = Collections.emptyMap();
    String thirdPartyLinkPrefix = (String) request.getAttribute("thirdPartyLinkPrefix");
    if (thirdPartyLinkPrefix == null) thirdPartyLinkPrefix = "";
    String acceptanceLinkPrefix = (String) request.getAttribute("acceptanceLinkPrefix");
    String csrfToken = (String) request.getAttribute("csrfToken");
    SimpleDateFormat dateTime = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
    String createdRequestId = request.getParameter("createdRequestId");
    String status = request.getParameter("status");
    NavigationUtil.BackLink thirdPartyFormBack = NavigationUtil.thirdPartyFormDetailBack(request.getContextPath());
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>จัดการลิงก์แบบฟอร์มผู้ให้บริการภายนอก</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body>
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
<div id="main">
    <%@ include file="/WEB-INF/jspf/topbar.jspf" %>

    <main class="third-party-request-page owner-link-dashboard">
        <section class="third-party-page-head third-party-toolbar-head">
            <div>
                <p class="eyebrow">แบบฟอร์มสำหรับผู้ให้บริการภายนอก</p>
                <h1>ติดตามลิงก์ลงทะเบียนผู้ใช้ระบบงานสารสนเทศ</h1>
                <p>สร้างลิงก์ใหม่ ดูสถานะ และยกเลิกลิงก์ที่ยังไม่ถูกส่งแบบฟอร์มได้จากหน้านี้</p>
            </div>
            <div class="page-head-actions">
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/thirdParty/history">
                    <i class="fa-solid fa-clock-rotate-left"></i> ประวัติ
                </a>
                <a class="btn btn-secondary detail-back-button" href="<%= h(request.getContextPath() + "/index.jsp") %>">
                    <i class="fa-solid fa-arrow-left"></i> <%= h(thirdPartyFormBack.getLabel()) %>
                </a>
                <form method="post" action="${pageContext.request.contextPath}/thirdParty/request/new">
                    <input type="hidden" name="csrfToken" value="<%= h(csrfToken) %>">
                    <input type="hidden" name="action" value="create">
                    <button class="btn btn-primary primary-action" type="submit">
                        <i class="fa-solid fa-plus"></i> สร้างลิงก์ใหม่
                    </button>
                </form>
            </div>
        </section>

        <% if (createdRequestId != null && !createdRequestId.trim().isEmpty()) { %>
            <div class="form-alert neutral owner-request-alert">สร้างลิงก์ใหม่เรียบร้อยแล้ว รายการ #<%= h(createdRequestId) %> พร้อมให้คัดลอกจากรายการด้านล่าง</div>
        <% } else if ("cancelled".equals(status)) { %>
            <div class="form-alert neutral owner-request-alert">ยกเลิกและลบลิงก์ที่ยังไม่ถูกใช้งานเรียบร้อยแล้ว</div>
        <% } else if ("not_cancelled".equals(status)) { %>
            <div class="form-alert owner-request-alert">ไม่สามารถยกเลิกได้ อาจถูกส่งฟอร์มแล้ว หมดอายุ หรือถูกยกเลิกไปก่อนหน้า</div>
        <% } %>

        <section class="third-party-panel owner-request-list-panel">
            <div class="third-party-list-head">
                <div>
                    <div class="form-section-title">รายการลิงก์ที่สร้าง</div>
                    <p class="muted-text">รวมลิงก์สำหรับกรอกแบบฟอร์ม และลิงก์ตรวจรับ/ประเมินไว้ในรายการเดียวกัน</p>
                </div>
                <span class="third-party-count"><%= thirdPartyRequests.size() %> รายการ</span>
            </div>

            <% if (thirdPartyRequests.isEmpty()) { %>
                <div class="empty-link-state">
                    <i class="fa-solid fa-link"></i>
                    <h2>ยังไม่มีลิงก์ Third Party</h2>
                    <p>กด “สร้างลิงก์ใหม่” เพื่อสร้าง token link สำหรับส่งให้ผู้ให้บริการภายนอกกรอกข้อมูล</p>
                </div>
            <% } else { %>
                <div class="third-party-link-list compact-list">
                    <% for (ThirdPartyRequest item : thirdPartyRequests) {
                        boolean canCancel = "LINK_CREATED".equals(item.getStatus())
                            && "ACTIVE".equals(item.getLinkStatus())
                            && item.getSubmissionId() == null
                            && item.getLinkId() != null;
                        ThirdPartyAcceptanceToken acceptance =
                            acceptanceTokensByRequestId.get(Long.valueOf(item.getRequestId()));
                        String formPublicLink = item.getRawToken() == null || !"ACTIVE".equals(item.getLinkStatus())
                            ? null : thirdPartyLinkPrefix + item.getRawToken();
                        String acceptancePublicLink = acceptance == null || acceptance.getRawToken() == null
                            || !"ACTIVE".equals(acceptance.getStatus())
                            ? null : acceptanceLinkPrefix + acceptance.getRawToken();
                    %>
                        <article class="third-party-link-card compact-card owner-request-card">
                            <div class="link-card-main">
                                <div class="link-card-title-row">
                                    <div>
                                        <h2>คำขอ #<%= item.getRequestId() %></h2>
                                        <p class="muted-text compact-note">
                                            สร้างเมื่อ <%= item.getCreatedAt() == null ? "-" : dateTime.format(item.getCreatedAt()) %>
                                            <span class="compact-note-requester"><%= item.getExternalContactName() == null ? "" : " | ผู้ขอใช้บริการ " + h(item.getExternalContactName()) %></span>
                                        </p>
                                    </div>
                                    <div class="link-card-actions clean-actions owner-request-card-actions">
                                        <div class="link-card-badges">
                                            <span class="status-badge <%= badgeClass(item.getStatus()) %>"><%= h(requestStatusText(item.getStatus())) %></span>
                                            <span class="status-badge <%= badgeClass(item.getLinkStatus()) %>"><%= h(linkStatusText(item.getLinkStatus())) %></span>
                                        </div>
                                        <% if (canCancel) { %>
                                            <form method="post" action="${pageContext.request.contextPath}/thirdParty/request/new" onsubmit="return confirmCancelThirdPartyLink();">
                                                <input type="hidden" name="csrfToken" value="<%= h(csrfToken) %>">
                                                <input type="hidden" name="action" value="cancel">
                                                <input type="hidden" name="requestId" value="<%= item.getRequestId() %>">
                                                <input type="hidden" name="linkId" value="<%= item.getLinkId() %>">
                                                <button class="btn btn-danger-soft" type="submit">
                                                    <i class="fa-solid fa-trash-can"></i> ยกเลิกลิงก์
                                                </button>
                                            </form>
                                        <% } %>
                                    </div>
                                </div>

                                <div class="merged-link-grid">
                                    <div class="merged-link-box">
                                        <div class="merged-link-head">
                                            <span><i class="fa-solid fa-file-pen"></i> ลิงก์สำหรับกรอกแบบฟอร์ม</span>
                                            <strong><%= h(linkStatusText(item.getLinkStatus())) %></strong>
                                        </div>
                                        <% if (formPublicLink == null || formPublicLink.trim().isEmpty()) { %>
                                            <div class="blank-link-value">-</div>
                                        <% } else { %>
                                            <button class="copy-link-text" type="button" data-link="<%= h(formPublicLink) %>" onclick="copyMergedLink(this)">คัดลอกลิ้งก์</button>
                                        <% } %>
                                        <div class="merged-link-meta-grid">
                                            <span>หมดอายุ: <strong><%= item.getLinkExpiresAt() == null ? "-" : dateTime.format(item.getLinkExpiresAt()) %></strong></span>
                                            <span>ส่งฟอร์มเมื่อ: <strong><%= item.getSubmittedAt() == null ? "-" : dateTime.format(item.getSubmittedAt()) %></strong></span>
                                        </div>
                                    </div>
                                    <div class="merged-link-box">
                                        <div class="merged-link-head">
                                            <span><i class="fa-solid fa-clipboard-check"></i> ลิงก์ตรวจรับและประเมิน</span>
                                            <strong><%= acceptance == null ? "-" : h(linkStatusText(acceptance.getStatus())) %></strong>
                                        </div>
                                        <% if (acceptancePublicLink == null || acceptancePublicLink.trim().isEmpty()) { %>
                                            <div class="blank-link-value">-</div>
                                        <% } else { %>
                                            <button class="copy-link-text" type="button" data-link="<%= h(acceptancePublicLink) %>" onclick="copyMergedLink(this)">คัดลอกลิ้งก์</button>
                                        <% } %>
                                        <div class="merged-link-meta">หมดอายุ: <%= acceptance == null || acceptance.getExpiresAt() == null ? "-" : dateTime.format(acceptance.getExpiresAt()) %></div>
                                    </div>
                                </div>
                            </div>
                        </article>
                    <% } %>
                </div>
            <% } %>
        </section>
    </main>
    <%@ include file="/WEB-INF/jspf/footer.jspf" %>
</div>
<script>
function confirmCancelThirdPartyLink() {
    return window.confirm("ยืนยันยกเลิกลิงก์นี้หรือไม่? รายการที่ยังไม่ถูกใช้งานจะถูกลบออกจากประวัติและฐานข้อมูล");
}
function copyMergedLink(button) {
    if (!button) return;
    var link = button.getAttribute("data-link") || "";
    if (!link) return;
    var original = button.textContent;
    var done = function () {
        button.textContent = "คัดลอกแล้ว";
        window.setTimeout(function () { button.textContent = original; }, 1400);
    };
    if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(link).then(done).catch(function () {
            copyTextFallback(link);
            done();
        });
    } else {
        copyTextFallback(link);
        done();
    }
}
function copyTextFallback(text) {
    var input = document.createElement("input");
    input.type = "text";
    input.value = text;
    input.setAttribute("readonly", "readonly");
    input.style.position = "fixed";
    input.style.left = "-9999px";
    document.body.appendChild(input);
    input.select();
    document.execCommand("copy");
    document.body.removeChild(input);
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


