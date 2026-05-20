<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page isELIgnored="false" %>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ส่งคำขอสำเร็จ</title>
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        /* Modern Font Face Linking & Smooth Text Rendering */
        @font-face {
            font-family: 'DBHelvethaica';
            src: url("fonts/DB\ HelvethaicaMon\ X\ Bd\ v3.2.ttf") format('ttf');
            font-weight: normal;
            font-style: normal;
        }

        * {
            box-sizing: border-box;
            transition: all 0.25s ease-in-out;
        }

        body {
            margin: 0;
            padding: 0;
            font-family: 'DBHelvethaica', 'Sarabun', sans-serif;
            background: #f4f8fc; /* Slightly softer tint */
            display: flex;
            flex-direction: column;
            align-items: center;
            min-height: 100vh;
        }

        /* Upgraded Header Top Bar */
        .top-bar {
            width: 100%;
            background: white;
            border-bottom: 5px solid #3272BB; /* Kept your exact 5px brand line */
            display: flex;
            align-items: center;
            padding: 12px 40px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }

        .top-bar img {
            height: 48px; /* Match your main form logo height */
            margin-right: 12px;
        }

        .top-bar .contact-info {
            margin-left: auto;
            display: flex;
            align-items: center;
            gap: 8px;
            color: #003366;
            font-size: 18px;
            font-weight: bold;
        }

        /* Flex container to center card vertically on screen */
        .content-container {
            display: flex;
            flex-content: center;
            align-items: center;
            flex-grow: 1;
            width: 100%;
            padding: 40px 20px;
            justify-content: center;
        }

        /* Modern Success Card styling */
        .success-card {
            background: white;
            padding: 50px 40px;
            border-radius: 20px; /* Matching your main page card borders */
            border: 3px solid #C3EAFF; /* Using your soft blue accent color */
            box-shadow: 0 15px 35px rgba(50, 114, 187, 0.12); /* Clean brand-tinted blur shadow */
            text-align: center;
            max-width: 520px;
            width: 100%;
            animation: cardAppear 0.5s cubic-bezier(0.25, 0.8, 0.25, 1) forwards;
        }

        /* Modern Success Icon Animation */
        .success-card i.main-tick {
            font-size: 80px;
            color: #2e7d32; /* Rich success green */
            background: #e8f5e9;
            padding: 20px;
            border-radius: 50%;
            display: inline-block;
            margin-bottom: 25px;
            animation: scaleIn 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275) 0.2s both;
        }

        .success-card h1 {
            color: #003366;
            font-size: 32px;
            margin: 0 0 15px 0;
            font-weight: bold;
        }

        .success-card p {
            color: #555555;
            font-size: 20px;
            line-height: 1.5;
            margin: 0 0 35px 0;
        }

        /* Responsive Button Group Layout */
        .button-group {
            display: flex;
            gap: 16px;
            justify-content: center;
        }

        .btn {
            padding: 12px 30px;
            border-radius: 10px;
            font-size: 18px;
            font-weight: bold;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            flex: 1; /* Make buttons even width */
            white-space: nowrap;
        }

        /* Primary Button (Fill Theme Color) */
        .btn-primary {
            background: #3272BB;
            color: white;
            box-shadow: 0 4px 12px rgba(50, 114, 187, 0.3);
        }

        .btn-primary:hover {
            background: #003366; /* Changes to darker blue on hover */
            transform: translateY(-3px);
            box-shadow: 0 6px 18px rgba(0, 51, 102, 0.35);
        }

        /* Outline Button */
        .btn-outline {
            background: transparent;
            color: #3272BB;
            border: 2px solid #3272BB;
        }

        .btn-outline:hover {
            background: #f0f6fc;
            color: #003366;
            border-color: #003366;
            transform: translateY(-3px);
        }

        .btn:active {
            transform: translateY(-1px);
        }

        /* Aesthetic Micro-Animations */
        @keyframes cardAppear {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes scaleIn {
            from { transform: scale(0); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
        }

        /* Mobile Responsive View */
        @media (max-width: 480px) {
            .top-bar { padding: 12px 20px; }
            .top-bar .contact-info { display: none; } /* Hide phone info on extra small screens */
            .success-card { padding: 35px 20px; }
            .button-group { flex-direction: column; width: 100%; }
            .btn { width: 100%; }
        }
    </style>
</head>
<body>

<div class="top-bar">
    <img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF Logo">
    <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo">
    <div class="contact-info">
        <i class="fa-solid fa-circle-info"></i>
        <span>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</span>
    </div>
</div>

<div class="content-container">
    <div class="success-card">
        <i class="fa-solid fa-check main-tick"></i>
        <h1>ส่งคำขอเรียบร้อยแล้ว</h1>
        <p>คำขอของคุณถูกบันทึกเข้าสู่ระบบอย่างปลอดภัยแล้ว<br>เจ้าหน้าที่จะดำเนินการตรวจสอบข้อมูลในลำดับถัดไป</p>
        
        <div class="button-group">
            <a href="${pageContext.request.contextPath}/form.jsp" class="btn btn-primary">
                <i class="fa-solid fa-plus"></i> สร้างคำขอใหม่
            </a>
            <a href="${pageContext.request.contextPath}/" class="btn btn-outline">
                <i class="fa-solid fa-house"></i> กลับหน้าหลัก
            </a>
        </div>
    </div>
</div>

</body>
</html>