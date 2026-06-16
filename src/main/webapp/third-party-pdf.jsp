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
        return input == null || String.valueOf(input).trim().isEmpty() ? "" : h(input);
    }

    private String formatDate(java.util.Date value, SimpleDateFormat formatter) {
        return value == null ? "" : formatter.format(value);
    }

    private String actorName(ThirdPartyWorkflowActionEntry action) {
        if (action == null) return "";
        if (action.getActorEmpName() != null && !action.getActorEmpName().trim().isEmpty()) {
            return action.getActorEmpName();
        }
        if ("SYSTEM".equals(action.getActorType())) return "ระบบ";
        if ("EXTERNAL".equals(action.getActorType())) return "ผู้ขอใช้บริการ";
        return action.getActorEmpId() == null ? "" : "Employee #" + action.getActorEmpId();
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
            return "....................................................................................................................................";
        }
        return h(action.getCommentText());
    }

    private String actionDate(ThirdPartyWorkflowActionEntry action, SimpleDateFormat formatter) {
        if (action == null || action.getActedAt() == null) return "......../......../........";
        return formatter.format(action.getActedAt());
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
    
    // Extract optional details safely
    String fullNameEn = "";
    if (submission.getAccessRequests() != null && !submission.getAccessRequests().isEmpty()) {
        fullNameEn = display(submission.getAccessRequests().get(0).getFullNameEn());
    }
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <title>Third-party Registration Form #<%= submission.getSubmissionId() %></title>
    <style>
        @font-face {
            font-family: 'Anuphan';
            src: url('${pageContext.request.contextPath}/css/fonts/Anuphan-VariableFont_wght.ttf') format('truetype');
            font-weight: 100 700;
            font-display: swap;
        }

        @page {
            size: A4;
            margin: 12mm 15mm 12mm 15mm;
        }

        * {
            box-sizing: border-box;
        }

        body {
            font-family: 'Anuphan', Tahoma, Arial, sans-serif;
            margin: 0;
            padding: 0;
            font-size: 9.5pt; /* Slightly reduced base font */
            line-height: 1.35; /* Reduced line-height to save vertical space */
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

        @media print {
            .btn-print { display: none; }
            .page-break { page-break-before: always; }
        }

        .header-container {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 15px;
        }

        .logo-img {
            height: 55px; /* Slightly scaled down */
            object-fit: contain;
        }

        .form-title-right {
            text-align: right;
            font-size: 9.5pt;
        }
        
        .form-title-right .th-title {
            font-weight: bold;
            color: #4a6fa5;
        }

        .doc-code {
            font-weight: bold;
            border-bottom: 1px solid #000;
            display: inline-block;
            padding-bottom: 2px;
            margin-top: 5px;
        }

        .sub-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            font-weight: bold;
        }

        .form-table {
            width: 100%;
            border-collapse: collapse;
            border: 1px solid #000;
            margin-bottom: 10px;
        }

        .form-table th, .form-table td {
            border: 1px solid #000;
            padding: 6px 8px; /* Reduced padding */
            vertical-align: top;
        }

        .section-header {
            background-color: #d9d9d9;
            font-weight: bold;
            text-align: left;
            padding: 4px 10px !important;
        }

        .flex-row {
            display: flex;
            margin-bottom: 4px;
            align-items: baseline;
        }

        .fill-line {
            flex-grow: 1;
            border-bottom: 1px dotted #000;
            margin: 0 5px;
            min-height: 16px;
            color: #000;
            padding-left: 5px;
        }
        
        .fill-fixed {
            border-bottom: 1px dotted #000;
            display: inline-block;
            min-width: 150px;
            text-align: center;
        }

        .long-text-block {
            text-indent: 40px;
            text-align: justify;
            margin: 10px 0;
            line-height: 1.5;
        }

        .signature-block {
            text-align: center;
            margin-top: 15px;
            margin-bottom: 10px;
        }

        .sig-line {
            display: inline-block;
            width: 250px;
            border-bottom: 1px dotted #000;
            margin-bottom: 4px;
        }

        .footnotes {
            font-size: 8pt;
            margin-top: 8px;
            line-height: 1.2;
        }

        .checkbox-group {
            margin: 8px 0;
        }

        .checkbox-group span {
            margin-right: 20px;
        }

        .footer-line {
            text-align: center;
            font-size: 8.5pt;
            border-top: 1px solid #000;
            border-bottom: 1px solid #000;
            padding: 4px 0;
            margin-top: 15px;
            margin-bottom: 8px;
        }

        .doc-rev {
            display: flex;
            justify-content: space-between;
            font-size: 8.5pt;
        }
        
        .doc-secret {
            font-weight: bold;
        }

        /* Page 2 specifics optimized for height */
        .matrix-table {
            width: 100%;
            border-collapse: collapse;
            border: 1px solid #000;
        }
        .matrix-table th, .matrix-table td {
            border: 1px solid #000;
            padding: 5px 6px; /* Tighter padding for page 2 */
            vertical-align: top;
            width: 50%;
        }
        .matrix-header {
            background-color: #d9d9d9;
            font-weight: bold;
            padding: 3px 6px;
        }
        .action-box {
            min-height: 85px; /* Reduced min-height */
            position: relative;
        }
        .action-box .signature-block {
            margin-top: 10px; /* Reduced to pull signatures up */
            margin-bottom: 2px;
        }
        .action-box .sig-line {
            width: 180px;
            margin-bottom: 2px;
        }
    </style>
</head>
<body>

<button class="btn-print" onclick="window.print()">พิมพ์เอกสาร / Print</button>

<div class="header-container">
    <div>
        <img class="logo-img" src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo">
    </div>
    <div class="form-title-right">
        <div class="th-title">แบบฟอร์มร้องขอสิทธิการเข้าถึง สำหรับผู้ให้บริการภายนอก</div>
        <div>User Registration for Third Party Form</div>
        <div class="doc-code">FR-ISMS-022</div>
    </div>
</div>

<div class="sub-header">
    <div>เรียน ผู้อำนวยการฝ่ายเทคโนโลยีสารสนเทศ</div>
    <div>เลขที่รับเอกสาร...............................................................</div>
</div>

<table class="form-table">
    <tr>
        <td class="section-header" style="width: 70%;">ส่วนที่ 1 ผู้ขอใช้บริการ</td>
        <td class="section-header" style="width: 30%; text-align: right; font-weight: normal;">
            วันที่ <span class="fill-fixed"><%= formatDate(submission.getFilledDate(), dateOnly) %></span>
        </td>
    </tr>
    <tr>
        <td colspan="2">
            <div class="flex-row">
                <span>ชื่อ - สกุล (ภาษาไทย)</span>
                <span class="fill-line"><%= display(submission.getFullNameTh()) %></span>
            </div>
            <div class="flex-row">
                <span>ชื่อ - สกุล (ภาษาอังกฤษ)</span>
                <span class="fill-line"><%= fullNameEn %></span>
            </div>
            <div class="flex-row">
                <span>บริษัท/หน่วยงาน</span>
                <span class="fill-line"><%= display(submission.getOrganization()) %></span>
            </div>
            <div class="flex-row">
                <span>เบอร์โทรศัพท์</span>
                <span class="fill-line" style="flex: 0.4;"><%= display(submission.getPhone()) %></span>
                <span>Email</span>
                <span class="fill-line"><%= display(submission.getEmail()) %></span>
            </div>
            <div class="flex-row">
                <span><strong>มีความประสงค์จะขอใช้ระบบ</strong></span>
                <span class="fill-line"><%= display(submission.getProjectName()) %></span>
            </div>
            <div class="flex-row">
                <span><strong>เหตุผลและวัตถุประสงค์การขอ</strong></span>
                <span class="fill-line"><%= display(submission.getReasonObjective()) %></span>
            </div>
            <div class="flex-row">
                <span class="fill-line"></span>
            </div>
            <div class="flex-row">
                <span><strong>เพื่อใช้ในโครงการ</strong></span>
                <span class="fill-line"></span>
            </div>
            <div class="flex-row">
                <span><strong>ระยะเวลาที่ต้องการใช้ระบบงาน</strong> วันที่เริ่มต้น</span>
                <span class="fill-line" style="flex: 0.3; text-align: center;"><%= formatDate(submission.getAccessStartDate(), dateOnly) %></span>
                <span>ถึงวันที่</span>
                <span class="fill-line" style="flex: 0.3; text-align: center;"><%= formatDate(submission.getAccessEndDate(), dateOnly) %></span>
            </div>

            <div class="long-text-block">
                ข้าพเจ้าขอรับรองว่าข้อมูลข้างต้น เป็นความจริงทุกประการ โดยจะไม่ใช้ เปิดเผย หรือเอาไปซึ่งข้อมูลไม่ว่าทั้งหมดหรือบางส่วนอันเป็นความลับของทางราชการ หรืออนุญาตให้บุคคลอื่นกระทำการดังกล่าว โดยไม่ได้รับความยินยอมจากกองทุนเงินให้กู้ยืมเพื่อการศึกษา เป็นลายลักษณ์อักษรไม่ว่าข้อมูลนั้นจะอยู่ในรูปแบบใด และจะปฏิบัติตามระเบียบข้อกำหนด นโยบายการรักษาความมั่นคงปลอดภัยด้านเทคโนโลยีสารสนเทศ และยินยอมรับเงื่อนไขตามที่กำหนด นโยบายว่าด้วยการรักษาความลับระบบสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา ทั้งนี้ ยินดีจะรับผิดชอบต่อความเสียหายที่เกิดขึ้นตามพระราชบัญญัติว่าด้วยการกระทำความผิดเกี่ยวกับคอมพิวเตอร์ พ.ศ. 2560 ข้าพเจ้ายอมรับข้อตกลงดังกล่าว และจะปฏิบัติตาม อย่างเคร่งครัด ทุกประการ
            </div>

            <div class="signature-block">
                ลงชื่อ<span class="sig-line"><%= display(submission.getFullNameTh()) %></span>ผู้ขอใช้บริการ<br>
                (<span class="sig-line" style="width: 200px;"><%= display(submission.getFullNameTh()) %></span>)<br>
                วันที่<span class="sig-line" style="width: 200px;"><%= formatDate(submission.getFilledDate(), dateOnly) %></span>
            </div>

            <div class="footnotes">
                <u>*หมายเหตุ</u> ผู้ขอใช้บริการต้องลงนามในหนังสือยินยอมรับเงื่อนไข นโยบายว่าด้วยการรักษาความลับระบบสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา<br>
                **กรณีที่ขอสิทธิ์การใช้งาน มากกว่า 1 คน ให้แนบเอกสารขอลงทะเบียนผู้ใช้ระบบงานสารสนเทศ (สำหรับบุคคลภายนอก)
            </div>
        </td>
    </tr>
    <tr>
        <td colspan="2" class="section-header">ความเห็นของผู้บังคับบัญชาของผู้ขอใช้บริการ</td>
    </tr>
    <tr>
        <td colspan="2">
            <div class="checkbox-group">
                <span>&#9744; เห็นควรอนุมัติ</span><br>
                <div class="flex-row" style="margin-top: 5px;">
                    <span>&#9744; ไม่เห็นควรอนุมัติ เพราะ</span>
                    <span class="fill-line"></span>
                </div>
            </div>
            
            <div class="signature-block" style="margin-left: 200px;">
                ลงชื่อ<span class="sig-line"></span><br>
                (<span class="sig-line" style="width: 200px;"></span>)<br>
                ตำแหน่ง<span class="sig-line" style="width: 200px;"></span><br>
                วันที่<span class="sig-line" style="width: 200px;"></span>
            </div>
        </td>
    </tr>
</table>

<div class="footer-line">
    ติดต่อสอบถามรายละเอียดเพิ่มเติม ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา โทร 408-412
</div>

<div class="doc-rev">
    <div>
        Rev. 01 (01/08/2566)<br>
        <span class="doc-secret">ชั้นความลับเอกสาร : ใช้ภายในเท่านั้น</span>
    </div>
    <div style="text-align: right;">
        หน้าที่ 1/3
    </div>
</div>

<div class="page-break"></div>

<div class="header-container" style="justify-content: flex-end; margin-bottom: 5px;">
    <div class="form-title-right">
        <div class="th-title">แบบฟอร์มร้องขอสิทธิการเข้าถึง สำหรับผู้ให้บริการภายนอก</div>
        <div>User Registration for Third Party Form</div>
        <div class="doc-code">FR-ISMS-022</div>
    </div>
</div>

<%
    ThirdPartyWorkflowActionEntry sectionHeadAction = findAction(approvalHistory, "SECTION_HEAD_SUBMITTED");
    ThirdPartyWorkflowActionEntry itDirectorAction = findAction(approvalHistory, "IT_DIRECTOR_APPROVED", "IT_DIRECTOR_REJECTED");
    ThirdPartyWorkflowActionEntry operatorAction = findAction(approvalHistory, "OPERATOR_COMPLETED");
    ThirdPartyWorkflowActionEntry acceptanceAction = findAction(approvalHistory, "EXTERNAL_ACCEPTED", "EXTERNAL_REJECTED", "EXTERNAL_ACCEPTANCE_EXPIRED");
    ThirdPartyWorkflowActionEntry revokerAction = findAction(approvalHistory, "REVOKER_COMPLETED");
    ThirdPartyWorkflowActionEntry reviewerAction = findAction(approvalHistory, "REVOKE_REVIEWER_APPROVED", "REVOKE_REVIEWER_REJECTED");
    ThirdPartyWorkflowActionEntry reportAction = findAction(approvalHistory, "SECTION_HEAD_REPORTED");
    ThirdPartyWorkflowActionEntry finalAction = findAction(approvalHistory, "FINAL_CERTIFIED");
    
    boolean isApproved = itDirectorAction != null && "IT_DIRECTOR_APPROVED".equals(itDirectorAction.getActionType());
    boolean isRejected = itDirectorAction != null && "IT_DIRECTOR_REJECTED".equals(itDirectorAction.getActionType());
    
    boolean isAccSat = acceptanceScore != null && acceptanceScore == 3;
    boolean isAccNeu = acceptanceScore != null && acceptanceScore == 2;
    boolean isAccDis = acceptanceScore != null && acceptanceScore == 1;
%>

<table class="matrix-table">
    <tr>
        <td colspan="2" class="matrix-header" style="padding: 0; border: 0;">
            <table style="width: 100%; border-collapse: collapse;">
                <tr><th class="matrix-header" style="border-bottom: 1px solid #000; text-align: left;">ส่วนที่ 2 สำหรับฝ่ายเทคโนโลยีสารสนเทศ</th></tr>
            </table>
        </td>
    </tr>
    <tr>
        <td class="action-box">
            เรียน ผอ.ฝ่ายเทคโนโลยีสารสนเทศ<br>
            เพื่อโปรดพิจารณา<span class="fill-line" style="display:inline-block; width: 80%;"><%= actionComment(sectionHeadAction).equals("....................................................................................................................................") ? "" : actionComment(sectionHeadAction) %></span>
            <div class="flex-row"><span class="fill-line"></span></div>
            
            <div class="signature-block">
                ลงชื่อ<span class="sig-line"><%= display(actorName(sectionHeadAction)) %></span>หัวหน้ากลุ่มงาน<br>
                (<span class="sig-line"><%= display(sectionHeadAction == null ? "" : sectionHeadAction.getActorEmpName()) %></span>)<br>
                วันที่<span class="sig-line"><%= actionDate(sectionHeadAction, dateOnly) %></span>
            </div>
        </td>
        <td class="action-box">
            <div style="text-align: center; font-weight: bold; margin-bottom: 5px;">
                <span style="margin-right: 30px;"><%= isApproved ? "&#9745;" : "&#9744;" %> อนุมัติ</span>
                <span><%= isRejected ? "&#9745;" : "&#9744;" %> ไม่อนุมัติ</span>
            </div>
            คำสั่ง/ความเห็น(ถ้ามี)<span class="fill-line" style="display:inline-block; width: 70%;"><%= actionComment(itDirectorAction).equals("....................................................................................................................................") ? "" : actionComment(itDirectorAction) %></span>
            <div class="flex-row"><span class="fill-line"></span></div>

            <div class="signature-block">
                ลงชื่อ<span class="sig-line"><%= display(actorName(itDirectorAction)) %></span>ผู้อำนวยการฝ่าย<br>
                (<span class="sig-line"><%= display(itDirectorAction == null ? "" : itDirectorAction.getActorEmpName()) %></span>)<br>
                วันที่<span class="sig-line"><%= actionDate(itDirectorAction, dateOnly) %></span>
            </div>
        </td>
    </tr>
    <tr>
        <th class="matrix-header" style="text-align: left;">ส่วนที่ 3 การดำเนินการ</th>
        <th class="matrix-header" style="text-align: left;">ส่วนที่ 4 ผลตรวจรับและประเมินความพึงพอใจ</th>
    </tr>
    <tr>
        <td class="action-box">
            มอบหมาย/สั่งการ<span class="fill-line" style="display:inline-block; width: 70%;"></span>
            <div class="signature-block" style="margin-top: 8px;">
                ลงชื่อ<span class="sig-line"></span>หัวหน้ากลุ่มงาน<br>
                (<span class="sig-line"></span>)<br>
                วันที่<span class="sig-line"></span>
            </div>
            การดำเนินการ<span class="fill-line" style="display:inline-block; width: 75%;"><%= actionComment(operatorAction).equals("....................................................................................................................................") ? "" : actionComment(operatorAction) %></span>
            <div class="flex-row"><span class="fill-line"></span></div>
            <div class="signature-block" style="margin-top: 8px;">
                ลงชื่อ<span class="sig-line"><%= display(actorName(operatorAction)) %></span>ผู้ดำเนินการ<br>
                (<span class="sig-line"><%= display(operatorAction == null ? "" : operatorAction.getActorEmpName()) %></span>)<br>
                วันที่<span class="sig-line"><%= actionDate(operatorAction, dateOnly) %></span>
            </div>
        </td>
        <td class="action-box">
            ผู้ขอใช้บริการ ตรวจรับและประเมินความพึงพอใจ<br>
            ผลการตรวจรับ<span class="fill-line" style="display:inline-block; width: 75%;"><%= actionComment(acceptanceAction).equals("....................................................................................................................................") ? "" : actionComment(acceptanceAction) %></span>
            <div class="flex-row"><span class="fill-line"></span></div>
            
            <div style="text-align: center; font-weight: bold; margin: 10px 0;">
                <span style="margin-right: 15px;"><%= isAccDis ? "&#9745;" : "&#9744;" %> ไม่พอใจ</span>
                <span style="margin-right: 15px;"><%= isAccNeu ? "&#9745;" : "&#9744;" %> ธรรมดา</span>
                <span><%= isAccSat ? "&#9745;" : "&#9744;" %> พอใจ</span>
            </div>

            <div class="signature-block" style="margin-top: 20px;">
                ลงชื่อ<span class="sig-line"><%= display(actorName(acceptanceAction)) %></span>ผู้ขอใช้บริการ<br>
                (<span class="sig-line"><%= display(acceptanceAction == null ? "" : submission.getFullNameTh()) %></span>)<br>
                ตำแหน่ง<span class="sig-line"></span><br>
                วันที่<span class="sig-line"><%= actionDate(acceptanceAction, dateOnly) %></span>
            </div>
        </td>
    </tr>
    <tr>
        <td colspan="2" class="matrix-header" style="padding: 0; border: 0;">
            <table style="width: 100%; border-collapse: collapse;">
                <tr><th class="matrix-header" style="border-bottom: 1px solid #000; text-align: left;">ส่วนที่ 5 ผู้ดูแลระบบยกเลิกสิทธิ</th></tr>
            </table>
        </td>
    </tr>
    <tr>
        <td class="action-box">
            การดำเนินการ<span class="fill-line" style="display:inline-block; width: 75%;"><%= actionComment(revokerAction).equals("....................................................................................................................................") ? "" : actionComment(revokerAction) %></span>
            <div class="flex-row"><span class="fill-line"></span></div>
            <div class="signature-block">
                ลงชื่อ<span class="sig-line"><%= display(actorName(revokerAction)) %></span>ผู้ดำเนินการ<br>
                (<span class="sig-line"><%= display(revokerAction == null ? "" : revokerAction.getActorEmpName()) %></span>)<br>
                วันที่<span class="sig-line"><%= actionDate(revokerAction, dateOnly) %></span>
            </div>
        </td>
        <td class="action-box">
            การดำเนินการ<span class="fill-line" style="display:inline-block; width: 75%;"><%= actionComment(reviewerAction).equals("....................................................................................................................................") ? "" : actionComment(reviewerAction) %></span>
            <div class="flex-row"><span class="fill-line"></span></div>
            <div class="signature-block">
                ลงชื่อ<span class="sig-line"><%= display(actorName(reviewerAction)) %></span>ผู้ตรวจทาน<br>
                (<span class="sig-line"><%= display(reviewerAction == null ? "" : reviewerAction.getActorEmpName()) %></span>)<br>
                วันที่<span class="sig-line"><%= actionDate(reviewerAction, dateOnly) %></span>
            </div>
        </td>
    </tr>
    <tr>
        <td colspan="2" class="matrix-header" style="padding: 0; border: 0;">
            <table style="width: 100%; border-collapse: collapse;">
                <tr><th class="matrix-header" style="border-bottom: 1px solid #000; text-align: left;">ส่วนที่ 6 แจ้งผู้อำนวยการฝ่ายเจ้าของข้อมูล</th></tr>
            </table>
        </td>
    </tr>
    <tr>
        <td class="action-box">
            เรียน ผู้อำนวยการฝ่ายเทคโนโลยีสารสนเทศ<br>
            เพื่อโปรดทราบ<span class="fill-line" style="display:inline-block; width: 75%;"><%= actionComment(reportAction).equals("....................................................................................................................................") ? "" : actionComment(reportAction) %></span>
            <div class="flex-row"><span class="fill-line"></span></div>
            <div class="signature-block">
                ลงชื่อ<span class="sig-line"><%= display(actorName(reportAction)) %></span>หัวหน้ากลุ่มงาน<br>
                (<span class="sig-line"><%= display(reportAction == null ? "" : reportAction.getActorEmpName()) %></span>)<br>
                วันที่<span class="sig-line"><%= actionDate(reportAction, dateOnly) %></span>
            </div>
        </td>
        <td class="action-box">
            <div class="signature-block" style="margin-top: 25px;">
                ลงชื่อ<span class="sig-line"><%= display(actorName(finalAction)) %></span>ผู้อำนวยการฝ่าย<br>
                (<span class="sig-line"><%= display(finalAction == null ? "" : finalAction.getActorEmpName()) %></span>)<br>
                วันที่<span class="sig-line"><%= actionDate(finalAction, dateOnly) %></span>
            </div>
        </td>
    </tr>
</table>

<div class="doc-rev" style="margin-top: 10px;">
    <div>
        Rev. 01 (01/08/2566)<br>
        <span class="doc-secret">ชั้นความลับเอกสาร : ใช้ภายในเท่านั้น</span>
    </div>
    <div style="text-align: right;">
        หน้าที่ 2/3
    </div>
</div>

</body>
</html>