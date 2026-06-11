<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%
    Object submittedFormId = session.getAttribute("submittedFormId");
    String submittedFormIdParam = request.getParameter("formId");
    if (submittedFormIdParam != null && !submittedFormIdParam.trim().isEmpty()) {
        submittedFormId = submittedFormIdParam.trim();
    }
    if (submittedFormId != null) {
        request.setAttribute("submittedFormId", submittedFormId);
        session.removeAttribute("submittedFormId");
    }
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ส่งคำขอสำเร็จ</title>
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/images/cropped-logo-192x192.png">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body>
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>

<div id="main" class="enterprise-index-shell">
    <%@ include file="/WEB-INF/jspf/topbar.jspf" %>

    <main class="submit-success-page">
        <section class="submit-success-card">
            <div class="submit-success-icon">
                <i class="fa-solid fa-check"></i>
            </div>
            <p class="enterprise-eyebrow">Requisition Form</p>
            <h1>ส่งคำขอเรียบร้อยแล้ว</h1>
            <div class="form-id-badge">
                <i class="fa-solid fa-file-lines"></i>
                <span>FormID: ${submittedFormId}</span>
            </div>
            <p class="submit-success-message">
                คำขอของคุณถูกบันทึกเข้าสู่ระบบแล้ว เจ้าหน้าที่จะดำเนินการตรวจสอบข้อมูลตามขั้นตอนถัดไป
            </p>
            <div class="submit-success-actions">
                <a href="${pageContext.request.contextPath}/forms/select?code=IT_REQUISITION_REQUEST" class="form-type-action">
                    <i class="fa-solid fa-plus"></i> สร้างคำขอใหม่
                </a>
                <a href="${pageContext.request.contextPath}/it-requisition-form-detail.jsp" class="form-type-action secondary">
                    <i class="fa-solid fa-arrow-left"></i> กลับหน้ารายละเอียดฟอร์ม
                </a>
            </div>
        </section>
    </main>

    <%@ include file="/WEB-INF/jspf/footer.jspf" %>
</div>

<script>
if (window.history && window.history.pushState) {
    window.history.replaceState({ page: "submit-success" }, "", window.location.href);
    window.history.pushState({ page: "submit-success-guard" }, "", window.location.href);
    window.addEventListener("popstate", function () {
        window.location.replace("${pageContext.request.contextPath}/it-requisition-form-detail.jsp");
    });
}

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
