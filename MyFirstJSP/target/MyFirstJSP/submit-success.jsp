<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page isELIgnored="false" %>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <title>ส่งคำขอสำเร็จ</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/form.css">
</head>
<body>
    <div style="text-align:center; margin-top:100px;">
        <h1>ส่งคำขอเรียบร้อยแล้ว</h1>
        <p>คำขอของคุณถูกบันทึกเข้าสู่ระบบ</p>
        <a href="${pageContext.request.contextPath}/newForm">สร้างคำขอใหม่</a> |
        <a href="${pageContext.request.contextPath}/">กลับหน้าหลัก</a>
    </div>
</body>
</html>