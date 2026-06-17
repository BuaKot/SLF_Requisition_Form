<%@ include file="/WEB-INF/checkAuth.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    request.setAttribute("approvalTitle", "รายการรออนุมัติของผู้อำนวยการฝ่าย");
    request.setAttribute("approvalSubtitle", "ตรวจสอบรายละเอียดและเลือกใบขอที่ต้องการอนุมัติ");
    request.setAttribute("approvalDetailPage", "/RequisitionDetail.jsp");
    request.setAttribute("approvalHistoryBackPage", "/directorApprove");
%>
<jsp:include page="/WEB-INF/views/ApprovalList.jsp" />
