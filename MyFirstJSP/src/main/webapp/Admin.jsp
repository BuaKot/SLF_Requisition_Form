<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%!
    // Keep this if you want, or remove it.
    public String escapeHtml(Object input) {
        if (input == null) return "";
        String str = String.valueOf(input);
        return str.replace("&", "&amp;")
                  .replace("<", "&lt;")
                  .replace(">", "&gt;")
                  .replace("\"", "&quot;")
                  .replace("'", "&#x27;")
                  .replace("/", "&#x2F;");
    }
%>

<%
    String currentRole = (String) session.getAttribute("position");
    String employeeName = (String) session.getAttribute("loggedInEmpName");

    if (currentRole == null || employeeName == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="th">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IT Requisition - Admin Database Authentication</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">

    <style>
        * { box-sizing: border-box; }
        body {
            font-family: 'Sarabun', sans-serif;
            margin: 0; padding: 0; background-color: #ffffff;
            overflow-x: hidden; display: flex; flex-direction: column; min-height: 100vh;
        }
        .banner { background: #C3EAFF; padding: clamp(20px, 6vw, 40px) 15px; text-align: center; color: #003366; }
        .banner h1 { font-size: clamp(1.1rem, 4vw, 1.5rem); margin: 0; line-height: 1.2; }
        .admin-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 25px; padding: 40px 20px; max-width: 1400px; margin: 0 auto; width: 100%; }
        .card {
            background: white; border: 3px solid #3272BB; border-radius: 20px; padding: 30px 15px; text-align: center; cursor: pointer;
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1); display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 300px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
        }
        .card:hover { transform: translateY(-10px); box-shadow: 0 15px 30px rgba(50, 114, 187, 0.2); border-color: #003366; }
        .card:active { transform: translateY(-2px); box-shadow: 0 5px 10px rgba(50, 114, 187, 0.1); }
        .card:hover i { color: #003366; transform: scale(1.1); transition: all 0.3s ease; }
        .card i { font-size: 90px; color: #3272BB; margin-bottom: 20px; transition: all 0.3s ease; }
        .card p { font-weight: bold; font-size: 20px; color: #003366; margin: 0; line-height: 1.3; }
        
        .user-badge { background-color: #3272BB; color: white; padding: 8px 15px; border-radius: 20px; display: inline-block; margin-top: 10px; font-size: 0.9rem; }
        .role-badge { background-color: #2ecc71; color: white; padding: 4px 10px; border-radius: 10px; font-weight: bold; margin-left: 5px; }
        @media (max-width: 400px) { .admin-grid { grid-template-columns: 1fr; padding: 20px 15px; } .card { min-height: 250px; } .sidebar { width: 0; } }
    </style>
</head>

<body>
    <div id="mySidebar" class="sidebar">
        <a href="javascript:void(0)" class="closebtn" onclick="toggleNav()">&times;</a>
        <a href="${pageContext.request.contextPath}"><i class="fa-solid fa-house" style='margin-right: 10px'></i>หน้าหลัก</a>
        <a href="${pageContext.request.contextPath}/newForm"><i class="fa-solid fa-plus" style='margin-right: 10px'></i>สร้างฟอร์มใหม่</a>
        <a href="${pageContext.request.contextPath}/submit.jsp"><i class="fa-solid fa-paper-plane" style='margin-right: 10px'></i>ฟอร์มที่ส่งแล้ว</a>
        <a href="${pageContext.request.contextPath}/logout"><i class="fa-solid fa-arrow-right-from-bracket" style='margin-right: 10px'></i>ออกจากระบบ</a>
        <a href="${pageContext.request.contextPath}/Admin.jsp" class="admin-tab">
            <i class="fa-solid fa-circle-user"></i>Admin
        </a>    
    </div>

<div id='main'>
    <div class="sticky-bar">
        <i id="menuBtn" class="fa-solid fa-bars" onclick="toggleNav()"></i>
        <img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF Logo">
        <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo">
        
        <div class="user-info">
            <i class="fa fa-circle-user"></i>
            <p>
                ${sessionScope.loggedInEmpName} | ID: ${sessionScope.loggedInEmpId}
            </p>
        </div>
        <div class="contact-info">
            <i class="fa-solid fa-circle-info"></i>
            <p>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
        </div>
        
    </div>

    <div class="banner">
        <h1>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</h1>
        <h1>ใบขอให้ดำเนินการ / Requisition Form</h1>
        <div class="user-badge">
            สิทธิ์การใช้งานจริงจากฐานข้อมูล: <span class="role-badge"><%= escapeHtml(currentRole) %></span>
        </div>
    </div>

    <div class="admin-grid">
        
        <% if (currentRole.equalsIgnoreCase("Admin") || currentRole.equalsIgnoreCase("Director")) { %>
            <div class="card" onclick="location.href='${pageContext.request.contextPath}/DirectorApprove.jsp'">
                <i class="fa-regular fa-circle-user"></i>
                <p>ผู้อำนวยการฝ่าย</p>
            </div>
        <% } %>

        <% if (currentRole.equalsIgnoreCase("Admin") || currentRole.equalsIgnoreCase("Technical")) { %>
            <div class="card" onclick="location.href='${pageContext.request.contextPath}/TechnicalApprove.jsp'">
                <i class="fa-solid fa-screwdriver-wrench"></i>
                <p>ความเห็นและการอนุมัติเชิงเทคนิค</p>
            </div>
        <% } %>

        <% if (currentRole.equalsIgnoreCase("Admin") || currentRole.equalsIgnoreCase("ITDirector")) { %>
            <div class="card" onclick="location.href='${pageContext.request.contextPath}/ITDirectorApprove.jsp'">
                <i class="fa-solid fa-user-gear"></i>
                <p>ผู้อำนวยการฝ่าย<br>เทคโนโลยีสารสนเทศ</p>
            </div>
        <% } %>

        <% 
            if (currentRole.equalsIgnoreCase("Admin") || 
                currentRole.equalsIgnoreCase("Technical") || 
                currentRole.equalsIgnoreCase("Development") || 
                currentRole.equalsIgnoreCase("Data") || 
                currentRole.equalsIgnoreCase("Infrastructure") || 
                currentRole.equalsIgnoreCase("Cyber Security") || 
                currentRole.equalsIgnoreCase("Reseach") || 
                currentRole.equalsIgnoreCase("IT Planning")) { 
        %>
            <div class="card" onclick="location.href='${pageContext.request.contextPath}/Process.jsp'">
                <i class="fa-solid fa-bars-progress"></i>
                <p>รายละเอียดการดำเนินการ</p>
            </div>
        <% } %>
        
    </div>
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