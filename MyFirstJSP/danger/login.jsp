<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>เข้าสู่ระบบพนักงาน</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    
    <style>
        * { box-sizing: border-box; }
        body { font-family: 'Sarabun', sans-serif; background-color: #f4f7f6; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .login-box { background: white; border: 3px solid #3272BB; border-radius: 20px; padding: 40px 30px; width: 100%; max-width: 400px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); text-align: center; }
        .login-box h2 { color: #003366; margin-bottom: 25px; font-size: 1.6rem; }
        .input-group { margin-bottom: 20px; text-align: left; }
        .input-group label { display: block; font-weight: bold; color: #003366; margin-bottom: 5px; }
        .input-group input { width: 100%; padding: 12px; border: 2px solid #3272BB; border-radius: 10px; font-size: 1rem; outline: none; }
        .input-group input:focus { border-color: #003366; }
        .btn-login { width: 100%; background: #3272BB; color: white; border: none; padding: 12px; border-radius: 10px; font-size: 1.1rem; font-weight: bold; cursor: pointer; transition: 0.2s; }
        .btn-login:hover { background: #003366; }
        .error-msg { color: #e74c3c; margin-bottom: 15px; font-weight: bold; }
    </style>
</head>
<body>

    <div class="login-box">
        <h2><i class="fa-solid fa-lock" style="color:#3272BB; margin-right:10px;"></i>เข้าสู่ระบบพนักงาน</h2>
        
        <% if (request.getParameter("error") != null) { %>
            <div class="error-msg">รหัสพนักงานหรือรหัสแผนกไม่ถูกต้อง</div>
        <% } %>

        <form action="authen.jsp" method="POST">
            <div class="input-group">
                <label>รหัสพนักงาน (EMPID)</label>
                <input type="text" name="EMPID" required placeholder="กรอกรหัสพนักงาน">
            </div>
            <div class="input-group">
                <label>รหัสแผนก (SECID)</label>
                <input type="password" name="SECID" required placeholder="กรอกรหัสแผนก">
            </div>
            <button type="submit" class="btn-login">เข้าสู่ระบบ</button>
        </form>
    </div>

</body>
</html>