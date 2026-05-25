<%@ include file="/WEB-INF/checkAuth.jsp" %>
<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*, com.slf.dao.DBConnection" %>
<%
    String idParam = request.getParameter("id");
    if (idParam == null || idParam.trim().isEmpty()) {
        response.sendRedirect("submit");
        return;
    }
    int formId = Integer.parseInt(idParam);

    Connection conn = null;
    PreparedStatement psHeader = null, psItems = null, psPerm = null, psApproval = null;
    ResultSet rsHeader = null, rsItems = null, rsPerm = null, rsApproval = null;

    String fullName = "", sectionName = "", departmentName = "", phone = "";
    String requestDate = "", deadline = "", requestTitle = "", status = "";
    boolean found = false;

    java.util.List<java.util.Map<String,String>> items = new java.util.ArrayList<>();
    java.util.List<java.util.Map<String,Object>> permissions = new java.util.ArrayList<>();
    java.util.Map<String, java.util.Map<String,String>> approvalSections = new java.util.LinkedHashMap<>();

    approvalSections.put("director", createStandbyApproval("ผู้อำนวยการฝ่าย"));
    approvalSections.put("technical", createStandbyApproval("Technical"));
    approvalSections.put("itDirector", createStandbyApproval("ผู้อำนวยการฝ่ายเทคโนโลยีสารสนเทศ"));
    approvalSections.put("process", createStandbyApproval("ผู้ดำเนินการแก้ไข"));
%>
<%!
    private java.util.Map<String,String> createStandbyApproval(String label) {
        java.util.Map<String,String> row = new java.util.HashMap<>();
        row.put("label", label);
        row.put("hasApproval", "false");
        return row;
    }

    private String approvalKey(int stateStep) {
        int step = Math.abs(stateStep);
        if (step == 1) return "director";
        if (step == 2) return "technical";
        if (step == 3) return "itDirector";
        if (step == 4) return "process";
        return null;
    }

    private String nvlDisplay(String value) {
        return (value == null || value.trim().isEmpty()) ? "-" : value.trim();
    }

    private String approvalActionText(int stateStep) {
        return stateStep < 0 ? "ไม่อนุมัติ" : "อนุมัติ";
    }
%>

