<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, com.slf.dao.DBConnection, java.text.SimpleDateFormat" %>
<%
    // 🛠️ 1. ดักรับพารามิเตอร์ ID ที่ส่งมาจากหน้ารายการรวม
    String formId = request.getParameter("id");
    if (formId == null || formId.trim().isEmpty()) {
        formId = request.getParameter("formId");
    }
    if (formId != null) {
        formId = formId.trim();
    }

    // 🛠️ 2. เตรียมตัวแปรสำหรับพักข้อมูลมารอหยอดลงใน UI
    String empName = "";
    String sectionName = "";
    String departmentName = "ฝ่ายบริหารหนี้"; // ตั้ง Default ไว้ก่อนถ้าหากใน DB ไม่มีคอลัมน์นี้ครับ
    String phone = "411";
    String reqDate = "";
    String deadlineDate = "";
    String titleForm = "";
    String objective = "";
    String currentProcess = "";
    boolean hasData = false;

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    SimpleDateFormat sdfInput = new SimpleDateFormat("yyyy-MM-dd"); // สำหรับใส่ใน <input type="date">
    SimpleDateFormat sdfDisplay = new SimpleDateFormat("dd/MM/yyyy"); // สำหรับแสดงผลข้อความทั่วไป

    try {
        if (formId != null && !formId.isEmpty()) {
            conn = DBConnection.getConnection();
            
            // ดึงข้อมูลเชื่อมตาราง REQUISITIONFORM และ EMPLOYEE ตามโครงสร้างดั้งเดิมของคุณ
            String sql = "SELECT r.FORMID, e.EMPNAME, r.ASSIGN_SECID, r.TITLEFORM, r.DEADLINE " +
                         "FROM REQUISITIONFORM r " +
                         "LEFT JOIN EMPLOYEE e ON r.EMPID = e.EMPID " +
                         "WHERE r.FORMID = ?";
                         
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, formId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                hasData = true;
                empName = rs.getString("EMPNAME") != null ? rs.getString("EMPNAME") : "-";
                sectionName = rs.getString("ASSIGN_SECID") != null ? rs.getString("ASSIGN_SECID") : "-";
                titleForm = rs.getString("TITLEFORM") != null ? rs.getString("TITLEFORM") : "-";
                
                // แปลงฟอร์แมตวันที่ให้อยู่ในรูปแบบที่ถูกต้องเพื่อนำไปใส่ใน Value
                if (rs.getDate("DEADLINE") != null) {
                    deadlineDate = sdfDisplay.format(rs.getDate("DEADLINE"));
                } else {
                    deadlineDate = "-";
                }
                
                // สำหรับฟิลด์ วันที่ยื่นคำขอ ปัจจุบันให้ดึงเป็นวันปัจจุบันรอไว้ก่อน
                reqDate = sdfInput.format(new java.util.Date());
                
                // รายละเอียดจำลองเพิ่มเติมในกรณีที่ยังไม่มี Field แยกในตารางหลัก
                objective = "เพื่อช่วยเหลือกองทุนเงินให้กู้ยืมเพื่อการศึกษา กรณีผู้กู้ยืมเป็นผู้ประสบอุทกภัย หรือภัยพิบัติต่างๆ ตามที่คณะกรรมการกำหนด";
                currentProcess = "ปัจจุบันดำเนินการผ่านระบบ Manual และบันทึกข้อมูลในไฟล์ Microsoft Excel ทำให้เกิดความล่าช้า";
            }
        }
    } catch (Exception e) {
        System.out.println("Error Loading Form Details: " + e.getMessage());
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>
<!DOCTYPE html>
<html lang="th">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>รายละเอียดใบขอให้ดำเนินการ (ID: <%= (formId != null) ? formId : "-" %>)</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Sarabun:wght@400;700&display=swap');
        * {
            box-sizing: border-box;
        }

        body {
            font-family: 'Sarabun', sans-serif;
            margin: 0;
            background-color: #f4f7f9;
        }

        /* Header Bar */
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
            color: #333;
            font-weight: bold;
        }

        /* Banner */
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

        /* Form Container */
        .form-container {
            max-width: 900px;
            margin: 20px auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
        }

        /* Grid System สำหรับฟอร์ม */
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }

        .form-group label {
            font-weight: bold;
            margin-bottom: 8px;
            font-size: 0.9rem;
            color: #333;
        }

        .form-group input,
        .form-group select,
        .form-group textarea {
            padding: 10px;
            border: 1px solid #3272BB;
            border-radius: 5px;
            font-size: 14px;
            background-color: #ffffff;
        }

        /* สไตล์สำหรับฟิลด์ที่ห้ามแก้ (Readonly) */
        .form-group input[readonly],
        .form-group textarea[readonly],
        .form-group select[disabled] {
            background-color: #f8fafc;
            border-color: #cbd5e1;
            color: #475569;
        }

        .full-width {
            grid-column: span 2;
        }

        /* Section Box (ช่องกรอกความเห็นของกรรมการ) */
        .section-box {
            border: 2px solid #3272BB;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 25px;
        }

        /* Button Group */
        .btn-group {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 20px;
            margin-top: 25px;
            width: 100%;
        }

        .btn {
            padding: 12px 40px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-weight: bold;
            font-size: 1rem;
            transition: 0.3s;
            color: white;
        }

        .btn-reject {
            background-color: #CC0000;
        }

        .btn-approve {
            background-color: #00A859;
        }

        .btn:hover {
            opacity: 0.8;
            transform: translateY(-2px);
        }

        /* Responsive */
        @media (max-width: 768px) {
            .form-grid {
                grid-template-columns: 1fr;
            }

            .full-width {
                grid-column: span 1;
            }
        }
    </style>
