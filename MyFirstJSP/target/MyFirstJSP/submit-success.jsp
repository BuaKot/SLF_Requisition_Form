<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page isELIgnored="false" %>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <title>ส่งคำขอสำเร็จ</title>
    <!-- Reuse your existing styles if needed, else keep it self-contained -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        body {
            margin: 0;
            font-family: 'Sarabun', 'Noto Sans Thai', sans-serif;
            background: #f0f4f8;
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        .top-bar {
            width: 100%;
            background: white;
            border-bottom: 3px solid #3272BB;
            display: flex;
            align-items: center;
            padding: 10px 20px;
        }
        .top-bar img {
            height: 40px;
            margin-right: 10px;
        }
        .success-card {
            background: white;
            margin-top: 60px;
            padding: 40px 30px;
            border-radius: 12px;
            box-shadow: 0 6px 20px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 480px;
            width: 90%;
        }
        .success-card i {
            font-size: 64px;
            color: #2e7d32;
            margin-bottom: 20px;
        }
        .success-card h1 {
            color: #003366;
            margin: 0 0 10px 0;
        }
        .success-card p {
            color: #444;
            margin-bottom: 30px;
        }
        .button-group {
            display: flex;
            gap: 15px;
            justify-content: center;
            flex-wrap: wrap;
        }
        .btn {
            padding: 12px 28px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
        }
        .btn-primary {
            background: #003366;
            color: white;
        }
        .btn-primary:hover { background: #005599; }
        .btn-outline {
            background: white;
            color: #003366;
            border: 2px solid #003366;
        }
        .btn-outline:hover { background: #f0f8ff; }
    </style>
</head>
<body>

<!-- Simple header bar with logos (optional, but makes it feel part of the same system) -->
<div class="top-bar">
    <img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF">
    <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF">
    <span style="margin-left:auto; font-size:14px; color:#555;">สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</span>
</div>

<div class="success-card">
    <i class="fa-regular fa-circle-check"></i>  <!-- Font Awesome tick -->
    <h1>ส่งคำขอเรียบร้อยแล้ว</h1>
    <p>คำขอของคุณถูกบันทึกเข้าสู่ระบบแล้ว<br>เจ้าหน้าที่จะดำเนินการตรวจสอบในลำดับถัดไป</p>
    <div class="button-group">
        <a href="${pageContext.request.contextPath}/newForm" class="btn btn-primary">
            <i class="fa fa-plus"></i> สร้างคำขอใหม่
        </a>
        <a href="${pageContext.request.contextPath}/" class="btn btn-outline">
            <i class="fa fa-home"></i> กลับหน้าหลัก
        </a>
    </div>
</div>

</body>
</html>