<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, com.util.DBConnection, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: 'Sarabun', sans-serif; background-color: #f4f7f9; }
        .form-container { max-width: 800px; margin: 20px auto; background: white; padding: 30px; border-radius: 10px; border: 1px solid #ccc; }
        .blue-box { border: 2px solid #3272BB; padding: 20px; border-radius: 8px; margin: 15px 0; }
        input, textarea { width: 100%; padding: 10px; margin-top: 5px; border: 1px solid #3272BB; border-radius: 4px; background: #fdfdfd; }
        label { font-weight: bold; display: block; margin-top: 10px; }
    </style>
</head>
<body>

<%
    String id = request.getParameter("id");
    String empName="", section="", title="", objective="", currentProcess="", deadline="";

    try (Connection conn = DBConnection.getConnection()) {
        String sql = "SELECT r.*, e.EMPNAME FROM REQUISITIONFORM r LEFT JOIN EMPLOYEE e ON r.EMPID = e.EMPID WHERE r.FORMID = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, id);
        ResultSet rs = pstmt.executeQuery();

        if (rs.next()) {
            empName = rs.getString("EMPNAME");
            section = rs.getString("ASSIGN_SECID");
            title = rs.getString("TITLEFORM");
            objective = rs.getString("OBJECTIVE");
            currentProcess = rs.getString("CURRENT_PROCESS");
            deadline = (rs.getDate("DEADLINE") != null) ? new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("DEADLINE")) : "";
        }
%>

<div class="form-container">
    <h2 style="text-align:center;">ใบคำขอเลขที่: <%= id %></h2>
    
    <form action="ApproveServlet" method="POST">
        <input type="hidden" name="formId" value="<%= id %>">

        <label>ชื่อ-นามสกุล:</label>
        <input type="text" value="<%= (empName != null) ? empName : "ไม่พบข้อมูล" %>" readonly>

        <label>ส่วนงาน:</label>
        <input type="text" value="<%= section %>" readonly>

        <div class="blue-box">
            <label>หัวข้อความต้องการ:</label>
            <input type="text" value="<%= title %>" readonly>
            
            <label>ภายในวันที่:</label>
            <input type="text" value="<%= deadline %>" readonly>
        </div>

        <label>วัตถุประสงค์:</label>
        <textarea rows="4" readonly><%= objective %></textarea>

        <label>วิธีการปัจจุบัน:</label>
        <textarea rows="3" readonly><%= currentProcess %></textarea>

        <div style="margin-top:20px; padding-top:20px; border-top:1px solid #eee;">
            <label>ความเห็นผู้อำนวยการ:</label>
            <input type="text" name="comment" required placeholder="ใส่ความเห็นที่นี่...">
            
            <div style="display:flex; gap:10px; margin-top:20px;">
                <button type="submit" name="action" value="approve" style="background:green; color:white; padding:10px 20px; flex:1; cursor:pointer;">อนุมัติ</button>
                <button type="submit" name="action" value="reject" style="background:red; color:white; padding:10px 20px; flex:1; cursor:pointer;">ส่งกลับ</button>
            </div>
        </div>
    </form>
</div>

<%
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    }
%>
</body>
</html>