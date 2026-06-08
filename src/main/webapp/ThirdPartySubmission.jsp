<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.slf.model.ThirdPartyFormSubmission" %>
<%@ page import="com.slf.util.AuthUtil" %>
<%!
    public String h(Object input) {
        if (input == null) return "";
        return String.valueOf(input)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#x27;");
    }

    public String display(Object input) {
        if (input == null || String.valueOf(input).trim().isEmpty()) return "-";
        return h(input);
    }
%>
<%
    String currentRole = (String) session.getAttribute("position");
    if (!AuthUtil.isAllowedForPage(currentRole, "thirdPartySubmission")) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }
    ThirdPartyFormSubmission submission = (ThirdPartyFormSubmission) request.getAttribute("submission");
    if (submission == null) {
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
        return;
    }
    SimpleDateFormat dateTime = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
    SimpleDateFormat dateOnly = new SimpleDateFormat("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Third-party Submission #<%= submission.getSubmissionId() %></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; background: #f4f8fc; color: #102a43; font-family: 'Sarabun', sans-serif; }
        .page { max-width: 1160px; margin: 0 auto; padding: 26px 28px 44px; }
        .page-head { display: flex; justify-content: space-between; align-items: flex-start; gap: 18px; margin-bottom: 18px; }
        .page-title h1 { margin: 0; color: #003366; font-size: 28px; }
        .page-title p { margin: 6px 0 0; color: #5b6f82; }
        .panel { background: #fff; border: 1px solid #d9e6f2; border-radius: 10px; box-shadow: 0 8px 22px rgba(0, 51, 102, 0.08); padding: 20px; margin-bottom: 18px; }
        .section-title { margin: 0 0 14px; color: #003366; font-size: 20px; }
        .grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 14px 18px; }
        .field { border-bottom: 1px solid #e5eef6; padding-bottom: 10px; }
        .full { grid-column: 1 / -1; }
        .label { color: #64748b; font-size: 13px; font-weight: 800; margin-bottom: 4px; }
        .value { color: #102a43; font-size: 16px; line-height: 1.55; overflow-wrap: anywhere; white-space: pre-wrap; }
        .status { display: inline-flex; align-items: center; border-radius: 999px; padding: 4px 10px; font-weight: 900; font-size: 12px; background: #e8f2fb; color: #00509e; }
        .btn { border: 0; border-radius: 7px; min-height: 40px; padding: 0 16px; display: inline-flex; align-items: center; justify-content: center; gap: 8px; font-family: inherit; font-weight: 800; cursor: pointer; text-decoration: none; white-space: nowrap; }
        .btn-secondary { background: #e8f2fb; color: #003366; }
        @media (max-width: 800px) {
            .page { padding: 18px 14px 34px; }
            .page-head { flex-direction: column; }
            .grid { grid-template-columns: 1fr; }
            .full { grid-column: auto; }
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/sidebar.jsp" %>
<div id="main">
    <div class="sticky-bar">
        <i id="menuBtn" class="fa-solid fa-bars" onclick="toggleNav()"></i>
        <img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF Logo">
        <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo">
        <div class="user-info">
            <i class="fa fa-circle-user"></i>
            <p>${sessionScope.loggedInEmpName} | ID: ${sessionScope.loggedInEmpId}</p>
        </div>
        <div class="contact-info">
            <i class="fa-solid fa-circle-info"></i>
            <p>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
        </div>
    </div>

    <main class="page">
        <div class="page-head">
            <div class="page-title">
                <h1><i class="fa-solid fa-file-lines"></i> Submission #<%= submission.getSubmissionId() %></h1>
                <p>เลขที่รับเอกสาร <strong><%= display(submission.getDocumentReceiveNo()) %></strong></p>
            </div>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/thirdPartyLinks">
                <i class="fa-solid fa-arrow-left"></i> กลับหน้า Third-party Links
            </a>
        </div>

        <section class="panel">
            <h2 class="section-title">สถานะและลิงก์</h2>
            <div class="grid">
                <div class="field">
                    <div class="label">สถานะ Submission</div>
                    <div class="value"><span class="status"><%= display(submission.getStatus()) %></span></div>
                </div>
                <div class="field">
                    <div class="label">Link ID / สถานะลิงก์</div>
                    <div class="value">#<%= submission.getLinkId() %> / <%= display(submission.getLinkStatus()) %></div>
                </div>
                <div class="field">
                    <div class="label">เวลาส่งข้อมูล</div>
                    <div class="value"><%= submission.getCreatedAt() == null ? "-" : dateTime.format(submission.getCreatedAt()) %></div>
                </div>
                <div class="field">
                    <div class="label">วันหมดอายุลิงก์</div>
                    <div class="value"><%= submission.getLinkExpiresAt() == null ? "-" : dateTime.format(submission.getLinkExpiresAt()) %></div>
                </div>
                <div class="field full">
                    <div class="label">หมายเหตุลิงก์</div>
                    <div class="value"><%= display(submission.getLinkNote()) %></div>
                </div>
            </div>
        </section>

        <section class="panel">
            <h2 class="section-title">ข้อมูลผู้กรอก</h2>
            <div class="grid">
                <div class="field">
                    <div class="label">เลขที่รับเอกสาร</div>
                    <div class="value"><%= display(submission.getDocumentReceiveNo()) %></div>
                </div>
                <div class="field">
                    <div class="label">ชื่อ-สกุล ภาษาไทย</div>
                    <div class="value"><%= display(submission.getFullNameTh()) %></div>
                </div>
                <div class="field">
                    <div class="label">ชื่อ-สกุล ภาษาอังกฤษ</div>
                    <div class="value"><%= display(submission.getFullNameEn()) %></div>
                </div>
                <div class="field">
                    <div class="label">หน่วยงาน</div>
                    <div class="value"><%= display(submission.getOrganization()) %></div>
                </div>
                <div class="field">
                    <div class="label">เบอร์โทรศัพท์</div>
                    <div class="value"><%= display(submission.getPhone()) %></div>
                </div>
                <div class="field full">
                    <div class="label">Email</div>
                    <div class="value"><%= display(submission.getEmail()) %></div>
                </div>
            </div>
        </section>

        <section class="panel">
            <h2 class="section-title">รายละเอียดการขอใช้งาน</h2>
            <div class="grid">
                <div class="field full">
                    <div class="label">เหตุผลและวัตถุประสงค์การขอ</div>
                    <div class="value"><%= display(submission.getReasonObjective()) %></div>
                </div>
                <div class="field full">
                    <div class="label">เพื่อใช้ในโครงการ</div>
                    <div class="value"><%= display(submission.getProjectName()) %></div>
                </div>
                <div class="field">
                    <div class="label">วันที่เริ่มต้นใช้ระบบงาน</div>
                    <div class="value"><%= submission.getAccessStartDate() == null ? "-" : dateOnly.format(submission.getAccessStartDate()) %></div>
                </div>
                <div class="field">
                    <div class="label">ถึงวันที่</div>
                    <div class="value"><%= submission.getAccessEndDate() == null ? "-" : dateOnly.format(submission.getAccessEndDate()) %></div>
                </div>
            </div>
        </section>
    </main>
</div>
<script>
function toggleNav() {
    var sidebar = document.getElementById("mySidebar");
    var main = document.getElementById("main");
    if (sidebar.style.width === "250px") {
        sidebar.style.width = "0";
        main.style.marginLeft = "0";
        main.style.width = "100%";
    } else {
        sidebar.style.width = "250px";
        main.style.marginLeft = "250px";
        main.style.width = "calc(100% - 250px)";
    }
}
</script>
</body>
</html>
