<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat,java.util.Collections,java.util.List,com.slf.model.ThirdPartyRequest" %>
<%!
    private String h(Object input){if(input==null)return "";return String.valueOf(input).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");}
%>
<%
    List<ThirdPartyRequest> grantRequests=(List<ThirdPartyRequest>)request.getAttribute("grantOperatorRequests");
    List<ThirdPartyRequest> revokeRequests=(List<ThirdPartyRequest>)request.getAttribute("revokeOperatorRequests");
    List<ThirdPartyRequest> reviewerRequests=(List<ThirdPartyRequest>)request.getAttribute("revokeReviewerRequests");
    if(grantRequests==null)grantRequests=Collections.emptyList();
    if(revokeRequests==null)revokeRequests=Collections.emptyList();
    if(reviewerRequests==null)reviewerRequests=Collections.emptyList();
    SimpleDateFormat dateTime=new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="th"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>งาน Third-party ที่ได้รับมอบหมาย</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
<style>
.workflow-inbox{max-width:1180px;margin:0 auto;padding:28px 28px 48px}.workflow-section{margin-top:28px}.workflow-section h2{color:#003366;margin:0 0 12px}.workflow-list{display:grid;gap:14px}.workflow-item{display:grid;grid-template-columns:1fr auto;gap:20px;align-items:center;padding:20px;background:#fff;border:1px solid #d9e6f2;border-radius:10px;box-shadow:0 8px 22px rgba(0,51,102,.06)}.workflow-item h3{margin:0 0 8px;color:#003366}.workflow-meta{display:flex;flex-wrap:wrap;gap:8px 20px;color:#526b80}.workflow-empty{padding:24px;text-align:center;background:#fff;border:1px dashed #bfd0df;border-radius:10px;color:#526b80}.role-badge{display:inline-block;padding:4px 10px;border-radius:999px;background:#e7f1fb;color:#075985;font-size:13px;font-weight:800;margin-bottom:7px}@media(max-width:720px){.workflow-inbox{padding:20px 14px 36px}.workflow-item{grid-template-columns:1fr}}
</style></head><body>
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
<div id="main"><%@ include file="/WEB-INF/jspf/topbar.jspf" %>
<main class="workflow-inbox">
<section class="third-party-page-head"><div><p class="eyebrow">Third-party Workflow · Infrastructure</p><h1>งาน Third-party ที่ได้รับมอบหมาย</h1><p>เลือกดำเนินงานตามหน้าที่ที่ได้รับมอบหมายในแต่ละคำขอ</p></div></section>
<%
    List<ThirdPartyRequest>[] groups=new List[]{grantRequests,revokeRequests,reviewerRequests};
    String[] headings={"งานให้สิทธิ์","งานยกเลิกสิทธิ์","งานตรวจทานการยกเลิกสิทธิ์"};
    String[] roles={"ผู้ดำเนินการให้สิทธิ์","ผู้ยกเลิกสิทธิ์","ผู้ตรวจทาน"};
    String[] routes={"/thirdParty/operator/review?id=","/thirdParty/revoker/review?id=","/thirdParty/revokeReviewer/review?id="};
    String[] buttons={"ดำเนินการให้สิทธิ์","ดำเนินการยกเลิกสิทธิ์","ตรวจทาน"};
    for(int groupIndex=0;groupIndex<groups.length;groupIndex++){ List<ThirdPartyRequest> items=groups[groupIndex];
%>
<section class="workflow-section"><h2><%= headings[groupIndex] %> (<%= items.size() %>)</h2><div class="workflow-list">
<% if(items.isEmpty()){ %><div class="workflow-empty">ขณะนี้ไม่มี<%= headings[groupIndex] %>ที่รอดำเนินการ</div><% } %>
<% for(ThirdPartyRequest item:items){ %>
<article class="workflow-item"><div><span class="role-badge"><%= roles[groupIndex] %></span><h3>คำขอ #<%= item.getRequestId() %></h3>
<div class="workflow-meta"><span><strong>ผู้ขอ:</strong> <%= h(item.getExternalContactName()) %></span><span><strong>หน่วยงาน:</strong> <%= h(item.getExternalCompanyName()) %></span><span><strong>อัปเดต:</strong> <%= item.getUpdatedAt()==null?"-":dateTime.format(item.getUpdatedAt()) %></span></div></div>
<a class="btn btn-primary primary-action" href="${pageContext.request.contextPath}<%= routes[groupIndex] %><%= item.getRequestId() %>"><i class="fa-solid fa-arrow-right"></i> <%= buttons[groupIndex] %></a></article>
<% } %></div></section><% } %>
</main><%@ include file="/WEB-INF/jspf/footer.jspf" %></div>
<script>function toggleNav(){var s=document.getElementById("mySidebar"),m=document.getElementById("main"),o=s.style.width==="250px";s.style.width=o?"0":"250px";m.style.marginLeft=o?"0":"250px";m.style.width=o?"100%":"calc(100% - 250px)";}</script>
</body></html>
