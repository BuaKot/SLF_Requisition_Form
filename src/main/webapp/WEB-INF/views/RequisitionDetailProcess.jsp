<%@ include file="/WEB-INF/checkAuth.jsp" %>
<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*, com.slf.dao.DBConnection, java.text.SimpleDateFormat, com.slf.util.SecurityUtil, com.slf.util.NavigationUtil" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    final int EXPECTED_STEP = 3;

    // ----- Session Check -----
    Object empObj = session.getAttribute("loggedInEmpId");
    if (empObj == null) {
        empObj = session.getAttribute("empid");
    }
    if (empObj == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String loggedInEmpId = empObj.toString().trim();
    String csrfToken = SecurityUtil.ensureCsrfToken(request);

    // ----- 1. Grab the form ID -----
    String formId = request.getParameter("id");
    if (formId == null || formId.trim().isEmpty()) {
        formId = request.getParameter("formId");
    }
    if (formId != null) {
        formId = formId.trim();
    }

    String fromPage = request.getParameter("from");
    NavigationUtil.BackLink backLink = NavigationUtil.approvalDetailBack(
        request.getContextPath(), fromPage, "/process", "กลับหน้ารายการดำเนินการ"
    );

    // ----- 2. Data holders -----
    String empName = "", sectionName = "", departmentName = "", phone = "";
    String reqDate = "", deadlineDate = "", titleForm = "";
    boolean hasData = false;
    boolean canApproveExpectedStep = false;
    List<Map<String, String>> requestItems = new ArrayList<>();
    List<Map<String, Object>> permissions = new ArrayList<>();

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    SimpleDateFormat sdfInput = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat sdfDisplay = new SimpleDateFormat("dd/MM/yyyy");

    try {
        if (formId != null && !formId.isEmpty()) {
            conn = DBConnection.getConnection();

            // ----- Header -----
            String sql = "SELECT r.FORMID, e.EMPNAME, e.PHONE, requester_s.SECNAME, requester_d.DEPTNAME, " +
                         "r.TITLEFORM, r.REQUESTDATE, r.DEADLINE, " +
                         "(SELECT ai.DEV_EMPID " +
                         "     FROM APPROVALINFO ai " +
                         "     WHERE ai.FORMID = r.FORMID " +
                         "     AND ai.DEV_EMPID IS NOT NULL " +
                         "     ORDER BY ai.APPROVALID DESC " +
                         "     FETCH FIRST 1 ROWS ONLY) AS LATEST_DEV_EMPID, " +
                         "assigned_s.SECTIONHEAD_EMPID AS ASSIGNED_SECTION_HEAD_EMPID, " +
                         "assigned_d.DEPTHEAD_EMPID AS ASSIGNED_DEPT_HEAD_EMPID, " +
                         "NVL((SELECT ai.STATE_STEP " +
                         "     FROM APPROVALINFO ai " +
                         "     WHERE ai.FORMID = r.FORMID " +
                         "     ORDER BY ai.APPROVALID DESC " +
                         "     FETCH FIRST 1 ROWS ONLY), 0) AS STATE_STEP " +
                         "FROM REQUISITIONFORM r " +
                         "LEFT JOIN EMPLOYEE e ON r.EMPID = e.EMPID " +
                         "LEFT JOIN SECTION requester_s ON e.SECID = requester_s.SECID " +
                         "LEFT JOIN DEPARTMENT requester_d ON requester_s.DEPTID = requester_d.DEPTID " +
                         "LEFT JOIN SECTION assigned_s ON r.ASSIGN_SECID = assigned_s.SECID " +
                         "LEFT JOIN DEPARTMENT assigned_d ON assigned_s.DEPTID = assigned_d.DEPTID " +
                         "WHERE r.FORMID = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, formId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                hasData = true;
                empName = nvl(rs.getString("EMPNAME"));
                sectionName = nvl(rs.getString("SECNAME"));
                departmentName = nvl(rs.getString("DEPTNAME"));
                phone = nvl(rs.getString("PHONE"));
                titleForm = nvl(rs.getString("TITLEFORM"));
                String latestDevEmpId = rs.getString("LATEST_DEV_EMPID");
                String assignedSectionHeadEmpId = rs.getString("ASSIGNED_SECTION_HEAD_EMPID");
                String assignedDeptHeadEmpId = rs.getString("ASSIGNED_DEPT_HEAD_EMPID");
                canApproveExpectedStep = rs.getInt("STATE_STEP") == EXPECTED_STEP
                    && matchesAnyReviewer(loggedInEmpId, latestDevEmpId, assignedSectionHeadEmpId, assignedDeptHeadEmpId);
                if (rs.getDate("DEADLINE") != null) {
                    deadlineDate = sdfDisplay.format(rs.getDate("DEADLINE"));
                } else {
                    deadlineDate = "-";
                }
                if (rs.getDate("REQUESTDATE") != null) {
                    reqDate = sdfInput.format(rs.getDate("REQUESTDATE"));
                } else {
                    reqDate = "-";
                }
            }
            closeQuietly(rs, pstmt);

            // ----- Request items -----
            if (hasData) {
                String itemSql =
                    "SELECT req.REQUESTID, req.TYPEID, rt.TYPENAME, req.OTHERDETAILS_OR_PROGRAM, " +
                    "req.DETAILOBJECTIVE, req.CURRENTMETHOD " +
                    "FROM REQUEST req " +
                    "LEFT JOIN REQUESTTYPE rt ON req.TYPEID = rt.TYPEID " +
                    "WHERE req.FORMID = ? ORDER BY req.REQUESTID";
                pstmt = conn.prepareStatement(itemSql);
                pstmt.setString(1, formId);
                rs = pstmt.executeQuery();
                while (rs.next()) {
                    Map<String, String> item = new HashMap<>();
                    item.put("typeName", nvl(rs.getString("TYPENAME")));
                    item.put("typeDetail", nvl(rs.getString("OTHERDETAILS_OR_PROGRAM")));
                    item.put("objective", nvl(rs.getString("DETAILOBJECTIVE")));
                    item.put("currentMethod", nvl(rs.getString("CURRENTMETHOD")));
                    requestItems.add(item);
                }
                closeQuietly(rs, pstmt);

                // ----- Permissions -----
                String permSql =
                    "SELECT ISROOT, PATH, HASFULLCONTROL, HASMODIFY, HASREADEXECUTE, HASREAD, HASWRITE " +
                    "FROM PERMISSIONDETAILS WHERE FORMID = ? ORDER BY ISROOT DESC, PATH";
                pstmt = conn.prepareStatement(permSql);
                pstmt.setString(1, formId);
                rs = pstmt.executeQuery();
                while (rs.next()) {
                    Map<String, Object> perm = new HashMap<>();
                    perm.put("isRoot", rs.getInt("ISROOT"));
                    perm.put("path", nvl(rs.getString("PATH")));
                    perm.put("full", rs.getInt("HASFULLCONTROL"));
                    perm.put("modify", rs.getInt("HASMODIFY"));
                    perm.put("readExec", rs.getInt("HASREADEXECUTE"));
                    perm.put("read", rs.getInt("HASREAD"));
                    perm.put("write", rs.getInt("HASWRITE"));
                    permissions.add(perm);
                }
            }
        }
    } catch (Exception e) {
        System.out.println("Error Loading Form Details: " + e.getMessage());
    } finally {
        closeQuietly(rs, pstmt, conn);
    }
