<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat,java.util.Collections,java.util.List,com.slf.model.ThirdPartyRequest" %>
<%!
private String h(Object input){if(input==null)return "";return String.valueOf(input).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");}
%>
<%
List<ThirdPartyRequest> reviewRequests=(List<ThirdPartyRequest>)request.getAttribute("reviewRequests");
List<ThirdPartyRequest> reportRequests=(List<ThirdPartyRequest>)request.getAttribute("reportRequests");
if(reviewRequests==null)reviewRequests=Collections.emptyList(); if(reportRequests==null)reportRequests=Collections.emptyList();
SimpleDateFormat dateOnly=new SimpleDateFormat("dd/MM/yyyy");
%>
<!DOCTYPE html><html lang="th"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>งาน Third-party ของหัวหน้าส่วน</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css?v=20260618-3"><link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css"></head><body class="view-third-party-section-head-inbox">
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %><div id="main"><%@ include file="/WEB-INF/jspf/topbar.jspf" %><main class="inbox">
<section class="third-party-page-head"><div><p class="eyebrow">Third-party Workflow · หัวหน้าส่วน</p><h1>งาน Third-party ของหัวหน้าส่วน</h1><p>พิจารณาคำขอ มอบหมายผู้รับผิดชอบ และเขียนรายงานสรุปก่อนส่งรับรอง</p></div></section>
<% List<ThirdPartyRequest>[] groups=new List[]{reviewRequests,reportRequests}; String[] titles={"คำขอรอพิจารณา","คำขอรอเขียนรายงานสรุป"}; String[] routes={"/thirdParty/sectionHead/review?id=","/thirdParty/sectionHead/report?id="}; for(int g=0;g<groups.length;g++){ %>
<section class="group"><h2><%= titles[g] %> (<%= groups[g].size() %>)</h2><div class="list"><% if(groups[g].isEmpty()){ %><div class="empty">ขณะนี้ไม่มี<%= titles[g] %></div><% } for(ThirdPartyRequest item:groups[g]){ %>
<a class="item" href="${pageContext.request.contextPath}<%= routes[g] %><%= item.getRequestId() %>" aria-label="เปิดคำขอ #<%= item.getRequestId() %>"><div class="inbox-row"><h3 class="request-number">คำขอ #<%= item.getRequestId() %></h3><div class="request-secondary-info"><span class="request-meta"><strong>ผู้ขอ:</strong><span class="request-value"><%= h(item.getExternalContactName()) %></span></span><span class="request-meta"><strong>หน่วยงาน:</strong><span class="request-value"><%= h(item.getExternalCompanyName()) %></span></span><span class="request-meta request-project"><strong>โครงการ:</strong><span class="request-value"><%= h(item.getTargetSystem()) %></span></span></div><span class="request-date" aria-label="วันที่: <%= item.getAccessStartDate()==null?"-":dateOnly.format(item.getAccessStartDate()) %> - <%= item.getAccessEndDate()==null?"-":dateOnly.format(item.getAccessEndDate()) %>"><span class="request-date-start"><strong>วันที่เริ่มต้น:</strong><span class="request-value"><%= item.getAccessStartDate()==null?"-":dateOnly.format(item.getAccessStartDate()) %></span></span><span class="request-date-separator" aria-hidden="true">-</span><span class="request-date-end"><strong>ถึงวันที่:</strong><span class="request-value"><%= item.getAccessEndDate()==null?"-":dateOnly.format(item.getAccessEndDate()) %></span></span></span></div></a>
<% } %></div></section><% } %>
</main><%@ include file="/WEB-INF/jspf/footer.jspf" %></div><script>function toggleNav(){var s=document.getElementById("mySidebar"),m=document.getElementById("main"),o=s.style.width==="250px";s.style.width=o?"0":"250px";m.style.marginLeft=o?"0":"250px";m.style.width=o?"100%":"calc(100% - 250px)";}</script></body></html>
