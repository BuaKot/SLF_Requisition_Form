<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat,java.sql.Timestamp,java.util.Collections,java.util.List" %>
<%@ page import="com.slf.model.ThirdPartyAccessRequest" %>
<%@ page import="com.slf.model.ThirdPartyFormSubmission" %>
<%@ page import="com.slf.model.ThirdPartyRequest" %>
<%@ page import="com.slf.model.ThirdPartyWorkflowActionEntry" %>
<%!
    private String h(Object input) {
        if (input == null) return "";
        return String.valueOf(input)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }

    private String display(Object input) {
        return input == null || String.valueOf(input).trim().isEmpty() ? "-" : h(input);
    }

    private String formatDate(java.util.Date value, SimpleDateFormat formatter) {
        return value == null ? "-" : formatter.format(value);
    }

    private String actorName(ThirdPartyWorkflowActionEntry action) {
        if (action == null) return "-";
        if (action.getActorEmpName() != null && !action.getActorEmpName().trim().isEmpty()) {
            return action.getActorEmpName();
        }
        if ("SYSTEM".equals(action.getActorType())) return "ระบบ";
        if ("EXTERNAL".equals(action.getActorType())) return "ผู้ขอใช้บริการ";
        return action.getActorEmpId() == null ? "-" : "Employee #" + action.getActorEmpId();
    }

    private String workflowStepLabel(String actionType) {
        if ("EXTERNAL_SUBMITTED".equals(actionType)) return "ส่งแบบฟอร์ม";
        if ("SECTION_HEAD_SUBMITTED".equals(actionType)) return "หัวหน้ากลุ่มงานพิจารณา";
        if ("IT_DIRECTOR_APPROVED".equals(actionType)) return "ผอ.IT อนุมัติ";
        if ("IT_DIRECTOR_REJECTED".equals(actionType)) return "ผอ.IT ไม่อนุมัติ";
        if ("OPERATOR_COMPLETED".equals(actionType)) return "ผู้ดำเนินการบันทึกงาน";
        if ("EXTERNAL_ACCEPTED".equals(actionType)) return "ผู้ขอภายนอกตรวจรับ";
        if ("EXTERNAL_REJECTED".equals(actionType)) return "ผู้ขอภายนอกไม่ตรวจรับ";
        if ("EXTERNAL_ACCEPTANCE_EXPIRED".equals(actionType)) return "ลิงก์ตรวจรับหมดอายุ";
        if ("REVOKER_COMPLETED".equals(actionType)) return "ผู้ยกเลิกสิทธิ์ดำเนินการ";
        if ("REVOKE_REVIEWER_APPROVED".equals(actionType)) return "ผู้ตรวจทานอนุมัติ";
        if ("REVOKE_REVIEWER_REJECTED".equals(actionType)) return "ผู้ตรวจทานไม่อนุมัติ";
        if ("SECTION_HEAD_REPORTED".equals(actionType)) return "หัวหน้ากลุ่มงานสรุปรายงาน";
        if ("FINAL_CERTIFIED".equals(actionType)) return "IT Director รับรอง";
        return actionType == null ? "-" : actionType;
    }

    private ThirdPartyWorkflowActionEntry findAction(List<ThirdPartyWorkflowActionEntry> actions, String... actionTypes) {
        if (actions == null || actionTypes == null) return null;
        for (String actionType : actionTypes) {
            for (ThirdPartyWorkflowActionEntry action : actions) {
                if (action != null && actionType.equals(action.getActionType())) {
                    return action;
                }
            }
        }
        return null;
    }

    private String actionComment(ThirdPartyWorkflowActionEntry action) {
        if (action == null || action.getCommentText() == null || action.getCommentText().trim().isEmpty()) {
            return "";
        }
        return h(action.getCommentText());
    }

    private String actionDate(ThirdPartyWorkflowActionEntry action, SimpleDateFormat formatter) {
        if (action == null || action.getActedAt() == null) return "............/............/............";
        return formatter.format(action.getActedAt());
    }

    private String statusText(String status) {
        if ("COMPLETED".equals(status)) return "เสร็จสิ้น";
        if ("REJECTED".equals(status)) return "ไม่อนุมัติ";
        if ("PENDING_FINAL_CERTIFICATION".equals(status)) return "รอ IT Director รับรอง";
        if ("PENDING_SECTION_HEAD_REPORT".equals(status)) return "รอหัวหน้ากลุ่มงานสรุปรายงาน";
        if ("PENDING_REVOKE_REVIEWER".equals(status)) return "รอผู้ตรวจทาน";
        if ("PENDING_REVOKER".equals(status)) return "รอผู้ยกเลิกสิทธิ์";
        if ("PENDING_EXTERNAL_ACCEPTANCE".equals(status)) return "รอผู้ขอภายนอกตรวจรับ";
        if ("PENDING_OPERATOR".equals(status)) return "รอผู้ดำเนินการ";
        if ("PENDING_IT_DIRECTOR".equals(status)) return "รอ IT Director อนุมัติ";
        if ("PENDING_SECTION_HEAD".equals(status)) return "รอหัวหน้ากลุ่มงานพิจารณา";
        return status == null ? "-" : status;
    }