<%
    try {
        conn = DBConnection.getConnection();

        // ---------- Header ----------
        String headerSQL =
            "SELECT E.EMPNAME, E.PHONE, S.SECNAME, D.DEPTNAME, " +
            "RF.TITLEFORM, TO_CHAR(RF.REQUESTDATE, 'DD/MM/YYYY') AS REQDATE, " +
            "TO_CHAR(RF.DEADLINE, 'DD/MM/YYYY') AS DDL, RF.STATUS " +
            "FROM REQUISITIONFORM RF " +
            "JOIN EMPLOYEE E ON RF.EMPID = E.EMPID " +
            "LEFT JOIN SECTION S ON E.SECID = S.SECID " +
            "LEFT JOIN DEPARTMENT D ON S.DEPTID = D.DEPTID " +
            "WHERE RF.FORMID = ?";
        psHeader = conn.prepareStatement(headerSQL);
        psHeader.setInt(1, formId);
        rsHeader = psHeader.executeQuery();
        if (rsHeader.next()) {
            found = true;
            fullName = rsHeader.getString("EMPNAME");
            phone = rsHeader.getString("PHONE") != null ? rsHeader.getString("PHONE").trim() : "";
            sectionName = rsHeader.getString("SECNAME") != null ? rsHeader.getString("SECNAME").trim() : "";
            departmentName = rsHeader.getString("DEPTNAME") != null ? rsHeader.getString("DEPTNAME").trim() : "";
            requestTitle = rsHeader.getString("TITLEFORM");
            requestDate = rsHeader.getString("REQDATE");
            deadline = rsHeader.getString("DDL");
            status = rsHeader.getString("STATUS");
        }

        // ---------- Request items ----------
        if (found) {
            String itemsSQL =
                "SELECT RT.TYPENAME, R.TYPEID, R.OTHERDETAILS_OR_PROGRAM, " +
                "R.DETAILOBJECTIVE, R.CURRENTMETHOD " +
                "FROM REQUEST R " +
                "JOIN REQUESTTYPE RT ON R.TYPEID = RT.TYPEID " +
                "WHERE R.FORMID = ? ORDER BY R.REQUESTID";
            psItems = conn.prepareStatement(itemsSQL);
            psItems.setInt(1, formId);
            rsItems = psItems.executeQuery();
            while (rsItems.next()) {
                java.util.Map<String,String> item = new java.util.HashMap<>();
                item.put("typeName", rsItems.getString("TYPENAME"));
                item.put("typeId", String.valueOf(rsItems.getInt("TYPEID")));
                String sProg = rsItems.getString("OTHERDETAILS_OR_PROGRAM");
                item.put("programOrOther", (sProg != null) ? sProg.trim() : "");
                String sObj = rsItems.getString("DETAILOBJECTIVE");
                item.put("objective", (sObj != null) ? sObj.trim() : "");
                String sCurr = rsItems.getString("CURRENTMETHOD");
                item.put("currentMethod", (sCurr != null) ? sCurr.trim() : "");
                items.add(item);
            }
        }

        // ---------- Permissions (for server access) ----------
        if (found) {
            String permSQL = "SELECT ISROOT, PATH, HASFULLCONTROL, HASMODIFY, " +
                             "HASREADEXECUTE, HASREAD, HASWRITE " +
                             "FROM PERMISSIONDETAILS WHERE FORMID = ? ORDER BY ISROOT DESC, PATH";
            psPerm = conn.prepareStatement(permSQL);
            psPerm.setInt(1, formId);
            rsPerm = psPerm.executeQuery();
            while (rsPerm.next()) {
                java.util.Map<String,Object> perm = new java.util.HashMap<>();
                perm.put("isRoot", rsPerm.getInt("ISROOT"));
                perm.put("path", rsPerm.getString("PATH"));
                perm.put("full", rsPerm.getInt("HASFULLCONTROL"));
                perm.put("modify", rsPerm.getInt("HASMODIFY"));
                perm.put("readExec", rsPerm.getInt("HASREADEXECUTE"));
                perm.put("read", rsPerm.getInt("HASREAD"));
                perm.put("write", rsPerm.getInt("HASWRITE"));
                permissions.add(perm);
            }
        }

        // ---------- Approvals (if you want to display them) ----------
        if (found) {
            String approvalSQL =
                "SELECT AI.STATE_STEP, AI.IT_COMMENT, " +
                "TO_CHAR(AI.APPROVED_DATE, 'DD/MM/YYYY') AS APPROVED_DAY, " +
                "TO_CHAR(AI.APPROVED_DATE, 'HH24:MI') AS APPROVED_TIME, " +
                "EMP.EMPNAME, EMP.POSITION " +
                "FROM APPROVALINFO AI " +
                "LEFT JOIN EMPLOYEE EMP ON AI.REVIEWER_EMPID = EMP.EMPID " +
                "WHERE AI.FORMID = ? " +
                "AND ABS(AI.STATE_STEP) BETWEEN 1 AND 4 " +
                "ORDER BY AI.APPROVALID";
            psApproval = conn.prepareStatement(approvalSQL);
            psApproval.setInt(1, formId);
            rsApproval = psApproval.executeQuery();
            while (rsApproval.next()) {
                int stateStep = rsApproval.getInt("STATE_STEP");
                String key = approvalKey(stateStep);
                if (key != null && approvalSections.containsKey(key)) {
                    java.util.Map<String,String> approval = approvalSections.get(key);
                    approval.put("hasApproval", "true");
                    approval.put("position", nvlDisplay(rsApproval.getString("POSITION")));
                    approval.put("empName", nvlDisplay(rsApproval.getString("EMPNAME")));
                    approval.put("action", approvalActionText(stateStep));
                    approval.put("approvedDay", nvlDisplay(rsApproval.getString("APPROVED_DAY")));
                    approval.put("approvedTime", nvlDisplay(rsApproval.getString("APPROVED_TIME")));
                    approval.put("comment", nvlDisplay(rsApproval.getString("IT_COMMENT")));
                }
            }
        }
    } catch (Exception e) {
        out.println("<div style='color:red;text-align:center;'>เกิดข้อผิดพลาด: " + e.getMessage() + "</div>");
        e.printStackTrace();
    } finally {
        try { if (rsApproval != null) rsApproval.close(); } catch (Exception ignored) {}
        try { if (psApproval != null) psApproval.close(); } catch (Exception ignored) {}
        try { if (rsPerm != null) rsPerm.close(); } catch (Exception ignored) {}
        try { if (psPerm != null) psPerm.close(); } catch (Exception ignored) {}
        try { if (rsItems != null) rsItems.close(); } catch (Exception ignored) {}
        try { if (psItems != null) psItems.close(); } catch (Exception ignored) {}
        try { if (rsHeader != null) rsHeader.close(); } catch (Exception ignored) {}
        try { if (psHeader != null) psHeader.close(); } catch (Exception ignored) {}
        try { if (conn != null) conn.close(); } catch (Exception ignored) {}
    }
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <title>ใบขอให้ดำเนินการ #<%= formId %></title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Sarabun:wght@400;600;700&display=swap');

        @page {
            size: A4;
            margin: 10mm 12mm 10mm 12mm;
        }

        body {
            font-family: 'Sarabun', sans-serif;
            margin: 0;
            padding: 0;
            font-size: 9.5pt;
            line-height: 1.4;
            color: #000;
            background-color: #fff;
            -webkit-print-color-adjust: exact;
            print-color-adjust: exact;
        }

        .meta-top-right {
            text-align: right;
            font-size: 9.5pt;
            margin-bottom: 4px;
            color: #444;
        }

        .meta-top-right span {
            margin-left: 15px;
            font-weight: 600;
        }

        .head-table {
            border-collapse: collapse;
            width: 100%;
            table-layout: fixed;
            margin-bottom: 12px;
        }

        .head-table td {
            border: 1px solid #000;
            padding: 6px 8px;
            vertical-align: middle;
        }

        .head-table td.logo-cell {
            text-align: center;
            width: 18%;
        }

        .head-table td.title-cell {
            text-align: center;
            width: 57%;
        }

        .head-table td.meta-cell {
            width: 25%;
            font-size: 9.5pt;
            padding: 4px 8px;
        }

        .head-table td.meta-cell div {
            margin-bottom: 2px;
        }

        .invisible-header th {
            border: none !important;
            padding: 0 !important;
            font-size: 0 !important;
            height: 0 !important;
        }

        .section-title {
            font-size: 9.5pt;
            font-weight: 700;
            border-bottom: 1.5px solid #000;
            margin: 12px 0 6px 0;
            padding-bottom: 2px;
        }

        .info-grid-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 4px;
        }

        .info-grid-table td {
            padding: 4px 2px;
            vertical-align: baseline;
        }

        .info-label {
            font-weight: 600;
            white-space: nowrap;
        }

        .info-value {
            border-bottom: 1px dotted #444;
            padding-left: 4px;
        }

        .form-subject {
            font-size: 12pt;
            font-weight: 700;
            margin: 10px 0;
            background-color: #f5f5f5;
            padding: 6px 10px;
            border-left: 3px solid #000;
        }

        .request-card {
            border: 1px solid #000;
            margin-top: 8px;
            width: 100%;
            border-collapse: collapse;
        }

        .request-card th {
            background-color: #f5f5f5;
            border-bottom: 1px solid #000;
            padding: 6px 10px;
            text-align: left;
            font-size: 9pt;
            font-weight: 700;
        }

        .request-card td {
            padding: 8px 10px;
            font-size: 9pt;
        }

        .request-field {
            margin-bottom: 6px;
        }

        .request-field:last-child {
            margin-bottom: 0;
        }

        .perm-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 6px;
            font-size: 9pt;
        }

        .perm-table th, .perm-table td {
            border: 1px solid #666;
            padding: 4px 8px;
            text-align: left;
            vertical-align: middle;
        }

        .perm-table th {
            background-color: #fafafa;
            font-weight: 600;
        }

        .checkbox-item {
            display: inline-block;
            margin-right: 12px;
            white-space: nowrap;
        }

        .checkbox-char {
            font-family: 'Sarabun', Arial, sans-serif;
            font-size: 11pt;
            margin-right: 3px;
            font-weight: bold;
        }

        .approval-matrix {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }

        .approval-matrix td {
            border: 1px solid #000;
            width: 50%;
            padding: 8px 10px;
            vertical-align: top;
            font-size: 9.5pt;
        }

        .signature-area {
            text-align: center;
            margin-top: 8px;
        }

        .signature-line {
            margin-top: 15px;
            border-bottom: 1px dotted #000;
            display: inline-block;
            width: 160px;
        }

        .status-badge {
            font-weight: bold;
            padding: 1px 4px;
            border: 1px solid #000;
            display: inline-block;
            background: #fff;
            font-size: 8.5pt;
        }

        .btn-print {
            position: fixed;
            top: 15px;
            right: 15px;
            background: #003366;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 4px;
            cursor: pointer;
            z-index: 999;
            font-size: 13px;
            font-family: inherit;
        }

        @media print {
            .btn-print {
                display: none;
            }
        }
    </style>
