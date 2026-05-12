<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="th">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IT Requisition - Admin (Responsive)</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    
    <style>
        * { box-sizing: border-box; }

        body {
            font-family: 'Sarabun', sans-serif;
            margin: 0;
            padding: 0;
            background-color: #ffffff;
            overflow-x: hidden;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
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

        .header-logos { 
            display: flex; 
            align-items: center; 
            gap: clamp(5px, 2vw, 20px); 
            margin-left: 15px;
        }
        .header-logos img { height: clamp(30px, 8vw, 45px); }

        /* Sidebar - ปรับให้ยืดหยุ่นตามหน้าจอ */
        .sidebar {
            height: 100%;
            width: 0;
            position: fixed;
            z-index: 1001;
            top: 0;
            left: 0;
            background-color: #3272BB;
            overflow-x: hidden;
            transition: 0.4s;
            padding-top: 60px;
            box-shadow: 2px 0 10px rgba(0,0,0,0.2);
        }

        .sidebar a {
            padding: 15px 32px;
            text-decoration: none;
            font-size: 1.2rem;
            color: white;
            display: block;
            white-space: nowrap;
            transition: 0.2s;
        }

        .sidebar a:hover { background: rgba(255,255,255,0.1); }

        /* Banner - ปรับตัวหนังสือ */
        .banner {
            background: #C3EAFF;
            padding: clamp(20px, 6vw, 40px) 15px;
            text-align: center;
            color: #003366;
        }

        .banner h1 { font-size: clamp(1.1rem, 4vw, 1.5rem); margin: 0; line-height: 1.2; }
        .banner h2 { font-size: clamp(0.9rem, 3vw, 1.1rem); margin-top: 10px; font-weight: normal; }

        /* Grid System - Responsive */
        .admin-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); 
            gap: 20px;
            padding: 40px 20px;
            max-width: 1300px;
            margin: 0 auto;
        }

        /* Card Design */
        .card {
            background: white;
            border: 3px solid #3272BB;
            border-radius: 20px;
            padding: 30px 15px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            background-color: #f8fcff;
            transform: translateY(-8px);
            box-shadow: 0 12px 24px rgba(50, 114, 187, 0.15);
        }

        .card i {
            font-size: clamp(60px, 15vw, 90px);
            color: #3272BB;
            margin-bottom: 20px;
        }

        .card p {
            font-weight: bold;
            font-size: clamp(1rem, 2.5vw, 1.2rem);
            color: #333;
            margin: 0;
            line-height: 1.3;
        }

        .contact-info p { margin: 0; white-space: nowrap; }

        @media (max-width: 400px) {
            .admin-grid { grid-template-columns: 1fr; padding: 20px 15px; }
            .card { min-height: 250px; }
            .sidebar { width: 0; } 
        }
    </style>
</head>

<body>
    <div id="mySidebar" class="sidebar">
        <a href="javascript:void(0)" style="font-size:2.5rem; padding: 0 20px;" onclick="toggleNav()">&times;</a>
        <a href="#"><i class="fa fa-home"></i> หน้าหลัก</a>
        <a href="#"><i class="fa fa-history"></i> ประวัติรายการ</a>
        <a href="#"><i class="fa fa-info-circle"></i> ช่วยเหลือ</a>
    </div>

    <div class='sticky-bar'>
        <i class="fa fa-bars" onclick="toggleNav()" style="font-size:1.8rem; cursor:pointer; color:#333; padding: 10px;"></i>
        <div class="header-logos">
            <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo">
            <img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF Logo">
        </div>
        <div class="contact-info" style="margin-left:auto; display:flex; align-items:center">
            <i class='fa fa-circle-user' style='font-size:1.4rem; color:#333;'></i>
            <p style='margin-left: 8px; font-size: 0.9rem;'>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
        </div>
    </div>

    <div class="banner">
        <h1>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</h1>
        <h1>ใบขอให้ดำเนินการ / Requisition Form</h1>
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

        <div class="card" onclick="location.href='${pageContext.request.contextPath}/Process.jsp'">
            <i class="fa-regular fa-circle-user"></i>
            <p>รายละเอียดการดำเนินการ</p>
        </div>
    </div>

    <script>
        function toggleNav() {
            var sidebar = document.getElementById("mySidebar");
            var openWidth = (window.innerWidth < 400) ? "80%" : "250px";
            sidebar.style.width = (sidebar.style.width === openWidth) ? "0" : openWidth;
        }


        window.onclick = function(event) {
            var sidebar = document.getElementById("mySidebar");
            if (event.target == sidebar) {
                sidebar.style.width = "0";
            }
        }
    </script>
</body>
</html>