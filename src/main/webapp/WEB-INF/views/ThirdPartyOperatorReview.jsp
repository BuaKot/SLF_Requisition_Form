<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat,com.slf.model.ThirdPartyAccessRequest,com.slf.model.ThirdPartyFormSubmission,com.slf.model.ThirdPartyRequest" %>
<%!
    private String h(Object input){if(input==null)return "";return String.valueOf(input).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");}
    private String display(Object input){return input==null||String.valueOf(input).trim().isEmpty()?"-":h(input);}
%>
<%
    ThirdPartyRequest thirdPartyRequest=(ThirdPartyRequest)request.getAttribute("thirdPartyRequest");
    ThirdPartyFormSubmission submission=(ThirdPartyFormSubmission)request.getAttribute("submission");
    String sectionHeadComment=(String)request.getAttribute("sectionHeadComment");
    String itDirectorComment=(String)request.getAttribute("itDirectorComment");
    String csrfToken=(String)request.getAttribute("csrfToken");
    String formError=(String)request.getAttribute("formError");
    String operationDetail=request.getParameter("operationDetail");
    SimpleDateFormat dateOnly=new SimpleDateFormat("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ดำเนินการคำขอ Third-party #<%= thirdPartyRequest.getRequestId() %></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="view-third-party-operator-review">
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
<div id="main"><%@ include file="/WEB-INF/jspf/topbar.jspf" %>
<main class="operator-review">
    <section class="third-party-page-head"><div>
        <p class="eyebrow">Third-party Workflow · ผู้ดำเนินการ</p>
        <h1>ดำเนินการคำขอ #<%= thirdPartyRequest.getRequestId() %></h1>
        <p>บันทึกรายละเอียดงานที่ดำเนินการเสร็จแล้วเพื่อส่งให้ผู้ขอภายนอกตรวจรับ</p>
    </div></section>
    <% if(formError!=null){ %><div class="form-alert"><%= h(formError) %></div><% } %>
    <section class="review-panel"><h2 class="form-section-title">ข้อมูลผู้ขอและรายละเอียดการใช้งาน</h2>
        <div class="review-grid">
            <div class="review-field"><div class="review-label">ชื่อ-สกุล</div><div class="review-value"><%= display(submission.getFullNameTh()) %></div></div>
            <div class="review-field"><div class="review-label">หน่วยงาน</div><div class="review-value"><%= display(submission.getOrganization()) %></div></div>
            <div class="review-field"><div class="review-label">Email</div><div class="review-value"><%= display(submission.getEmail()) %></div></div>
            <div class="review-field"><div class="review-label">เบอร์โทรศัพท์</div><div class="review-value"><%= display(submission.getPhone()) %></div></div>
            <div class="review-field full"><div class="review-label">เหตุผลและวัตถุประสงค์</div><div class="review-value"><%= display(submission.getReasonObjective()) %></div></div>
            <div class="review-field"><div class="review-label">วันที่เริ่มต้น</div><div class="review-value"><%= submission.getAccessStartDate()==null?"-":dateOnly.format(submission.getAccessStartDate()) %></div></div>
            <div class="review-field"><div class="review-label">วันที่สิ้นสุด</div><div class="review-value"><%= submission.getAccessEndDate()==null?"-":dateOnly.format(submission.getAccessEndDate()) %></div></div>
        </div>
    </section>
    <section class="review-panel"><h2 class="form-section-title">รายการผู้ขอรับสิทธิ์</h2>
        <% for(ThirdPartyAccessRequest item:submission.getAccessRequests()){ %>
        <article class="access-item"><div class="review-grid">
            <div class="review-field"><div class="review-label">ชื่อ-สกุล</div><div class="review-value"><%= display(item.getFullNameTh()) %></div></div>
            <div class="review-field"><div class="review-label">Username</div><div class="review-value"><%= display(item.getUsername()) %></div></div>
            <div class="review-field"><div class="review-label">ระบบงาน</div><div class="review-value"><%= display(item.getSystemName()) %></div></div>
            <div class="review-field"><div class="review-label">สิทธิ์การใช้งาน</div><div class="review-value"><%= display(item.getRequestedRole()) %></div></div>
        </div></article><% } %>
    </section>
    <section class="review-panel"><h2 class="form-section-title">ความเห็นประกอบการดำเนินงาน</h2>
        <div class="comment-grid">
            <div class="comment-card"><div class="review-label">ความเห็นหัวหน้าส่วน</div><div class="review-value"><%= display(sectionHeadComment) %></div></div>
            <div class="comment-card"><div class="review-label">ความเห็น IT Director</div><div class="review-value"><%= display(itDirectorComment) %></div></div>
        </div>
    </section>
    <section class="review-panel operation-box"><h2 class="form-section-title">รายละเอียดการดำเนินการ</h2>
        <form method="post" action="${pageContext.request.contextPath}/thirdParty/operator/review">
            <input type="hidden" name="csrfToken" value="<%= h(csrfToken) %>"><input type="hidden" name="requestId" value="<%= thirdPartyRequest.getRequestId() %>">
            <textarea name="operationDetail" maxlength="4000" required placeholder="ระบุรายละเอียดการดำเนินการให้สิทธิ์..."><%= h(operationDetail) %></textarea>
            <div class="submit-row"><button class="workflow-submit-button" type="submit" data-workflow-confirm data-confirm-title="ส่งผลตรวจรับและประเมินเสร็จสิ้น" data-confirm-message="รายละเอียดจะถูกบันทึกและส่งงานไปยังขั้นตอนถัดไป" data-confirm-label="ยืนยันส่งต่อ"><i class="fa-solid fa-paper-plane"></i> บันทึกและส่งตรวจรับ</button></div>
        </form>
    </section>
</main>
<%@ include file="/WEB-INF/jspf/footer.jspf" %></div>
<%@ include file="/WEB-INF/jspf/third-party-confirm-dialog.jspf" %>
<script>window.addEventListener("pageshow",function(e){if(e.persisted)window.location.replace("${pageContext.request.contextPath}/thirdParty/operator");});function toggleNav(){var s=document.getElementById("mySidebar"),m=document.getElementById("main"),o=s.style.width==="250px";s.style.width=o?"0":"250px";m.style.marginLeft=o?"0":"250px";m.style.width=o?"100%":"calc(100% - 250px)";}</script>
</body></html>
