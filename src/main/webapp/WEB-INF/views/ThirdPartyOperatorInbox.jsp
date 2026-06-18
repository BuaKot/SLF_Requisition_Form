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
    SimpleDateFormat dateOnly=new SimpleDateFormat("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="th"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>งาน Third-party ที่ได้รับมอบหมาย</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css?v=20260618-2">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css"></head><body class="view-third-party-operator-inbox">
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
<a class="workflow-item <%= groupClasses[groupIndex] %>" href="${pageContext.request.contextPath}<%= routes[groupIndex] %><%= item.getRequestId() %>" aria-label="<%= actions[groupIndex] %> คำขอ #<%= item.getRequestId() %>"><div class="workflow-row"><span class="role-badge"><%= roles[groupIndex] %></span><h3>คำขอ #<%= item.getRequestId() %></h3><span><strong>ผู้ขอ:</strong> <%= h(item.getExternalContactName()) %></span><span><strong>หน่วยงาน:</strong> <%= h(item.getExternalCompanyName()) %></span><span><strong>โครงการ:</strong> <%= h(item.getTargetSystem()) %></span><span><strong>วันที่เริ่มต้น:</strong> <%= item.getAccessStartDate()==null?"-":dateOnly.format(item.getAccessStartDate()) %></span><span><strong>ถึงวันที่:</strong> <%= item.getAccessEndDate()==null?"-":dateOnly.format(item.getAccessEndDate()) %></span></div></a>
<% } %></div></section><% } %>
</main><%@ include file="/WEB-INF/jspf/footer.jspf" %></div>
<script>function toggleNav(){var s=document.getElementById("mySidebar"),m=document.getElementById("main"),o=s.style.width==="250px";s.style.width=o?"0":"250px";m.style.marginLeft=o?"0":"250px";m.style.width=o?"100%":"calc(100% - 250px)";}</script>
</body></html>
