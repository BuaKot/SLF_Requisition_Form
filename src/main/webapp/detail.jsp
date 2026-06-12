<%@ include file="/WEB-INF/checkAuth.jsp" %>
<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*, com.slf.dao.DBConnection" %>

<%
    String idParam = request.getParameter("id");
    String fromPage = request.getParameter("from");
    String backPath = "history".equals(fromPage) ? "history.jsp" : "submit";
    String backLabel = "history".equals(fromPage) ? "กลับหน้าประวัติ" : "กลับหน้าฟอร์มที่ส่งแล้ว";
    if (idParam == null || idParam.trim().isEmpty()) {
        response.sendRedirect("submit"); // zennnne แก้
        return;
    }
    int formId = Integer.parseInt(idParam);
    Object viewerEmpObj = session.getAttribute("loggedInEmpId");
    if (viewerEmpObj == null) viewerEmpObj = session.getAttribute("empid");
    if (viewerEmpObj == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    int viewerEmpId = Integer.parseInt(viewerEmpObj.toString());

    Connection conn = null;
    PreparedStatement psHeader = null, psItems = null, psPerm = null, psApproval = null;
    ResultSet rsHeader = null, rsItems = null, rsPerm = null, rsApproval = null;

    String fullName = "", sectionName = "", departmentName = "", phone = "";
    String requestDate = "", deadline = "", requestTitle = "", status = "";
    boolean found = false;

    // List of items (each map holds typeName, programOrOther, objective, currentMethod, typeId)
    java.util.List<java.util.Map<String,String>> items = new java.util.ArrayList<>();
    // List of permission rows (each map holds isRoot, path, fullControl, modify, readExec, read, write)
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

    private String approvalActionClass(String action) {
        return "ไม่อนุมัติ".equals(action) ? "is-rejected" : "is-approved";
    }
%>

<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>รายละเอียดใบขอให้ดำเนินการ</title>
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/images/cropped-logo-192x192.png">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/form.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
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
        .sticky-bar .contact-info {
            margin-left: auto;
            display: flex;
            align-items: center;
        }
        .approval-history {
            margin-top: 26px;
            border-top: 1px solid #d8e2ef;
            padding-top: 18px;
        }
        .approval-history h3 {
            margin: 0 0 14px;
            color: #003366;
        }
        .approval-section {
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            padding: 14px 16px;
            margin-bottom: 12px;
            background: #ffffff;
        }
        .approval-section.is-standby {
            color: #777;
            background: #f8fafc;
        }
        .approval-row {
            margin: 5px 0;
            line-height: 1.45;
        }
        .approval-row strong {
            color: #3272BB;
        }
        .approval-action {
            font-weight: bold;
        }
        .approval-action.is-approved {
            color: #1e8000;
        }
        .approval-action.is-rejected {
            color: #CC0000;
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
<div id="main">
<%@ include file="/WEB-INF/jspf/topbar.jspf" %>
<div class="banner">
    <h1>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินกู้ยืมเพื่อการศึกษา</h1>
    <h2>ใบขอให้ดำเนินการ / Requisition Form</h2>
</div>
<div class="detail-action-bar"><a class="detail-back-button" href="<%= backPath %>"><i class="fa fa-arrow-left"></i> <%= backLabel %></a></div>

<%
    try {
        conn = DBConnection.getConnection();

        // ---------- Header ----------
        String headerSQL =
            "WITH latest_step AS ( " +
            "    SELECT FORMID, STATE_STEP, " +
            "           ROW_NUMBER() OVER (PARTITION BY FORMID ORDER BY APPROVALID DESC) AS RN " +
            "    FROM APPROVALINFO " +
            ") " +
            "SELECT E.EMPNAME, E.PHONE, S.SECNAME, D.DEPTNAME, " +
            "RF.TITLEFORM, TO_CHAR(RF.REQUESTDATE, 'DD/MM/YYYY') AS REQDATE, " +
            "TO_CHAR(RF.DEADLINE, 'DD/MM/YYYY') AS DDL, NVL(LS.STATE_STEP, 0) AS STATE_STEP " +
            "FROM REQUISITIONFORM RF " +
            "JOIN EMPLOYEE E ON RF.EMPID = E.EMPID " +
            "LEFT JOIN SECTION S ON E.SECID = S.SECID " +
            "LEFT JOIN DEPARTMENT D ON S.DEPTID = D.DEPTID " +
            "LEFT JOIN latest_step LS ON LS.FORMID = RF.FORMID AND LS.RN = 1 " +
            "WHERE RF.FORMID = ? " +
            "AND (RF.EMPID = ? OR EXISTS ( " +
            "    SELECT 1 FROM APPROVALINFO VIEWER_AI " +
            "    WHERE VIEWER_AI.FORMID = RF.FORMID " +
            "    AND VIEWER_AI.REVIEWER_EMPID = ? " +
            "))";
        psHeader = conn.prepareStatement(headerSQL);
        psHeader.setInt(1, formId);
        psHeader.setInt(2, viewerEmpId);
        psHeader.setInt(3, viewerEmpId);
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
            status = rsHeader.getString("STATE_STEP");
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

<!-- Main Detail -->
<div class="form-container">
    <form>
        <div style="font-size:0.9rem; color:#777;">#<%= formId %></div>
        <div class="form-grid">
            <!-- personal info -->
            <div class="form-group"><label>ชื่อ-นามสกุล</label><input type="text" value="<%= fullName %>" readonly></div>
            <div class="form-group"><label>ส่วน</label><input type="text" value="<%= sectionName %>" readonly></div>
            <div class="form-group"><label>ฝ่าย</label><input type="text" value="<%= departmentName %>" readonly></div>
            <div class="form-group"><label>เบอร์ต่อ</label><input type="text" value="<%= phone %>" readonly></div>
            <div class="form-group"><label>วันที่</label><input type="text" value="<%= requestDate %>" readonly></div>
            <div class="form-group"><label>Deadline</label><input type="text" value="<%= deadline %>" readonly></div>
            <div class="form-group full-width" style="margin-bottom:20px;"><label>ชื่อหัวข้อความต้องการ :</label><input type="text" value="<%= requestTitle %>" readonly></div>
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

        <div class="approval-history">
            <h3>ความเห็นและผลการดำเนินการ</h3>
            <%
                for (java.util.Map<String,String> approval : approvalSections.values()) {
                    boolean hasApproval = "true".equals(approval.get("hasApproval"));
                    if (!hasApproval) {
                        // Standby approval labels are fixed workflow labels until a reviewer row exists.
            %>
                <div class="approval-section is-standby">
                    <div class="approval-row"><strong><%= approval.get("label") %></strong></div>
                </div>
            <%
                    } else {
            %>
                <div class="approval-section">
                    <div class="approval-row"><strong>ตำแหน่ง:</strong> <%= approval.get("position") %></div>
                    <div class="approval-row"><strong>ชื่อ-สกุล:</strong> <%= approval.get("empName") %></div>
                    <div class="approval-row">
                        <span class="approval-action <%= approvalActionClass(approval.get("action")) %>"><%= approval.get("action") %></span>
                        เมื่อ <%= approval.get("approvedDay") %> เวลา <%= approval.get("approvedTime") %>
                    </div>
                    <div class="approval-row"><strong>ความคิดเห็น:</strong> <%= approval.get("comment") %></div>
                </div>
            <%
                    }
                }
            %>
        </div>

        <div class="btn-group">
            <button type="button" style="background-color:red;" class="btn btn-back" onclick="history.back()">ย้อนกลับ</button>
            <a href="${pageContext.request.contextPath}/pdf.jsp?id=<%= formId %>" target="_blank" class="btn" style="background-color:red;">
                <i class="fa-solid fa-file-pdf"></i> ส่งออก PDF
            </a>
        </div>
    </form>
</div>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</div>
</body>
</html>