%>
<%
    ThirdPartyFormSubmission submission = (ThirdPartyFormSubmission) request.getAttribute("submission");
    ThirdPartyRequest thirdPartyRequest = (ThirdPartyRequest) request.getAttribute("thirdPartyRequest");
    List<ThirdPartyWorkflowActionEntry> approvalHistory =
        (List<ThirdPartyWorkflowActionEntry>) request.getAttribute("approvalHistory");
    if (approvalHistory == null) approvalHistory = Collections.emptyList();
    Integer acceptanceScore = (Integer) request.getAttribute("acceptanceScore");
    if (submission == null || thirdPartyRequest == null) {
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
        return;
    }
    SimpleDateFormat dateOnly = new SimpleDateFormat("dd/MM/yyyy");
    SimpleDateFormat dateTime = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <title>Third-party Registration Form #<%= submission.getSubmissionId() %></title>
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/images/cropped-logo-192x192.png">
    <style>
        @font-face {
            font-family: 'Anuphan';
            src: url('${pageContext.request.contextPath}/css/fonts/Anuphan-VariableFont_wght.ttf') format('truetype');
            font-weight: 100 700;
            font-display: swap;
        }

        @page {
            size: A4;
            margin: 10mm 12mm 10mm 12mm;
        }

        * {
            box-sizing: border-box;
        }

        body {
            font-family: 'Anuphan', Arial, sans-serif;
            margin: 0;
            padding: 0;
            font-size: 9.5pt;
            line-height: 1.4;
            color: #000;
            background: #fff;
            -webkit-print-color-adjust: exact;
            print-color-adjust: exact;
        }

        .btn-print {
            position: fixed;
            top: 15px;
            right: 15px;
            z-index: 999;
            border: 0;
            border-radius: 4px;
            background: #003366;
            color: #fff;
            padding: 8px 16px;
            font: inherit;
            font-size: 13px;
            cursor: pointer;
        }

        .meta-top-right {
            text-align: right;
            font-size: 9.5pt;
            margin-bottom: 4px;
            color: #222;
        }

        .meta-top-right span {
            margin-left: 15px;
            font-weight: 700;
        }

        .head-table {
            width: 100%;
            table-layout: fixed;
            border-collapse: collapse;
            margin-bottom: 12px;
        }

        .head-table td {
            border: 1px solid #000;
            padding: 6px 8px;
            vertical-align: middle;
        }

        .logo-cell {
            width: 18%;
            text-align: center;
        }

        .logo-cell img {
            max-height: 45px;
            max-width: 110px;
            object-fit: contain;
        }

        .title-cell {
            width: 57%;
            text-align: center;
        }

        .meta-cell {
            width: 25%;
            font-size: 9.5pt;
        }

        .doc-title {
            display: block;
            margin-bottom: 2px;
            font-size: 12pt;
            font-weight: 800;
        }

        .doc-subtitle {
            display: block;
            font-size: 9.5pt;
            font-weight: 700;
        }

        .section-title {
            margin: 12px 0 6px;
            padding-bottom: 2px;
            border-bottom: 1.5px solid #000;
            font-size: 9.5pt;
            font-weight: 800;
        }

        .info-grid-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 4px;
        }

        .info-grid-table td {
            padding: 4px 2px;
            vertical-align: baseline;
        }

        .info-label {
            font-weight: 700;
            white-space: nowrap;
        }

        .info-value {
            border-bottom: 1px dotted #444;
            padding-left: 4px;
        }

        .form-subject {
            margin: 10px 0;
            padding: 6px 10px;
            border-left: 3px solid #000;
            background: #f5f5f5;
            font-size: 11pt;
            font-weight: 800;
        }

        .request-card,
        .data-table,
        .approval-matrix {
            width: 100%;
            border-collapse: collapse;
        }

        .request-card {
            margin-top: 8px;
            border: 1px solid #000;
        }

        .request-card th,
        .data-table th {
            border-bottom: 1px solid #000;
            background: #f5f5f5;
            padding: 6px 10px;
            text-align: left;
            font-size: 9pt;
            font-weight: 800;
        }

        .request-card td {
            padding: 8px 10px;
            font-size: 9pt;
        }

        .request-field {
            margin-bottom: 6px;
        }

        .request-field:last-child {
            margin-bottom: 0;
        }

        .data-table th,
        .data-table td,
        .approval-matrix td {
            border: 1px solid #000;
            padding: 5px 7px;
            vertical-align: top;
            font-size: 9pt;
        }

        .approval-matrix {
            margin-top: 10px;
        }

        .approval-matrix td {
            width: 50%;
            min-height: 86px;
        }

        .workflow-form {
            width: 100%;
            border-collapse: collapse;
            margin-top: 8px;
            page-break-inside: avoid;
        }

        .workflow-form th {
            border: 1px solid #000;
            background: #d9d9d9;
            padding: 3px 6px;
            text-align: left;
            font-size: 9pt;
            font-weight: 800;
        }

        .workflow-form td {
            border: 1px solid #000;
            width: 50%;
            min-height: 110px;
            padding: 6px 8px;
            vertical-align: top;
            font-size: 8.8pt;
        }

        .workflow-line {
            min-height: 18px;
            margin: 3px 0;
            border-bottom: 1px dotted #555;
        }

        .workflow-checks {
            display: flex;
            justify-content: center;
            gap: 28px;
            margin: 12px 0;
            font-weight: 700;
        }

        .workflow-sign {
            margin-top: 12px;
            text-align: center;
        }

        .workflow-date {
            margin-top: 5px;
            text-align: center;
        }

        .workflow-rev {
            margin: 8px 0 0 38px;
            font-size: 8pt;
            font-weight: 700;
        }

        .signature-area {
            margin-top: 8px;
            text-align: center;
        }

        .signature-line {
            display: inline-block;
            width: 160px;
            margin-top: 14px;
            border-bottom: 1px dotted #000;
        }

        .status-badge {
            display: inline-block;
            border: 1px solid #000;
            padding: 1px 5px;
            background: #fff;
            font-weight: 800;
        }

        .small {
            color: #333;
            font-size: 8.5pt;
        }

        @media print {
            .btn-print {
                display: none;
            }
        }
    </style>
