<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String id = request.getParameter("id");

    /* MOCK DATA ก่อน (ยังไม่ใช้ DB) */
    String fullName = "";
    String division = "";
    String department = "";
    String phone = "";
    String requestDate = "";
    String requestType = "";
    String requestTitle = "";
    String dueDate = "";
    String priorityType = "";
    String programName = "";
    String objective = "";
    String currentProcess = "";

    if(id != null){
        switch(id){
            case "1":
                fullName = "ธนภัทร กาญจนรุจิวุฒิ";
                division = "บริหารหนี้ 2";
                department = "ฝ่ายบริหารหนี้";
                phone = "411";
                requestDate = "2026-05-11";
                requestType = "พัฒนาโปรแกรมใหม่";
                requestTitle = "ระบบลงทะเบียนขอผ่อนผันการชำระเงินกองทุน";
                dueDate = "16/01/2569 (X วัน)";
                priorityType = "เร่งด่วน";
                programName = "SLF-Relief System";
                objective = "เพื่อช่วยเหลือกองทุนเงินให้กู้ยืมเพื่อการศึกษา กรณีผู้กู้ยืมเป็นผู้ประสบอุทกภัย...";
                currentProcess = "ปัจจุบันดำเนินการผ่านระบบ Manual และบันทึกใน Excel...";
                break;

            case "2":
                fullName = "สมชาย ใจดี";
                division = "เทคโนโลยีสารสนเทศ";
                department = "ฝ่าย IT";
                phone = "422";
                requestDate = "2026-05-10";
                requestType = "ปรับปรุงระบบ";
                requestTitle = "ระบบจัดการข้อมูลนักศึกษา";
                dueDate = "20/01/2569 (X วัน)";
                priorityType = "ปกติ";
                programName = "Student Data";
                objective = "เพื่อเพิ่มประสิทธิภาพการจัดเก็บข้อมูล...";
                currentProcess = "ใช้ระบบเดิมที่ล่าช้า...";
                break;

            default:
                fullName = "ไม่พบข้อมูล";
        }
    }
%>

<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>รายละเอียดใบขอให้ดำเนินการ</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

    <style>
        * {
            box-sizing: border-box;
            font-family: 'Sarabun', sans-serif;
        }

        body {
            margin: 0;
            background-color: #f0f0f0;
        }

        /* Header */
        .sticky-bar {
            position: sticky;
            top: 0;
            background: white;
            height: 60px;
            border-bottom: 4px solid #3272BB;
            display: flex;
            align-items: center;
            padding: 0 20px;
            z-index: 1000;
        }

        .sticky-bar a {
            text-decoration: none;
            color: black;
            font-size: 18px;
            font-weight: bold;
        }

        /* Banner */
        .banner {
            background: #d9f1ff;
            text-align: center;
            padding: 15px;
        }

        .banner h1, .banner h2 {
            margin: 5px 0;
            color: #003366;
        }

        /* Main Form */
        .form-container {
            width: 95%;
            max-width: 1200px;
            margin: 20px auto;
            background: #e9e9e9;
            padding: 25px;
            border-radius: 10px;
        }

        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 25px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }

        label {
            font-weight: bold;
            margin-bottom: 8px;
            font-size: 16px;
        }

        input, select, textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #3272BB;
            border-radius: 8px;
            font-size: 16px;
            background: white;
        }

        textarea {
            resize: none;
        }

        .full-width {
            grid-column: span 2;
        }

        .section-box {
            border: 2px solid #3272BB;
            border-radius: 15px;
            padding: 20px;
            grid-column: span 2;
        }

        /* Buttons */
        .btn-group {
            display: flex;
            justify-content: center;
            gap: 25px;
            margin-top: 30px;
        }

        .btn {
            padding: 14px 50px;
            border: none;
            border-radius: 8px;
            color: white;
            font-size: 22px;
            font-weight: bold;
            cursor: pointer;
        }

        .btn-back {
            background: #d50000;
        }

        .btn-approve {
            background: #00b050;
        }

        .btn:hover {
            opacity: 0.85;
        }

        @media(max-width: 768px){
            .form-grid {
                grid-template-columns: 1fr;
            }

            .full-width,
            .section-box {
                grid-column: span 1;
            }
        }
    </style>
</head>
<body>

<!-- Header -->
<div class="sticky-bar">
    <a href="submit.jsp">
        <i class="fa fa-arrow-left"></i> กลับ
    </a>

    <div style="margin-left:auto; display:flex; align-items:center;">
        <span style="margin-right:10px;">สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</span>
        <i class="fa fa-circle-user" style="font-size:24px;"></i>
    </div>
</div>

<!-- Banner -->
<div class="banner">
    <h1>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</h1>
    <h2>ใบขอให้ดำเนินการ / Requisition Form</h2>
</div>

<!-- Form -->
<div class="form-container">
    <form>
        <div class="form-grid">

            <div class="form-group">
                <label>ชื่อ-นามสกุล</label>
                <input type="text" value="<%= fullName %>" readonly>
            </div>

            <div class="form-group">
                <label>ส่วน</label>
                <input type="text" value="<%= division %>" readonly>
            </div>

            <div class="form-group">
                <label>ฝ่าย</label>
                <input type="text" value="<%= department %>" readonly>
            </div>

            <div class="form-group">
                <label>เบอร์ต่อ</label>
                <input type="text" value="<%= phone %>" readonly>
            </div>

            <div class="form-group">
                <label>วันที่</label>
                <input type="date" value="<%= requestDate %>" readonly>
            </div>

            <div class="form-group">
                <label>ความต้องการ</label>
                <select disabled>
                    <option><%= requestType %></option>
                </select>
            </div>

            <!-- Blue Box -->
            <div class="section-box">
                <div class="form-group" style="margin-bottom:20px;">
                    <label>ชื่อหัวข้อความต้องการ :</label>
                    <input type="text" value="<%= requestTitle %>" readonly>
                </div>

                <div class="form-group">
                    <label>ภายในวันที่ :</label>
                    <input type="text" value="<%= dueDate %>" readonly>
                </div>
            </div>

            <div class="form-group">
                <label>ประเภทคำขอ</label>
                <select disabled>
                    <option><%= priorityType %></option>
                </select>
            </div>

            <div class="form-group">
                <label>ชื่อโปรแกรม (ถ้ามี)</label>
                <input type="text" value="<%= programName %>" readonly>
            </div>

            <div class="form-group full-width">
                <label>วัตถุประสงค์ / ความต้องการ</label>
                <textarea rows="4" readonly><%= objective %></textarea>
            </div>

            <div class="form-group full-width">
                <label>วิธีการดำเนินการปัจจุบัน</label>
                <textarea rows="4" readonly><%= currentProcess %></textarea>
            </div>

        </div>
    </form>
</div>

</body>
</html>