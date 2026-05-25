<%@ include file="/WEB-INF/checkAuth.jsp" %>
<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="com.slf.model.MemberProfile" %>
<%@ page import="com.slf.model.Section" %>
<%@ page import="com.slf.util.AuthUtil" %>
<%!
    public String h(Object input) {
        if (input == null) return "";
        String str = String.valueOf(input);
        return str.replace("&", "&amp;")
                  .replace("<", "&lt;")
                  .replace(">", "&gt;")
                  .replace("\"", "&quot;")
                  .replace("'", "&#x27;");
    }
%>
<%
    String currentRole = (String) session.getAttribute("position");
    String employeeName = (String) session.getAttribute("loggedInEmpName");
    if (currentRole == null || employeeName == null ||
            !AuthUtil.isAllowedForPage(currentRole, "memberManage")) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    if (request.getAttribute("members") == null && request.getParameter("direct") == null) {
        response.sendRedirect(request.getContextPath() + "/memberManage");
        return;
    }

    List<MemberProfile> members = (List<MemberProfile>) request.getAttribute("members");
    List<Section> sections = (List<Section>) request.getAttribute("sections");
    List<String> positions = (List<String>) request.getAttribute("positions");
    if (members == null) members = Collections.emptyList();
    if (sections == null) sections = Collections.emptyList();
    if (positions == null) positions = Collections.emptyList();

    String selectedSectionId = (String) request.getAttribute("selectedSectionId");
    String selectedPosition = (String) request.getAttribute("selectedPosition");
    String selectedStatus = (String) request.getAttribute("selectedStatus");
    String message = (String) request.getAttribute("message");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Member Management</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        body { margin: 0; background: #f4f8fc; color: #102a43; font-family: 'Sarabun', sans-serif; }
        .member-page { max-width: 1320px; margin: 0 auto; padding: 26px 28px 44px; }
        .page-head { display: flex; justify-content: space-between; align-items: flex-start; gap: 18px; margin-bottom: 18px; }
        .page-title h1 { margin: 0; color: #003366; font-size: 28px; line-height: 1.2; }
        .page-title p { margin: 6px 0 0; color: #5b6f82; font-size: 15px; }
        .panel { background: #fff; border: 1px solid #d9e6f2; border-radius: 10px; box-shadow: 0 8px 22px rgba(0, 51, 102, 0.08); }
        .filter-panel { padding: 18px; margin-bottom: 18px; }
        .filter-grid { display: grid; grid-template-columns: repeat(4, minmax(170px, 1fr)); gap: 12px; align-items: end; }
        label { display: block; font-weight: 700; color: #003366; margin-bottom: 6px; font-size: 14px; }
        input, select { width: 100%; height: 40px; border: 1px solid #c7d7e6; border-radius: 7px; padding: 0 10px; font-family: inherit; font-size: 15px; background: #fff; }
        input:focus, select:focus { outline: 2px solid rgba(50, 114, 187, 0.2); border-color: #3272BB; }
        .btn { border: 0; border-radius: 7px; min-height: 40px; padding: 0 16px; display: inline-flex; align-items: center; justify-content: center; gap: 8px; font-family: inherit; font-weight: 700; cursor: pointer; text-decoration: none; }
        .btn-primary { background: #003366; color: #fff; }
        .btn-secondary { background: #e8f2fb; color: #003366; }
        .btn-danger { background: #d64545; color: #fff; }
        .btn-success { background: #138a4d; color: #fff; }
        .notice { border-radius: 8px; padding: 10px 14px; margin-bottom: 14px; font-weight: 700; }
        .notice-ok { background: #e7f7ee; color: #137a42; border: 1px solid #bde8ce; }
        .notice-error { background: #fdecec; color: #b42318; border: 1px solid #f5c2c2; }
        .table-wrap { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; min-width: 940px; }
        th, td { padding: 12px 14px; border-bottom: 1px solid #e5eef6; text-align: left; vertical-align: middle; }
        th { background: #f0f6fc; color: #003366; font-size: 14px; }
        td { font-size: 15px; }
        .member-id { font-weight: 800; color: #003366; }
        .status-pill { display: inline-flex; align-items: center; gap: 6px; border-radius: 999px; padding: 4px 10px; font-weight: 800; font-size: 13px; }
        .status-active { background: #e7f7ee; color: #137a42; }
        .status-inactive { background: #f1f5f9; color: #64748b; }
        .actions { display: flex; gap: 8px; flex-wrap: wrap; }
        .form-panel { padding: 18px; margin-bottom: 18px; }
        .form-title { display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px; }
        .form-title h2 { margin: 0; color: #003366; font-size: 20px; }
        .member-form { display: grid; grid-template-columns: repeat(3, minmax(180px, 1fr)); gap: 12px; }
        .form-actions { display: flex; align-items: end; gap: 10px; }
        .empty { padding: 28px; text-align: center; color: #60758a; font-weight: 700; }
        @media (max-width: 920px) {
            .filter-grid, .member-form { grid-template-columns: 1fr 1fr; }
            .page-head { flex-direction: column; }
        }
        @media (max-width: 620px) {
            .member-page { padding: 18px 14px 34px; }
            .filter-grid, .member-form { grid-template-columns: 1fr; }
            .form-actions { align-items: stretch; flex-direction: column; }
            .btn { width: 100%; }
        }
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

    <main class="member-page">
        <div class="page-head">
            <div class="page-title">
                <h1><i class="fa-solid fa-users-gear"></i> จัดการข้อมูลสมาชิก</h1>
                <p>เพิ่ม แก้ไข ปิดใช้งาน และกรองสมาชิกตามส่วนงาน ตำแหน่ง หรือสถานะ</p>
            </div>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/Admin.jsp">
                <i class="fa-solid fa-arrow-left"></i> กลับหน้า Admin
            </a>
        </div>

        <% if (message != null && !message.trim().isEmpty()) { %>
            <div class="notice notice-ok"><%= h(message) %></div>
        <% } %>
        <% if (error != null && !error.trim().isEmpty()) { %>
            <div class="notice notice-error"><%= h(error) %></div>
        <% } %>

        <section class="panel form-panel">
            <div class="form-title">
                <h2 id="formHeading">เพิ่มสมาชิกใหม่</h2>
            </div>
            <form class="member-form" method="post" action="${pageContext.request.contextPath}/memberManage" id="memberForm">
                <input type="hidden" name="action" id="formAction" value="add">
                <div>
                    <label for="empId">รหัสพนักงาน</label>
                    <input id="empId" name="empId" type="number" required>
                </div>
                <div>
                    <label for="empName">ชื่อ-นามสกุล</label>
                    <input id="empName" name="empName" type="text" maxlength="120" required>
                </div>
                <div>
                    <label for="position">ตำแหน่ง / Role</label>
                    <input id="position" name="position" type="text" list="positionOptions" maxlength="80" required>
                    <datalist id="positionOptions">
                        <% for (String pos : positions) { %>
                            <option value="<%= h(pos) %>"></option>
                        <% } %>
                    </datalist>
                </div>
                <div>
                    <label for="secId">ส่วนงาน</label>
                    <select id="secId" name="secId" required>
                        <option value="">เลือกส่วนงาน</option>
                        <% for (Section section : sections) { %>
                            <option value="<%= section.getSecId() %>"><%= h(section.getSecName()) %></option>
                        <% } %>
                    </select>
                </div>
                <div>
                    <label for="phone">เบอร์โทร</label>
                    <input id="phone" name="phone" type="text" maxlength="40">
                </div>
                <div>
                    <label for="password">รหัสผ่าน <span id="passwordHint">(จำเป็นตอนเพิ่ม)</span></label>
                    <input id="password" name="password" type="password" autocomplete="new-password" required>
                </div>
                <div>
                    <label for="status">สถานะ</label>
                    <select id="status" name="status">
                        <option value="active">ใช้งาน</option>
                        <option value="inactive">ปิดใช้งาน</option>
                    </select>
                </div>
                <div class="form-actions">
                    <button class="btn btn-primary" type="submit">
                        <i class="fa-solid fa-floppy-disk"></i> บันทึก
                    </button>
                </div>
            </form>
        </section>

        <section class="panel filter-panel">
            <form method="get" action="${pageContext.request.contextPath}/memberManage" class="filter-grid">
                <div>
                    <label for="filterSection">ส่วนงาน</label>
                    <select id="filterSection" name="sectionId">
                        <option value="">ทุกส่วนงาน</option>
                        <% for (Section section : sections) {
                            String secValue = String.valueOf(section.getSecId());
                        %>
                            <option value="<%= secValue %>" <%= secValue.equals(selectedSectionId) ? "selected" : "" %>>
                                <%= h(section.getSecName()) %>
                            </option>
                        <% } %>
                    </select>
                </div>
                <div>
                    <label for="filterPosition">ตำแหน่ง</label>
                    <select id="filterPosition" name="position">
                        <option value="">ทุกตำแหน่ง</option>
                        <% for (String pos : positions) { %>
                            <option value="<%= h(pos) %>" <%= pos.equals(selectedPosition) ? "selected" : "" %>><%= h(pos) %></option>
                        <% } %>
                    </select>
                </div>
                <div>
                    <label for="filterStatus">สถานะ</label>
                    <select id="filterStatus" name="status">
                        <option value="active" <%= "active".equals(selectedStatus) ? "selected" : "" %>>ใช้งาน</option>
                        <option value="inactive" <%= "inactive".equals(selectedStatus) ? "selected" : "" %>>ปิดใช้งาน</option>
                        <option value="all" <%= "all".equals(selectedStatus) ? "selected" : "" %>>ทั้งหมด</option>
                    </select>
                </div>
                <div class="form-actions">
                    <button class="btn btn-primary" type="submit"><i class="fa-solid fa-filter"></i> กรอง</button>
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/memberManage">ล้าง</a>
                </div>
            </form>
        </section>

        <section class="panel table-wrap">
            <% if (members.isEmpty()) { %>
                <div class="empty">ไม่พบข้อมูลสมาชิกตามเงื่อนไขที่เลือก</div>
            <% } else { %>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>ชื่อสมาชิก</th>
                            <th>ตำแหน่ง</th>
                            <th>ส่วนงาน</th>
                            <th>เบอร์โทร</th>
                            <th>สถานะ</th>
                            <th>จัดการ</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (MemberProfile member : members) { %>
                        <tr>
                            <td class="member-id"><%= member.getEmpId() %></td>
                            <td><%= h(member.getEmpName()) %></td>
                            <td><%= h(member.getPosition()) %></td>
                            <td><%= h(member.getSecName()) %></td>
                            <td><%= h(member.getPhone()) %></td>
                            <td>
                                <span class="status-pill <%= member.isActive() ? "status-active" : "status-inactive" %>">
                                    <i class="fa-solid <%= member.isActive() ? "fa-circle-check" : "fa-circle-pause" %>"></i>
                                    <%= member.isActive() ? "ใช้งาน" : "ปิดใช้งาน" %>
                                </span>
                            </td>
                            <td>
                                <div class="actions">
                                    <button type="button" class="btn btn-secondary"
                                            onclick="editMember('<%= member.getEmpId() %>', '<%= h(member.getEmpName()) %>', '<%= h(member.getPosition()) %>', '<%= member.getSecId() %>', '<%= h(member.getPhone()) %>', '<%= member.isActive() ? "active" : "inactive" %>')">
                                        <i class="fa-solid fa-pen"></i> แก้ไข
                                    </button>
                                    <form method="post" action="${pageContext.request.contextPath}/memberManage" style="margin:0;">
                                        <input type="hidden" name="empId" value="<%= member.getEmpId() %>">
                                        <input type="hidden" name="action" value="<%= member.isActive() ? "disable" : "enable" %>">
                                        <button class="btn <%= member.isActive() ? "btn-danger" : "btn-success" %>" type="submit">
                                            <i class="fa-solid <%= member.isActive() ? "fa-user-slash" : "fa-user-check" %>"></i>
                                            <%= member.isActive() ? "ปิดใช้งาน" : "เปิดใช้งาน" %>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            <% } %>
        </section>
    </main>
</div>

<script type="text/javascript">
window.toggleNav = () => {
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
};

window.editMember = (empId, empName, position, secId, phone, status) => {
    document.getElementById('formHeading').textContent = 'แก้ไขข้อมูลสมาชิก';
    document.getElementById('formAction').value = 'update';
    document.getElementById('empId').value = empId;
    document.getElementById('empId').readOnly = true;
    document.getElementById('empName').value = decodeHtml(empName);
    document.getElementById('position').value = decodeHtml(position);
    document.getElementById('secId').value = secId;
    document.getElementById('phone').value = decodeHtml(phone);
    document.getElementById('status').value = status;
    document.getElementById('password').value = '';
    document.getElementById('password').required = false;
    document.getElementById('passwordHint').textContent = '(เว้นว่างถ้าไม่เปลี่ยน)';
    window.scrollTo({ top: 0, behavior: 'smooth' });
};

const decodeHtml = (value) => {
    var textarea = document.createElement('textarea');
    textarea.innerHTML = value || '';
    return textarea.value;
};
</script>
</body>
</html>
