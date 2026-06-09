<%@ include file="/WEB-INF/checkAuth.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    request.setAttribute("approvalTitle", "รายการรออนุมัติของผู้อำนวยการฝ่ายเทคโนโลยีสารสนเทศ");
    request.setAttribute("approvalSubtitle", "ตรวจสอบรายละเอียดและเลือกใบขอที่ต้องการอนุมัติ");
    request.setAttribute("approvalDetailPage", "/RequisitionDetail_ITDirector.jsp");
%>
<jsp:include page="/WEB-INF/approvalList.jsp" />