</head>

<body>

    <div class="sticky-bar">
        <a href="Process.jsp">
            <i class="fa fa-arrow-left"></i> กลับหน้ารายการ
        </a>
        <div class="contact-info" style="margin-left:auto; display:flex; align-items:center">
            <i class='fa fa-circle-user' style='font-size:1.4rem; color:#333;'></i>
            <p style='margin-left: 8px; font-size: 0.9rem; margin-top:0; margin-bottom:0;'>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
        </div>
    </div>

    <div class="banner">
        <h1>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</h1>
        <h1 style="margin-top: 5px;">ใบขอให้ดำเนินการ / Requisition Form (ใบที่: <%= (formId != null) ? formId : "-" %>)</h1>
    </div>

    <div class="form-container">
        
        <% if (!hasData) { %>
            <div style="text-align: center; color: #CC0000; padding: 30px; font-weight: bold;">
                ❌ ไม่พบข้อมูลใบขอให้ดำเนินการเลขที่ "<%= formId %>" ในระบบฐานข้อมูล
            </div>
        <% } else { %>
            
            <form action="SubmitApprovalServlet" method="post">
                <input type="hidden" name="formId" value="<%= formId %>">

                <div class="form-grid">
                    <div class="form-group">
                        <label>ชื่อ-นามสกุล <span style="color:red">*</span></label>
                        <input type="text" value="<%= empName %>" readonly>
                    </div>
                    <div class="form-group">
                        <label>ส่วน</label>
                        <input type="text" value="<%= sectionName %>" readonly>
                    </div>
                    <div class="form-group">
                        <label>ฝ่าย <span style="color:red">*</span></label>
                        <input type="text" value="<%= departmentName %>" readonly>
                    </div>
                    <div class="form-group">
                        <label>เบอร์ต่อ <span style="color:red">*</span></label>
                        <input type="text" value="<%= phone %>" readonly>
                    </div>
                    <div class="form-group">
                        <label>วันที่ <span style="color:red">*</span></label>
                        <input type="date" value="<%= reqDate %>" readonly>
                    </div>
                    <div class="form-group">
                        <label>Deadline <span style="color:red">*</span></label>
                        <input type="text" value="<%= deadlineDate %>" readonly>
                    </div>
                    <div class="form-group full-width">
                        <label>ชื่อหัวข้อความต้องการ :</label>
                        <input type="text" value="<%= titleForm %>" readonly>
                    </div>
                </div>

                <div class="section-box-main">
                    <div class="form-grid">
                        <div class="form-group full-width">
                            <label>ประเภทคำขอ</label>
                            <select disabled>
                                <option>แจ้งปัญหาการใช้งาน / ขอพัฒนาปรับปรุงระบบ</option>
                            </select>
                        </div>

                        <div class="form-group full-width">
                            <label>วัตถุประสงค์ / ความต้องการ</label>
                            <textarea rows="4" readonly><%= objective %></textarea>
                        </div>

                        <div class="form-group full-width">
                            <label>วิธีการดำเนินการปัจจุบัน</label>
                            <textarea rows="3" readonly><%= currentProcess %></textarea>
                        </div>
                    </div>
                </div>

                <div class="section-box full-width" style="background-color: #ffffff; border: 2px solid #000000; margin-top:30px;">
                    <h3 style="margin-top: 0; color: #3272BB; font-size: 1.1rem; font-weight: bold; margin-bottom: 15px;">
                        การดำเนินการ
                    </h3>
                    <div class="form-grid" style="margin-top: 15px; display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                        <div class="form-group">
                            <label style="font-weight: bold;">ผลการดำเนินการ:</label>  
                            <textarea rows="4" name="directorComment" style="width: 100%; border: 1px solid #3272BB; border-radius: 5px; padding: 10px;" placeholder="ระบุความเห็นและบันทึกข้อความที่นี่..."></textarea>
                        </div>
                        <div class="form-group">
                            <label style="font-weight: bold;">ผู้ดำเนินการ :</label>
                            <input type="text" name="approverName" placeholder="ระบุชื่อผู้ดำเนินการ" style="padding: 8px; border: 1px solid #3272BB; border-radius: 5px;">
                        </div>
                    </div>
                </div>

                <div class="btn-group">
                    <button type="submit" name="action" value="reject" class="btn btn-reject">ส่งกลับ</button>
                    <button type="submit" name="action" value="approve" class="btn btn-approve">อนุมัติ</button>
                </div>
            </form>
            
        <% } %>
    </div>

</body>
</html>