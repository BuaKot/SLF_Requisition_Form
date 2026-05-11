<%@ page isELIgnored="false" %>
    <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
        <!DOCTYPE html>
        <html lang="th">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>IT Requisition - Admin</title>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

            <style>
                body {
                    font-family: 'Sarabun', sans-serif;
                    margin: 0;
                    padding: 0;
                    background-color: #ffffff;
                    height: 100vh;
                }

                .sticky-bar {
                    position: sticky;
                    top: 0;
                    background: white;
                    width: 100%;
                    height: 70px;
                    border-bottom: 5px solid #3272BB;
                    display: flex;
                    align-items: center;
                    padding: 0 20px;
                    z-index: 100;
                }

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
                    transition: 0.3s;
                }

                .sidebar .closebtn {
                    position: absolute;
                    top: 10px;
                    right: 25px;
                    font-size: 36px;
                }

                .banner {
                    background: #C3EAFF;
                    padding: 40px 20px;
                    text-align: center;
                    color: #003366;
                    display: flex;
                    flex-direction: column;
                    justify-content: center;
                }

                .banner h1 {
                    margin: 0;
                    font-size: 24px;
                }

                .banner h2 {
                    margin: 10px 0 0;
                    font-size: 18px;
                    font-weight: normal;
                }

                .admin-grid {
                    display: flex;
                    flex-wrap: wrap;
                    justify-content: center;
                    gap: 40px;
                    margin-top: 50px;
                    padding: 20px;
                }

                .card {
                    border: solid 2px #3272BB;
                    border-radius: 15px;
                    padding: 30px;
                    text-align: center;
                    cursor: pointer;
                    transition: 0.3s;
                    width: 250px;
                    background: white;
                }

                .card:hover {
                    transform: translateY(-10px);
                    box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
                }

                .card i {
                    font-size: 80px;
                    color: #3272BB;
                    display: block;
                    margin-bottom: 20px;
                }

                .card p {
                    font-weight: bold;
                    font-size: 18px;
                    color: #333;
                    margin: 0;
                }
            </style>
        </head>

        <body>
            <div id="mySidebar" class="sidebar">
                <a href="javascript:void(0)" class="closebtn" onclick="toggleNav()">&times;</a>
                <a href="#"><i class="fa fa-home"></i> หน้าหลัก</a>
                <a href="#"><i class="fa fa-file-alt"></i> รายการคำขอ</a>
                <a href="#"><i class="fa fa-user-cog"></i> ตั้งค่าผู้ใช้งาน</a>
                <a href="#"><i class="fa fa-sign-out-alt"></i> ออกจากระบบ</a>
            </div>

            <div class='sticky-bar'>
                <i id="menuBtn" class="fa fa-bars" onclick="toggleNav()"
                    style="font-size:30px; cursor:pointer; color:#3272BB;"></i>

                <img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF Logo"
                    style="height: 48px; margin-left: 20px;">
                <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo"
                    style="height: 48px; margin-left: 10px;">

                <div style="margin-left:auto; display:flex; align-items:center">
                    <i class='fa fa-circle-user' style='font-size:24px; color:#3272BB;'></i>
                    <p style='margin-left: 10px; font-size: 16px; color:#333;'>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
                </div>
            </div>

            <div class="banner">
                <h1>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</h1>
                <h2>ใบขอให้ดำเนินการ / Requisition Form</h2>
            </div>

            <div class="admin-grid">
                <a href="${pageContext.request.contextPath}/DirectorApprove.jsp" style="text-decoration: none;">
                    <div class="card">
                        <i class="fa-regular fa-circle-user"></i>
                        <p>ผู้อำนวยการฝ่าย</p>
                    </div>
                </a>

                <a href="${pageContext.request.contextPath}/TechnicalApprove.jsp" style="text-decoration: none;">
                    <div class="card">
                        <i class="fa-solid fa-screwdriver-wrench"></i>
                        <p>ความเห็นและการอนุมัติเชิงเทคนิค</p>
                    </div>
                </a>

                <a href="${pageContext.request.contextPath}/ITDirectorApprove.jsp" style="text-decoration: none;">
                    <div class="card">
                        <i class="fa-regular fa-circle-user"></i>
                        <p>ผู้อำนวยการฝ่าย<br>เทคโนโลยีสารสนเทศ</p>
                    </div>
                </a>
            </div>

            <script>
                function toggleNav() {
                    var sidebar = document.getElementById("mySidebar");
                    if (sidebar.style.width === "250px") {
                        sidebar.style.width = "0";
                    } else {
                        sidebar.style.width = "250px";
                    }
                }
            </script>
        </body>

        </html>