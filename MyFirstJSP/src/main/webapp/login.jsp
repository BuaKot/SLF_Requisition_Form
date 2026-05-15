<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>เข้าสู่ระบบ</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        body {
            font-family: 'Sarabun', sans-serif;
            background-color: #f4f6f9;
            margin: 0;
            padding: 0;
        }
        .login-container {
            max-width: 500px;
            margin: 80px auto;
            background: white;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            text-align: center;
        }
        .login-container h1 {
            margin-bottom: 20px;
            color: #003366;
        }
        .login-container select {
            width: 100%;
            padding: 12px;
            font-size: 16px;
            border: 1px solid #ccc;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        .login-container button {
            background-color: #003366;
            color: white;
            border: none;
            padding: 12px 30px;
            font-size: 16px;
            border-radius: 4px;
            cursor: pointer;
        }
        .login-container button:hover {
            background-color: #0055a5;
        }
    </style>
</head>
<body>

<div class="blue-title">
    <h1 style='margin-block-start: 0.1em; margin-block-end: 0.1em;color:#003366;'>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินกู้ยืมเพื่อการศึกษา</h1>
    <h2 style='margin-block-start: 0.1em; margin-block-end: 0.1em;color:#003366;'>ใบขอให้ดำเนินการ / Requisition Form</h2>
</div>

<div class="login-container">
    <h1><i class="fa fa-sign-in"></i> เข้าสู่ระบบ</h1>
    <p>กรุณาเลือกชื่อของท่านจากรายการ</p>
    <form action="${pageContext.request.contextPath}/processLogin" method="post">
        <select name="empId" required>
            <option value="" disabled selected hidden>-- โปรดเลือก --</option>
            <c:forEach var="emp" items="${employees}">
                <option value="${emp.empId}">${emp.empName} (${emp.position})</option>
            </c:forEach>
        </select>
        <br>
        <button type="submit">เข้าสู่ระบบ</button>
    </form>
    <p style="margin-top:20px; font-size:0.9em;">สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
</div>

</body>
</html>