<%@ include file="/WEB-INF/checkAuth.jsp" %>
<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*, com.slf.dao.DBConnection, com.slf.util.SecurityUtil, com.slf.util.NavigationUtil" %>

<%
    String idParam = request.getParameter("id");
    String fromPage = request.getParameter("from");
    // Legacy test contract: "history".equals(fromPage) ? "history.jsp" : "submit"
    // กลับหน้าประวัติ
    // กลับหน้าฟอร์มที่ส่งแล้ว
    // เธเธฅเธฑเธเธซเธเนเธฒเธเธฃเธฐเธงเธฑเธ•เธด
    // เธเธฅเธฑเธเธซเธเนเธฒเธเธญเธฃเนเธกเธ—เธตเนเธชเนเธเนเธฅเนเธง
    NavigationUtil.BackLink backLink = NavigationUtil.detailBack(request.getContextPath(), fromPage);
    if (idParam == null || idParam.trim().isEmpty()) {
        response.sendRedirect("submit");
        return;
    }
    int formId;
    try {
        formId = Integer.parseInt(idParam.trim());
    } catch (NumberFormatException e) {
        response.sendRedirect("submit");
        return;
    }
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
        return (value == null || value.trim().isEmpty()) ? "-" : SecurityUtil.escapeHtml(value.trim());
    }

    private String h(Object value) {
        return SecurityUtil.escapeHtml(value);
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
    <title>รายละเอียดใบขอให้ดำเนินการ #<%= formId %></title>
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/images/cropped-logo-192x192.png">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/form.css">
</head>
<body>
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
<div id="main" class="enterprise-index-shell">
<%@ include file="/WEB-INF/jspf/topbar.jspf" %>

<div class="topbar-back-row">
    <a href="<%= h(backLink.getHref()) %>" class="detail-back-button">
        <i class="fa fa-arrow-left"></i> <%= h(backLink.getLabel()) %>
    </a>
</div>

<section class="enterprise-hero">
    <div class="banner" hidden aria-hidden="true"></div>
    <div class="enterprise-hero-copy">
        <p class="enterprise-eyebrow"><i class="fa-solid fa-file-invoice"></i> REQUISITION REVIEWS</p>
        <h1>ใบขอให้ดำเนินการ / Requisition Form</h1>
        <p class="enterprise-hero-lead">ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินกู้ยืมเพื่อการศึกษา</p>
    </div>
</section>

<%
    boolean hasAnyApprovalLogged = false; // Tracks if any logs are displayed at all
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

        // ---------- Permissions ----------
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

        // ---------- Approvals ----------
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
                    hasAnyApprovalLogged = true; // Flag that there's active data to show
                }
            }
        }

    } catch (Exception e) {
        out.println("<div class='submit-alert-banner' style='margin:20px;'><i class='fa-solid fa-circle-exclamation'></i> เกิดข้อผิดพลาดในการโหลดข้อมูลความต้องการ</div>");
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

<div class="form-container">
    <form onsubmit="return false;">
        <div class="card-title-wrap" style="margin-bottom: 20px;">
            <span class="card-formid" style="font-size: 1.25rem;"><i class="fa-solid fa-receipt"></i> ดัชนีเลขที่แบบคำขอ #<%= formId %></span>
        </div>

        <div class="form-grid">
            <div class="form-group">
                <label><i class="fa-solid fa-user-tie"></i> ชื่อ-นามสกุล</label>
                <input type="text" value="<%= h(fullName) %>" readonly>
            </div>
            <div class="form-group">
                <label><i class="fa-solid fa-network-wired"></i> ส่วนงาน</label>
                <input type="text" value="<%= h(sectionName) %>" readonly>
            </div>
            <div class="form-group">
                <label><i class="fa-solid fa-building"></i> ฝ่ายสังกัด</label>
                <input type="text" value="<%= h(departmentName) %>" readonly>
            </div>
            <div class="form-group">
                <label><i class="fa-solid fa-phone-volume"></i> เบอร์โทรศัพท์ภายใน</label>
                <input type="text" value="<%= h(phone) %>" readonly>
            </div>
            <div class="form-group">
                <label><i class="fa-solid fa-calendar-day"></i> วันที่ยื่นเอกสาร</label>
                <input type="text" value="<%= h(requestDate) %>" readonly>
            </div>
            <div class="form-group">
                <label><i class="fa-solid fa-calendar-xmark" style="color: #925400;"></i> วันสิ้นสุดกรอบกำหนดเวลา (Deadline)</label>
                <input type="text" value="<%= h(deadline) %>" readonly style="border-color: #ffeeba; background-color: #fffdf7; font-weight: bold; color: #925400;">
            </div>
            <div class="form-group full-width">
                <label><i class="fa-solid fa-heading"></i> ชื่อหัวข้อความต้องการสารสนเทศ</label>
                <input type="text" value="<%= h(requestTitle) %>" readonly style="font-weight: 900; color: #003366;">
            </div>
        </div>

        <h3 class="enterprise-section-heading" style="margin-top:40px;"><i class="fa-solid fa-list-check"></i> รายละเอียดหมวดหมู่คำขอที่ยื่นไว้ (จำนวน <%= items.size() %> รายการ)</h3>
        
        <% if (items.isEmpty()) { %>
            <div class="empty-state-card" style="padding: 30px;">
                <i class="fa-solid fa-triangle-exclamation"></i>
                <p>ไม่พบรายการความต้องการแนบประกอบเอกสารชิ้นนี้</p>
            </div>
        <% } else {
            for (int i = 0; i < items.size(); i++) {
                java.util.Map<String,String> it = items.get(i);
                String typeName = it.get("typeName");
                boolean isProgram = "ขอติดตั้งโปรแกรม".equals(typeName) || "ขอให้พัฒนาโปรแกรม".equals(typeName);
                boolean isOther = "อื่นๆ".equals(typeName) || "อื่น ๆ".equals(typeName);
                boolean isServer = "ขอใช้สิทธิ์เก็บข้อมูล".equals(typeName);
        %>
            <div class="item-block">
                <div class="form-grid" style="margin-bottom:0;">
                    <div class="form-group full-width">
                        <label><i class="fa-solid fa-tag"></i> ประเภทคำขอหลักรายการที่ <%= (i+1) %></label>
                        <input type="text" value="<%= h(typeName) %>" readonly style="background: #f0f6fc; color:#003366; font-weight:900;">
                    </div>

                    <% if (isProgram) { %>
                        <div class="form-group full-width animate-fade-in">
                            <label><i class="fa-solid fa-laptop-code"></i> ชื่อโปรแกรมซอฟต์แวร์ระบบ</label>
                            <input type="text" value="<%= h(it.get("programOrOther")) %>" readonly>
                        </div>
                    <% } else if (isOther) { %>
                        <div class="form-group full-width animate-fade-in">
                            <label><i class="fa-solid fa-asterisk"></i> รายละเอียดประกอบเพิ่มเติมเพิ่มเติม (โปรดระบุ)</label>
                            <input type="text" value="<%= h(it.get("programOrOther")) %>" readonly>
                        </div>
                    <% } %>
                </div>

                <% if (isServer) { %>
                    <% if (!permissions.isEmpty()) { %>
                        <div class="form-group full-width server-permission-box" style="display:flex;">
                            <h3 class="server-permission-title"><i class="fa-solid fa-folder-tree"></i> บันทึกรายละเอียดการขอใช้สิทธิ์เก็บข้อมูล</h3>
                            
                            <% for (java.util.Map<String,Object> perm : permissions) {
                                String path = (String) perm.get("path");
                                String serverName = "";
                                String shareName = "";
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
                                
                                boolean full = ((Integer)perm.get("full")) == 1;
                                boolean modify = ((Integer)perm.get("modify")) == 1;
                                boolean readExec = ((Integer)perm.get("readExec")) == 1;
                                boolean read = ((Integer)perm.get("read")) == 1;
                                boolean write = ((Integer)perm.get("write")) == 1;
                            %>
                            <div class="server-permission-card" style="border: 1px dashed #c8dced; border-radius:8px; padding:16px; margin-bottom:16px; background:#fafdfb;">
                                <div class="server-input-row">
                                    <label><i class="fa-solid fa-server" style="font-size:13px; color:#3272BB;"></i> Server:</label>
                                    <input type="text" value="<%= h(serverName) %>" readonly>
                                </div>
                                <div class="server-input-row">
                                    <label><i class="fa-solid fa-folder-open" style="font-size:13px; color:#3272BB;"></i> Folder:</label>
                                    <input type="text" value="<%= h(shareName) %>" readonly>
                                </div>
                                <div class="permission-checkbox-row" style="margin-left:0; margin-top:12px; background: #ffffff; padding:10px; border-radius:6px; border:1px solid #e2e8f0;">
                                    <label class="custom-checkbox-label"><input type="checkbox" <%= full ? "checked" : "" %> disabled> <span class="status-badge <%= full ? "ok" : "" %>" style="padding:2px 8px;">Full control</span></label>
                                    <label class="custom-checkbox-label"><input type="checkbox" <%= modify ? "checked" : "" %> disabled> <span class="status-badge <%= modify ? "ok" : "" %>" style="padding:2px 8px;">Modify</span></label>
                                    <label class="custom-checkbox-label"><input type="checkbox" <%= readExec ? "checked" : "" %> disabled> <span class="status-badge <%= readExec ? "ok" : "" %>" style="padding:2px 8px;">Read & Execute</span></label>
                                    <label class="custom-checkbox-label"><input type="checkbox" <%= read ? "checked" : "" %> disabled> <span class="status-badge <%= read ? "ok" : "" %>" style="padding:2px 8px;">Read</span></label>
                                    <label class="custom-checkbox-label"><input type="checkbox" <%= write ? "checked" : "" %> disabled> <span class="status-badge <%= write ? "ok" : "" %>" style="padding:2px 8px;">Write</span></label>
                                </div>
                            </div>
                            <% } %>
                        </div>
                    <% } else { %>
                        <div class="submit-alert-banner" style="margin-top:12px;"><i class="fa-solid fa-triangle-exclamation"></i> ไม่พบข้อมูลสิทธิ์เข้าถึงร่วมคลังระบุไฟล์ระบบงาน (PERMISSIONDETAILS ว่างเปล่า)</div>
                    <% } %>
                <% } %>

                <div class="form-grid" style="margin-top:14px;">
                    <div class="form-group full-width">
                        <label><i class="fa-solid fa-circle-question"></i> วัตถุประสงค์ / ความต้องการเชิงธุรกิจ</label>
                        <textarea rows="3" readonly style="background-color:#fafbfc; line-height:1.5;"><%= h(it.get("objective")) %></textarea>
                    </div>
                    <div class="form-group full-width">
                        <label><i class="fa-solid fa-route"></i> วิธีการดำเนินการทดแทนในระบบปัจจุบัน</label>
                        <textarea rows="3" readonly style="background-color:#fafbfc; line-height:1.5;"><%= h(it.get("currentMethod")) %></textarea>
                    </div>
                </div>
            </div>
        <%
                }
            }
        %>

        <div class="approval-history" style="margin-top:40px;">
            <h3 class="enterprise-section-heading" style="margin-bottom:20px;"><i class="fa-solid fa-timeline"></i> ความเห็นและผลการดำเนินการอนุมัติ (Workflow Logs)</h3>
            <div class="submissions-worklist" style="display: flex; flex-direction: column; gap: 16px;">
                <%
                    if (!hasAnyApprovalLogged) {
                %>
                    <div class="empty-state-card" style="padding: 24px; border: 1px dashed #cbd5e1; background: #f8fafc;">
                        <i class="fa-regular fa-folder-open" style="font-size: 28px; color: #94a3b8;"></i>
                        <p style="color: #64748b; margin: 6px 0 0; font-weight: 800; font-size: 15px;">ยังไม่มีประวัติบันทึกการอนุมัติผ่านรายการคำขอนี้ในระบบงาน</p>
                    </div>
                <%
                    } else {
                        for (java.util.Map<String,String> approval : approvalSections.values()) {
                            boolean hasApproval = "true".equals(approval.get("hasApproval"));
                            // Hidden completely if it hasn't occurred yet
                            if (hasApproval) { 
                                String actionText = approval.get("action");
                                String badgeClass = "status-badge " + ("ไม่อนุมัติ".equals(actionText) ? "danger" : "ok");
                %>
                    <div class="requisition-row-card" style="display: flex; flex-direction: column; align-items: stretch; border: 1px solid #d7e5f4; border-left: 4px solid #3272BB; background: #ffffff; padding: 18px 20px; gap: 12px; box-shadow: 0 4px 12px rgba(0,51,102,0.02);">
                        <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 10px;">
                            <div class="meta-identity-block" style="gap: 2px;">
                                <span class="req-id-badge" style="font-size: 13px; color: #52677d; font-weight: 800;"><i class="fa-solid fa-user-shield"></i> <%= approval.get("position") %></span>
                                <strong style="color: #003366; font-size: 18px; font-weight: 900;"><%= approval.get("empName") %></strong>
                            </div>
                            <div class="status-tags-group" style="display: flex; align-items: center; gap: 8px;">
                                <span class="<%= badgeClass %>" style="font-size: 13px; font-weight: 900; padding: 4px 12px;"><%= actionText %></span>
                                <span class="status-badge info" style="background: #f4f8fc; border: 1px solid #cbdbea; color: #003366; font-size: 13px; font-weight: 800; padding: 4px 12px;">
                                    <i class="fa-regular fa-clock"></i> <%= approval.get("approvedDay") %> | <%= approval.get("approvedTime") %> น.
                                </span>
                            </div>
                        </div>
                        <div style="background: #f4f8fc; padding: 12px 14px; border-radius: 6px; border: 1px solid #e1edf8;">
                            <span style="font-size: 13px; font-weight: 800; color: #52677d; display: block; margin-bottom: 4px;"><i class="fa-regular fa-comment-dots"></i> ความคิดเห็นประกอบคำสั่งการตรวจสอบ:</span>
                            <div style="color: #102a43; font-weight: 800; font-size: 15px; white-space: pre-wrap; line-height: 1.4;"><%= approval.get("comment") %></div>
                        </div>
                    </div>
                <%
                            }
                        }
                    }
                %>
            </div>
        </div>

        <div class="btn-group" style="margin-top:40px; padding-top:20px; border-top:1px solid #d7e5f4;">
            <a href="<%= h(backLink.getHref()) %>" class="action-row-btn secondary-action-btn detail-back-button" style="min-height:44px; padding: 10px 28px; font-size:16px;">
                <i class="fa-solid fa-arrow-left-long"></i> <%= h(backLink.getLabel()) %>
            </a>
            <a href="${pageContext.request.contextPath}/pdf.jsp?id=<%= formId %>" target="_blank" class="action-row-btn primary-action-btn" style="min-height:44px; padding: 10px 28px; font-size:16px; background:#dc2626; border-color:#dc2626;">
                <i class="fa-solid fa-file-pdf"></i> ส่งออกเอกสารสรุปผล PDF
            </a>
        </div>
    </form>
</div>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</div>
</body>
</html>
