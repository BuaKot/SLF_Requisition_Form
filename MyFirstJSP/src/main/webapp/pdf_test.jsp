<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*, com.slf.dao.DBConnection" %>
<%
    String idParam = request.getParameter("id");
    if (idParam == null || idParam.trim().isEmpty()) {
        response.sendRedirect("submit"); // zennnne แก้
        return;
    }
    int formId = Integer.parseInt(idParam);

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

<head>
<style>
body {
    margin-left: 50px;
    margin-right: 50px;
    margin-top: 25px;
    margin-bottom: 25px;

}

.top-row {
    display: inline-block;
    margin-left: 30px;
}

.head-table {
    border-collapse: collapse;
    width: 100%;
}

td, th {
    border: 1px solid black;
    padding: 8px;
    vertical-align: middle; /* Keeps text centered with the logo height */
    text-align:center;
    vertical-align: middle;
}

/* Make the logo scale nicely to fit its column container tightly */
.logo {
    max-width: 100%;
    height: auto;
    display: block;
}

.invisible-header th {
    border: none !important;
    padding: 0 !important;
    font-size: 0 !important;
    color: transparent !important;
    background: transparent !important;
    height: 0 !important;
}

/* Base info layout rules */
.info-row-table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 15px;
    border: none;
}

.info-label {
    font-family: 'THSarabunNew', sans-serif;
    font-size: 16px;
    font-weight: bold;
    white-space: nowrap;
    padding: 6px 4px 2px 4px;
    vertical-align: bottom;
    border: none;
}

.info-value-field {
    font-family: 'THSarabunNew', sans-serif;
    font-size: 16px;
    padding: 6px 4px 1px 4px;
    vertical-align: bottom;
    border-top: none;
    border-left: none;
    border-right: none;
    border-bottom: 1px dotted #333;
    color: #002244;
}

</style>
</head>

<body>
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

    <div style='text-align:right; margin-bottom: 5px;'>
        <p class="top-row"><strong>ใบขอให้ดำเนินการ / Requisition Form</strong></p>
        <p class="top-row"><strong>SLF-RF-007 V1.0</strong></p>
    </div>

    <table class='head-table'>
        <tr class='invisible-header'>
            <th style="width: 15%;">1 (Logo Column)</th>
            <th style="width: 65%;">2 (Main Body Space)</th>
            <th style="width: 10%;">3</th>
            <th style="width: 10%;">4</th>
        </tr>
        <tr>
            <td rowspan="2" style="padding-top:40px;padding-bottom:40px">
                <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo" class='logo'>
            </td>
            <td colspan="3" rowspan="1">
                <p>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินกู้ยืมเพื่อการศึกษา</p>
            </td>
        </tr>
        <tr>
            <td colspan="1" rowspan="1">
                <p>ใบขอให้ดำเนินการ / Requisition Form</p>
            </td>
            <td colspan="2" rowspan="1">
                <p>TOILET</p>
            </td>
        </tr>
    </table>

    <table class="info-row-table">
        <tr>
            <td class="info-label" style="width: 12%;">ผู้ขอ / Requestor</td>
            <td class="info-value-field" style="width: 48%;"><%= fullName %></td>
            
            <td class="info-label" style="width: 5%; text-align: right;">ส่วน</td>
            <td class="info-value-field" style="width: 35%;"><%= sectionName %></td>
        </tr>
    </table>
    
    <table class="info-row-table">
        <tr>
            <td class="info-label" style="width: 5%;">ฝ่าย</td>
            <td class="info-value-field" style="width: 45%;"><%= departmentName %></td>
            
            <td class="info-label" style="width: 7%; text-align: right;">เบอร์ต่อ</td>
            <td class="info-value-field" style="width: 15%;"><%= phone %></td>
            
            <td class="info-label" style="width: 5%; text-align: right;">วันที่</td>
            <td class="info-value-field" style="width: 23%;"><%= requestDate %></td>
        </tr>
    </table>

</body>