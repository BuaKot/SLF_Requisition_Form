<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="th">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0"> <title>IT Requisition - Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    
    <style>
        * { box-sizing: border-box; }

        body {
            font-family: 'Sarabun', sans-serif;
            margin: 0;
            padding: 0;
            background-color: #ffffff;
            overflow-x: hidden;
        }

        /* Navigation Bar */
        .sticky-bar {
            position: sticky;
            top: 0;
            background: white;
            width: 100%;
            height: 70px;
            border-bottom: 5px solid #3272BB;
            display: flex;
            align-items: center;
            padding: 0 15px;
            z-index: 100;
        }

        .header-logos { display: flex; align-items: center; gap: 10px; }
        .header-logos img { height: 40px; }

        /* Sidebar */
        .sidebar {
            height: 100%;
            width: 0;
            position: fixed;
            z-index: 1000;
            top: 0;
            left: 0;
            background-color: #3272BB;
            overflow-x: hidden;
            transition: 0.5s;
            padding-top: 60px;
        }

        .sidebar a {
            padding: 15px 32px;
            text-decoration: none;
            font-size: 20px;
            color: white;
            display: block;
            white-space: nowrap;
        }

        /* Banner - ปรับขนาดตามหน้าจอ */
        .banner {
            background: #C3EAFF;
            padding: 30px 15px;
            text-align: center;
            color: #003366;
        }

        .banner h1 { font-size: clamp(18px, 5vw, 24px); margin: 0; }
        .banner h2 { font-size: clamp(14px, 4vw, 18px); margin-top: 10px; font-weight: normal; }

        /* Grid System - Responsive */
        .admin-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); /* ปรับจำนวนคอลัมน์อัตโนมัติ */
            gap: 25px;
            padding: 40px 20px;
            max-width: 1200px;
            margin: 0 auto;
        }

        /* Card Design */
        .card {
            background: white;
            border: 3px solid #3272BB;
            border-radius: 20px;
            padding: 40px 20px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 350px;
        }

        .card:hover {
            background-color: #f0f8ff;
            transform: translateY(-10px);
            box-shadow: 0 10px 20px rgba(50, 114, 187, 0.2);
        }

        .card i {
            font-size: 100px;
            color: #3272BB;
            margin-bottom: 25px;
        }

        .card p {
            font-weight: bold;
            font-size: 20px;
            color: #333;
            margin: 0;
            line-height: 1.4;
        }

        /* ซ่อนข้อความติดต่อในมือถือเล็กๆ */
        @media (max-width: 480px) {
            .contact-info { display: none; }
            .admin-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>

<body>
    <div id="mySidebar" class="sidebar">
        <a href="javascript:void(0)" style="font-size:36px" onclick="toggleNav()">&times;</a>
        <a href="#"><i class="fa fa-home"></i> หน้าหลัก</a>
        <a href="#"><i class="fa fa-history"></i> ประวัติรายการ</a>
    </div>

    <div class='sticky-bar'>
        <i class="fa fa-bars" onclick="toggleNav()" style="font-size:28px; cursor:pointer; color:#3272BB;"></i>
        <div class="header-logos" style="margin-left: 15px;">
            <img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF">
            <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF">
        </div>
        <div class="contact-info" style="margin-left:auto; display:flex; align-items:center">
            <i class='fa fa-circle-user' style='font-size:20px; color:#3272BB;'></i>
            <p style='margin-left: 8px; font-size: 14px;'>ติดต่อ 411</p>
        </div>
    </div>

    <div class="banner">
        <h1>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</h1>
        <h2>ใบขอให้ดำเนินการ / Requisition Form</h2>
    </div>

    <div class="admin-grid">
        <div class="card" onclick="location.href='${pageContext.request.contextPath}/DirectorApprove.jsp'">
            <i class="fa-regular fa-circle-user"></i>
            <p>ผู้อำนวยการฝ่าย</p>
        </div>

        <div class="card" onclick="location.href='${pageContext.request.contextPath}/TechnicalApprove.jsp'">
            <i class="fa-solid fa-screwdriver-wrench"></i>
            <p>ความเห็นและการอนุมัติเชิงเทคนิค</p>
        </div>

        <div class="card" onclick="location.href='${pageContext.request.contextPath}/ITDirectorApprove.jsp'">
            <i class="fa-regular fa-circle-user"></i>
            <p>ผู้อำนวยการฝ่าย<br>เทคโนโลยีสารสนเทศ</p>
        </div>
    </div>

    <script>
        function toggleNav() {
            var sidebar = document.getElementById("mySidebar");
            sidebar.style.width = (sidebar.style.width === "250px") ? "0" : "250px";
        }
    </script>
</body>
</html>