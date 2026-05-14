<%@ page isELIgnored="false" %>
    <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
        <!DOCTYPE html>
        <html lang="th">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>ผู้อำนวยการฝ่ายเทคโนโลยีสารสนเทศ - รายการใบคำขอ</title>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
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

                .banner {
                    background: #C3EAFF;
                    padding: clamp(20px, 6vw, 40px) 15px;
                    text-align: center;
                    color: #003366;
                }

                .banner h1 {
                    font-size: clamp(1.1rem, 4vw, 1.5rem);
                    margin: 0;
                    line-height: 1.2;
                }

                .banner h2 {
                    font-size: clamp(0.9rem, 3vw, 1.1rem);
                    margin-top: 10px;
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
                    border: 2px solid #333;
                    border-radius: 12px;
                    padding: 15px 20px;
                    min-width: 200px;
                    text-align: center;
                    font-weight: bold;
                    font-size: 18px;
                    color: #333;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                }

                .req-details {
                    flex-grow: 1;
                    font-size: 16px;
                    line-height: 1.8;
                    padding-left: 10px;
                }

                .req-details b {
                    color: #003366;
                }

                .status-icon {
                    font-size: 40px;
                    padding-right: 15px;
                }

                .status-success {
                    color: #28a745;
                }

                .status-pending {
                    color: #ffc107;
                }

                .back-btn {
                    display: inline-flex;
                    align-items: center;
                    margin-bottom: 20px;
                    text-decoration: none;
                    color: #3272BB;
                    font-weight: bold;
                    font-size: 1.2rem;
                    gap: 10px;
                    transition: 0.3s;
                }

                .back-btn i {
                    font-size: 1.4rem;
                }

                .back-btn:hover {
                    color: #003366;
                    transform: translateX(-5px);
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
                <div class="contact-info" style="margin-left:auto; display:flex; align-items:center">
                    <i class='fa fa-circle-user' style='font-size:1.4rem; color:#333;'></i>
                    <p>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
                </div>
            </div>

            <div class="banner">
                <h1>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</h1>
                <h1>ใบขอให้ดำเนินการ / Requisition Form</h1>
            </div>

            <div class="list-container">
                <a href="${pageContext.request.contextPath}/Admin.jsp" class="back-btn">
                    <i class="fa fa-chevron-left"></i> กลับหน้าหลัก
                </a>

                <div class="requisition-item" onclick="location.href='RequisitionDetail_Process.jsp'">
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

                <div class="requisition-item" onclick="location.href='RequisitionDetail_Process.jsp'">
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

                <div class="requisition-item" onclick="location.href='RequisitionDetail_Process.jsp'">
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