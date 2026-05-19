<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<%
    // รับค่าจากหน้าฟอร์ม login (ใช้ตัวพิมพ์ใหญ่ตามที่แก้ไข)
    String empid = request.getParameter("EMPID");
    String secid = request.getParameter("SECID");

    if (empid != null && secid != null && !empid.trim().isEmpty() && !secid.trim().isEmpty()) {
        
        String dbURL = "jdbc:oracle:thin:@//172.25.18.186:1521/XE"; 
        String dbUser = "C##DEVUSER";
        String dbPassword = "mypassword";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("oracle.jdbc.OracleDriver");
            conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
            
            // 🛠️ แก้ไขตรงนี้: เปลี่ยนชื่อตารางเป็น EMPLOYEE และคอลัมน์ให้ตรงกับฐานข้อมูลจริงของคุณ
            String sql = "SELECT EMPNAME, POSITION FROM EMPLOYEE WHERE EMPID = ? AND SECID = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, empid.trim());
            pstmt.setString(2, secid.trim());
            
            rs = pstmt.executeQuery();
            if (rs.next()) {
                // ล็อกอินผ่าน! เก็บข้อมูลใส่ Session ไว้ใช้ยาวๆ ในหน้าอื่น
                session.setAttribute("emp_id", empid.trim());
                session.setAttribute("emp_name", rs.getString("EMPNAME"));
                session.setAttribute("position", rs.getString("POSITION"));
                
                // ส่งต่อไปหน้าหลัก
                response.sendRedirect("index.jsp"); 
                return;
            } else {
                response.sendRedirect("login.jsp?error=1");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("เกิดข้อผิดพลาดในระบบ: " + e.getMessage());
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    } else {
        response.sendRedirect("login.jsp?error=1");
    }
%>