<%@ include file="/WEB-INF/checkAuth.jsp" %>
<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*, com.slf.dao.DBConnection, java.text.SimpleDateFormat" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    final int EXPECTED_STEP = 1;

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

    // ----- 1. Grab the form ID -----
    String formId = request.getParameter("id");
    if (formId == null || formId.trim().isEmpty()) {
        formId = request.getParameter("formId");
    }
    if (formId != null) {
        formId = formId.trim();
    }

    // ----- 2. Data holders -----
    String empName = "", sectionName = "", departmentName = "", phone = "";
    String reqDate = "", deadlineDate = "", titleForm = "";
    int assignedSecId = 0;
    boolean hasData = false;
    boolean canApproveExpectedStep = false;
    List<Map<String, String>> requestItems = new ArrayList<>();
    List<Map<String, Object>> permissions = new ArrayList<>();
    List<Map<String, String>> technicians = new ArrayList<>();

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
                         "r.TITLEFORM, r.REQUESTDATE, r.DEADLINE, r.ASSIGN_SECID, " +
                         "assigned_s.SECTIONHEAD_EMPID AS ASSIGNED_SECTIONHEAD_EMPID, " +
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
                assignedSecId = rs.getInt("ASSIGN_SECID");
                String assignedSectionHeadEmpId = rs.getString("ASSIGNED_SECTIONHEAD_EMPID");
                canApproveExpectedStep = rs.getInt("STATE_STEP") == EXPECTED_STEP
                    && assignedSectionHeadEmpId != null
                    && assignedSectionHeadEmpId.trim().equals(loggedInEmpId);
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
                if (assignedSecId > 0) {
                    String technicianSql =
                        "SELECT EMPID, EMPNAME, POSITION " +
                        "FROM EMPLOYEE " +
                        "WHERE SECID = ? " +
                        "ORDER BY EMPNAME";
                    pstmt = conn.prepareStatement(technicianSql);
                    pstmt.setInt(1, assignedSecId);
                    rs = pstmt.executeQuery();
                    while (rs.next()) {
                        Map<String, String> technician = new HashMap<>();
                        technician.put("empId", String.valueOf(rs.getInt("EMPID")));
                        technician.put("empName", nvl(rs.getString("EMPNAME")));
                        technician.put("position", nvl(rs.getString("POSITION")));
                        technicians.add(technician);
                    }
                    closeQuietly(rs, pstmt);
                }

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
                    perm.put("path", rs.getString("PATH"));
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
        return (s == null || s.trim().isEmpty()) ? "-" : s.trim();
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
    <title>รายละเอียดใบขอให้ดำเนินการ (ID: <%= (formId != null) ? formId : "-" %>)</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Sarabun:wght@400;700&display=swap');
        * { box-sizing: border-box; }
        body { font-family: 'Sarabun', sans-serif; margin: 0; background-color: #f4f7f9; }
        .banner { background: #C3EAFF; padding: clamp(20px, 6vw, 40px) 15px; text-align: center; color: #003366; }
        .banner h1 { font-size: clamp(1.1rem, 4vw, 1.5rem); margin: 0; line-height: 1.2; }
        .form-container { width: min(900px, calc(100% - 32px)); margin: 20px auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); overflow-x: hidden; }
        .form-grid { display: grid; grid-template-columns: minmax(0, 1fr) minmax(0, 1fr); gap: 20px; margin-bottom: 20px; }
        .form-group { display: flex; flex-direction: column; min-width: 0; }
        .form-group label { font-weight: bold; margin-bottom: 8px; font-size: 0.9rem; color: #333; }
        .form-group input, .form-group select, .form-group textarea { display: block; width: 100%; max-width: 100%; min-width: 0; padding: 10px; border: 1px solid #3272BB; border-radius: 5px; font-size: 14px; background-color: #ffffff; }
        .form-group input[readonly], .form-group textarea[readonly], .form-group select[disabled] { background-color: #f8fafc; border-color: #cbd5e1; color: #475569; }
        .full-width { grid-column: span 2; }
        .form-id-note { color: #777; font-size: 0.9rem; margin-bottom: 14px; }
        form, .section-box-main, .item-block, .section-box, .server-permission-box { width: 100%; max-width: 100%; min-width: 0; }
        .item-block { border: 1px solid #3272BB; border-radius: 10px; padding: 15px; margin-bottom: 16px; background: #ffffff; }
        .permission-checkbox-row { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 10px; }
        .permission-checkbox-row label { display: inline-flex; align-items: center; gap: 5px; font-weight: normal; }
        .permission-checkbox-row input[type="checkbox"] { width: auto; }
        .server-permission-box { border: 1px solid #cbd5e1; border-radius: 8px; padding: 14px; margin-top: 12px; background: #f8fafc; }
        .server-input-row { display: flex; flex-direction: column; margin-bottom: 10px; }
        .section-box { border: 2px solid #3272BB; border-radius: 10px; padding: 20px; margin-bottom: 25px; }
        .btn-group { display: flex; justify-content: center; align-items: center; gap: 20px; margin-top: 25px; width: 100%; }
        .btn { padding: 12px 40px; border: none; border-radius: 5px; cursor: pointer; font-weight: bold; font-size: 1rem; transition: 0.3s; color: white; }
        .btn-reject { background-color: #CC0000; }
        .btn-approve { background-color: #00A859; }
        .btn:hover { opacity: 0.8; transform: translateY(-2px); }
        @media (max-width: 768px) {
            .form-grid { grid-template-columns: 1fr; }
            .full-width { grid-column: span 1; }
        }
        /* Byte counter styles (from original) */
        .byte-counter { font-size: 0.8rem; margin-left: 10px; color: #666; }
        .over-limit { color: red; font-weight: bold; }
        .input-over-limit { border-color: red !important; }
    </style>
</head>
<body>

<div class="sticky-bar">
        <a href="javascript:history.back()">
            <i class="fa fa-arrow-left" style="font-size:24px;"></i>
        </a>
        <img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF Logo">
        <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo">
        
        <div class="user-info">
            <i class="fa fa-circle-user"></i>
            <p>
                ${sessionScope.loggedInEmpName} | ID: ${sessionScope.loggedInEmpId}
            </p>
        </div>
        <div class="contact-info">
            <i class="fa-solid fa-circle-info"></i>
            <p>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
        </div>
        
</div>

<div class="banner">
    <h1>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</h1>
    <h1 style="margin-top: 5px;">ใบขอให้ดำเนินการ / Requisition Form (ใบที่: <%= (formId != null) ? formId : "-" %>)</h1>
</div>

<div class="form-container">
    <% if (!hasData) { %>
        <div style="text-align: center; color: #CC0000; padding: 30px; font-weight: bold;">
            ❌ ไม่พบข้อมูลใบขอให้ดำเนินการเลขที่ "<%= formId %>" ในระบบฐานข้อมูล
        </div>
    <% } else if (!canApproveExpectedStep) { %>
        <div style="text-align: center; color: #CC0000; padding: 30px; font-weight: bold;">
            ใบขอนี้ไม่ได้อยู่ในขั้นตอนความเห็นและการอนุมัติเชิงเทคนิคแล้ว
        </div>
    <% } else { %>
        <form action="SubmitApprovalServlet" method="post">
            <input type="hidden" name="formId" value="<%= formId %>">
            <input type="hidden" name="expectedStep" value="<%= EXPECTED_STEP %>">
            <input type="hidden" name="redirectPage" value="technicalApprove">

            <!-- Header fields -->
            <div class="form-id-note">#<%= (formId != null) ? formId : "-" %></div>
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

            <!-- Technical comment box (preserved) -->
            <div class="section-box full-width" style="background-color: #ffffff; border: 2px solid #000000; margin-top:30px;">
                <h3 style="margin-top: 0; color: #3272BB; font-size: 1.1rem; font-weight: bold; margin-bottom: 15px;">
                    ความเห็นและการอนุมัติเชิงเทคนิค
                </h3>
                <div class="form-group full-width" style="margin-bottom: 16px;">
                    <label>ผู้รับมอบหมายงาน <span style="color:red">*</span></label>
                    <select name="devEmpId" id="devEmpId">
                        <option value="">-- เลือกผู้รับมอบหมาย --</option>
                        <% for (Map<String, String> technician : technicians) { %>
                            <option value="<%= technician.get("empId") %>">
                                <%= technician.get("empName") %> (ID: <%= technician.get("empId") %>, <%= technician.get("position") %>)
                            </option>
                        <% } %>
                    </select>
                    <% if (technicians.isEmpty()) { %>
                        <small style="color:#CC0000; margin-top:6px;">ไม่พบพนักงานในส่วนงานปลายทางของคำขอนี้</small>
                    <% } %>
                </div>
                <div class="form-group full-width">
                    <textarea name="comment" rows="4" data-maxbytes="500" style="width: 100%; border: 1px solid #3272BB; border-radius: 5px; padding: 10px;" placeholder="ระบุความเห็นและบันทึกข้อความที่นี่..."></textarea>
                </div>
            </div>

            <div class="btn-group">
                <button type="submit" name="action" value="reject" class="btn btn-reject">ไม่อนุมัติ</button>
                <button type="submit" name="action" value="approve" class="btn btn-approve">อนุมัติ</button>
            </div>
        </form>
    <% } %>
</div>
<!-- Byte counter script (unchanged) -->
<script>
function getByteLength(str) {
    return new TextEncoder().encode(str).length;
}
function attachCounters() {
    document.querySelectorAll("[data-maxbytes]").forEach(function (el) {
        if (el.dataset.counterAttached) return;
        el.dataset.counterAttached = "1";
        var max = parseInt(el.dataset.maxbytes);
        var counter = document.createElement("span");
        counter.className = "byte-counter";
        el.parentNode.insertBefore(counter, el.nextSibling);
        function update() {
            var used = getByteLength(el.value);
            counter.textContent = used + " / " + max + " bytes";
            if (used > max) {
                counter.classList.add("over-limit");
                el.classList.add("input-over-limit");
            } else {
                counter.classList.remove("over-limit");
                el.classList.remove("input-over-limit");
            }
        }
        el.addEventListener("input", update);
        update();
    });
}
document.addEventListener("DOMContentLoaded", function () {
    attachCounters();
    var form = document.querySelector("form");
    if (form) {
        form.addEventListener("submit", function (event) {
            var overLimit = [];
            document.querySelectorAll("[data-maxbytes]").forEach(function (el) {
                var max = parseInt(el.dataset.maxbytes);
                if (getByteLength(el.value) > max) {
                    var group = el.closest(".form-group");
                    var label = group && group.querySelector("label");
                    overLimit.push(label ? label.textContent.replace(/[*]/g, "").trim() : el.name);
                }
            });
            if (overLimit.length > 0) {
                event.preventDefault();
                alert("ข้อมูลเกินขนาดที่กำหนด :\n- " + overLimit.join("\n- "));
                return;
            }
            var submitter = event.submitter || document.activeElement;
            if (submitter && submitter.name === "action" && submitter.value === "approve") {
                var devSelect = document.getElementById("devEmpId");
                if (!devSelect || devSelect.value.trim() === "") {
                    event.preventDefault();
                    alert("กรุณาเลือกผู้รับมอบหมายงาน");
                    if (devSelect) devSelect.focus();
                    return;
                }
            }
        });
    }
});
window.addEventListener("pageshow", function (event) {
    if (event.persisted) {
        window.location.reload();
    }
});
</script>
</body>
</html>
