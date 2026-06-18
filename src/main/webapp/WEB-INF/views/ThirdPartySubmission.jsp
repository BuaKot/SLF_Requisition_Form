<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page import="com.slf.model.ThirdPartyFormSubmission" %>
<%@ page import="com.slf.model.ThirdPartyAccessRequest" %>
<%@ page import="com.slf.model.ThirdPartyWorkflowActionEntry" %>
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

    public String maskNationalId(String input) {
        if (input == null || input.length() != 13) return "-";
        return h(input.substring(0, 1) + "-xxxx-xxxxx-" + input.substring(11, 13));
    }

    public String actionTitle(String actionType) {
        if ("SECTION_HEAD_SUBMITTED".equals(actionType)) return "หัวหน้ากลุ่มงาน";
        if ("IT_DIRECTOR_APPROVED".equals(actionType)) return "ผู้อำนวยการฝ่ายเทคโนโลยีสารสนเทศ";
        if ("IT_DIRECTOR_REJECTED".equals(actionType)) return "ผู้อำนวยการฝ่ายเทคโนโลยีสารสนเทศ ไม่อนุมัติ";
        if ("OPERATOR_COMPLETED".equals(actionType)) return "ผู้ดำเนินการ";
        if ("EXTERNAL_ACCEPTED".equals(actionType)) return "ผลตรวจรับ";
        if ("EXTERNAL_REJECTED".equals(actionType)) return "ผลตรวจรับ ไม่อนุมัติ";
        if ("EXTERNAL_ACCEPTANCE_EXPIRED".equals(actionType)) return "ผลตรวจรับหมดอายุ";
        if ("REVOKER_COMPLETED".equals(actionType)) return "ผู้ดูแลระบบยกเลิกสิทธิ์";
        if ("REVOKE_REVIEWER_APPROVED".equals(actionType)) return "ผู้ตรวจทานการยกเลิกสิทธิ์";
        if ("REVOKE_REVIEWER_REJECTED".equals(actionType)) return "ผู้ตรวจทานการยกเลิกสิทธิ์ ไม่อนุมัติ";
        if ("SECTION_HEAD_REPORTED".equals(actionType)) return "หัวหน้ากลุ่มงาน";
        if ("FINAL_CERTIFIED".equals(actionType)) return "ผู้อำนวยการฝ่ายเทคโนโลยีสารสนเทศ";
        return actionType == null ? "-" : actionType;
    }

    public boolean isRejectedAction(String actionType) {
        return actionType != null && (actionType.endsWith("_REJECTED")
            || "EXTERNAL_ACCEPTANCE_EXPIRED".equals(actionType));
    }

    public String actorLabel(ThirdPartyWorkflowActionEntry action) {
        if (action == null) return "-";
        if ("SYSTEM".equals(action.getActorType())) return "ระบบ";
        if (action.getActorEmpName() != null && !action.getActorEmpName().trim().isEmpty()) return action.getActorEmpName();
        if ("EXTERNAL".equals(action.getActorType())) return "ผู้ขอใช้บริการ";
        if (action.getActorEmpId() != null) return "Employee #" + action.getActorEmpId();
        return "-";
    }

