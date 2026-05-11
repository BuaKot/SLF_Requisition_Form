<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IT Requisition - Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body>

    <nav id="mySidebar" class="sidebar">
        <a href="javascript:void(0)" class="closebtn" onclick="toggleNav()">&times;</a>
        <a href="${pageContext.request.contextPath}/index.jsp"><i class="fa fa-home"></i> Home</a>
        <a href="#"><i class="fa fa-history"></i> ประวัติรายการ</a>
        <div class="sidebar-footer">
            <a href="#"><i class="fa fa-sign-out-alt"></i> ออกจากระบบ</a>
        </div>
    </nav>

    <div id="main">
        <header class="sticky-bar">
            <i class="fa fa-bars" onclick="toggleNav()" style="font-size:28px; cursor:pointer;"></i>
            
            <img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF Logo" style="height: 48px; margin-left: 15px;">
            <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo" style="height: 48px; margin-left: 10px;">
            
            <div class="user-info">
                <span>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</span>
                <i class="fa-solid fa-circle-user" style="font-size: 28px; color: #666;"></i>
            </div>
        </header>

        <div class="blue-title">
            <h1>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</h1>
            <h2>ใบขอให้ดำเนินการ / Requisition Form</h2>
        </div>

        <div class="admin-container">
            <div class="admin-card" onclick="location.href='approve_dept.jsp'">
                <i class="fa-regular fa-circle-user"></i>
                <p>ผู้อำนวยการฝ่าย</p>
            </div>

            <div class="admin-card" onclick="location.href='it_review.jsp'">
                <div class="icon-stack">
                    <i class="fa-solid fa-window-maximize"></i>
                    <i class="fa-solid fa-wrench sub-icon"></i>
                </div>
                <p>ความเห็นและการอนุมัติเชิงเทคนิค</p>
            </div>

            <div class="admin-card" onclick="location.href='approve_final.jsp'">
                <i class="fa-regular fa-circle-user"></i>
                <p>ผู้อำนวยการฝ่าย<br>เทคโนโลยีสารสนเทศ</p>
            </div>
        </div>
    </div>

    <script>
        function toggleNav() {
            var sidebar = document.getElementById("mySidebar");
            var main = document.getElementById("main");
            if (sidebar.style.width === "250px") {
                sidebar.style.width = "0";
                main.style.marginLeft = "0";
            } else {
                sidebar.style.width = "250px";
                main.style.marginLeft = "250px";
            }
        }
    </script>
</body>
</html>