</head>
<body>

<button class="btn-print" onclick="window.print()">พิมพ์เอกสาร / Print</button>

<div class="meta-top-right">
    <span>ใบขอให้ดำเนินการ / Requisition Form</span>
    <span>SLF-RF-007 V1.0</span>
</div>

<table class="head-table">
    <tr class="invisible-header">
        <th style="width: 18%;">Logo</th>
        <th style="width: 62%;">Title</th>
        <th style="width: 20%;">Meta</th>
    </tr>
    <tr>
        <td class="logo-cell" rowspan="2">
            <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo" style="max-height: 45px; max-width: 110px; object-fit: contain;">
        </td>
        <td class="title-cell">
            <strong style="font-size: 12pt; display: block; margin-bottom: 2px;">ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินกู้ยืมเพื่อการศึกษา</strong>
            <span style="font-size: 9.5pt; font-weight: 600; color: #222;">ใบขอให้ดำเนินการ / Requisition Form</span>
        </td>
        <td class="meta-cell">
            <div><strong>เลขที่เอกสาร:</strong> #<%= formId %></div>
        </td>
    </tr>
</table>

<div class="section-title">1. ข้อมูลผู้ส่งคำขอ / Requestor Information</div>
<table class="info-grid-table">
    <tr>
        <td class="info-label" style="width: 14%;">ผู้ขอใช้งาน:</td>
        <td class="info-value" style="width: 36%;"><%= fullName %></td>
        <td class="info-label" style="width: 10%; text-align: right;">ส่วน:</td>
        <td class="info-value" style="width: 40%;"><%= sectionName %></td>
    </tr>
    <tr>
        <td class="info-label">ฝ่าย / สำนัก:</td>
        <td class="info-value"><%= departmentName %></td>
        <td class="info-label" style="text-align: right;">เบอร์ภายใน:</td>
        <td class="info-value"><%= phone %></td>
    </tr>
    <tr>
        <td class="info-label">วันที่ยื่นคำขอ:</td>
        <td class="info-value"><%= requestDate %></td>
        <td class="info-label" style="text-align: right;">Deadline:</td>
        <td class="info-value" style="color: #b30000; font-weight: 600;"><%= deadline %></td>
    </tr>
