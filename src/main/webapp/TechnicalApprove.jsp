<%@ include file="/WEB-INF/checkAuth.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    request.setAttribute("approvalTitle", "รายการรอตรวจสอบของหัวหน้าส่วน");
    request.setAttribute("approvalSubtitle", "ตรวจสอบรายละเอียด แสดงความคิดเห็น และดำเนินการรายการที่รับผิดชอบ");
    request.setAttribute("approvalDetailPage", "/RequisitionDetail_Comment.jsp");
%>
<jsp:include page="/WEB-INF/approvalList.jsp" />