%>
<%
    String currentRole = (String) session.getAttribute("position");
    if (!Boolean.TRUE.equals(request.getAttribute("thirdPartySubmissionAuthorized"))) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }
    ThirdPartyFormSubmission submission = (ThirdPartyFormSubmission) request.getAttribute("submission");
    if (submission == null) {
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
        return;
    }
    String backUrl = (String) request.getAttribute("thirdPartySubmissionBackUrl");
    if (backUrl == null) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }
    NavigationUtil.BackLink thirdPartyBackLink = NavigationUtil.thirdPartyDetailBack(backUrl);
    backUrl = thirdPartyBackLink.getHref();
    List<ThirdPartyWorkflowActionEntry> approvalHistory =
        (List<ThirdPartyWorkflowActionEntry>) request.getAttribute("approvalHistory");
    if (approvalHistory == null) approvalHistory = Collections.emptyList();
    Integer acceptanceScore = (Integer) request.getAttribute("acceptanceScore");
    boolean thirdPartyCompleted = Boolean.TRUE.equals(request.getAttribute("thirdPartyCompleted"));
    SimpleDateFormat dateTime = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
    SimpleDateFormat dateOnly = new SimpleDateFormat("dd/MM/yyyy");
    SimpleDateFormat timeOnly = new SimpleDateFormat("HH:mm:ss");
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>คำขอ Third-party #<%= submission.getRequestId() %></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css?v=20260618-2">
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/images/cropped-logo-192x192.png">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="view-third-party-submission">
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
<div id="main">
    <%@ include file="/WEB-INF/jspf/topbar.jspf" %>

    <main class="page third-party-request-page">
        <div class="page-head">
            <div class="page-title">
                <h1><i class="fa-solid fa-file-lines"></i> คำขอ #<%= submission.getRequestId() %></h1>
                <p>เลขที่รับเอกสาร <strong><%= display(submission.getDocumentReceiveNo()) %></strong></p>
            </div>
            <div class="page-actions">
                <% if (thirdPartyCompleted) { %>
                <a class="btn btn-primary primary-action" target="_blank" rel="noopener"
                   href="${pageContext.request.contextPath}/thirdParty/exportPdf?submissionId=<%= submission.getSubmissionId() %>">
                    <i class="fa-solid fa-file-pdf"></i> Export PDF
                </a>
                <% } %>
                <a class="btn btn-secondary detail-back-button" href="<%= h(backUrl) %>">
                    <i class="fa-solid fa-arrow-left"></i> <%= h(thirdPartyBackLink.getLabel()) %>
                </a>
            </div>
        </div>

        <section class="panel">
            <h2 class="section-title">รายละเอียดการขอใช้งาน</h2>
            <div class="grid">
                <div class="field full">
                    <div class="label">เหตุผลและวัตถุประสงค์การขอ</div>
                    <div class="value"><%= display(submission.getReasonObjective()) %></div>
                </div>
                <div class="field full">
                    <div class="label">เพื่อใช้ในโครงการ</div>
                    <div class="value"><%= display(submission.getProjectName()) %></div>
                </div>
                <div class="field">
                    <div class="label">วันที่เริ่มต้นใช้ระบบงาน</div>
                    <div class="value"><%= submission.getAccessStartDate() == null ? "-" : dateOnly.format(submission.getAccessStartDate()) %></div>
                </div>
                <div class="field">
                    <div class="label">ถึงวันที่</div>
                    <div class="value"><%= submission.getAccessEndDate() == null ? "-" : dateOnly.format(submission.getAccessEndDate()) %></div>
                </div>
            </div>
        </section>

        <section class="panel">
            <h2 class="section-title">รายชื่อผู้ขอรับสิทธิ์การเข้าถึง</h2>
            <% for (ThirdPartyAccessRequest item : submission.getAccessRequests()) { %>
                <div class="access-item">
                    <div class="access-item-title">รายชื่อคนที่ <%= item.getDisplayOrder() %></div>
                    <div class="grid">
                        <div class="field"><div class="label">รหัสพนักงาน</div><div class="value"><%= display(item.getEmployeeCode()) %></div></div>
                        <div class="field"><div class="label">ชื่อผู้ใช้งาน</div><div class="value"><%= display(item.getUsername()) %></div></div>
                        <div class="field"><div class="label">เลขที่บัตรประชาชน</div><div class="value"><%= maskNationalId(item.getNationalId()) %></div></div>
                        <div class="field"><div class="label">ชื่อ-สกุล (TH)</div><div class="value"><%= display(item.getFullNameTh()) %></div></div>
                        <div class="field"><div class="label">ชื่อ-สกุล (EN)</div><div class="value"><%= display(item.getFullNameEn()) %></div></div>
                        <div class="field"><div class="label">ตำแหน่ง</div><div class="value"><%= display(item.getPositionName()) %></div></div>
                        <div class="field"><div class="label">เบอร์โทรศัพท์มือถือ</div><div class="value"><%= display(item.getMobilePhone()) %></div></div>
                        <div class="field"><div class="label">ฝ่าย/กลุ่มงาน</div><div class="value"><%= display(item.getDepartmentName()) %></div></div>
                        <div class="field"><div class="label">Email</div><div class="value"><%= display(item.getEmail()) %></div></div>
                        <div class="field"><div class="label">ระบบงาน</div><div class="value"><%= display(item.getSystemName()) %></div></div>
                        <div class="field full"><div class="label">สิทธิ์การใช้งาน (Role)</div><div class="value"><%= display(item.getRequestedRole()) %></div></div>
                    </div>
                </div>
            <% } %>
            <div class="table-note"><strong>หมายเหตุ*</strong> โปรดระบุเลขที่บัตรประชาชนหากขอใช้ระบบงานกองทุนเงินให้กู้ยืมเพื่อการศึกษาแบบดิจิทัล (DSL)</div>
        </section>

        <section class="panel">
            <h2 class="section-title">ประวัติการดำเนินงาน</h2>
            <% if (approvalHistory.isEmpty()) { %>
                <div class="empty-approval-state">ยังไม่มีประวัติการดำเนินงานสำหรับคำขอนี้</div>
            <% } else { %>
                <div class="approval-list">
                    <% for (ThirdPartyWorkflowActionEntry action : approvalHistory) {
                        String actionType = action.getActionType();
                        boolean rejectedAction = isRejectedAction(actionType);
                    %>
                        <article class="approval-card <%= rejectedAction ? "rejected" : "" %>">
                            <div class="approval-card-title"><%= h(actionTitle(actionType)) %></div>
                            <div class="approval-actor"><%= display(actorLabel(action)) %></div>
                            <div class="approval-time">
                                <%= "EXTERNAL_ACCEPTED".equals(actionType) || "EXTERNAL_REJECTED".equals(actionType)
                                    ? "ส่งเมื่อ" : "อนุมัติเมื่อ" %>
                                <%= action.getActedAt() == null ? "-" : dateOnly.format(action.getActedAt()) %>
                                เวลา
                                <%= action.getActedAt() == null ? "-" : timeOnly.format(action.getActedAt()) %>
                            </div>

                            <% if ("SECTION_HEAD_SUBMITTED".equals(actionType)) { %>
                                <div class="approval-detail-label">รับเรื่อง/ส่งต่อ</div>
                                <div class="approval-card-detail"><%= display(action.getCommentText()) %></div>
                            <% } else if ("IT_DIRECTOR_APPROVED".equals(actionType) || "IT_DIRECTOR_REJECTED".equals(actionType)) { %>
                                <div class="approval-detail-label">คำสั่ง/ความเห็น</div>
                                <div class="approval-card-detail"><%= display(action.getCommentText()) %></div>
                            <% } else if ("EXTERNAL_ACCEPTED".equals(actionType) || "EXTERNAL_REJECTED".equals(actionType)) { %>
                                <% if (acceptanceScore != null) { %>
                                    <div class="approval-score">คะแนน <%= acceptanceScore %></div>
                                <% } %>
                                <div class="approval-card-detail"><%= display(action.getCommentText()) %></div>
                            <% } else if ("SECTION_HEAD_REPORTED".equals(actionType)) { %>
                                <div class="approval-detail-label">รายงานเพื่อโปรดทราบ</div>
                                <div class="approval-card-detail"><%= display(action.getCommentText()) %></div>
                            <% } else if (!"FINAL_CERTIFIED".equals(actionType)) { %>
                                <div class="approval-card-detail"><%= display(action.getCommentText()) %></div>
                            <% } %>
                        </article>
                    <% } %>
                </div>
            <% } %>
        </section>

        <section class="panel">
            <h2 class="section-title">หลักฐานการยินยอมรับเงื่อนไข</h2>
            <div class="grid">
                <div class="field">
                    <div class="label">สถานะการยินยอม</div>
                    <div class="value"><%= submission.isConsentAccepted() ? "ยินยอมแล้ว" : "ไม่พบการยินยอม" %></div>
                </div>
                <div class="field">
                    <div class="label">ฉบับหนังสือยินยอม</div>
                    <div class="value"><%= display(submission.getConsentVersion()) %></div>
                </div>
                <div class="field">
                    <div class="label">เวลาที่ยินยอม</div>
                    <div class="value"><%= submission.getConsentAcceptedAt() == null ? "-" : dateTime.format(submission.getConsentAcceptedAt()) %></div>
                </div>
                <div class="field">
                    <div class="label">IP Address</div>
                    <div class="value"><%= display(submission.getConsentIpAddress()) %></div>
                </div>
                <div class="field full">
                    <div class="label">User-Agent</div>
                    <div class="value"><%= display(submission.getConsentUserAgent()) %></div>
                </div>
            </div>
        </section>

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
