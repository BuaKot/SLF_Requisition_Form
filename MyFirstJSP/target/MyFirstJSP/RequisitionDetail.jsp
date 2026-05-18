<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, com.util.DBConnection, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>รายละเอียดใบขอให้ดำเนินการ / Requisition Form</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/form.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Sarabun:wght@400;700&display=swap');
        * { box-sizing: border-box; font-family: 'Sarabun', sans-serif; }
        body { background-color: #ffffff; margin: 0; }
        
        /* ปรับดีไซน์ช่อง Input ให้อ่านง่ายสไตล์ Read-Only (โชว์ข้อมูล) */
        .form-control-static {
            width: 100%;
            padding: 10px 15px;
            background-color: #f8fafc;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            font-size: 16px;
            color: #334155;
            min-height: 42px;
        }
        .textarea-static {
            min-height: 100px;
            overflow-wrap: anywhere;
        }
    </style>
</head>
<body>

<div id="mySidebar" class="sidebar">
    <a href="javascript:void(0)" class="closebtn" onclick="toggleNav()">&times;</a>
    <a href="${pageContext.request.contextPath}" style='font-size:20px'>Home</a>
    <a href="${pageContext.request.contextPath}/DirectorApprove.jsp" style='font-size:20px'>Submitted Forms</a>
    <a href="${pageContext.request.contextPath}/form.jsp" style='font-size:20px'>New Form</a>
    <a href='#' class='admin-tab'><i class='fa fa-circle-user' style='font-size:36px;padding-left:0px;padding-right:25%'></i>Admin</a>
</div>

<div id="main">
    <div class='sticky-bar'>
        <i id="menuBtn" class="fa fa-bars" onclick="toggleNav()" style="font-size:36px; cursor:pointer; padding-left:5px; padding-right:5px;"></i>
        <img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF Logo" style="height: 48px; padding-left: 10px; padding-right: 5px">
        <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo" style="height: 48px; padding-left: 5px; padding-right: 5px">
        <div style="margin-left:auto; display:flex; align-items:center">
            <i class='fa fa-circle-user' style='font-size:24px; padding-left:10px; padding-right:0px'></i>
            <p style='margin-left: 5px; margin-right: 15px; margin-top:0; margin-bottom:0;'>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
        </div>
    </div>

<%
    String formId = request.getParameter("id");
    if (formId == null || formId.trim().isEmpty()) {
        formId = request.getParameter("formId");
    }
    if (formId != null) {
        formId = formId.trim();
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");

    String empName = "";
    String section = "";
    String department = "";
    String phone = "";
    String reqDate = "";
    String titleForm = "";
    boolean hasData = false;

    try {
        if (formId != null && !formId.isEmpty()) {
            conn = DBConnection.getConnection();
            
            // Query ค้นหาข้อมูลตามเลข ID ใบขอให้ดำเนินการ
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
                section = rs.getString("ASSIGN_SECID") != null ? rs.getString("ASSIGN_SECID") : "-";
                titleForm = rs.getString("TITLEFORM") != null ? rs.getString("TITLEFORM") : "-";
                reqDate = rs.getDate("DEADLINE") != null ? sdf.format(rs.getDate("DEADLINE")) : "-";
                
                phone = "411";
                department = "ฝ่ายบริหารหนี้";
            }
        }
    } catch (Exception e) {
        out.println("<div style='color:red; text-align:center; padding:10px;'>Error: " + e.getMessage() + "</div>");
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>

    <div class='blue-title'>
        <h1 style='margin-block-start: 0.1em; margin-block-end: 0.1em;'>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินกู้ยืมเพื่อการศึกษา</h1>
        <h2 style='margin-block-start: 0.1em; margin-block-end: 0.1em;'>ใบขอให้ดำเนินการ / Requisition Form (ID: <%= (formId != null) ? formId : "ไม่ได้ระบุ" %>)</h2>
    </div>

    <div class="form-page">
        <div class="form-card">
            <h3 class="form-title">รายละเอียดข้อมูลในระบบ</h3>

            <% if (!hasData) { %>
                <div style="text-align:center; color:#ff304f; padding: 20px; font-weight:bold;">
                    ❌ ไม่พบข้อมูลใบคำขอเลขที่ "<%= formId %>" ในระบบฐานข้อมูล
                </div>
            <% } else { %>
                <div class="form-grid">

                    <div class="form-group">
                        <label>ชื่อ-นามสกุล</label>
                        <div class="form-control-static"><%= empName %></div>
                    </div>

                    <div class="form-group">
                        <label>ส่วน</label>
                        <div class="form-control-static"><%= section %></div>
                    </div>

                    <div class="form-group">
                        <label>ฝ่าย</label>
                        <div class="form-control-static"><%= department %></div>
                    </div>

                    <div class="form-group">
                        <label>เบอร์ต่อ</label>
                        <div class="form-control-static"><%= phone %></div>
                    </div>

                    <div class="form-group">
                        <label>วันที่ / Deadline</label>
                        <div class="form-control-static"><%= reqDate %></div>
                    </div>

                </div>

                <div class="form-group" style="margin-top: 15px; padding: 0 10px;">
                    <label>ชื่อหัวข้อความต้องการ / รายละเอียด</label>
                    <div class="form-control-static textarea-static"><%= titleForm %></div>
                </div>
            <% } %>

            <div class="form-actions" style="margin-top: 25px;">
                <a href="DirectorApprove.jsp" class="btn-secondary" style="text-decoration:none; display:inline-block; text-align:center; line-height:35px;">
                    <i class="fa fa-chevron-left"></i> กลับหน้ารายการ
                </a>
            </div>
        </div>
    </div>

</div>

<script>
function toggleNav() {
  var sidebar = document.getElementById("mySidebar");
  var main = document.getElementById("main");
  
  if (sidebar.style.width === "250px") {
    sidebar.style.width = "0";
    main.style.marginLeft = "0";
    main.style.width = "100%";
  } else {
    sidebar.style.width = "250px";
    main.style.marginLeft = "250px";
    main.style.width = "calc(100% - 250px)"; 
  }
}
</script>
</body>
</html>