</table>

<div class="form-subject">
    <strong>หัวข้อความต้องการ:</strong> <%= requestTitle %>
</div>

<div class="section-title">2. รายละเอียดความต้องการ / Request Details</div>
<%
    for (int i = 0; i < items.size(); i++) {
        java.util.Map<String,String> it = items.get(i);
        String typeName = it.get("typeName");
        boolean isProgram = "ขอติดตั้งโปรแกรม".equals(typeName) || "ขอให้พัฒนาโปรแกรม".equals(typeName);
        boolean isOther = "อื่นๆ".equals(typeName) || "อื่น ๆ".equals(typeName);
        boolean isServer = "ขอใช้สิทธิ์เก็บข้อมูล".equals(typeName);
%>
<table class="request-card">
    <tr>
        <th>ความประสงค์ที่ <%= i+1 %>: <%= typeName %></th>
    </tr>
    <tr>
        <td>
            <% if (isProgram || isOther) { %>
                <div class="request-field">
                    <strong><%= isProgram ? "ชื่อระบบงาน/โปรแกรม" : "รายละเอียดเพิ่มเติม" %>:</strong> 
                    <%= it.get("programOrOther") %>
                </div>
            <% } %>

            <div class="request-field">
                <strong>วัตถุประสงค์และความจำเป็น:</strong> 
                <%= it.get("objective") %>
            </div>
            
            <div class="request-field">
                <strong>กระบวนการหรือวิธีการทำงานปัจจุบัน:</strong> 
                <%= it.get("currentMethod") %>
            </div>

            <% if (isServer && !permissions.isEmpty()) { %>
                <div style="margin-top: 8px;">
                    <strong>รายละเอียดการขอสิทธิ์การเข้าถึงข้อมูลระบบ (Server Access Matrix):</strong>
                    <table class="perm-table">
                        <thead>
                            <tr>
                                <th style="width: 40%;">เส้นทางโฟลเดอร์ (Server / Folder Path)</th>
                                <th style="width: 60%;">สิทธิ์การเข้าใช้งานที่ได้รับ (Permissions Assigned)</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (java.util.Map<String,Object> perm : permissions) {
                                String path = (String) perm.get("path");
                                String serverName = "", shareName = "";
                                if (path != null && path.startsWith("\\\\")) {
                                    String noPrefix = path.substring(2);
                                    int slashIdx = noPrefix.indexOf("\\");
                                    if (slashIdx > 0) {
                                        serverName = noPrefix.substring(0, slashIdx);
                                        shareName = noPrefix.substring(slashIdx + 1);
                                    } else {
                                        serverName = noPrefix;
                                    }
                                }
                                boolean full = (Integer)perm.get("full") == 1;
                                boolean modify = (Integer)perm.get("modify") == 1;
                                boolean readExec = (Integer)perm.get("readExec") == 1;
                                boolean read = (Integer)perm.get("read") == 1;
                                boolean write = (Integer)perm.get("write") == 1;
                            %>
                                <tr>
                                    <td>\\<%= serverName %>\<%= shareName %></td>
                                    <td>
                                        <span class="checkbox-item"><span class="checkbox-char"><%= full ? "&#9746;" : "&#9744;" %></span> Full control</span>
                                        <span class="checkbox-item"><span class="checkbox-char"><%= modify ? "&#9746;" : "&#9744;" %></span> Modify</span>
                                        <span class="checkbox-item"><span class="checkbox-char"><%= readExec ? "&#9746;" : "&#9744;" %></span> Read & Execute</span>
                                        <span class="checkbox-item"><span class="checkbox-char"><%= read ? "&#9746;" : "&#9744;" %></span> Read</span>
                                        <span class="checkbox-item"><span class="checkbox-char"><%= write ? "&#9746;" : "&#9744;" %></span> Write</span>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </td>
    </tr>
</table>
<% } %>

<div class="section-title">3. ความเห็นและผลการตรวจสอบพิจารณา / Sign-off & Approval Routing</div>
<table class="approval-matrix">
    <%
        java.util.List<java.util.Map<String,String>> sectionsList = new java.util.ArrayList<>(approvalSections.values());
        for (int k = 0; k < sectionsList.size(); k += 2) {
    %>
    <tr>
        <% for (int stepOffset = 0; stepOffset < 2; stepOffset++) { 
            if ((k + stepOffset) < sectionsList.size()) {
                java.util.Map<String,String> approval = sectionsList.get(k + stepOffset);
                boolean hasApproval = "true".equals(approval.get("hasApproval"));
        %>
            <td>
                <strong>ผู้พิจารณา:</strong> <%= approval.get("label") %><br>
                <div style="margin-top: 4px; min-height: 24px;">
                    <strong>ความเห็น:</strong> 
                    <% if (hasApproval && !approval.get("comment").equals("-")) { %>
                        <%= approval.get("comment") %>
                    <% } else if (hasApproval) { %>
                        -
                    <% } else { %>
                        <span style="color:#777; font-style: italic; font-size: 9.5pt;">(รอดำเนินการพิจารณาความคิดเห็น)</span>
                    <% } %>
                </div>

                <div class="signature-area">
                    ลงชื่อ: 
                    <% if (hasApproval) { %>
                        <strong style="color: #004488; text-decoration: underline;"><%= approval.get("empName") %></strong>
                    <% } else { %>
                        <span class="signature-line"></span>
                    <% } %>
                    <br>
                    (<%= approval.get("label") %>)
                </div>

                <div style="margin-top: 6px; font-size: 9.5pt; color: #333;">
                    <strong>ผล:</strong> 
                    <% if (hasApproval) { %>
                        <span style="font-weight:bold; color:<%= "ไม่อนุมัติ".equals(approval.get("action")) ? "#cc0000" : "#006600" %>">
                            <%= approval.get("action") %>
                        </span> 
                        | <%= approval.get("approvedDay") %>
                    <% } else { %>
                        <span style="color:#666;">(รอดำเนินการระบบ)</span>
                    <% } %>
                </div>
            </td>
        <% } else { %>
            <td></td>
        <% } } %>
    </tr>
    <% } %>
</table>

</body>
</html>