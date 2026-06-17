<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat,java.util.Collections,java.util.List,com.slf.model.ThirdPartyRequest" %>
<%!
private String h(Object input){if(input==null)return "";return String.valueOf(input).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");}
%>
<%
List<ThirdPartyRequest> approvalRequests=(List<ThirdPartyRequest>)request.getAttribute("approvalRequests");
List<ThirdPartyRequest> certificationRequests=(List<ThirdPartyRequest>)request.getAttribute("certificationRequests");
if(approvalRequests==null)approvalRequests=Collections.emptyList(); if(certificationRequests==null)certificationRequests=Collections.emptyList();
SimpleDateFormat dateTime=new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html><html lang="th"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>งาน Third-party ของ IT Director</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css"><link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css"></head><body class="view-third-party-it-director-inbox">
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %><div id="main"><%@ include file="/WEB-INF/jspf/topbar.jspf" %><main class="inbox">
<section class="third-party-page-head"><div><p class="eyebrow">Third-party Workflow · IT Director</p><h1>งาน Third-party ของ IT Director</h1><p>พิจารณาอนุมัติคำขอและเซ็นรับรองแบบฟอร์มที่ดำเนินการครบถ้วน</p></div></section>
<% List<ThirdPartyRequest>[] groups=new List[]{approvalRequests,certificationRequests}; String[] titles={"คำขอรอพิจารณาอนุมัติ","คำขอรอเซ็นรับรอง"}; String[] routes={"/thirdParty/itDirector/review?id=","/thirdParty/itDirector/certify?id="}; for(int g=0;g<groups.length;g++){ %>
<section class="group"><h2><%= titles[g] %> (<%= groups[g].size() %>)</h2><div class="list"><% if(groups[g].isEmpty()){ %><div class="empty">ขณะนี้ไม่มี<%= titles[g] %></div><% } for(ThirdPartyRequest item:groups[g]){ %>
<a class="item" href="${pageContext.request.contextPath}<%= routes[g] %><%= item.getRequestId() %>" aria-label="เปิดคำขอ #<%= item.getRequestId() %>"><h3>คำขอ #<%= item.getRequestId() %></h3><div class="meta"><span><strong>ผู้ขอ:</strong> <%= h(item.getExternalContactName()) %></span><span><strong>หน่วยงาน:</strong> <%= h(item.getExternalCompanyName()) %></span><span><strong>อัปเดต:</strong> <%= item.getUpdatedAt()==null?"-":dateTime.format(item.getUpdatedAt()) %></span></div></a>
<% } %></div></section><% } %>
</main><%@ include file="/WEB-INF/jspf/footer.jspf" %></div><script>function toggleNav(){var s=document.getElementById("mySidebar"),m=document.getElementById("main"),o=s.style.width==="250px";s.style.width=o?"0":"250px";m.style.marginLeft=o?"0":"250px";m.style.width=o?"100%":"calc(100% - 250px)";}</script></body></html>
