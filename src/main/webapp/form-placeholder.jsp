<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.slf.model.FormType" %>
<%!
    private String h(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>
<%
    FormType formType = (FormType) request.getAttribute("formType");
    if (formType == null) {
        response.sendRedirect(request.getContextPath() + "/newForm");
        return;
    }
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>แบบฟอร์มอยู่ระหว่างเตรียมเปิดใช้งาน</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
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

    <main class="form-selection-page">
        <section class="placeholder-panel">
            <div class="placeholder-icon">
                <i class="<%= h(formType.getIcon()) %>"></i>
            </div>
            <p class="eyebrow">อยู่ระหว่างเตรียมเปิดใช้งาน</p>
            <h1><%= h(formType.getFormName()) %></h1>
            <p>
                แบบฟอร์มนี้ถูกลงทะเบียนไว้ในระบบแล้ว แต่ยังไม่ได้เปิดขั้นตอนการกรอกและส่งข้อมูลจริง
                เมื่อพร้อมใช้งานสามารถเปิดจากทะเบียนแบบฟอร์มส่วนกลางได้ โดยไม่ต้องปรับหน้าแรกใหม่
            </p>
            <div class="placeholder-actions">
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/newForm">
                    <i class="fa-solid fa-table-list"></i> เลือกฟอร์มอื่น
                </a>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/">
                    <i class="fa-solid fa-house"></i> กลับหน้าหลัก
                </a>
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
