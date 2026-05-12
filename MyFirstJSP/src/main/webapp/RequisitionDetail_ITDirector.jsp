<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>รายละเอียดใบขอให้ดำเนินการ</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        * { box-sizing: border-box; }
        body { font-family: 'Sarabun', sans-serif; margin: 0; background-color: #f4f7f9; }

        /* Header Bar */
        .sticky-bar {
            position: sticky; top: 0; background: white; height: 60px;
            border-bottom: 4px solid #3272BB; display: flex; align-items: center;
            padding: 0 20px; z-index: 1000;
        }

        /* Banner */
        .banner {
            background: #C3EAFF; padding: 15px; text-align: center; color: #003366;
            border-bottom: 1px solid #b2d8ed;
        }
        .banner h1 { font-size: 1.2rem; margin: 0; }
        .banner h2 { font-size: 1rem; margin: 5px 0 0; font-weight: normal; }

        /* Form Container */
        .form-container {
            max-width: 900px; margin: 20px auto; background: white;
            padding: 30px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.05);
        }

        /* Grid System สำหรับฟอร์ม */
        .form-grid {
            display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px;
        }

        .form-group { display: flex; flex-direction: column; }
        .form-group label { font-weight: bold; margin-bottom: 8px; font-size: 0.9rem; color: #333; }
        
        .form-group input, .form-group select, .form-group textarea {
            padding: 10px; border: 1px solid #3272BB; border-radius: 5px; font-size: 14px;
        }

        .full-width { grid-column: span 2; }

        /* Section Box (ช่องสีน้ำเงินรอบหัวข้อความต้องการ) */
        .section-box {
            border: 2px solid #3272BB; border-radius: 10px; padding: 20px; margin-bottom: 25px;
        }

        /* Button Group */
        .btn-group {
            display: flex; justify-content: center; gap: 20px; margin-top: 30px;
        }
        .btn {
            padding: 12px 40px; border: none; border-radius: 5px; cursor: pointer;
            font-weight: bold; font-size: 1rem; transition: 0.3s; color: white;
        }
        .btn-reject { background-color: #CC0000; } /* สีแดง */
        .btn-approve { background-color: #00A859; } /* สีเขียว */
        .btn:hover { opacity: 0.8; transform: translateY(-2px); }

        /* Responsive */
        @media (max-width: 768px) {
            .form-grid { grid-template-columns: 1fr; }
            .full-width { grid-column: span 1; }
        }
    </style>
</head>
<body>

    <div class="sticky-bar">
        <a href="ITDirectorApprove.jsp" style="text-decoration:none; color:#333;">
            <i class="fa fa-arrow-left"></i> กลับ
        </a>
        <div style="margin-left:auto; display:flex; align-items:center;">
            <span style="font-size:0.8rem; margin-right:10px;">สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</span>
            <i class="fa fa-circle-user" style="font-size:24px;"></i>
        </div>
    </div>

    <div class="banner">
        <h1>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</h1>
        <h2>ใบขอให้ดำเนินการ / Requisition Form</h2>
    </div>

    <div class="form-container">
        <form>
            <div class="form-grid">
                <div class="form-group">
                    <label>ชื่อ-นามสกุล</label>
                    <input type="text" value="ธนภัทร กาญจนรุจิวุฒิ" readonly>
                </div>
                <div class="form-group">
                    <label>ส่วน</label>
                    <input type="text" value="บริหารหนี้ 2" readonly>
                </div>
                <div class="form-group">
                    <label>ฝ่าย</label>
                    <input type="text" value="ฝ่ายบริหารหนี้" readonly>
                </div>
                <div class="form-group">
                    <label>เบอร์ต่อ</label>
                    <input type="text" value="411" readonly>
                </div>
                <div class="form-group">
                    <label>วันที่</label>
                    <input type="date" value="2026-05-11" readonly>
                </div>
                <div class="form-group">
                    <label>ความต้องการ</label>
                    <select disabled>
                        <option>พัฒนาโปรแกรมใหม่</option>
                    </select>
                </div>

                <div class="section-box full-width">
                    <div class="form-group" style="margin-bottom:15px;">
                        <label>ชื่อหัวข้อความต้องการ :</label>
                        <input type="text" value="ระบบลงทะเบียนขอผ่อนผันการชำระเงินกองทุน">
                    </div>
                    <div class="form-group">
                        <label>ภายในวันที่ :</label>
                        <input type="text" value="16/01/2569 (X วัน)">
                    </div>
                </div>

                <div class="form-group">
                    <label>ประเภทคำขอ</label>
                    <select disabled>
                        <option>เร่งด่วน</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>ชื่อโปรแกรม (ถ้ามี)</label>
                    <input type="text" value="SLF-Relief System">
                </div>

                <div class="form-group full-width">
                    <label>วัตถุประสงค์ / ความต้องการ</label>
                    <textarea rows="4">เพื่อช่วยเหลือกองทุนเงินให้กู้ยืมเพื่อการศึกษา กรณีผู้กู้ยืมเป็นผู้ประสบอุทกภัย...</textarea>
                </div>

                <div class="form-group full-width">
                    <label>วิธีการดำเนินการปัจจุบัน</label>
                    <textarea rows="4">ปัจจุบันดำเนินการผ่านระบบ Manual และบันทึกใน Excel...</textarea>
                </div>
            </div>
            <div class="section-box full-width" style="background-color: #ffffff; border: 2px solid #000000;">
                        <h3
                            style="margin-top: 0; color: #000000; font-size: 1.1rem; font-weight: bold; margin-bottom: 15px;">
                            ผู้อำนวยการฝ่ายเทคโนโลยีสารสนเทศ
                        </h3>


                        <div class="form-grid"
                            style="margin-top: 15px; display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                            <div class="form-group">
                                <label style="font-weight: bold;">ผู้อำนวยการฝ่ายเทคโนโลยีสารสนเทศ :</label>
                                <input type="text" placeholder="ระบุชื่อ :"
                                    style="padding: 8px; border: 1px solid #3272BB; border-radius: 5px;">
                            </div>
                        </div>
                    </div>

            <div class="btn-group">
                <button type="button" class="btn btn-reject" onclick="alert('ส่งกลับแก้ไข')">ส่งกลับ</button>
                <button type="button" class="btn btn-approve" onclick="alert('อนุมัติเรียบร้อย')">อนุมัติ</button>
            </div>
        </form>
    </div>

</body>
</html>