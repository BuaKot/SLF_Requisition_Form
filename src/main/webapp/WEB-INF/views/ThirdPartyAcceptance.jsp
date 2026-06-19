<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat,com.slf.model.ThirdPartyAccessRequest,com.slf.model.ThirdPartyFormSubmission" %>
<%!
    private String h(Object input){if(input==null)return "";return String.valueOf(input).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");}
    private String display(Object input){return input==null||String.valueOf(input).trim().isEmpty()?"-":h(input);}
%>
<%
    response.setHeader("Cache-Control","no-store, no-cache, must-revalidate, max-age=0");
    response.setHeader("Pragma","no-cache"); response.setDateHeader("Expires",0L);
    String invalidLinkMessage=(String)request.getAttribute("invalidLinkMessage");
    ThirdPartyFormSubmission submission=(ThirdPartyFormSubmission)request.getAttribute("submission");
    String token=(String)request.getAttribute("token");
    String operationDetail=(String)request.getAttribute("operationDetail");
    SimpleDateFormat dateOnly=new SimpleDateFormat("dd/MM/yyyy");
%>
<!DOCTYPE html><html lang="th"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>ตรวจรับและประเมินการดำเนินงาน</title><link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css"></head><body class="view-third-party-acceptance"><main class="accept-page">
<% if(invalidLinkMessage!=null){ %>
<section class="external-link-warning-banner">
    <i class="fa-solid fa-triangle-exclamation" aria-hidden="true"></i>
    <div>
        <h2>ลิงก์หรือแบบฟอร์มนี้หมดอายุแล้ว</h2>
        <p>กรุณาติดต่อผู้ดูแลเพื่อสร้างลิงก์ใหม่ หรือสอบถามสถานะคำขอจากผู้ประสานงานภายใน</p>
    </div>
</section>
<section class="panel"><h1>ไม่สามารถเปิดลิงก์ได้</h1><p><%= h(invalidLinkMessage) %></p></section><% } else { %>
<section class="accept-head"><h1>ตรวจรับและประเมินการดำเนินงาน</h1><p>โปรดตรวจสอบข้อมูลและผลการดำเนินงานก่อนส่งผลตรวจรับ</p></section>
<section class="panel"><h2>ข้อมูลที่ท่านเคยกรอก</h2><div class="grid">
<div class="field"><div class="label">ชื่อ-สกุล</div><div class="value"><%= display(submission.getFullNameTh()) %></div></div>
<div class="field"><div class="label">หน่วยงาน</div><div class="value"><%= display(submission.getOrganization()) %></div></div>
<div class="field full"><div class="label">มีความประสงค์จะขอใช้ระบบ</div><div class="value"><%= display(submission.getRequestedSystem()) %></div></div>
<div class="field full"><div class="label">เหตุผลและวัตถุประสงค์</div><div class="value"><%= display(submission.getReasonObjective()) %></div></div>
<div class="field"><div class="label">วันที่เริ่มต้น</div><div class="value"><%= submission.getAccessStartDate()==null?"-":dateOnly.format(submission.getAccessStartDate()) %></div></div>
<div class="field"><div class="label">วันที่สิ้นสุด</div><div class="value"><%= submission.getAccessEndDate()==null?"-":dateOnly.format(submission.getAccessEndDate()) %></div></div>
</div>
<% for(ThirdPartyAccessRequest item:submission.getAccessRequests()){ %><article class="access"><div class="grid">
<div class="field"><div class="label">ผู้ขอรับสิทธิ์</div><div class="value"><%= display(item.getFullNameTh()) %></div></div>
<div class="field"><div class="label">Username</div><div class="value"><%= display(item.getUsername()) %></div></div>
<div class="field"><div class="label">ระบบงาน</div><div class="value"><%= display(item.getSystemName()) %></div></div>
<div class="field"><div class="label">สิทธิ์การใช้งาน</div><div class="value"><%= display(item.getRequestedRole()) %></div></div>
</div></article><% } %></section>
<section class="panel"><h2>รายละเอียดการดำเนินงาน</h2><div class="value"><%= display(operationDetail) %></div></section>
<section class="panel"><h2>ผลตรวจรับและประเมิน</h2><form method="post" action="${pageContext.request.contextPath}/thirdparty/accept/submit">
<input type="hidden" name="token" value="<%= h(token) %>"><label class="label" for="satisfactionLevel">คะแนนความพึงพอใจ</label>
<select id="satisfactionLevel" name="satisfactionLevel" required><option value="">-- เลือกคะแนน --</option><option value="5">5 - พึงพอใจมากที่สุด</option><option value="4">4 - พึงพอใจมาก</option><option value="3">3 - พึงพอใจปานกลาง</option><option value="2">2 - พึงพอใจน้อย</option><option value="1">1 - พึงพอใจน้อยที่สุด</option></select>
<label class="label" for="comment" style="display:block;margin-top:16px">ความคิดเห็น</label><textarea id="comment" name="comment" maxlength="4000" required></textarea>
<div class="actions"><button class="btn btn-primary primary-action" type="submit" data-workflow-confirm data-confirm-title="ยืนยันส่งผลตรวจรับและประเมิน" data-confirm-message="โปรดตรวจสอบคะแนนและความคิดเห็นก่อนยืนยันส่งผลตรวจรับ" data-confirm-label="ยืนยันส่งผล">ส่งผลตรวจรับและประเมิน</button></div>
</form></section><% } %></main><%@ include file="/WEB-INF/jspf/third-party-confirm-dialog.jspf" %><script>window.addEventListener("pageshow",function(e){if(e.persisted)window.location.reload();});</script></body></html>
