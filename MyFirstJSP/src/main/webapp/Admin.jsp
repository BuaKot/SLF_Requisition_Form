<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="th">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IT Requisition - Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Sarabun:wght@300;400;700&display=swap" rel="stylesheet">

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            font-family: 'Sarabun', sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f7f9;
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
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }

        .header-logos {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-left: 15px;
        }

        .header-logos img {
            height: clamp(30px, 8vw, 45px);
        }

        .contact-info {
            margin-left: auto;
            display: flex;
            align-items: center;
            color: #333;
        }

        /* Sidebar */
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
        }

        .sidebar a {
            padding: 15px 32px;
            text-decoration: none;
            font-size: 1.1rem;
            color: white;
            display: block;
            transition: 0.3s;
        }

        .sidebar a:hover {
            background: rgba(255, 255, 255, 0.1);
        }

        /* Banner */
        .banner {
            background: #C3EAFF;
            padding: 30px 15px;
            text-align: center;
            color: #003366;
        }

        .banner h1 {
            font-size: clamp(1.2rem, 4vw, 1.8rem);
            margin: 5px 0;
        }

        /* Grid System */
        .admin-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 25px;
            padding: 40px 20px;
            max-width: 1000px;
            margin: 0 auto;
            width: 100%;
        }

        /* Card Design */
        .card {
            background: white;
            border: 2px solid #3272BB;
            border-radius: 15px;
            padding: 35px 20px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 250px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.05);
        }

        .card:hover {
            transform: translateY(-8px);
            box-shadow: 0 12px 20px rgba(50, 114, 187, 0.2);
            background-color: #fdfdfd;
        }

        .card i {
            font-size: 60px;
            color: #3272BB;
            margin-bottom: 20px;
        }

        .card p {
            font-weight: bold;
            font-size: 1.1rem;
            color: #333;
            margin: 0;
            line-height: 1.4;
        }

        @media (max-width: 600px) {
            .contact-info p {
                display: none; /* ซ่อนข้อความในมือถือเพื่อไม่ให้เบียดโลโก้ */
            }
            .admin-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>

<body>
    <div id="mySidebar" class="sidebar">
        <a href="javascript:void(0)" style="font-size:2.5rem; position:absolute; top:10px; right:25px;" onclick="toggleNav()">&times;</a>
        <a href="#"><i class="fa fa-home"></i> หน้าหลัก</a>
        <a href="#"><i class="fa fa-history"></i> ประวัติรายการ</a>
        <a href="#"><i class="fa fa-info-circle"></i> ช่วยเหลือ</a>
    </div>

    <div class='sticky-bar'>
        <i class="fa fa-bars" onclick="toggleNav()" style="font-size:1.5rem; cursor:pointer; color:#333; padding: 10px;"></i>
        <div class="header-logos">
            <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo">
            <img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF Logo">
        </div>
        <div class="contact-info">
            <i class='fa fa-circle-user' style='font-size:1.4rem; margin-right: 8px;'></i>
            <p style='font-size: 0.9rem;'>สอบถามเพิ่มเติม ติดต่อ 411</p>
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

        <div class="card" onclick="location.href='${pageContext.request.contextPath}/OperationDetail.jsp'">
            <i class="fa-solid fa-screwdriver-wrench"></i>
            <p>รายละเอียดการดำเนินการ</p>
        </div>
    </div>

    <script>
        function toggleNav() {
            var sidebar = document.getElementById("mySidebar");
            if (sidebar.style.width === "250px" || sidebar.style.width === "80%") {
                sidebar.style.width = "0";
            } else {
                sidebar.style.width = (window.innerWidth < 500) ? "80%" : "250px";
            }
        }
    </script>
</body>
</html>