</head>
<body>

<button class="btn-print" onclick="window.print()">พิมพ์เอกสาร / Print</button>

<div class="meta-top-right">
    <span>แบบฟอร์มลงทะเบียนผู้ใช้ระบบงานสารสนเทศ / Third-party Registration Form</span>
    <span>SLF-TP-001</span>
</div>

<table class="head-table">
    <tr>
        <td class="logo-cell">
            <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo">
        </td>
        <td class="title-cell">
            <span class="doc-title">ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</span>
            <span class="doc-subtitle">แบบฟอร์มการขอลงทะเบียนผู้ใช้ระบบงานสารสนเทศ สำหรับผู้ให้บริการภายนอก</span>
        </td>
        <td class="meta-cell">
            <div><strong>เลขที่คำขอ:</strong> #<%= thirdPartyRequest.getRequestId() %></div>
            <div><strong>เลขที่เอกสาร:</strong> #<%= submission.getSubmissionId() %></div>
        </td>
    </tr>
</table>

<div class="section-title">1. ข้อมูลผู้ยื่นคำขอ / Requestor Information</div>
<table class="info-grid-table">
    <tr>
        <td class="info-label" style="width: 14%;">ผู้ขอใช้บริการ:</td>
        <td class="info-value" style="width: 36%;"><%= display(submission.getFullNameTh()) %></td>
        <td class="info-label" style="width: 12%; text-align: right;">หน่วยงาน:</td>
        <td class="info-value" style="width: 38%;"><%= display(submission.getOrganization()) %></td>
    </tr>
    <tr>
        <td class="info-label">Email:</td>
        <td class="info-value"><%= display(submission.getEmail()) %></td>
        <td class="info-label" style="text-align: right;">โทรศัพท์:</td>
        <td class="info-value"><%= display(submission.getPhone()) %></td>
    </tr>
    <tr>
        <td class="info-label">วันที่กรอก:</td>
        <td class="info-value"><%= formatDate(submission.getFilledDate(), dateOnly) %></td>
        <td class="info-label" style="text-align: right;">สถานะ:</td>
        <td class="info-value"><span class="status-badge"><%= h(statusText(thirdPartyRequest.getStatus())) %></span></td>
    </tr>
    <tr>
        <td class="info-label">ช่วงเวลาใช้งาน:</td>
        <td class="info-value" colspan="3">
            <%= formatDate(submission.getAccessStartDate(), dateOnly) %> - <%= formatDate(submission.getAccessEndDate(), dateOnly) %>
        </td>
    </tr>
