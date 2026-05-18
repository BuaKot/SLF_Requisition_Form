<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, com.util.DBConnection, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Sarabun:wght@400;700&display=swap');
        * { box-sizing: border-box; font-family: 'Sarabun', sans-serif; }
        body { background-color: #ffffff; margin: 0; }
        .banner { background: #C3EAFF; padding: 25px 20px; text-align: center; color: #003366; }
        .banner h1 { font-size: 22px; margin: 5px 0; }
        .list-container { max-width: 1200px; margin: 20px auto; padding: 0 20px; }
        .back-btn { text-decoration: none; color: #3272BB; font-size: 15px; font-weight: bold; display: inline-block; margin-bottom: 15px; }
        
        .requisition-card {
            display: flex; align-items: center; background: white; border: 1px solid #ccc; 
            border-radius: 12px; padding: 12px 20px; margin-bottom: 10px; gap: 20px; 
            cursor: pointer; transition: 0.2s; box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }
        .requisition-card:hover { border-color: #3272BB; transform: scale(1.005); }
        .card-id-box { border: 1px solid #333; border-radius: 8px; padding: 6px 12px; min-width: 180px; text-align: center; font-weight: bold; font-size: 17px; }
        .card-info { flex-grow: 1; }
        .info-row { display: flex; gap: 15px; margin-bottom: 4px; font-size: 15px; }
        .info-item b { color: #3272BB; }
        .status-section { display: flex; align-items: center; gap: 12px; min-width: 80px; justify-content: flex-end; }
        .status-icon { font-size: 38px; }
    </style>
</head>
<body>

<div class="banner">
    <h1>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</h1>
    <h1>รายการใบขอให้ดำเนินการ (Director Approval)</h1>
</div>

<div class="list-container">
    <a href="Admin.jsp" class="back-btn"><i class="fa fa-chevron-left"></i> กลับหน้าหลัก</a>

<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    
    try {
        conn = DBConnection.getConnection();
        // ดึงข้อมูลฟอร์ม เรียงตาม Deadline เร็วสุดไปช้าสุด
        String sql = "SELECT r.FORMID, e.EMPNAME, r.TITLEFORM, r.DEADLINE, r.ASSIGN_SECID, a.APPROVALSTATUS " +
                     "FROM REQUISITIONFORM r " +
                     "LEFT JOIN EMPLOYEE e ON r.EMPID = e.EMPID " + 
                     "LEFT JOIN APPROVALINFO a ON r.FORMID = a.REQUESTID " +
                     "ORDER BY r.DEADLINE ASC"; 

        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();

        while (rs.next()) {
            String formId = rs.getString("FORMID");
            String status = rs.getString("APPROVALSTATUS");
%>
    <div class="requisition-card" onclick="location.href='RequisitionDetail.jsp?id=<%= formId %>'">
        <div class="card-id-box">ใบขอให้ดำเนินการที่ <%= formId %></div>
        <div class="card-info">
            <div class="info-row">
                <div class="info-item"><b>ชื่อ :</b> <%= rs.getString("EMPNAME") %></div>
                <div class="info-item"><b>ส่วน :</b> <%= rs.getString("ASSIGN_SECID") %></div>
                <div class="info-item"><b>Deadline :</b> <%= rs.getDate("DEADLINE") != null ? sdf.format(rs.getDate("DEADLINE")) : "-" %></div>
            </div>
            <div style="font-size: 15px;"><b>รายละเอียด :</b> <%= rs.getString("TITLEFORM") %></div>
        </div>
        <div class="status-section">
            <div class="status-icon">
                <% if ("Approved".equalsIgnoreCase(status)) { %>
                    <i class="fa-solid fa-circle-check" style="color: #28a745;"></i>
                <% } else { %>
                    <i class="fa-solid fa-clock-rotate-left" style="color: #ffc107;"></i>
                <% } %>
            </div>
            <i class="fa-solid fa-chevron-right" style="color:#ddd"></i>
        </div>
    </div>
<%
        }
    } catch (Exception e) { out.println("Error: " + e.getMessage()); }
    finally { if (conn != null) conn.close(); }
%>
</div>
</body>
</html>