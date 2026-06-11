<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page import="com.slf.model.Employee" %>
<%@ page import="com.slf.model.ThirdPartyAccessRequest" %>
<%@ page import="com.slf.model.ThirdPartyFormSubmission" %>
<%@ page import="com.slf.model.ThirdPartyRequest" %>
<%!
    private String h(Object input) {
        if (input == null) return "";
        return String.valueOf(input)
            .replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
            .replace("\"", "&quot;").replace("'", "&#39;");
    }

    private String display(Object input) {
        return input == null || String.valueOf(input).trim().isEmpty() ? "-" : h(input);
    }

    private String maskNationalId(String input) {
        if (input == null || input.length() != 13) return "-";
        return h(input.substring(0, 1) + "-xxxx-xxxxx-" + input.substring(11, 13));
    }

    private String workflowStatusText(String status) {
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
%>
<%
    ThirdPartyRequest thirdPartyRequest = (ThirdPartyRequest) request.getAttribute("thirdPartyRequest");
    ThirdPartyFormSubmission submission = (ThirdPartyFormSubmission) request.getAttribute("submission");
    List<Employee> infrastructureEmployees = (List<Employee>) request.getAttribute("infrastructureEmployees");
    if (infrastructureEmployees == null) infrastructureEmployees = Collections.emptyList();
    String csrfToken = (String) request.getAttribute("csrfToken");
    String formError = (String) request.getAttribute("formError");
    boolean canSubmit = "PENDING_SECTION_HEAD".equals(thirdPartyRequest.getStatus());
    boolean submitted = "submitted".equals(request.getParameter("status"));
    boolean separateRevoker = request.getParameter("separateRevoker") != null;
    String selectedGrant = request.getParameter("grantOperatorEmpId");
    String selectedRevoke = request.getParameter("revokeOperatorEmpId");
    String selectedReviewer = request.getParameter("revokeReviewerEmpId");
    String comment = request.getParameter("comment");
    SimpleDateFormat dateOnly = new SimpleDateFormat("dd/MM/yyyy");
    SimpleDateFormat dateTime = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>หัวหน้าส่วนพิจารณาคำขอ Third-party #<%= thirdPartyRequest.getRequestId() %></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        .section-head-review-page { max-width: 1180px; margin: 0 auto; padding: 26px 28px 48px; }
        .review-panel { background: #fff; border: 1px solid #d9e6f2; border-radius: 10px; padding: 22px; margin-bottom: 18px; box-shadow: 0 8px 22px rgba(0,51,102,.07); }
        .review-grid { display: grid; grid-template-columns: repeat(2, minmax(0,1fr)); gap: 15px 20px; }
        .review-field { border-bottom: 1px solid #e5eef6; padding-bottom: 10px; }
        .review-field.full { grid-column: 1 / -1; }
        .review-label { color: #64748b; font-size: 13px; font-weight: 800; margin-bottom: 5px; }
        .review-value { color: #102a43; line-height: 1.55; white-space: pre-wrap; overflow-wrap: anywhere; }
        .assignment-grid { display: grid; grid-template-columns: repeat(2, minmax(0,1fr)); gap: 16px 20px; }
        .assignment-grid .full { grid-column: 1 / -1; }
        .assignment-grid label { display: block; color: #24435e; font-weight: 800; margin-bottom: 7px; }
        .assignment-grid select, .assignment-grid textarea { width: 100%; border: 1px solid #bfd0df; border-radius: 7px; padding: 10px 12px; font: inherit; background: #fff; }
        .assignment-grid textarea { min-height: 130px; resize: vertical; }
        .same-person-toggle { display: flex; align-items: center; gap: 9px; font-weight: 800; color: #24435e; }
        .same-person-toggle input { width: 18px; height: 18px; }
        .access-item { border: 1px solid #d9e6f2; border-radius: 8px; padding: 16px; margin-top: 14px; }
        .access-item h3 { margin: 0 0 14px; color: #003366; }
        .workflow-status { display: inline-flex; padding: 5px 11px; border-radius: 999px; background: #fff4cc; color: #805b00; font-weight: 900; }
        .submit-row { display: flex; justify-content: flex-end; margin-top: 20px; }
        @media (max-width: 800px) {
            .section-head-review-page { padding: 18px 14px 36px; }
            .review-grid, .assignment-grid { grid-template-columns: 1fr; }
            .review-field.full, .assignment-grid .full { grid-column: auto; }
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
<div id="main">
    <%@ include file="/WEB-INF/jspf/topbar.jspf" %>
    <main class="section-head-review-page">
        <section class="third-party-page-head">
            <div>
                <p class="eyebrow">Third-party Workflow · หัวหน้าส่วน</p>
                <h1>พิจารณาคำขอ #<%= thirdPartyRequest.getRequestId() %></h1>
                <p>ตรวจสอบข้อมูล ให้ความเห็น และมอบหมายผู้รับผิดชอบก่อนส่งต่อให้ IT Director</p>
            </div>
            <span class="workflow-status"><%= h(workflowStatusText(thirdPartyRequest.getStatus())) %></span>
        </section>

        <% if (submitted) { %>
            <div class="form-alert neutral">ส่งคำขอให้ IT Director เรียบร้อยแล้ว</div>
        <% } %>
        <% if (formError != null) { %>
            <div class="form-alert"><%= h(formError) %></div>
        <% } %>

        <section class="review-panel">
            <h2 class="form-section-title">ข้อมูลผู้ขอภายนอก</h2>
            <div class="review-grid">
                <div class="review-field"><div class="review-label">เลขที่รับเอกสาร</div><div class="review-value"><%= display(submission.getDocumentReceiveNo()) %></div></div>
                <div class="review-field"><div class="review-label">วันที่ส่งฟอร์ม</div><div class="review-value"><%= submission.getCreatedAt() == null ? "-" : dateTime.format(submission.getCreatedAt()) %></div></div>
                <div class="review-field"><div class="review-label">ชื่อ-สกุล ภาษาไทย</div><div class="review-value"><%= display(submission.getFullNameTh()) %></div></div>
                <div class="review-field"><div class="review-label">ชื่อ-สกุล ภาษาอังกฤษ</div><div class="review-value"><%= display(submission.getFullNameEn()) %></div></div>
                <div class="review-field"><div class="review-label">หน่วยงาน</div><div class="review-value"><%= display(submission.getOrganization()) %></div></div>
                <div class="review-field"><div class="review-label">เบอร์โทรศัพท์</div><div class="review-value"><%= display(submission.getPhone()) %></div></div>
                <div class="review-field full"><div class="review-label">Email</div><div class="review-value"><%= display(submission.getEmail()) %></div></div>
            </div>
        </section>

        <section class="review-panel">
            <h2 class="form-section-title">รายละเอียดการขอใช้งาน</h2>
            <div class="review-grid">
                <div class="review-field full"><div class="review-label">เหตุผลและวัตถุประสงค์</div><div class="review-value"><%= display(submission.getReasonObjective()) %></div></div>
                <div class="review-field full"><div class="review-label">โครงการ</div><div class="review-value"><%= display(submission.getProjectName()) %></div></div>
                <div class="review-field"><div class="review-label">วันที่เริ่มต้น</div><div class="review-value"><%= submission.getAccessStartDate() == null ? "-" : dateOnly.format(submission.getAccessStartDate()) %></div></div>
                <div class="review-field"><div class="review-label">วันที่สิ้นสุด</div><div class="review-value"><%= submission.getAccessEndDate() == null ? "-" : dateOnly.format(submission.getAccessEndDate()) %></div></div>
            </div>
        </section>

        <section class="review-panel">
            <h2 class="form-section-title">รายการผู้ขอรับสิทธิ์</h2>
            <% for (ThirdPartyAccessRequest item : submission.getAccessRequests()) { %>
                <article class="access-item">
                    <h3>รายการที่ <%= item.getDisplayOrder() %>: <%= display(item.getFullNameTh()) %></h3>
                    <div class="review-grid">
                        <div class="review-field"><div class="review-label">รหัสพนักงาน</div><div class="review-value"><%= display(item.getEmployeeCode()) %></div></div>
                        <div class="review-field"><div class="review-label">ชื่อผู้ใช้งาน</div><div class="review-value"><%= display(item.getUsername()) %></div></div>
                        <div class="review-field"><div class="review-label">เลขบัตรประชาชน</div><div class="review-value"><%= maskNationalId(item.getNationalId()) %></div></div>
                        <div class="review-field"><div class="review-label">ชื่อ-สกุล ภาษาอังกฤษ</div><div class="review-value"><%= display(item.getFullNameEn()) %></div></div>
                        <div class="review-field"><div class="review-label">ตำแหน่ง</div><div class="review-value"><%= display(item.getPositionName()) %></div></div>
                        <div class="review-field"><div class="review-label">ฝ่าย/กลุ่มงาน</div><div class="review-value"><%= display(item.getDepartmentName()) %></div></div>
                        <div class="review-field"><div class="review-label">เบอร์โทรศัพท์มือถือ</div><div class="review-value"><%= display(item.getMobilePhone()) %></div></div>
                        <div class="review-field"><div class="review-label">ระบบงาน</div><div class="review-value"><%= display(item.getSystemName()) %></div></div>
                        <div class="review-field"><div class="review-label">Email</div><div class="review-value"><%= display(item.getEmail()) %></div></div>
                        <div class="review-field full"><div class="review-label">สิทธิ์การใช้งาน</div><div class="review-value"><%= display(item.getRequestedRole()) %></div></div>
                    </div>
                </article>
            <% } %>
        </section>

        <section class="review-panel">
            <h2 class="form-section-title">หลักฐานการยินยอม</h2>
            <div class="review-grid">
                <div class="review-field"><div class="review-label">สถานะการยินยอม</div><div class="review-value"><%= submission.isConsentAccepted() ? "ยินยอมแล้ว" : "ไม่พบการยินยอม" %></div></div>
                <div class="review-field"><div class="review-label">ฉบับหนังสือยินยอม</div><div class="review-value"><%= display(submission.getConsentVersion()) %></div></div>
                <div class="review-field"><div class="review-label">เวลาที่ยินยอม</div><div class="review-value"><%= submission.getConsentAcceptedAt() == null ? "-" : dateTime.format(submission.getConsentAcceptedAt()) %></div></div>
                <div class="review-field"><div class="review-label">IP Address</div><div class="review-value"><%= display(submission.getConsentIpAddress()) %></div></div>
            </div>
        </section>

        <section class="review-panel">
            <h2 class="form-section-title">ความเห็นและการมอบหมายงาน</h2>
            <% if (!canSubmit) { %>
                <div class="form-alert neutral">คำขอนี้ถูกส่งออกจากขั้นตอนหัวหน้าส่วนแล้ว จึงไม่สามารถแก้ไขหรือส่งซ้ำได้</div>
            <% } else if (infrastructureEmployees.isEmpty()) { %>
                <div class="form-alert">ไม่พบพนักงาน Infrastructure ที่ active สำหรับรับมอบหมายงาน</div>
            <% } else { %>
                <form method="post" action="${pageContext.request.contextPath}/thirdParty/sectionHead/review" onsubmit="return validateAssignments();">
                    <input type="hidden" name="csrfToken" value="<%= h(csrfToken) %>">
                    <input type="hidden" name="requestId" value="<%= thirdPartyRequest.getRequestId() %>">
                    <div class="assignment-grid">
                        <div class="full">
                            <label for="comment">ความเห็นหัวหน้าส่วน</label>
                            <textarea id="comment" name="comment" maxlength="4000" required><%= h(comment) %></textarea>
                        </div>
                        <div>
                            <label for="grantOperatorEmpId">ผู้ดำเนินการ</label>
                            <select id="grantOperatorEmpId" name="grantOperatorEmpId" required>
                                <option value="">-- เลือกผู้ดำเนินการ --</option>
                                <% for (Employee employee : infrastructureEmployees) { String value = String.valueOf(employee.getEmpId()); %>
                                    <option value="<%= value %>" <%= value.equals(selectedGrant) ? "selected" : "" %>><%= h(employee.getEmpName()) %> (#<%= value %>)</option>
                                <% } %>
                            </select>
                        </div>
                        <div>
                            <label for="revokeReviewerEmpId">ผู้ตรวจทานการยกเลิกสิทธิ์</label>
                            <select id="revokeReviewerEmpId" name="revokeReviewerEmpId" required>
                                <option value="">-- เลือกผู้ตรวจทาน --</option>
                                <% for (Employee employee : infrastructureEmployees) { String value = String.valueOf(employee.getEmpId()); %>
                                    <option value="<%= value %>" <%= value.equals(selectedReviewer) ? "selected" : "" %>><%= h(employee.getEmpName()) %> (#<%= value %>)</option>
                                <% } %>
                            </select>
                        </div>
                        <div class="full">
                            <label class="same-person-toggle">
                                <input id="separateRevoker" name="separateRevoker" type="checkbox" value="1" <%= separateRevoker ? "checked" : "" %> onchange="toggleRevoker()">
                                กำหนดผู้ยกเลิกสิทธิ์เป็นคนละคนกับผู้ดำเนินการ
                            </label>
                        </div>
                        <div id="revokeOperatorField" class="full" <%= separateRevoker ? "" : "hidden" %>>
                            <label for="revokeOperatorEmpId">ผู้ยกเลิกสิทธิ์</label>
                            <select id="revokeOperatorEmpId" name="revokeOperatorEmpId" <%= separateRevoker ? "required" : "" %>>
                                <option value="">-- เลือกผู้ยกเลิกสิทธิ์ --</option>
                                <% for (Employee employee : infrastructureEmployees) { String value = String.valueOf(employee.getEmpId()); %>
                                    <option value="<%= value %>" <%= value.equals(selectedRevoke) ? "selected" : "" %>><%= h(employee.getEmpName()) %> (#<%= value %>)</option>
                                <% } %>
                            </select>
                        </div>
                    </div>
                    <div class="submit-row">
                        <button class="btn btn-primary primary-action" type="submit">
                            <i class="fa-solid fa-paper-plane"></i> ส่งต่อให้ IT Director
                        </button>
                    </div>
                </form>
            <% } %>
        </section>
    </main>
    <%@ include file="/WEB-INF/jspf/footer.jspf" %>
</div>
<script>
window.addEventListener("pageshow", function(event) {
    if (event.persisted) {
        window.location.replace("${pageContext.request.contextPath}/thirdParty/sectionHead");
    }
});

function toggleRevoker() {
    var checkbox = document.getElementById("separateRevoker");
    var field = document.getElementById("revokeOperatorField");
    var select = document.getElementById("revokeOperatorEmpId");
    field.hidden = !checkbox.checked;
    select.required = checkbox.checked;
    if (!checkbox.checked) select.value = "";
}

function validateAssignments() {
    var grant = document.getElementById("grantOperatorEmpId").value;
    var reviewer = document.getElementById("revokeReviewerEmpId").value;
    var separate = document.getElementById("separateRevoker").checked;
    var revoke = separate ? document.getElementById("revokeOperatorEmpId").value : grant;
    if (reviewer === grant || reviewer === revoke) {
        window.alert("ผู้ตรวจทานต้องไม่ใช่ผู้ดำเนินการหรือผู้ยกเลิกสิทธิ์");
        return false;
    }
    return window.confirm("ยืนยันส่งความเห็นและการมอบหมายงานให้ IT Director หรือไม่?");
}

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