</table>

<div class="form-subject">
    <strong>ระบบงานที่ต้องการใช้งาน:</strong> <%= display(submission.getProjectName()) %><br>
    <strong>วัตถุประสงค์:</strong> <%= display(submission.getReasonObjective()) %>
</div>

<div class="section-title">2. รายละเอียดผู้ขอใช้งาน / Access Users</div>
<% if (submission.getAccessRequests().isEmpty()) { %>
    <table class="request-card"><tr><td>-</td></tr></table>
<% } else { %>
    <% for (ThirdPartyAccessRequest item : submission.getAccessRequests()) { %>
        <table class="request-card">
            <tr>
                <th>ผู้ขอใช้งานลำดับที่ <%= item.getDisplayOrder() %>: <%= display(item.getFullNameTh()) %></th>
            </tr>
            <tr>
                <td>
                    <div class="request-field"><strong>ชื่อผู้ใช้:</strong> <%= display(item.getUsername()) %></div>
                    <div class="request-field"><strong>ชื่อ-สกุล (EN):</strong> <%= display(item.getFullNameEn()) %></div>
                    <div class="request-field"><strong>ตำแหน่ง:</strong> <%= display(item.getPositionName()) %></div>
                    <div class="request-field"><strong>ฝ่าย/กลุ่มงาน:</strong> <%= display(item.getDepartmentName()) %></div>
                    <div class="request-field"><strong>Email:</strong> <%= display(item.getEmail()) %></div>
                    <div class="request-field"><strong>ระบบงาน / Role:</strong> <%= display(item.getSystemName()) %> / <%= display(item.getRequestedRole()) %></div>
                </td>
            </tr>
        </table>
    <% } %>
<% } %>

<%
    ThirdPartyWorkflowActionEntry sectionHeadAction = findAction(approvalHistory, "SECTION_HEAD_SUBMITTED");
    ThirdPartyWorkflowActionEntry itDirectorAction = findAction(approvalHistory, "IT_DIRECTOR_APPROVED", "IT_DIRECTOR_REJECTED");
    ThirdPartyWorkflowActionEntry operatorAction = findAction(approvalHistory, "OPERATOR_COMPLETED");
    ThirdPartyWorkflowActionEntry acceptanceAction = findAction(approvalHistory, "EXTERNAL_ACCEPTED", "EXTERNAL_REJECTED", "EXTERNAL_ACCEPTANCE_EXPIRED");
    ThirdPartyWorkflowActionEntry revokerAction = findAction(approvalHistory, "REVOKER_COMPLETED");
    ThirdPartyWorkflowActionEntry reviewerAction = findAction(approvalHistory, "REVOKE_REVIEWER_APPROVED", "REVOKE_REVIEWER_REJECTED");
    ThirdPartyWorkflowActionEntry reportAction = findAction(approvalHistory, "SECTION_HEAD_REPORTED");
    ThirdPartyWorkflowActionEntry finalAction = findAction(approvalHistory, "FINAL_CERTIFIED");
%>

