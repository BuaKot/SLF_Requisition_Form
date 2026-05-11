<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <title>IT Requisition - Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Admin.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body>
    <header class="sticky-bar">
        <div class="header-left">
            <i class="fa fa-bars" onclick="toggleNav()"></i>
            <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF">
            <img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF">
        </div>
        <div class="header-right">
            <span>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</span>
        </div>
    </header>

    <div class="blue-banner">
        <h1>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</h1>
        <h2>ใบขอให้ดำเนินการ / Requisition Form</h2>
    </div>

    <div class="admin-grid">
        <div class="card" onclick="location.href='#'">
            <i class="fa-regular fa-circle-user icon-main"></i>
            <p>ผู้อำนวยการฝ่าย</p>
        </div>
        <div class="card" onclick="location.href='#'">
            <div class="icon-stack">
                <i class="fa-solid fa-window-maximize"></i>
                <i class="fa-solid fa-wrench icon-sub"></i>
            </div>
            <p>ความเห็นและการอนุมัติเชิงเทคนิค</p>
        </div>
        <div class="card" onclick="location.href='#'">
            <i class="fa-regular fa-circle-user icon-main"></i>
            <p>ผู้อำนวยการฝ่าย<br>เทคโนโลยีสารสนเทศ</p>
        </div>
    </div>
</body>
</html>