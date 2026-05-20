<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>

<%
    String idParam = request.getParameter("id");
    if (idParam == null || idParam.trim().isEmpty()) {
        response.sendRedirect("submit.jsp");
        return;
    }
    int formId = Integer.parseInt(idParam);

    Connection conn = null;
    PreparedStatement psHeader = null, psItems = null, psPerm = null;
    ResultSet rsHeader = null, rsItems = null, rsPerm = null;

    String fullName = "", sectionName = "", departmentName = "", phone = "";
    String requestDate = "", deadline = "", requestTitle = "", status = "";
    boolean found = false;

    // List of items (each map holds typeName, programOrOther, objective, currentMethod, typeId)
    java.util.List<java.util.Map<String,String>> items = new java.util.ArrayList<>();
    // List of permission rows (each map holds isRoot, path, fullControl, modify, readExec, read, write)
    java.util.List<java.util.Map<String,Object>> permissions = new java.util.ArrayList<>();
%>

<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>รายละเอียดใบขอให้ดำเนินการ</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/form.css">
    <style>
        .item-block {
            position: relative;
            width: 100%;
            border: 1px solid #3272BB;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 15px;
            background-color: white;
        }
        .permission-checkbox-row label {
            margin-right: 15px;
            font-weight: normal;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        .permission-checkbox-row input[type="checkbox"] {
            width: auto;
            margin: 0;
        }
    </style>
</head>
<body>

<!-- Header and Banner (unchanged) -->
<div class="sticky-bar">
    <a href="submit.jsp" style="text-decoration:none; color:#333;"><i class="fa fa-arrow-left"></i> กลับ</a>
    <div style="margin-left:auto;display:flex;align-items:center">
        <i class="fa fa-circle-user" style="font-size:24px;padding-left:10px;padding-right:0px"></i>
        <p style="font-size:0.8rem; margin-left: 10px;margin-right: 10px">สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
    </div>
</div>
<div class="banner">
    <h1>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินกู้ยืมเพื่อการศึกษา</h1>
    <h2>ใบขอให้ดำเนินการ / Requisition Form</h2>
</div>

<%
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection(
            "jdbc:oracle:thin:@172.25.18.186:1521:XE",
            "C##DEVUSER",
            "mypassword"
        );

        // ---------- Header ----------
        String headerSQL =
            "SELECT E.EMPNAME, E.PHONE, S.SECNAME, D.DEPTNAME, " +
            "RF.TITLEFORM, TO_CHAR(RF.REQUESTDATE, 'YYYY-MM-DD') AS REQDATE, " +
            "TO_CHAR(RF.DEADLINE, 'YYYY-MM-DD') AS DDL, RF.STATUS " +
            "FROM REQUISITIONFORM RF " +
            "JOIN EMPLOYEE E ON RF.EMPID = E.EMPID " +
            "LEFT JOIN SECTION S ON RF.ASSIGN_SECID = S.SECID " +
            "LEFT JOIN DEPARTMENT D ON S.DEPTID = D.DEPTID " +
            "WHERE RF.FORMID = ?";
        psHeader = conn.prepareStatement(headerSQL);
        psHeader.setInt(1, formId);
        rsHeader = psHeader.executeQuery();
        if (rsHeader.next()) {
            found = true;
            fullName = rsHeader.getString("EMPNAME");
            String sPhone = rsHeader.getString("PHONE");
            phone = (sPhone != null) ? sPhone.trim() : "";
            String sSec = rsHeader.getString("SECNAME");
            sectionName = (sSec != null) ? sSec.trim() : "";
            String sDept = rsHeader.getString("DEPTNAME");
            departmentName = (sDept != null) ? sDept.trim() : "";
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
        // Warning: assumes only ONE server-access request per form,
        // because PERMISSIONDETAILS lacks REQUESTID!
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

    } catch (Exception e) {
        out.println("<div style='color:red;text-align:center;'>เกิดข้อผิดพลาด: " + e.getMessage() + "</div>");
        e.printStackTrace();
    } finally {
        try { if (rsPerm != null) rsPerm.close(); } catch (Exception ignored) {}
        try { if (psPerm != null) psPerm.close(); } catch (Exception ignored) {}
        try { if (rsItems != null) rsItems.close(); } catch (Exception ignored) {}
        try { if (psItems != null) psItems.close(); } catch (Exception ignored) {}
        try { if (rsHeader != null) rsHeader.close(); } catch (Exception ignored) {}
        try { if (psHeader != null) psHeader.close(); } catch (Exception ignored) {}
        try { if (conn != null) conn.close(); } catch (Exception ignored) {}
    }
%>

<!-- Main Detail -->
<div class="form-container">
    <form>
        <div class="form-grid">
            <!-- personal info -->
            <div class="form-group"><label>ชื่อ-นามสกุล</label><input type="text" value="<%= fullName %>" readonly></div>
            <div class="form-group"><label>ส่วน</label><input type="text" value="<%= sectionName %>" readonly></div>
            <div class="form-group"><label>ฝ่าย</label><input type="text" value="<%= departmentName %>" readonly></div>
            <div class="form-group"><label>เบอร์ต่อ</label><input type="text" value="<%= phone %>" readonly></div>
            <div class="form-group"><label>วันที่</label><input type="date" value="<%= requestDate %>" readonly></div>
            <div class="form-group"><label>Deadline</label><input type="date" value="<%= deadline %>" readonly></div>
            <div class="form-group" style="margin-bottom:20px;"><label>ชื่อหัวข้อความต้องการ :</label><input type="text" value="<%= requestTitle %>" readonly></div>
            <div class="form-group"><label>สถานะ</label><input type="text" value="<%= status %>" readonly></div>
        </div>

        <h3 style="margin-top:30px;">รายละเอียดคำขอ (จำนวน <%= items.size() %> รายการ)</h3>
        <%
            if (items.isEmpty()) {
        %>
            <p>ไม่มีรายการคำขอ</p>
        <%
            } else {
                for (int i = 0; i < items.size(); i++) {
                    java.util.Map<String,String> it = items.get(i);
                    String typeName = it.get("typeName");
                    boolean isProgram = "ขอติดตั้งโปรแกรม".equals(typeName) || "ขอให้พัฒนาโปรแกรม".equals(typeName);
                    boolean isOther = "อื่นๆ".equals(typeName) || "อื่น ๆ".equals(typeName);
                    boolean isServer = "ขอใช้สิทธิ์เก็บข้อมูล".equals(typeName);
        %>
            <div class="item-block">
                <div class="form-group">
                    <label>ประเภทคำขอ</label>
                    <input type="text" value="<%= typeName %>" readonly>
                </div>

                <%-- Program name or Other detail --%>
                <% if (isProgram) { %>
                    <div class="form-group">
                        <label>ชื่อโปรแกรม</label>
                        <input type="text" value="<%= it.get("programOrOther") %>" readonly>
                    </div>
                <% } else if (isOther) { %>
                    <div class="form-group">
                        <label>โปรดระบุ (อื่น ๆ)</label>
                        <input type="text" value="<%= it.get("programOrOther") %>" readonly>
                    </div>
                <% } %>

                <%-- Server permissions --%>
                <% if (isServer) { %>
                    <% if (!permissions.isEmpty()) { %>
                    <div class="form-group full-width server-permission-box" style="display:flex;">
                            <h3 class="server-permission-title">รายละเอียดการขอใช้สิทธิ์เก็บข้อมูล</h3>
                            <% for (java.util.Map<String,Object> perm : permissions) {
                                int isRoot = (Integer) perm.get("isRoot");
                                String path = (String) perm.get("path");
                                
                                // Inline extraction – no methods needed
                                String serverName = "";
                                String shareName = "";
                                if (path != null && path.startsWith("\\\\")) {
                                    String noPrefix = path.substring(2);
                                    int slashIdx = noPrefix.indexOf("\\");
                                    if (slashIdx > 0) {
                                        serverName = noPrefix.substring(0, slashIdx);
                                        shareName = noPrefix.substring(slashIdx + 1);
                                    } else {
                                        serverName = noPrefix; // only server
                                    }
                                }
                                
                                boolean full = ((Integer)perm.get("full")) == 1;
                                boolean modify = ((Integer)perm.get("modify")) == 1;
                                boolean readExec = ((Integer)perm.get("readExec")) == 1;
                                boolean read = ((Integer)perm.get("read")) == 1;
                                boolean write = ((Integer)perm.get("write")) == 1;
                            %>
                            <div style="margin-bottom:20px;">
                                <div class="server-input-row">
                                    <label>Server :</label>
                                    <input type="text" value="<%= serverName %>" readonly placeholder="Server">
                                </div>
                                <div class="server-input-row">
                                    <label>Folder :</label>
                                    <input type="text" value="<%= shareName %>" readonly>
                                </div>
                                <div class="permission-checkbox-row">
                                    <label><input type="checkbox" <%= full ? "checked" : "" %> disabled> Full control</label>
                                    <label><input type="checkbox" <%= modify ? "checked" : "" %> disabled> Modify</label>
                                    <label><input type="checkbox" <%= readExec ? "checked" : "" %> disabled> Read & Execute</label>
                                    <label><input type="checkbox" <%= read ? "checked" : "" %> disabled> Read</label>
                                    <label><input type="checkbox" <%= write ? "checked" : "" %> disabled> Write</label>
                                </div>
                            </div>
                            <% } %>
                        </div>
                    <% } else { %>
                        <p>ไม่พบข้อมูลสิทธิ์ (ตาราง PERMISSIONDETAILS ว่างเปล่า)</p>
                    <% } %>
                <% } %>

                <!-- Objective and current method (unchanged) -->
                <div class="form-group full-width">
                    <label>วัตถุประสงค์ / ความต้องการ</label>
                    <textarea rows="4" readonly><%= it.get("objective") %></textarea>
                </div>
                <div class="form-group full-width">
                    <label>วิธีการดำเนินการปัจจุบัน</label>
                    <textarea rows="4" readonly><%= it.get("currentMethod") %></textarea>
                </div>
            </div>
        <%
                }
            }
        %>

        <div class="btn-group">
            <button type="button" style="background-color:red;" class="btn btn-back" onclick="history.back()">ย้อนกลับ</button>
        </div>
    </form>
</div>

</body>
</html>