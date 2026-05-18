<%@ page import="com.slf.dao.TechnicalApprovalDAO" %>
<%@ page isELIgnored="false" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    try {
        request.setAttribute("technicalForms", new TechnicalApprovalDAO().getAllForms());
    } catch (Exception e) {
        request.setAttribute("loadError", e.getMessage());
    }
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>รายการใบขอให้ดำเนินการ - Technical Approval</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Sarabun:wght@400;700&display=swap');

        * {
            box-sizing: border-box;
            font-family: 'Sarabun', sans-serif;
        }

        body {
            background-color: #ffffff;
            margin: 0;
        }

        .banner {
            background: #C3EAFF;
            padding: 25px 20px;
            text-align: center;
            color: #003366;
        }

        .banner h1 {
            font-size: 22px;
            margin: 5px 0;
        }

        .list-container {
            max-width: 1200px;
            margin: 20px auto;
            padding: 0 20px;
        }

        .back-btn {
            text-decoration: none;
            color: #3272BB;
            font-size: 15px;
            font-weight: bold;
            display: inline-block;
            margin-bottom: 15px;
        }

        .requisition-card {
            display: flex;
            align-items: center;
            background: white;
            border: 1px solid #ccc;
            border-radius: 12px;
            padding: 12px 20px;
            margin-bottom: 10px;
            gap: 20px;
            cursor: pointer;
            transition: 0.2s;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }

        .requisition-card:hover {
            border-color: #3272BB;
            transform: scale(1.005);
        }

        .card-id-box {
            border: 1px solid #333;
            border-radius: 8px;
            padding: 6px 12px;
            min-width: 180px;
            text-align: center;
            font-weight: bold;
            font-size: 17px;
        }

        .card-info {
            flex-grow: 1;
            min-width: 0;
        }

        .info-row {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            margin-bottom: 4px;
            font-size: 15px;
        }

        .info-item b,
        .detail-line b {
            color: #3272BB;
        }

        .detail-line {
            font-size: 15px;
            overflow-wrap: anywhere;
        }

        .status-section {
            display: flex;
            align-items: center;
            gap: 12px;
            min-width: 112px;
            justify-content: flex-end;
        }

        .status-icon {
            width: 72px;
            min-width: 72px;
            height: 58px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            font-size: 38px;
            line-height: 1;
            text-align: center;
        }

        .status-label {
            display: block;
            font-size: 11px;
            line-height: 1.1;
            margin-top: 3px;
            width: 72px;
            overflow-wrap: anywhere;
            text-align: center;
        }

        .status-complete {
            color: #28a745;
        }

        .status-pending {
            color: #ffc107;
        }

        .empty-message,
        .error-message {
            border: 1px solid #ccc;
            border-radius: 12px;
            padding: 18px;
            font-size: 15px;
            background: #fff;
        }

        .error-message {
            border-color: #ff304f;
            color: #b01828;
        }

        @media (max-width: 700px) {
            .requisition-card {
                align-items: flex-start;
                flex-direction: column;
            }

            .card-id-box {
                width: 100%;
            }

            .status-section {
                align-self: flex-end;
            }
        }
    </style>
</head>
<body>

<div class="sticky-bar">
    <a href="${pageContext.request.contextPath}/Admin.jsp" style="color:#333; text-decoration:none;">
        <i class="fa fa-arrow-left" style="font-size:24px;"></i>
    </a>
    <div class="contact-info" style="margin-left:auto; display:flex; align-items:center">
        <i class="fa fa-circle-user" style="font-size:1.4rem; color:#333;"></i>
        <p>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
    </div>
</div>

<div class="banner">
    <h1>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</h1>
    <h1>รายการใบขอให้ดำเนินการ (Technical Approval)</h1>
</div>

<div class="list-container">
    <a href="${pageContext.request.contextPath}/Admin.jsp" class="back-btn">
        <i class="fa fa-chevron-left"></i> กลับหน้าหลัก
    </a>

    <c:if test="${not empty loadError}">
        <div class="error-message">
            ไม่สามารถโหลดข้อมูลใบขอดำเนินการได้: <c:out value="${loadError}" />
        </div>
    </c:if>

    <c:if test="${empty loadError and empty technicalForms}">
        <div class="empty-message">ยังไม่มีข้อมูลใบขอดำเนินการ</div>
    </c:if>

    <c:forEach var="form" items="${technicalForms}">
        <div class="requisition-card" onclick="location.href='RequisitionDetail_Comment.jsp?formId=${form.formId}'">
            <div class="card-id-box">ใบขอให้ดำเนินการที่ <c:out value="${form.formId}" /></div>

            <div class="card-info">
                <div class="info-row">
                    <div class="info-item"><b>ชื่อ :</b> <c:out value="${form.requesterName}" /></div>
                    <div class="info-item"><b>ฝ่าย :</b> <c:out value="${form.departmentName}" /></div>
                    <div class="info-item"><b>ส่วน :</b> <c:out value="${form.sectionName}" /></div>
                    <div class="info-item"><b>Deadline :</b> <c:out value="${form.deadline}" /></div>
                </div>
                <div class="detail-line"><b>รายละเอียด :</b> <c:out value="${form.titleForm}" /></div>
            </div>

            <div class="status-section">
                <c:choose>
                    <c:when test="${form.technicalComplete}">
                        <div class="status-icon status-complete" title="${form.approvalStatus}">
                            <i class="fa-solid fa-circle-check"></i>
                            <span class="status-label"><c:out value="${form.approvalStatus}" /></span>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="status-icon status-pending" title="${form.approvalStatus}">
                            <i class="fa-solid fa-clock-rotate-left"></i>
                            <span class="status-label"><c:out value="${form.approvalStatus}" /></span>
                        </div>
                    </c:otherwise>
                </c:choose>
                <i class="fa-solid fa-chevron-right" style="color:#ddd"></i>
            </div>
        </div>
    </c:forEach>
</div>
</body>
</html>