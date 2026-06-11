<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page import="com.slf.model.ThirdPartyAccessRequest" %>
<%@ page import="com.slf.model.ThirdPartyFormSubmission" %>
<%@ page import="com.slf.model.ThirdPartyRequest" %>
<%@ page import="com.slf.model.ThirdPartyWorkflowAssignment" %>
<%!
    private String h(Object input) {
        if (input == null) return "";
        return String.valueOf(input).replace("&", "&amp;").replace("<", "&lt;")
            .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
    private String display(Object input) {
        return input == null || String.valueOf(input).trim().isEmpty() ? "-" : h(input);
    }
    private String assignmentLabel(String role) {
        if ("GRANT_OPERATOR".equals(role)) return "ผู้ดำเนินการให้สิทธิ์";
        if ("REVOKE_OPERATOR".equals(role)) return "ผู้ยกเลิกสิทธิ์";
        if ("REVOKE_REVIEWER".equals(role)) return "ผู้ตรวจทานการยกเลิกสิทธิ์";
        return role;
    }
%>
<%
    ThirdPartyRequest thirdPartyRequest = (ThirdPartyRequest) request.getAttribute("thirdPartyRequest");
    ThirdPartyFormSubmission submission = (ThirdPartyFormSubmission) request.getAttribute("submission");
    List<ThirdPartyWorkflowAssignment> assignments =
        (List<ThirdPartyWorkflowAssignment>) request.getAttribute("assignments");
    if (assignments == null) assignments = Collections.emptyList();
    String sectionHeadComment = (String) request.getAttribute("sectionHeadComment");
    String csrfToken = (String) request.getAttribute("csrfToken");
    String formError = (String) request.getAttribute("formError");
    String comment = request.getParameter("comment");
    SimpleDateFormat dateOnly = new SimpleDateFormat("dd/MM/yyyy");
    SimpleDateFormat dateTime = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IT Director พิจารณาคำขอ Third-party #<%= thirdPartyRequest.getRequestId() %></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        .director-review { max-width: 1180px; margin: 0 auto; padding: 28px 28px 48px; }
        .review-panel { background:#fff; border:1px solid #d9e6f2; border-radius:10px; padding:22px; margin-bottom:18px; box-shadow:0 8px 22px rgba(0,51,102,.06); }
        .review-grid { display:grid; grid-template-columns:repeat(2,minmax(0,1fr)); gap:15px 20px; }
        .review-field { border-bottom:1px solid #e5eef6; padding-bottom:10px; }
        .review-field.full { grid-column:1/-1; }
        .review-label { color:#64748b; font-size:13px; font-weight:800; margin-bottom:5px; }
        .review-value { color:#102a43; line-height:1.55; white-space:pre-wrap; overflow-wrap:anywhere; }
        .access-item, .assignment-item { border:1px solid #d9e6f2; border-radius:8px; padding:16px; margin-top:14px; }
        .assignment-list { display:grid; grid-template-columns:repeat(3,minmax(0,1fr)); gap:14px; }
        .decision-box textarea { width:100%; min-height:130px; border:1px solid #bfd0df; border-radius:7px; padding:12px; font:inherit; resize:vertical; }
        .decision-actions { display:flex; justify-content:flex-end; gap:12px; margin-top:18px; }
        .btn-reject { background:#b42318; color:#fff; }
        @media(max-width:800px){.director-review{padding:18px 14px 36px}.review-grid,.assignment-list{grid-template-columns:1fr}.review-field.full{grid-column:auto}.decision-actions{flex-direction:column-reverse}.decision-actions button{width:100%}}
    </style>
</head>
<body>
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
<div id="main">
    <%@ include file="/WEB-INF/jspf/topbar.jspf" %>
    <main class="director-review">
        <section class="third-party-page-head">
            <div>
                <p class="eyebrow">Third-party Workflow · IT Director</p>
                <h1>พิจารณาคำขอ #<%= thirdPartyRequest.getRequestId() %></h1>
                <p>ตรวจสอบรายละเอียดและเลือกอนุมัติหรือไม่อนุมัติคำขอ</p>
            </div>
        </section>
        <% if (formError != null) { %><div class="form-alert"><%= h(formError) %></div><% } %>

        <section class="review-panel">
            <h2 class="form-section-title">ข้อมูลผู้ขอภายนอก</h2>
            <div class="review-grid">
                <div class="review-field"><div class="review-label">เลขที่รับเอกสาร</div><div class="review-value"><%= display(submission.getDocumentReceiveNo()) %></div></div>
                <div class="review-field"><div class="review-label">วันที่ส่งฟอร์ม</div><div class="review-value"><%= submission.getCreatedAt()==null?"-":dateTime.format(submission.getCreatedAt()) %></div></div>
                <div class="review-field"><div class="review-label">ชื่อ-สกุล ภาษาไทย</div><div class="review-value"><%= display(submission.getFullNameTh()) %></div></div>
                <div class="review-field"><div class="review-label">ชื่อ-สกุล ภาษาอังกฤษ</div><div class="review-value"><%= display(submission.getFullNameEn()) %></div></div>
                <div class="review-field"><div class="review-label">หน่วยงาน</div><div class="review-value"><%= display(submission.getOrganization()) %></div></div>
                <div class="review-field"><div class="review-label">เบอร์โทรศัพท์</div><div class="review-value"><%= display(submission.getPhone()) %></div></div>
                <div class="review-field full"><div class="review-label">Email</div><div class="review-value"><%= display(submission.getEmail()) %></div></div>
                <div class="review-field full"><div class="review-label">เหตุผลและวัตถุประสงค์</div><div class="review-value"><%= display(submission.getReasonObjective()) %></div></div>
                <div class="review-field full"><div class="review-label">โครงการ</div><div class="review-value"><%= display(submission.getProjectName()) %></div></div>
                <div class="review-field"><div class="review-label">วันที่เริ่มต้น</div><div class="review-value"><%= submission.getAccessStartDate()==null?"-":dateOnly.format(submission.getAccessStartDate()) %></div></div>
                <div class="review-field"><div class="review-label">วันที่สิ้นสุด</div><div class="review-value"><%= submission.getAccessEndDate()==null?"-":dateOnly.format(submission.getAccessEndDate()) %></div></div>
            </div>
        </section>

        <section class="review-panel">
            <h2 class="form-section-title">รายการผู้ขอรับสิทธิ์</h2>
            <% for (ThirdPartyAccessRequest item : submission.getAccessRequests()) { %>
                <article class="access-item">
                    <div class="review-grid">
                        <div class="review-field"><div class="review-label">ชื่อ-สกุล</div><div class="review-value"><%= display(item.getFullNameTh()) %></div></div>
                        <div class="review-field"><div class="review-label">ระบบงาน</div><div class="review-value"><%= display(item.getSystemName()) %></div></div>
                        <div class="review-field"><div class="review-label">Username</div><div class="review-value"><%= display(item.getUsername()) %></div></div>
                        <div class="review-field"><div class="review-label">หน่วยงาน</div><div class="review-value"><%= display(item.getDepartmentName()) %></div></div>
                        <div class="review-field full"><div class="review-label">สิทธิ์การใช้งาน</div><div class="review-value"><%= display(item.getRequestedRole()) %></div></div>
                    </div>
                </article>
            <% } %>
        </section>

        <section class="review-panel">
            <h2 class="form-section-title">ความเห็นและการมอบหมายจากหัวหน้าส่วน</h2>
            <div class="review-field full"><div class="review-label">ความเห็นหัวหน้าส่วน</div><div class="review-value"><%= display(sectionHeadComment) %></div></div>
            <div class="assignment-list">
                <% for (ThirdPartyWorkflowAssignment assignment : assignments) { %>
                    <article class="assignment-item">
                        <div class="review-label"><%= h(assignmentLabel(assignment.getAssignmentRole())) %></div>
                        <div class="review-value"><strong><%= display(assignment.getAssignedEmpName()) %></strong> (#<%= assignment.getAssignedEmpId() %>)</div>
                    </article>
                <% } %>
            </div>
        </section>

        <section class="review-panel decision-box">
            <h2 class="form-section-title">ความเห็น IT Director</h2>
            <form method="post" action="${pageContext.request.contextPath}/thirdParty/itDirector/review">
                <input type="hidden" name="csrfToken" value="<%= h(csrfToken) %>">
                <input type="hidden" name="requestId" value="<%= thirdPartyRequest.getRequestId() %>">
                <textarea name="comment" maxlength="4000" required placeholder="กรอกความเห็นประกอบการพิจารณา..."><%= h(comment) %></textarea>
                <div class="decision-actions">
                    <button class="btn btn-reject" type="submit" name="decision" value="reject" onclick="return confirm('ยืนยันไม่อนุมัติคำขอนี้หรือไม่?')">ไม่อนุมัติ</button>
                    <button class="btn btn-primary primary-action" type="submit" name="decision" value="approve" onclick="return confirm('ยืนยันอนุมัติคำขอนี้หรือไม่?')">อนุมัติ</button>
                </div>
            </form>
        </section>
    </main>
    <%@ include file="/WEB-INF/jspf/footer.jspf" %>
</div>
<script>
window.addEventListener("pageshow",function(e){if(e.persisted)window.location.replace("${pageContext.request.contextPath}/thirdParty/itDirector");});
function toggleNav(){var s=document.getElementById("mySidebar"),m=document.getElementById("main"),o=s.style.width==="250px";s.style.width=o?"0":"250px";m.style.marginLeft=o?"0":"250px";m.style.width=o?"100%":"calc(100% - 250px)";}
</script>
</body>
</html>