%>
<%!
    private String nvl(String s) {
        return (s == null || s.trim().isEmpty()) ? "-" : SecurityUtil.escapeHtml(s.trim());
    }
    private String h(Object value) {
        return SecurityUtil.escapeHtml(value);
    }
    private boolean matchesAnyReviewer(String loggedInEmpId, String... candidateEmpIds) {
        if (loggedInEmpId == null) return false;
        for (String candidate : candidateEmpIds) {
            if (candidate != null && candidate.trim().equals(loggedInEmpId)) return true;
        }
        return false;
    }
    private void closeQuietly(AutoCloseable... resources) {
        for (AutoCloseable r : resources) {
            if (r != null) {
                try { r.close(); } catch (Exception ignored) {}
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/images/cropped-logo-192x192.png">
    <title>รายละเอียดใบขอให้ดำเนินการ (ID: <%= h((formId != null) ? formId : "-") %>)</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body class="view-requisition-detail-process">
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
<div id="main">
<%@ include file="/WEB-INF/jspf/topbar.jspf" %>
<section class="enterprise-hero requisition-detail-banner" aria-labelledby="detailHeroTitle">
    <div class="enterprise-hero-copy index-banner-inner">
        <p class="enterprise-eyebrow">ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</p>
        <h1 id="detailHeroTitle">ใบขอให้ดำเนินการ / Requisition Form (ใบที่: <%= h((formId != null) ? formId : "-") %>)</h1>
    </div>
</section>
<div class="detail-action-bar"><a class="detail-back-button" href="<%= h(backLink.getHref()) %>"><i class="fa fa-arrow-left"></i> <%= h(backLink.getLabel()) %></a></div>

<div class="form-container">
    <% if (!hasData) { %>
        <div style="text-align: center; color: #CC0000; padding: 30px; font-weight: bold;">
            ❌ ไม่พบข้อมูลใบขอให้ดำเนินการเลขที่ "<%= h(formId) %>" ในระบบฐานข้อมูล
        </div>
    <% } else if (!canApproveExpectedStep) { %>
        <div style="text-align: center; color: #CC0000; padding: 30px; font-weight: bold;">
            ใบขอนี้ไม่ได้อยู่ในขั้นตอนการดำเนินการแล้ว
        </div>
    <% } else { %>
        <form action="SubmitApprovalServlet" method="post">
            <input type="hidden" name="formId" value="<%= h(formId) %>">
            <input type="hidden" name="expectedStep" value="<%= EXPECTED_STEP %>">
            <input type="hidden" name="redirectPage" value="process">
            <input type="hidden" name="csrfToken" value="<%= h(csrfToken) %>">

            <!-- Header fields -->
            <div class="form-id-note">#<%= h((formId != null) ? formId : "-") %></div>
            <div class="form-grid">
                <div class="form-group">
                    <label>ชื่อ-นามสกุล</label>
                    <input type="text" value="<%= empName %>" readonly>
                </div>
                <div class="form-group">
                    <label>ส่วน</label>
                    <input type="text" value="<%= sectionName %>" readonly>
                </div>
                <div class="form-group">
                    <label>ฝ่าย</label>
                    <input type="text" value="<%= departmentName %>" readonly>
                </div>
                <div class="form-group">
                    <label>เบอร์ต่อ</label>
                    <input type="text" value="<%= phone %>" readonly>
                </div>
                <div class="form-group">
                    <label>วันที่</label>
                    <input type="date" value="<%= reqDate %>" readonly>
                </div>
                <div class="form-group">
                    <label>Deadline</label>
                    <input type="text" value="<%= deadlineDate %>" readonly>
                </div>
                <div class="form-group full-width">
                    <label>ชื่อหัวข้อความต้องการ :</label>
                    <input type="text" value="<%= titleForm %>" readonly>
                </div>
            </div>

            <!-- Request items and permissions -->
            <div class="section-box-main">
                <% if (requestItems.isEmpty()) { %>
                    <div class="form-group full-width">
                        <input type="text" value="ไม่พบรายการคำขอ" readonly>
                    </div>
                <% } else {
                    for (Map<String, String> item : requestItems) {
                        String typeName = item.get("typeName");
                        String typeDetail = item.get("typeDetail");
                        boolean isProgram = typeName != null && (typeName.contains("ติดตั้งโปรแกรม") || typeName.contains("พัฒนาโปรแกรม"));
                        boolean isServer = typeName != null && typeName.contains("สิทธิ์") && typeName.contains("ข้อมูล");
                        boolean isOther = typeName != null && typeName.contains("อื่น");
                %>
                    <div class="item-block">
                        <div class="form-grid">
                            <div class="form-group full-width">
                                <label>ประเภทคำขอ</label>
                                <input type="text" value="<%= typeName %>" readonly>
                            </div>

                            <% if (isProgram) { %>
                                <div class="form-group full-width">
                                    <label>ชื่อโปรแกรม</label>
                                    <input type="text" value="<%= typeDetail %>" readonly>
                                </div>
                            <% } else if (isOther) { %>
                                <div class="form-group full-width">
                                    <label>โปรดระบุ</label>
                                    <input type="text" value="<%= typeDetail %>" readonly>
                                </div>
                            <% } %>

                            <% if (isServer) { %>
                                <div class="form-group full-width">
                                    <label>โปรดระบุ Server</label>
                                    <input type="text" value="<%= typeDetail %>" readonly>
                                </div>

                                <div class="form-group full-width server-permission-box">
                                    <h3 class="server-permission-title">รายละเอียดการขอใช้สิทธิ์เก็บข้อมูล</h3>
                                    <% if (permissions.isEmpty()) { %>
                                        <input type="text" value="ไม่พบข้อมูลสิทธิ์ใน PERMISSIONDETAILS" readonly>
                                    <% } else {
                                        for (Map<String, Object> permission : permissions) {
                                            String path = (String) permission.get("path");
                                            String serverName = "";
                                            String folderName = "";
                                            if (path != null && path.startsWith("\\\\")) {
                                                String noPrefix = path.substring(2);
                                                int slashIdx = noPrefix.indexOf("\\");
                                                if (slashIdx > 0) {
                                                    serverName = noPrefix.substring(0, slashIdx);
                                                    folderName = noPrefix.substring(slashIdx + 1);
                                                } else {
                                                    serverName = noPrefix;
                                                }
                                            }
                                            boolean full = ((Integer) permission.get("full")) == 1;
                                            boolean modify = ((Integer) permission.get("modify")) == 1;
                                            boolean readExec = ((Integer) permission.get("readExec")) == 1;
                                            boolean read = ((Integer) permission.get("read")) == 1;
                                            boolean write = ((Integer) permission.get("write")) == 1;
                                    %>
                                        <div style="margin-bottom: 16px;">
                                            <div class="server-input-row">
                                                <label>Server :</label>
                                                <input type="text" value="<%= serverName %>" readonly>
                                            </div>
                                            <div class="server-input-row">
                                                <label>Folder :</label>
                                                <input type="text" value="<%= folderName %>" readonly>
                                            </div>
                                            <div class="permission-checkbox-row">
                                                <label><input type="checkbox" <%= full ? "checked" : "" %> disabled> Full control</label>
                                                <label><input type="checkbox" <%= modify ? "checked" : "" %> disabled> Modify</label>
                                                <label><input type="checkbox" <%= readExec ? "checked" : "" %> disabled> Read & Execute</label>
                                                <label><input type="checkbox" <%= read ? "checked" : "" %> disabled> Read</label>
                                                <label><input type="checkbox" <%= write ? "checked" : "" %> disabled> Write</label>
                                            </div>
                                        </div>
                                    <% } } %>
                                </div>
                            <% } %>

                            <div class="form-group full-width">
                                <label>วัตถุประสงค์ / ความต้องการ</label>
                                <textarea rows="4" readonly><%= item.get("objective") %></textarea>
                            </div>

                            <div class="form-group full-width">
                                <label>วิธีการดำเนินการปัจจุบัน</label>
                                <textarea rows="3" readonly><%= item.get("currentMethod") %></textarea>
                            </div>
                        </div>
                    </div>
                <% } } %>
            </div>

            <!-- Process action box (preserved from original) -->
            <div class="section-box full-width" style="background-color: #ffffff; border: 2px solid #000000; margin-top:30px;">
                <h3 style="margin-top: 0; color: #3272BB; font-size: 1.1rem; font-weight: bold; margin-bottom: 15px;">
                    การดำเนินการ
                </h3>
                <div class="form-grid" style="margin-top: 15px; display: grid; grid-template-columns: minmax(0, 1fr); gap: 20px;">
                    <div class="form-group">
                        <label style="font-weight: bold;">ผลการดำเนินการ:</label>  
                        <textarea rows="4" name="comment" style="width: 100%; border: 1px solid #3272BB; border-radius: 5px; padding: 10px;" placeholder="ระบุความเห็นและบันทึกข้อความที่นี่..."></textarea>
                    </div>
                </div>
            </div>

            <div class="btn-group">
                <button type="submit" name="action" value="reject" class="btn btn-reject">ไม่อนุมัติ</button>
                <button type="submit" name="action" value="approve" class="btn btn-approve">อนุมัติ</button>
            </div>
        </form>
    <% } %>
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
window.addEventListener("pageshow", function (event) {
    if (event.persisted) {
        window.location.reload();
    }
});
</script>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</div>
</body>
</html>




