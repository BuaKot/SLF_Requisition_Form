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

        /* Banner - ปรับตัวหนังสือให้สมดุล */
        .banner {
            background: #C3EAFF;
            padding: clamp(20px, 6vw, 40px) 15px;
            text-align: center;
            color: #003366;
        }

        .banner h1 { font-size: clamp(1.1rem, 4vw, 1.5rem); margin: 0; line-height: 1.2; }
        .banner h2 { font-size: clamp(0.9rem, 3vw, 1.1rem); margin-top: 10px; font-weight: normal; }

<<<<<<< HEAD
        /* Grid System - Responsive หัวใจสำคัญ */
        .admin-grid {
            display: grid;
            /* ปรับขนาดกล่องขั้นต่ำเป็น 260px เพื่อให้ลงตัวในมือถือส่วนใหญ่ */
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); 
            gap: clamp(15px, 4vw, 30px);
            padding: 30px 20px;
            max-width: 1100px;
=======
        /* Grid System - 2x2 layout */
        .admin-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: clamp(15px, 3vw, 25px);
            padding: clamp(20px, 4vw, 40px);
            max-width: 750px;
>>>>>>> a53e7a274200e1946f38236140b633bbc646deb4
            margin: 0 auto;
            width: 100%;
        }

<<<<<<< HEAD
        /* Card Design - ปรับขนาด Icons และ Padding */
=======
        /* Card Design */
>>>>>>> a53e7a274200e1946f38236140b633bbc646deb4
        .card {
            background: white;
            border: 3px solid #3272BB;
            border-radius: 20px;
<<<<<<< HEAD
            padding: clamp(20px, 5vw, 40px);
=======
            padding: clamp(20px, 4vw, 35px);
>>>>>>> a53e7a274200e1946f38236140b633bbc646deb4
            text-align: center;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
<<<<<<< HEAD
            min-height: clamp(280px, 50vh, 360px);
=======
            min-height: clamp(220px, 30vh, 280px);
>>>>>>> a53e7a274200e1946f38236140b633bbc646deb4
        }

        .card:hover {
            background-color: #f8fcff;
<<<<<<< HEAD
            transform: translateY(-8px);
=======
            transform: translateY(-6px);
>>>>>>> a53e7a274200e1946f38236140b633bbc646deb4
            box-shadow: 0 12px 24px rgba(50, 114, 187, 0.15);
        }

        .card i {
<<<<<<< HEAD
            font-size: clamp(60px, 15vw, 90px);
            color: #3272BB;
            margin-bottom: 20px;
=======
            font-size: clamp(50px, 10vw, 75px);
            color: #3272BB;
            margin-bottom: 16px;
>>>>>>> a53e7a274200e1946f38236140b633bbc646deb4
        }

        .card p {
            font-weight: bold;
<<<<<<< HEAD
            font-size: clamp(1rem, 2.5vw, 1.2rem);
            color: #333;
            margin: 0;
            line-height: 1.3;
        }

        /* ปรับแต่งส่วนติดต่อ */
        .contact-info p { margin: 0; white-space: nowrap; }

        /* Media Query สำหรับหน้าจอจิ๋ว */
        @media (max-width: 400px) {
            .admin-grid { grid-template-columns: 1fr; padding: 20px 15px; }
            .card { min-height: 250px; }
            .sidebar { width: 0; } /* ปรับ JavaScript คุม width แทน */
=======
            font-size: clamp(0.9rem, 2vw, 1.1rem);
            color: #333;
            margin: 0;
            line-height: 1.4;
        }

        .contact-info p { margin: 0; white-space: nowrap; }

        @media (max-width: 500px) {
            .admin-grid { grid-template-columns: 1fr; padding: 20px 15px; }
            .card { min-height: 200px; }
>>>>>>> a53e7a274200e1946f38236140b633bbc646deb4
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
<<<<<<< HEAD
=======

        <div class="card" onclick="location.href='${pageContext.request.contextPath}/OperationDetail.jsp'">
            <i class="fa-solid fa-screwdriver-wrench"></i>
            <p>รายละเอียดการดำเนินการ</p>
        </div>
>>>>>>> a53e7a274200e1946f38236140b633bbc646deb4
    </div>

    <script>
        function toggleNav() {
            var sidebar = document.getElementById("mySidebar");
            // ใช้คำนวณหน้าจอเบื้องต้น ถ้าจอมือถือเล็กให้กว้างขึ้น
            var openWidth = (window.innerWidth < 400) ? "80%" : "250px";
            sidebar.style.width = (sidebar.style.width === openWidth) ? "0" : openWidth;
        }

        // ปิด Sidebar เมื่อคลิกข้างนอก
        window.onclick = function(event) {
            var sidebar = document.getElementById("mySidebar");
            if (event.target == sidebar) {
                sidebar.style.width = "0";
            }
        }
    </script>
</body>
</html>