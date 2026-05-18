<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, com.slf.dao.DBConnection, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>รายการใบขอให้ดำเนินการ (Director Approval)</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Sarabun:wght@400;700&display=swap');

        * {
            box-sizing: border-box;
            font-family: 'Sarabun', sans-serif;
        }

        body {
            background-color: #ffffff;
            margin: 0;
        }

        /* Sticky Bar ตามแบบเป๊ะ */
        .sticky-bar {
            background: #fafafa;
            padding: 12px 20px;
            display: flex;
            align-items: center;
            border-bottom: 1px solid #ddd;
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .sticky-bar a {
            color: #333;
            text-decoration: none;
        }

        .contact-info {
            margin-left: auto;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .contact-info p {
            margin: 0;
            font-size: 14px;
        }

        .banner {
            background: #C3EAFF;
            padding: 25px 20px;
            text-align: center;
            color: #003366;
        }

        .banner h1 {
            font-size: 22px;
            margin: 5px 0;
        }

        .list-container {
            max-width: 1360px;
            margin: 20px auto;
            padding: 0 20px;
        }

        .back-btn {
            text-decoration: none;
            color: #3272BB;
            font-size: 15px;
            font-weight: bold;
            display: inline-block;
            margin-bottom: 15px;
        }

        /* โครงสร้าง Card แบบใหม่เหมือนเพื่อน */
        .requisition-card {
            display: flex;
            align-items: center;
            background: white;
            border: 1px solid #ccc;
            border-radius: 12px;
            padding: 12px 24px;
            margin-bottom: 10px;
            gap: 20px;
            cursor: pointer;
            transition: 0.2s;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }

        .requisition-card:hover {
            border-color: #3272BB;
            transform: scale(1.005);
        }

        .card-id-box {
            border: 1px solid #333;
            border-radius: 8px;
            padding: 6px 12px;
            min-width: 180px;
            text-align: center;
            font-weight: bold;
            font-size: 15px;
        }

        .card-info {
            flex-grow: 1;
            min-width: 0;
        }

        /* จัด Grid 4 คอลัมน์แบบหน้าเพื่อน */
        .info-row {
            display: grid;
            grid-template-columns: minmax(150px, 1fr) minmax(170px, 1fr) minmax(170px, 1fr) minmax(130px, auto);
            column-gap: 15px;
            row-gap: 4px;
            margin-bottom: 4px;
            font-size: 15px;
        }

        .info-item {
            min-width: 0;
            overflow-wrap: anywhere;
        }

        .info-item b,
        .detail-line b {
            color: #3272BB;
        }

        .detail-line {
            font-size: 15px;
            overflow-wrap: anywhere;
        }

        .status-section {
            display: flex;
            align-items: center;
            gap: 12px;
            min-width: 112px;
            justify-content: flex-end;
        }

        .status-icon {
            width: 72px;
            min-width: 72px;
            height: 58px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            font-size: 38px;
            line-height: 1;
            text-align: center;
        }

        .status-label {
            display: block;
            font-size: 11px;
            line-height: 1.1;
            margin-top: 3px;
            width: 72px;
            overflow-wrap: anywhere;
            text-align: center;
        }

        .status-complete {
            color: #28a745;
        }

        .status-pending {
            color: #ffc107;
        }

        @media (max-width: 1000px) {
            .requisition-card {
                align-items: flex-start;
                flex-direction: column;
            }

            .card-id-box {
                width: 100%;
            }

            .status-section {
                align-self: flex-end;
            }

            .info-row {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>

<div class="sticky-bar">
    <a href="Admin.jsp">
        <i class="fa fa-arrow-left" style="font-size:24px;"></i>
    </a>
    <div class="contact-info">
        <i class="fa fa-circle-user" style="font-size:1.4rem; color:#333;"></i>
        <p>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
    </div>
</div>

<div class="banner">
    <h1>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</h1>
    <h1>รายการใบขอให้ดำเนินการ</h1>
</div>

<div class="list-container">
    <a href="Admin.jsp" class="back-btn">
        <i class="fa fa-chevron-left"></i> กลับหน้าหลัก
    </a>

<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    
    try {
        conn = DBConnection.getConnection();
        
        String sql = "SELECT r.FORMID, e.EMPNAME, r.TITLEFORM, r.DEADLINE, r.ASSIGN_SECID " +
                     "FROM REQUISITIONFORM r " +
                     "LEFT JOIN EMPLOYEE e ON r.EMPID = e.EMPID " + 
                     "ORDER BY r.FORMID DESC"; 

        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();

        while (rs.next()) {
            String formId = rs.getString("FORMID") != null ? rs.getString("FORMID").trim() : "";
            
            String empName = rs.getString("EMPNAME") != null ? rs.getString("EMPNAME") : "-";
            String sectionName = rs.getString("ASSIGN_SECID") != null ? rs.getString("ASSIGN_SECID") : "-";
            String deadline = rs.getDate("DEADLINE") != null ? sdf.format(rs.getDate("DEADLINE")) : "-";
            String titleForm = rs.getString("TITLEFORM") != null ? rs.getString("TITLEFORM") : "-";
%>
    <div class="requisition-card" onclick="location.href='RequisitionDetail.jsp?id=<%= formId %>'">
        <div class="card-id-box">ใบขอให้ดำเนินการที่ <%= formId %></div>

        <div class="card-info">
            <div class="info-row">
                <div class="info-item"><b>ชื่อ :</b> <%= empName %></div>
                <div class="info-item"><b>ฝ่าย :</b> - </div> <div class="info-item"><b>ส่วน :</b> <%= sectionName %></div>
                <div class="info-item"><b>Deadline :</b> <%= deadline %></div>
            </div>
            <div class="detail-line"><b>รายละเอียด :</b> <%= titleForm %></div>
        </div>

        <div class="status-section">
            <div class="status-icon status-pending">
                <i class="fa-solid fa-clock-rotate-left"></i>
                <span class="status-label">Pending</span>
            </div>
            <i class="fa-solid fa-chevron-right" style="color:#ddd"></i>
        </div>
    </div>
<%
        }
    } catch (Exception e) { 
        out.println("<div style='color:red; padding:15px; border:1px solid red; border-radius:12px;'>Error: " + e.getMessage() + "</div>"); 
    } finally { 
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close(); 
    }
%>
</div>
</body>
</html>