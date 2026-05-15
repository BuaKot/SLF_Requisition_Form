<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, com.util.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>รายชื่อพนักงาน</title>
    <style>
        table {
            width: 50%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        th, td {
            border: 1px solid #dddddd;
            text-align: left;
            padding: 8px;
        }
        th {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
    <h2>ข้อมูลจากฐานข้อมูล Oracle</h2>
    <table>
        <tr>
            <th>ID</th>
            <th>ชื่อ-นามสกุล</th>
        </tr>
        <% 
            Connection conn = null; 
            Statement stmt = null; 
            ResultSet rs = null; 
            try {
                conn = DBConnection.getConnection(); 
                // แก้ไข SQL ให้ใช้ชื่อคอลัมน์ที่ถูกต้องตามตาราง EMPLOYEE
                String sql = "SELECT REQUESTORID, EMPNAME FROM EMPLOYEE"; 
                stmt = conn.createStatement(); 
                rs = stmt.executeQuery(sql); 
                while (rs.next()) { 
        %>
        <tr>
            <td>
                <%-- ดึงค่าจากคอลัมน์ REQUESTORID --%>
                <%= rs.getString("REQUESTORID") %>
            </td>
            <td>
                <%-- ดึงค่าจากคอลัมน์ EMPNAME --%>
                <%= rs.getString("EMPNAME") %>
            </td>
        </tr>
        <% 
                } 
            } catch (Exception e) { 
                out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
                e.printStackTrace();
            } finally {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            }
        %>
    </table>
</body>
</html>