<table class="workflow-form">
    <tr><th colspan="2">ส่วนที่ 2 สำหรับฝ่ายเทคโนโลยีสารสนเทศ</th></tr>
    <tr>
        <td>
            <strong>เรียน ผอ.ฝ่ายเทคโนโลยีสารสนเทศ</strong><br>
            เพื่อโปรดพิจารณา
            <div class="workflow-line"><%= actionComment(sectionHeadAction) %></div>
            <div class="workflow-line"></div>
            <div class="workflow-sign">ลงชื่อ <%= display(actorName(sectionHeadAction)) %> หัวหน้ากลุ่มงาน<br>(<%= display(sectionHeadAction == null ? null : sectionHeadAction.getActorPosition()) %>)</div>
            <div class="workflow-date">วันที่ <%= actionDate(sectionHeadAction, dateOnly) %></div>
        </td>
        <td>
            <div class="workflow-checks">
                <span>☐ อนุมัติ</span>
                <span>☐ ไม่อนุมัติ</span>
            </div>
            คำสั่ง/ความเห็น(ถ้ามี)
            <div class="workflow-line"><%= actionComment(itDirectorAction) %></div>
            <div class="workflow-line"></div>
            <div class="workflow-sign">ลงชื่อ <%= display(actorName(itDirectorAction)) %> ผู้อำนวยการฝ่าย<br>(<%= display(itDirectorAction == null ? null : itDirectorAction.getActorPosition()) %>)</div>
            <div class="workflow-date">วันที่ <%= actionDate(itDirectorAction, dateOnly) %></div>
        </td>
    </tr>
    <tr>
        <th>ส่วนที่ 3 การดำเนินการ</th>
        <th>ขั้นตอน: <%= h(workflowStepLabel(acceptanceAction == null ? "EXTERNAL_ACCEPTED" : acceptanceAction.getActionType())) %></th>
    </tr>
    <tr>
        <td>
            มอบหมาย/สั่งการ
            <div class="workflow-line"><%= actionComment(operatorAction) %></div>
            <div class="workflow-line"></div>
            <div class="workflow-sign">ลงชื่อ <%= display(actorName(operatorAction)) %> ผู้ดำเนินการ<br>(<%= display(operatorAction == null ? null : operatorAction.getActorPosition()) %>)</div>
            <div class="workflow-date">วันที่ <%= actionDate(operatorAction, dateOnly) %></div>
            การดำเนินการ
            <div class="workflow-line"><%= actionComment(operatorAction) %></div>
            <div class="workflow-line"></div>
        </td>
        <td>
            <strong>ผลตรวจรับและประเมิน</strong><br>
            ผลการตรวจรับ
            <div class="workflow-line"><%= actionComment(acceptanceAction) %></div>
            <div>คะแนนผลตรวจรับ: <%= acceptanceScore == null ? "-" : acceptanceScore %></div>
            <div class="workflow-sign">ลงชื่อ <%= display(actorName(acceptanceAction)) %> ผู้ขอใช้บริการ<br>(<%= display(acceptanceAction == null ? null : acceptanceAction.getActorPosition()) %>)</div>
            <div class="workflow-date">วันที่ <%= actionDate(acceptanceAction, dateOnly) %></div>
        </td>
    </tr>
    <tr><th colspan="2">ส่วนที่ 5 ผู้ดูแลระบบยกเลิกสิทธิ์</th></tr>
    <tr>
        <td>
            การดำเนินการ
            <div class="workflow-line"><%= actionComment(revokerAction) %></div>
            <div class="workflow-line"></div>
            <div class="workflow-sign">ลงชื่อ <%= display(actorName(revokerAction)) %> ผู้ดำเนินการ<br>(<%= display(revokerAction == null ? null : revokerAction.getActorPosition()) %>)</div>
            <div class="workflow-date">วันที่ <%= actionDate(revokerAction, dateOnly) %></div>
        </td>
        <td>
            การดำเนินการ
            <div class="workflow-line"><%= actionComment(reviewerAction) %></div>
            <div class="workflow-line"></div>
            <div class="workflow-sign">ลงชื่อ <%= display(actorName(reviewerAction)) %> ผู้ตรวจทาน<br>(<%= display(reviewerAction == null ? null : reviewerAction.getActorPosition()) %>)</div>
            <div class="workflow-date">วันที่ <%= actionDate(reviewerAction, dateOnly) %></div>
        </td>
    </tr>
    <tr><th colspan="2">ส่วนที่ 6 แจ้งผู้อำนวยการฝ่ายเจ้าของข้อมูล</th></tr>
    <tr>
        <td>
            เรียน ผู้อำนวยการฝ่ายเทคโนโลยีสารสนเทศ<br>
            เพื่อโปรดทราบ
            <div class="workflow-line"><%= actionComment(reportAction) %></div>
            <div class="workflow-line"></div>
            <div class="workflow-sign">ลงชื่อ <%= display(actorName(reportAction)) %> หัวหน้ากลุ่มงาน<br>(<%= display(reportAction == null ? null : reportAction.getActorPosition()) %>)</div>
            <div class="workflow-date">วันที่ <%= actionDate(reportAction, dateOnly) %></div>
        </td>
        <td>
            <br>
            <div class="workflow-sign">ลงชื่อ <%= display(actorName(finalAction)) %> ผู้อำนวยการฝ่าย<br>(<%= display(finalAction == null ? null : finalAction.getActorPosition()) %>)</div>
            <div class="workflow-date">วันที่ <%= actionDate(finalAction, dateOnly) %></div>
        </td>
    </tr>
</table>
<div class="workflow-rev">Rev. 01 (01/08/2566)</div>
</body>
</html>
