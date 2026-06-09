<%@ include file="/WEB-INF/checkAuth.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    request.setAttribute("approvalTitle", "รายการรอดำเนินการ");
    request.setAttribute("approvalSubtitle", "ตรวจสอบรายละเอียดและดำเนินการรายการที่ได้รับมอบหมาย");
    request.setAttribute("approvalDetailPage", "/RequisitionDetail_Process.jsp");
%>
<jsp:include page="/WEB-INF/approvalList.jsp" />
