<% request.setAttribute("requiredPageKey", "dashboard"); %>
<%@ include file="/WEB-INF/checkAuth.jsp" %>
<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.slf.dao.DBConnection" %>
<%@ page import="com.slf.dao.LookupDAO" %>
<%@ page import="com.slf.model.Department" %>
<%@ page import="com.slf.model.Section" %>
<%@ page import="com.slf.model.Employee" %>

<%!
    public String escapeHtml(String input) {
        if (input == null) return "";
        return input.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#x27;")
                    .replace("/", "&#x2F;");
    }

    public String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\b", "\\b")
                    .replace("\f", "\\f")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r")
                    .replace("\t", "\\t");
    }
%>

<%
    String employeeName = (session.getAttribute("empName") != null) ? escapeHtml((String)session.getAttribute("empName")) : "ผู้ใช้งานระบบ";
    
    String filter = request.getParameter("timeFilter");
    if (filter == null || filter.trim().equals("")) { filter = "30days"; }

    List<String> allowedFilters = Arrays.asList("7days", "30days", "quarters", "forecast", "custom");
    if (!allowedFilters.contains(filter)) { filter = "30days"; }

    String startDate = request.getParameter("startDate");
    String endDate = request.getParameter("endDate");
    
    if (startDate != null && !startDate.trim().equals("") && endDate != null && !endDate.trim().equals("")) {
        filter = "custom";
    } else {
        startDate = "";
        endDate = "";
    }

    // zennnne แก้
    String deptIdStr = request.getParameter("deptId");
    String secIdStr  = request.getParameter("secId");
    String empIdStr  = request.getParameter("empId");
    int filterDeptId = 0, filterSecId = 0, filterEmpId = 0;
    try { if (deptIdStr != null && !deptIdStr.trim().isEmpty()) filterDeptId = Integer.parseInt(deptIdStr.trim()); } catch (NumberFormatException ignored) {}
    try { if (secIdStr  != null && !secIdStr.trim().isEmpty())  filterSecId  = Integer.parseInt(secIdStr.trim());  } catch (NumberFormatException ignored) {}
    try { if (empIdStr  != null && !empIdStr.trim().isEmpty())  filterEmpId  = Integer.parseInt(empIdStr.trim());  } catch (NumberFormatException ignored) {}
    // zennnne แก้ end

    int totalEmployees = 0; 
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    Statement stmt = null;
    ResultSet countRs = null;
    PreparedStatement pstmt2 = null;
    ResultSet rs2 = null;

    List<String> labelsList = new ArrayList<String>();
    List<Integer> dataList = new ArrayList<Integer>();
    
    List<String> topCatLabels = new ArrayList<String>();
    List<Integer> topCatValues = new ArrayList<Integer>();
    boolean barQueryOk = false; // zennnne แก้

    // zennnne แก้
    List<Department> allDepts    = new ArrayList<Department>();
    List<Section>    allSections = new ArrayList<Section>();
    List<Employee>   allEmps     = new ArrayList<Employee>();
    String sectionsJson = "[]";
    String empsJson     = "[]";
    // zennnne แก้ end

    try {
        // ---- No more hardcoded credentials ----
        conn = DBConnection.getConnection();
        
        String countSql = "SELECT COUNT(*) as TOTAL_EMP FROM EMPLOYEE";
        stmt = conn.createStatement();
        countRs = stmt.executeQuery(countSql);
        if (countRs.next()) { totalEmployees = countRs.getInt("TOTAL_EMP"); }

        String sql = "SELECT POSITION, COUNT(*) as TOTAL FROM EMPLOYEE GROUP BY POSITION ORDER BY TOTAL DESC";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            String rawPosition = rs.getString("POSITION");
            labelsList.add(rawPosition != null ? escapeHtml(rawPosition) : "ไม่ระบุ");
            dataList.add(rs.getInt("TOTAL"));
        }
        
        // zennnne แก้
        List<String> barWhere  = new ArrayList<String>();
        List<Object> barParams = new ArrayList<Object>();
        if (filter.equals("custom") && !startDate.isEmpty() && !endDate.isEmpty()) {
            barWhere.add("RF.CREATE_DATE BETWEEN TO_DATE(?, 'YYYY-MM-DD') AND TO_DATE(?, 'YYYY-MM-DD')");
            barParams.add(startDate); barParams.add(endDate);
        }
        if (filterEmpId > 0) {
            barWhere.add("RF.EMPID = ?"); barParams.add(filterEmpId);
        } else if (filterSecId > 0) {
            barWhere.add("S.SECID = ?"); barParams.add(filterSecId);
        } else if (filterDeptId > 0) {
            barWhere.add("D.DEPTID = ?"); barParams.add(filterDeptId);
        }
        String barWhereStr = barWhere.isEmpty() ? "" : " WHERE " + String.join(" AND ", barWhere);
        String top5Sql =
            "SELECT RT.TYPENAME AS CATEGORY, COUNT(*) AS TOTAL " +
            "FROM REQUISITIONFORM RF " +
            "JOIN REQUEST REQ ON REQ.FORMID = RF.FORMID " +
            "JOIN REQUESTTYPE RT ON RT.TYPEID = REQ.TYPEID " +
            "JOIN EMPLOYEE E ON RF.EMPID = E.EMPID " +
            "JOIN SECTION S ON E.SECID = S.SECID " +
            "JOIN DEPARTMENT D ON S.DEPTID = D.DEPTID " +
            barWhereStr +
            " GROUP BY RT.TYPENAME ORDER BY TOTAL DESC FETCH FIRST 5 ROWS ONLY";
        pstmt2 = conn.prepareStatement(top5Sql);
        for (int i = 0; i < barParams.size(); i++) { pstmt2.setObject(i + 1, barParams.get(i)); }
        rs2 = pstmt2.executeQuery();
        while (rs2.next()) {
            String rawCategory = rs2.getString("CATEGORY");
            topCatLabels.add(rawCategory != null ? escapeHtml(rawCategory) : "ทั่วไป");
            topCatValues.add(rs2.getInt("TOTAL"));
        }
        barQueryOk = true; // zennnne แก้ — query สำเร็จ (0 rows ก็ถือว่าสำเร็จ ไม่ fallback mock)
        // zennnne แก้ end

    } catch (Exception e) {
        System.out.println("DB Connection Status: Fallback Mode Enabled.");
    } finally {
        if (countRs != null) try { countRs.close(); } catch (SQLException e) {}
        if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (rs2 != null) try { rs2.close(); } catch (SQLException e) {}
        if (pstmt2 != null) try { pstmt2.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }

    // zennnne แก้
    try {
        LookupDAO lookupDao = new LookupDAO();
        allDepts    = lookupDao.getAllDepartments();
        allSections = lookupDao.getAllSections();
        allEmps     = lookupDao.getAllEmployees();

        StringBuilder sbSec = new StringBuilder("[");
        for (int i = 0; i < allSections.size(); i++) {
            if (i > 0) sbSec.append(",");
            Section sc = allSections.get(i);
            sbSec.append("{\"secId\":").append(sc.getSecId())
                 .append(",\"secName\":\"").append(escapeJson(sc.getSecName())).append("\"")
                 .append(",\"deptId\":").append(sc.getDeptId()).append("}");
        }
        sbSec.append("]");
        sectionsJson = sbSec.toString();

        StringBuilder sbEmp = new StringBuilder("[");
        for (int i = 0; i < allEmps.size(); i++) {
            if (i > 0) sbEmp.append(",");
            Employee empItem = allEmps.get(i);
            sbEmp.append("{\"empId\":").append(empItem.getEmpId())
                 .append(",\"empName\":\"").append(escapeJson(empItem.getEmpName())).append("\"")
                 .append(",\"secId\":").append(empItem.getSecId()).append("}");
        }
        sbEmp.append("]");
        empsJson = sbEmp.toString();
    } catch (Exception e) { /* fallback: empty lists */ }
    // zennnne แก้ end

    // ---- Keep your mock data fallback exactly as before ----
    if (labelsList.isEmpty()) {
        labelsList.addAll(Arrays.asList("<script>alert('XSS_Tested')</script>", "IT Planning", "Infrastructure", "Development", "Data", "Research", "เจ้าหน้าที่คัดดี", "Admin", "IT Director", "Cyber Security"));
        dataList.addAll(Arrays.asList(12, 8, 7, 6, 4, 3, 2, 2, 1, 1));
    }
    if (topCatLabels.isEmpty() && !barQueryOk) { // zennnne แก้ — fallback เฉพาะเมื่อ DB พัง ไม่ใช่ผลลัพธ์ว่างจาก filter
        topCatLabels.addAll(Arrays.asList("ปัญหา Network", "ขอสิทธิ์เข้าใช้งาน", "เบิกอุปกรณ์ IT", "ซ่อมบำรุง HW", "ลงโปรแกรม/ซอฟต์แวร์"));
        topCatValues.addAll(Arrays.asList(45, 38, 25, 20, 15));
    }
    if (totalEmployees == 0) { totalEmployees = 40; }

    StringBuilder sbLabels = new StringBuilder(); StringBuilder sbValues = new StringBuilder();
    for(int i=0; i<labelsList.size(); i++){
        if(i>0) { sbLabels.append(","); sbValues.append(","); }
        sbLabels.append("\"").append(escapeJson(labelsList.get(i))).append("\""); 
        sbValues.append(dataList.get(i));
    }
    String pieLabelsJson = "[" + sbLabels.toString() + "]"; String pieValuesJson = "[" + sbValues.toString() + "]";

    StringBuilder sbBarLabels = new StringBuilder(); StringBuilder sbBarValues = new StringBuilder();
    for(int i=0; i<topCatLabels.size(); i++){
        if(i>0) { sbBarLabels.append(","); sbBarValues.append(","); }
        sbBarLabels.append("\"").append(escapeJson(topCatLabels.get(i))).append("\""); 
        sbBarValues.append(topCatValues.get(i));
    }
    String barLabelsJson = "[" + sbBarLabels.toString() + "]"; String barValuesJson = "[" + sbBarValues.toString() + "]";
    
    String trendLabelsJson = "";
    String trendDataJson = "";
    String chartTitle = "";
    
    if (filter.equals("7days")) {
        chartTitle = "สถิติปริมาณใบคำขอย้อนหลัง 7 วัน (รายวัน)";
        trendLabelsJson = "[\"อาทิตย์\",\"จันทร์\",\"อังคาร\",\"พุธ\",\"พฤหัสบดี\",\"ศุกร์\",\"เสาร์\"]";
        trendDataJson = "[3, 5, 2, 8, 6, 9, 4]";
    } 
    else if (filter.equals("30days")) {
        chartTitle = "สถิติปริมาณใบคำขอย้อนหลัง 30 วัน (รายสัปดาห์)";
        trendLabelsJson = "[\"สัปดาห์ที่ 1\",\"สัปดาห์ที่ 2\",\"สัปดาห์ที่ 3\",\"สัปดาห์ที่ 4\"]";
        trendDataJson = "[15, 28, 22, 34]";
    } 
    else if (filter.equals("quarters")) {
        chartTitle = "สรุปปริมาณใบคำขอแบ่งตามรายไตรมาส (ปีปัจจุบัน)";
        trendLabelsJson = "[\"ไตรมาส 1 (Q1)\",\"ไตรมาส 2 (Q2)\",\"ไตรมาส 3 (Q3)\",\"ไตรมาส 4 (Q4)\"]";
        trendDataJson = "[65, 82, 58, 94]";
    } 
    else if (filter.equals("forecast")) {
        chartTitle = "โมเดลวิเคราะห์และพยากรณ์แนวโน้มปริมาณคำขอ 3 ปีข้างหน้า (Forecasting)";
        trendLabelsJson = "[\"ปีปัจจุบัน (2026)\",\"ปีหน้า (2027)\",\"ปีถัดไป (2028)\",\"อนาคต (2029)\"]";
        trendDataJson = "[294, 345, 412, 490]";
    }
    else if (filter.equals("custom")) {
        chartTitle = "ผลการสืบค้นข้อมูลช่วงวันที่ " + escapeHtml(startDate) + " ถึง " + escapeHtml(endDate);
        trendLabelsJson = "[\"ช่วงเริ่มต้น\",\"ช่วงกลาง\",\"ช่วงสิ้นสุด\"]";
        trendDataJson = "[40, 65, 52]";
    }

    // zennnne แก้
    String drillSuffix = (filterDeptId > 0 ? "&deptId=" + filterDeptId : "") +
                         (filterSecId  > 0 ? "&secId="  + filterSecId  : "") +
                         (filterEmpId  > 0 ? "&empId="  + filterEmpId  : "");
    // zennnne แก้ end
%>



<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IT Requisition - Executive Dashboard</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { font-family: 'Sarabun', sans-serif; background-color: #f4f7f6; margin: 0; padding: 0; overflow-x: hidden; }
        .container { max-width: 1300px; margin: 25px auto; padding: 0 20px; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; border-bottom: 3px solid #3272BB; padding-bottom: 10px; }
        .filter-container { background: white; border-radius: 15px; padding: 20px 25px; margin-bottom: 25px; box-shadow: 0 4px 10px rgba(0,0,0,0.05); display: flex; flex-direction: column; gap: 15px; border: 1px solid #e0e0e0; }
        .filter-row { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 15px; }
        .filter-title { font-weight: bold; color: #003366; display: flex; align-items: center; gap: 8px; }
        .filter-buttons { display: flex; gap: 10px; flex-wrap: wrap; }
        .btn-filter { background: #f0f3f5; color: #555; border: 1px solid #ccc; padding: 8px 16px; border-radius: 8px; cursor: pointer; font-weight: bold; transition: all 0.2s ease; font-family: 'Sarabun', sans-serif; text-decoration: none; font-size: 0.9rem; }
        .btn-filter:hover { background: #e2e6e9; color: #003366; }
        .btn-filter.active { background: #3272BB; color: white; border-color: #3272BB; box-shadow: 0 3px 6px rgba(50,114,187,0.3); }
        .date-picker-form { display: flex; align-items: center; gap: 10px; background: #f8fafc; padding: 8px 15px; border-radius: 10px; border: 1px dashed #3272BB; }
        .date-input { padding: 6px 10px; border: 1px solid #ccc; border-radius: 6px; font-family: 'Sarabun', sans-serif; font-size: 0.9rem; color: #333; outline: none; }
        .date-input:focus { border-color: #3272BB; }
        .btn-submit-date { background: #2ecc71; color: white; border: none; padding: 7px 15px; border-radius: 6px; font-weight: bold; cursor: pointer; font-family: 'Sarabun', sans-serif; font-size: 0.9rem; transition: background 0.2s; }
        .btn-submit-date:hover { background: #27ae60; }
        .grid-kpi { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; margin-bottom: 25px; }
        .kpi-card { background: #3272BB; color: white; border-radius: 15px; padding: 20px; text-align: center; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
        .kpi-card h2 { margin: 10px 0 0 0; font-size: 2.5rem; }
        .grid-charts { display: grid; grid-template-columns: repeat(2, 1fr); gap: 25px; margin-bottom: 25px; }
        .full-chart { grid-column: span 2; }
        .chart-card { background: white; border-radius: 20px; padding: 25px; box-shadow: 0 4px 10px rgba(0,0,0,0.05); border: 1px solid #e0e0e0; }
        .chart-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }
        .chart-header h3 { color: #003366; margin: 0; font-size: 1.1rem; }
        .btn-export { background: #f0f3f5; border: none; width: 35px; height: 35px; border-radius: 50%; cursor: pointer; color: #555; }
        /* zennnne แก้ */
        .bar-filter-select { padding: 6px 10px; border: 1px solid #ccc; border-radius: 8px; font-family: 'Sarabun', sans-serif; font-size: 0.88rem; color: #333; background: #f8fafc; cursor: pointer; outline: none; min-width: 110px; }
        .bar-filter-select:focus { border-color: #3272BB; }
        @keyframes slideInFilter { from { opacity: 0; transform: translateX(-8px); } to { opacity: 1; transform: translateX(0); } }
        .bar-filter-reveal { animation: slideInFilter 0.2s ease; }
        /* zennnne แก้ end */
    </style>
</head>
<body>

<%@ include file="/WEB-INF/sidebar.jsp" %>

<div id="main">
    <div class="sticky-bar">
        <i id="menuBtn" class="fa-solid fa-bars" onclick="toggleNav()"></i>
        <img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF Logo">
        <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo">

        <div class="user-info">
            <i class="fa fa-circle-user"></i>
            <p>${sessionScope.loggedInEmpName} | ID: ${sessionScope.loggedInEmpId}</p>
        </div>
        <div class="contact-info">
            <i class="fa-solid fa-circle-info"></i>
            <p>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
        </div>
    </div>

<div id="data-bridge"
     data-trend-labels='<%= escapeHtml(trendLabelsJson) %>'
     data-trend-values='<%= escapeHtml(trendDataJson) %>'
     data-pie-labels='<%= escapeHtml(pieLabelsJson) %>'
     data-pie-values='<%= escapeHtml(pieValuesJson) %>'
     data-bar-labels='<%= escapeHtml(barLabelsJson) %>'
     data-bar-values='<%= escapeHtml(barValuesJson) %>'
     data-sections='<%= escapeHtml(sectionsJson) %>'
     data-emps='<%= escapeHtml(empsJson) %>'
     style="display: none;">
</div>
<div class="container">
    <div class="header">
        <h1><i class="fa-solid fa-chart-pie" style="color:#3272BB;"></i> IT Requisition Dashboard (BA Overview)</h1>
        <a href="Admin.jsp" style="text-decoration:none; background:#3272BB; color:white; padding:10px 20px; border-radius:10px; font-weight:bold;"><i class="fa fa-arrow-left"></i> กลับหน้าหลัก</a>
    </div>

    <div class="filter-container">
        <div class="filter-row">
            <div class="filter-title"><i class="fa-solid fa-filter" style="color: #3272BB;"></i> เลือกมุมมองข้อมูลด่วน:</div>
            <div class="filter-buttons">
                <!-- zennnne แก้ -->
                <a href="Dashboard.jsp?timeFilter=7days<%= drillSuffix %>" class="btn-filter <%= filter.equals("7days") ? "active" : "" %>">7 วันย้อนหลัง</a>
                <a href="Dashboard.jsp?timeFilter=30days<%= drillSuffix %>" class="btn-filter <%= filter.equals("30days") ? "active" : "" %>">30 วันย้อนหลัง</a>
                <a href="Dashboard.jsp?timeFilter=quarters<%= drillSuffix %>" class="btn-filter <%= filter.equals("quarters") ? "active" : "" %>">มุมมองรายไตรมาส</a>
                <a href="Dashboard.jsp?timeFilter=forecast<%= drillSuffix %>" class="btn-filter <%= filter.equals("forecast") ? "active" : "" %>" style="border-color: #2ecc71; color: <%= filter.equals("forecast") ? "#fff" : "#27ae60" %>;">
                    <i class="fa-solid fa-wand-magic-sparkles"></i> ทำนายผลอนาคต 3 ปี
                </a>
                <!-- zennnne แก้ end -->
            </div>
        </div>
        
        <div class="filter-row" style="border-top: 1px solid #f0f0f0; padding-top: 12px;">
            <div class="filter-title" style="font-size: 0.9rem; color:#555;"><i class="fa-regular fa-calendar-days" style="color: #3272BB;"></i> หรือกำหนดช่วงเวลาด้วยตนเอง:</div>
            <form action="Dashboard.jsp" method="GET" class="date-picker-form">
                <!-- zennnne แก้ -->
                <% if (filterDeptId > 0) { %><input type="hidden" name="deptId" value="<%= filterDeptId %>"><% } %>
                <% if (filterSecId  > 0) { %><input type="hidden" name="secId"  value="<%= filterSecId  %>"><% } %>
                <% if (filterEmpId  > 0) { %><input type="hidden" name="empId"  value="<%= filterEmpId  %>"><% } %>
                <!-- zennnne แก้ end -->
                <label style="font-size:0.85rem; color:#666;">เริ่มต้น:</label>
                <input type="date" name="startDate" value="<%= escapeHtml(startDate) %>" class="date-input" required>
                <label style="font-size:0.85rem; color:#666;">สิ้นสุด:</label>
                <input type="date" name="endDate" value="<%= escapeHtml(endDate) %>" class="date-input" required>
                <button type="submit" class="btn-submit-date"><i class="fa fa-search"></i> ค้นหา</button>
                <% if(filter.equals("custom")) { %>
                    <a href="Dashboard.jsp?timeFilter=30days<%= drillSuffix %>" style="color:#e74c3c; font-size:0.85rem; font-weight:bold; text-decoration:none; margin-left:5px;"><i class="fa fa-times-circle"></i> ล้างตัวกรอง</a>
                <% } %>
            </form>
        </div>
    </div>

    <div class="grid-kpi">
        <div class="kpi-card"><div><i class="fa-solid fa-users fa-2x"></i></div><span>พนักงานทั้งหมดในระบบ</span><h2><%= totalEmployees %> คน</h2></div>
        <div class="kpi-card" style="background:#2ecc71;"><div><i class="fa-solid fa-circle-check fa-2x"></i></div><span>ดำเนินการเสร็จสิ้นเดือนนี้</span><h2>94%</h2></div>
        <div class="kpi-card" style="background:#e67e22;"><div><i class="fa-solid fa-clock fa-2x"></i></div><span>ระยะเวลาเฉลี่ย (SLA)</span><h2>1.5 วัน</h2></div>
        <div class="kpi-card" style="background:#e74c3c;"><div><i class="fa-solid fa-triangle-exclamation fa-2x"></i></div><span>จำนวนการดำเนินการที่เลยกำหนด</span><h2>2 รายการ</h2></div>
    </div>

    <div class="grid-charts">
        <div class="chart-card">
            <div class="chart-header"><h3><%= chartTitle %></h3><button class="btn-export" onclick="downloadChart('trendChart')"><i class="fa fa-camera"></i></button></div>
            <canvas id="trendChart"></canvas>
        </div>
        <div class="chart-card">
            <div class="chart-header"><h3>สัดส่วนพนักงานแยกตามประเภทส่วนงาน</h3><button class="btn-export" onclick="downloadChart('pieChart')"><i class="fa fa-camera"></i></button></div>
            <canvas id="pieChart"></canvas>
        </div>
        <div class="chart-card full-chart">
            <!-- zennnne แก้ -->
            <div class="chart-header" style="flex-wrap:wrap; gap:10px;">
                <h3><i class="fa fa-trophy" style="color:#f1c40f;"></i> 5 อันดับประเภทใบคำขอที่ถูกแจ้งเข้ามามากที่สุด</h3>
                <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap;">
                    <div style="display:flex; align-items:center; gap:8px;">
                        <select id="deptSelect" class="bar-filter-select" onchange="cascadeSection(this)">
                            <option value="">แผนก</option>
                            <% for (Department dept : allDepts) { %>
                                <option value="<%= dept.getDeptId() %>"
                                    <%= (filterDeptId == dept.getDeptId() ? "selected" : "") %>>
                                    <%= escapeHtml(dept.getDeptName()) %>
                                </option>
                            <% } %>
                        </select>

                        <select id="secSelect" class="bar-filter-select bar-filter-reveal"
                                style="<%= filterDeptId > 0 ? "" : "display:none;" %>"
                                onchange="cascadeEmployee(this)">
                            <option value="">ส่วน</option>
                            <% for (Section sec : allSections) {
                                   if (filterDeptId == 0 || sec.getDeptId() == filterDeptId) { %>
                                <option value="<%= sec.getSecId() %>"
                                    <%= (filterSecId == sec.getSecId() ? "selected" : "") %>>
                                    <%= escapeHtml(sec.getSecName()) %>
                                </option>
                            <% } } %>
                        </select>

                        <select id="empSelect" class="bar-filter-select bar-filter-reveal"
                                style="<%= filterSecId > 0 ? "" : "display:none;" %>"
                                onchange="fetchBarData()">
                            <option value="">คน</option>
                            <% for (Employee empItem : allEmps) {
                                   if (filterSecId == 0 || empItem.getSecId() == filterSecId) { %>
                                <option value="<%= empItem.getEmpId() %>"
                                    <%= (filterEmpId == empItem.getEmpId() ? "selected" : "") %>>
                                    <%= escapeHtml(empItem.getEmpName()) %>
                                </option>
                            <% } } %>
                        </select>

                        <a id="clearBarBtn" href="javascript:clearBarFilter()"
                           style="color:#e74c3c; font-size:0.85rem; font-weight:bold; text-decoration:none;
                                  <%= (filterDeptId > 0 || filterSecId > 0 || filterEmpId > 0) ? "" : "display:none;" %>">
                            <i class="fa fa-times-circle"></i> ล้าง
                        </a>
                    </div>
                    <button class="btn-export" onclick="downloadChart('topBarChart')"><i class="fa fa-camera"></i></button>
                </div>
            </div>
            <!-- zennnne แก้ end -->
            <canvas id="topBarChart" style="max-height: 320px;"></canvas>
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

    function downloadChart(id) {
        const a = document.createElement('a');
        a.href = document.getElementById(id).toDataURL('image/png');
        a.download = id + '.png'; a.click();
    }

    const db = document.getElementById('data-bridge');
    const trendLabels = JSON.parse(db.getAttribute('data-trend-labels'));
    const trendValues = JSON.parse(db.getAttribute('data-trend-values'));
    const pieLabels = JSON.parse(db.getAttribute('data-pie-labels'));
    const pieValues = JSON.parse(db.getAttribute('data-pie-values'));
    const barLabels = JSON.parse(db.getAttribute('data-bar-labels'));
    const barValues = JSON.parse(db.getAttribute('data-bar-values'));

    // zennnne แก้
    const allSectionsData = JSON.parse(db.getAttribute('data-sections'));
    const allEmpsData     = JSON.parse(db.getAttribute('data-emps'));

    function cascadeSection(deptSel) {
        const deptId = parseInt(deptSel.value) || 0;
        const secSel = document.getElementById('secSelect');
        const empSel = document.getElementById('empSelect');
        secSel.innerHTML = '<option value="">ส่วน</option>';
        empSel.innerHTML = '<option value="">คน</option>';
        empSel.style.display = 'none';
        if (deptId) {
            allSectionsData.filter(s => s.deptId === deptId).forEach(s => {
                secSel.add(new Option(s.secName, s.secId));
            });
            secSel.style.display = 'inline-block';
        } else {
            secSel.style.display = 'none';
        }
        fetchBarData();
    }

    function cascadeEmployee(secSel) {
        const secId = parseInt(secSel.value) || 0;
        const empSel = document.getElementById('empSelect');
        empSel.innerHTML = '<option value="">คน</option>';
        if (secId) {
            allEmpsData.filter(e => e.secId === secId).forEach(e => {
                empSel.add(new Option(e.empName, e.empId));
            });
            empSel.style.display = 'inline-block';
        } else {
            empSel.style.display = 'none';
        }
        fetchBarData();
    }

    function fetchBarData() {
        const deptId = document.getElementById('deptSelect').value || '';
        const secId  = document.getElementById('secSelect').value  || '';
        const empId  = document.getElementById('empSelect').value  || '';

        const params = new URLSearchParams({ timeFilter: currentFilter, deptId, secId, empId });
        if (currentFilter === 'custom') {
            params.set('startDate', currentStartDate);
            params.set('endDate',   currentEndDate);
        }

        fetch(contextPath + '/dashboardBarData?' + params.toString())
            .then(r => r.json())
            .then(data => {
                topBarChartInstance.data.labels              = data.labels;
                topBarChartInstance.data.datasets[0].data   = data.values;
                topBarChartInstance.update();
                document.getElementById('clearBarBtn').style.display =
                    (deptId || secId || empId) ? 'inline' : 'none';
            })
            .catch(() => {}); // DB down — chart stays as-is
    }

    function clearBarFilter() {
        document.getElementById('deptSelect').value = '';
        const secSel = document.getElementById('secSelect');
        const empSel = document.getElementById('empSelect');
        secSel.innerHTML = '<option value="">ส่วน</option>';
        secSel.style.display = 'none';
        empSel.innerHTML = '<option value="">คน</option>';
        empSel.style.display = 'none';
        fetchBarData();
    }
    // zennnne แก้ end

    // zennnne แก้
    const contextPath      = '<%= request.getContextPath() %>';
    const currentFilter    = '<%= filter %>';
    const currentStartDate = '<%= escapeHtml(startDate) %>';
    const currentEndDate   = '<%= escapeHtml(endDate) %>';
    // zennnne แก้ end
    const lineColor = currentFilter === 'forecast' ? '#2ecc71' : '#3272BB';
    const areaColor = currentFilter === 'forecast' ? 'rgba(46, 204, 113, 0.1)' : 'rgba(50, 114, 187, 0.1)';
    
    new Chart(document.getElementById('trendChart'), {
        type: 'line',
        data: { 
            labels: trendLabels, 
            datasets: [{ 
                label: currentFilter === 'forecast' ? 'พยากรณ์ปริมาณคำขอ (เรื่อง)' : 'ปริมาณใบคำขอ (เรื่อง)', 
                data: trendValues, 
                borderColor: lineColor, fill: true, backgroundColor: areaColor, tension: 0.3, pointRadius: 4 
            }] 
        }
    });

    new Chart(document.getElementById('pieChart'), {
        type: 'pie',
        data: { labels: pieLabels, datasets: [{ data: pieValues, backgroundColor: ['#3498db', '#2ecc71', '#e67e22', '#9b59b6', '#f1c40f', '#e74c3c', '#1abc9c', '#2c3e50', '#7f8c8d', '#d35400'] }] },
        options: { plugins: { legend: { position: 'bottom' } } }
    });

    const topBarChartInstance = new Chart(document.getElementById('topBarChart'), { // zennnne แก้
        type: 'bar',
        data: {
            labels: barLabels,
            datasets: [{
                label: 'จำนวนใบคำขอ (เรื่อง)',
                data: barValues,
                backgroundColor: ['rgba(50,114,187,0.8)', 'rgba(46,204,113,0.8)', 'rgba(230,126,34,0.8)', 'rgba(155,89,182,0.8)', 'rgba(52,152,219,0.8)'],
                borderWidth: 1, borderRadius: 6
            }]
        },
        options: {
            responsive: true,
            scales: { y: { beginAtZero: true, grid: { display: false } }, x: { grid: { display: false } } },
            plugins: { legend: { display: false } }
        }
    });
</script>
</body>
</html>
