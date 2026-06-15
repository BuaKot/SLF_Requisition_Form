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
<style>
body{margin:0;background:var(--slf-color-bg);font-family:var(--slf-font-family);color:var(--slf-color-text)}.accept-page{max-width:1000px;margin:0 auto;padding:28px 18px 48px}.accept-head,.panel{background:var(--slf-color-surface);border:1px solid var(--slf-color-border);border-radius:var(--slf-radius-md);padding:22px;margin-bottom:18px;box-shadow:var(--slf-shadow-md)}
.accept-head{background:var(--slf-color-primary);color:#fff}.accept-head h1{margin:0 0 8px}.grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:15px 20px}.field{border-bottom:1px solid var(--slf-color-border);padding-bottom:10px}.full{grid-column:1/-1}.label{color:var(--slf-color-text-muted);font-size:13px;font-weight:bold;margin-bottom:5px}.value{line-height:1.55;white-space:pre-wrap;overflow-wrap:anywhere}.access{border:1px solid var(--slf-color-border);border-radius:var(--slf-radius-sm);padding:14px;margin-top:12px;background:var(--slf-color-surface-muted)}textarea,select{width:100%;box-sizing:border-box;border:1px solid var(--slf-color-border-strong);border-radius:var(--slf-radius-sm);padding:11px;font:inherit;background:var(--slf-color-surface);color:var(--slf-color-text)}textarea:focus,select:focus{outline:none;border-color:var(--slf-color-accent);box-shadow:var(--slf-focus-ring)}textarea{min-height:130px;resize:vertical}.actions{text-align:right;margin-top:18px}@media(max-width:700px){.grid{grid-template-columns:1fr}.full{grid-column:auto}}
</style></head><body><main class="accept-page">
<% if(invalidLinkMessage!=null){ %><section class="panel"><h1>ไม่สามารถเปิดลิงก์ได้</h1><p><%= h(invalidLinkMessage) %></p></section><% } else { %>
<section class="accept-head"><h1>ตรวจรับและประเมินการดำเนินงาน</h1><p>โปรดตรวจสอบข้อมูลและผลการดำเนินงานก่อนส่งผลตรวจรับ</p></section>
<section class="panel"><h2>ข้อมูลที่ท่านเคยกรอก</h2><div class="grid">
<div class="field"><div class="label">ชื่อ-สกุล</div><div class="value"><%= display(submission.getFullNameTh()) %></div></div>
<div class="field"><div class="label">หน่วยงาน</div><div class="value"><%= display(submission.getOrganization()) %></div></div>
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
<div class="actions"><button class="btn btn-primary primary-action" type="submit" onclick="return confirm('ยืนยันส่งผลตรวจรับและประเมินหรือไม่?')">ส่งผลตรวจรับและประเมิน</button></div>
</form></section><% } %></main><script>window.addEventListener("pageshow",function(e){if(e.persisted)window.location.reload();});</script></body></html>
