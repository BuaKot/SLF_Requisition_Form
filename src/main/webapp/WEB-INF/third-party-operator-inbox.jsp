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
.workflow-inbox{max-width:1180px;margin:0 auto;padding:28px 28px 48px}.workflow-section{margin-top:28px}.workflow-section h2{margin:0 0 12px}.workflow-section.grant h2{color:#075985}.workflow-section.revoke h2{color:#b42318}.workflow-section.reviewer h2{color:#6941c6}.workflow-list{display:grid;gap:14px}.workflow-item{display:block;padding:20px;border:2px solid;border-radius:12px;box-shadow:0 8px 22px rgba(0,51,102,.06);text-decoration:none;transition:transform .18s ease,box-shadow .18s ease,border-color .18s ease}.workflow-item:hover,.workflow-item:focus-visible{transform:translateY(-2px);box-shadow:0 12px 26px rgba(0,51,102,.14);outline:none}.workflow-item.grant{background:#f0f9ff;border-color:#7dd3fc}.workflow-item.grant:hover,.workflow-item.grant:focus-visible{border-color:#0284c7}.workflow-item.revoke{background:#fff4ed;border-color:#fda29b}.workflow-item.revoke:hover,.workflow-item.revoke:focus-visible{border-color:#d92d20}.workflow-item.reviewer{background:#f9f5ff;border-color:#d6bbfb}.workflow-item.reviewer:hover,.workflow-item.reviewer:focus-visible{border-color:#7f56d9}.workflow-item h3{margin:0 0 8px;color:#102a43}.workflow-meta{display:flex;flex-wrap:wrap;gap:8px 20px;color:#526b80}.workflow-empty{padding:24px;text-align:center;background:#fff;border:1px dashed #bfd0df;border-radius:10px;color:#526b80}.role-badge{display:inline-block;padding:4px 10px;border-radius:999px;font-size:13px;font-weight:800;margin-bottom:7px}.grant .role-badge{background:#e0f2fe;color:#075985}.revoke .role-badge{background:#fee4e2;color:#b42318}.reviewer .role-badge{background:#eee4ff;color:#6941c6}@media(max-width:720px){.workflow-inbox{padding:20px 14px 36px}}
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
    String[] groupClasses={"grant","revoke","reviewer"};
    String[] actions={"เปิดงานให้สิทธิ์","เปิดงานยกเลิกสิทธิ์","เปิดงานตรวจทาน"};
    for(int groupIndex=0;groupIndex<groups.length;groupIndex++){ List<ThirdPartyRequest> items=groups[groupIndex];
%>
<section class="workflow-section <%= groupClasses[groupIndex] %>"><h2><%= headings[groupIndex] %> (<%= items.size() %>)</h2><div class="workflow-list">
<% if(items.isEmpty()){ %><div class="workflow-empty">ขณะนี้ไม่มี<%= headings[groupIndex] %>ที่รอดำเนินการ</div><% } %>
<% for(ThirdPartyRequest item:items){ %>
<a class="workflow-item <%= groupClasses[groupIndex] %>" href="${pageContext.request.contextPath}<%= routes[groupIndex] %><%= item.getRequestId() %>" aria-label="<%= actions[groupIndex] %> คำขอ #<%= item.getRequestId() %>"><span class="role-badge"><%= roles[groupIndex] %></span><h3>คำขอ #<%= item.getRequestId() %></h3>
<div class="workflow-meta"><span><strong>ผู้ขอ:</strong> <%= h(item.getExternalContactName()) %></span><span><strong>หน่วยงาน:</strong> <%= h(item.getExternalCompanyName()) %></span><span><strong>อัปเดต:</strong> <%= item.getUpdatedAt()==null?"-":dateTime.format(item.getUpdatedAt()) %></span></div></a>
<% } %></div></section><% } %>
</main><%@ include file="/WEB-INF/jspf/footer.jspf" %></div>
<script>function toggleNav(){var s=document.getElementById("mySidebar"),m=document.getElementById("main"),o=s.style.width==="250px";s.style.width=o?"0":"250px";m.style.marginLeft=o?"0":"250px";m.style.width=o?"100%":"calc(100% - 250px)";}</script>
</body></html>
