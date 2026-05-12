<%@ page isELIgnored="false" %>
    <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
        <!DOCTYPE html>
        <html lang="th">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>ผู้อำนวยการฝ่ายเทคโนโลยีสารสนเทศ - รายการใบคำขอ</title>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
            <style>
                * {
                    box-sizing: border-box;
                }

                body {
                    font-family: 'Sarabun', sans-serif;
                    margin: 0;
                    padding: 0;
                    background-color: #ffffff;
                }

                .sticky-bar {
                    position: sticky;
                    top: 0;
                    background: white;
                    width: 100%;
                    height: 65px;
                    border-bottom: 5px solid #3272BB;
                    display: flex;
                    align-items: center;
                    padding: 0 15px;
                    z-index: 100;
                }

                .banner {
                    background: #C3EAFF;
                    padding: 20px 10px;
                    text-align: center;
                    color: #003366;
                    border-bottom: 1px solid #ddd;
                }

                .banner h1 {
                    font-size: clamp(16px, 4vw, 22px);
                    margin: 0;
                }

                .banner h2 {
                    font-size: clamp(14px, 3vw, 16px);
                    margin: 5px 0 0;
                    font-weight: normal;
                }

                .list-container {
                    max-width: 1000px;
                    margin: 20px auto;
                    padding: 0 15px;
                }

                .requisition-item {
                    display: flex;
                    align-items: center;
                    border: 2px solid #333;
                    border-radius: 15px;
                    margin-bottom: 15px;
                    padding: 10px;
                    gap: 15px;
                    background: white;
                    transition: 0.2s;
                    cursor: pointer;
                }

                .requisition-item:hover {
                    transform: scale(1.01);
                    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
                    border-color: #3272BB;
                }

                .req-number {
                    background: #f5f5f5;
                    border: 1px solid #333;
                    border-radius: 10px;
                    padding: 10px;
                    min-width: 140px;
                    text-align: center;
                    font-weight: bold;
                    font-size: 14px;
                }

                .req-details {
                    flex-grow: 1;
                    font-size: 14px;
                    line-height: 1.6;
                }

                .req-details b {
                    color: #003366;
                }

                .status-icon {
                    font-size: 30px;
                    padding-right: 10px;
                }

                .status-success {
                    color: #28a745;
                }

                .status-pending {
                    color: #ffc107;
                }

                .back-btn {
                    display: inline-block;
                    margin-bottom: 15px;
                    text-decoration: none;
                    color: #3272BB;
                    font-weight: bold;
                }

                @media (max-width: 600px) {
                    .requisition-item {
                        flex-direction: column;
                        align-items: flex-start;
                    }

                    .req-number {
                        width: 100%;
                    }

                    .status-icon {
                        align-self: flex-end;
                    }
                }
            </style>
        </head>

        <body>

            <div class='sticky-bar'>
                <a href="${pageContext.request.contextPath}/Admin.jsp" style="color:#333; text-decoration:none;">
                    <i class="fa fa-arrow-left" style="font-size:24px;"></i>
                </a>
                <div style="margin-left:auto; display:flex; align-items:center">
                    <p style='font-size: 14px; margin:0;'>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
                    <i class='fa fa-circle-user' style='font-size:24px; margin-left:10px;'></i>
                </div>
            </div>

            <div class="banner">
                <h1>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</h1>
                <h2>ใบขอให้ดำเนินการ / Requisition Form</h2>
            </div>

            <div class="list-container">
                <a href="${pageContext.request.contextPath}/Admin.jsp" class="back-btn">
                    <i class="fa fa-chevron-left"></i> กลับหน้าหลัก
                </a>

                <div class="requisition-item" onclick="location.href='RequisitionDetail_ITDirector.jsp'">
                    <div class="req-number">ใบขอดำเนินการที่ 1</div>
                    <div class="req-details">
                        <b>ชื่อ :</b> ธนภัทร กาญจนรุจิวุฒิ &nbsp;&nbsp; <b>ฝ่าย :</b> บริหารหนี้ 2 &nbsp;&nbsp;
                        <b>ส่วน :</b> ----- &nbsp;&nbsp; <b>Deadline :</b> 16/01/2569<br>
                        <b>รายละเอียด :</b> พัฒนาระบบลงทะเบียนขอผ่อนผันการชำระเงินกองทุน
                        กรณีผู้กู้ยืมเป็นผู้ประสบอุทกภัย
                    </div>
                    <div class="status-icon status-success">
                        <i class="fa-solid fa-circle-check"></i>
                    </div>
                </div>

                <div class="requisition-item" onclick="location.href='RequisitionDetail_ITDirector.jsp'">
                    <div class="req-number">ใบขอดำเนินการที่ 2</div>
                    <div class="req-details">
                        <b>ชื่อ :</b> ธนภัทร กาญจนรุจิวุฒิ &nbsp;&nbsp; <b>ฝ่าย :</b> บริหารหนี้ 2 &nbsp;&nbsp;
                        <b>ส่วน :</b> ----- &nbsp;&nbsp; <b>Deadline :</b> 16/01/2569<br>
                        <b>รายละเอียด :</b> ชื่อหัวข้อความต้องการ
                    </div>
                    <div class="status-icon status-pending">
                        <i class="fa-solid fa-clock-rotate-left"></i>
                    </div>
                </div>

                <div class="requisition-item" onclick="location.href='RequisitionDetail_ITDirector.jsp'">
                    <div class="req-number">ใบขอดำเนินการที่ 3</div>
                    <div class="req-details">
                        <b>รายละเอียด :</b> context (คลิกเพื่อดูรายละเอียดเพิ่มเติม)
                    </div>
                    <div class="status-icon status-success">
                        <i class="fa-solid fa-circle-check"></i>
                    </div>
                </div>

            </div>

        </body>

        </html>