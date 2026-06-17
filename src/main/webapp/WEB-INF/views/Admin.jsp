<%@ include file="/WEB-INF/checkAuth.jsp" %>
<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.slf.util.AuthUtil" %>
<%!
    public String escapeHtml(Object input) {
        if (input == null) return "";
        String str = String.valueOf(input);
        return str.replace("&", "&amp;")
                  .replace("<", "&lt;")
                  .replace(">", "&gt;")
                  .replace("\"", "&quot;")
                  .replace("'", "&#x27;")
                  .replace("/", "&#x2F;");
    }
%>
<%
    String currentRole = (String) session.getAttribute("position");
    String employeeName = (String) session.getAttribute("loggedInEmpName");

    // เช็คสิทธิ์ว่ามีสิทธิ์ของหน้า Admin ไหม
    if (currentRole == null || employeeName == null || !AuthUtil.isAllowedForPage(currentRole, "adminPage")) {
        
        String redirectPage = "/login"; // ค่าเริ่มต้นถ้าไม่พบตำแหน่งใดๆ
        
        if (currentRole != null) {
            switch (currentRole.toLowerCase()) {
                case "admin":
                    redirectPage = "/Admin.jsp";
                    break;
                case "director":
                case "itdirector":
                case "it director":
                    redirectPage = "/index.jsp";
                    break;
                case "technical":
                case "itdirectorapprove": 
                case "development":
                case "data":
                case "infrastructure":
                case "cyber security":
                case "research":
                case "reseach":
                case "it planning":
                    redirectPage = "/index.jsp";
                    break;
                case "employee": 
                    redirectPage = "/index.jsp"; 
                    break;
                case "staff":
                    redirectPage = "/index.jsp"; 
                    break;
                default:
                    redirectPage = "/index.jsp"; 
            }
        }
        
        
        response.sendRedirect(request.getContextPath() + redirectPage + "?error=nopermission");
        return;
    }
%>

<!DOCTYPE html>
<html lang="th">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IT Requisition - Admin Database Authentication</title>
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/images/cropped-logo-192x192.png">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>

<body class="view-admin">
    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>

    <div id='main'>
        <%@ include file="/WEB-INF/jspf/topbar.jspf" %>

        <div class="banner">
            <div class="banner-content">
                <h1>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</h1>
                <h1>ใบขอให้ดำเนินการ / Requisition Form</h1>
                <div class="banner-divider"></div>
                <div class="user-badge">
                    สิทธิ์การใช้งานจริงจากฐานข้อมูล: <span class="role-badge"><%= escapeHtml(currentRole) %></span>
                </div>
            </div>
        </div>

        <div class="admin-grid">

            <% if (AuthUtil.isAllowedForPage(currentRole, "directorApprove")) { %>
                <div class="card" onclick="location.href='${pageContext.request.contextPath}/directorApprove'" tabindex="0" role="button" aria-label="ผู้อำนวยการฝ่าย">
                    <div class="card-icon-wrapper">
                        <i class="fa-regular fa-circle-user" aria-hidden="true"></i>
                    </div>
                    <span class="card-title">ผู้อำนวยการฝ่าย</span>
                    <span class="card-subtitle">Director Approval</span>
                </div>
            <% } %>

            <% if (AuthUtil.isAllowedForPage(currentRole, "technicalApprove")) { %>
                <div class="card" onclick="location.href='${pageContext.request.contextPath}/technicalApprove'" tabindex="0" role="button" aria-label="ความเห็นและการอนุมัติเชิงเทคนิค">
                    <div class="card-icon-wrapper">
                        <i class="fa-solid fa-screwdriver-wrench" aria-hidden="true"></i>
                    </div>
                    <span class="card-title">ความเห็นและการอนุมัติเชิงเทคนิค</span>
                    <span class="card-subtitle">Technical Review &amp; Approval</span>
                </div>
            <% } %>

            <% if (AuthUtil.isAllowedForPage(currentRole, "itDirectorApprove")) { %>
                <div class="card" onclick="location.href='${pageContext.request.contextPath}/itDirectorApprove'" tabindex="0" role="button" aria-label="ผู้อำนวยการฝ่ายเทคโนโลยีสารสนเทศ">
                    <div class="card-icon-wrapper">
                        <i class="fa-solid fa-user-gear" aria-hidden="true"></i>
                    </div>
                    <span class="card-title">ผู้อำนวยการฝ่ายเทคโนโลยีสารสนเทศ</span>
                    <span class="card-subtitle">IT Director Approval</span>
                </div>
            <% } %>

            <% if (AuthUtil.isAllowedForPage(currentRole, "process")) { %>
                <div class="card" onclick="location.href='${pageContext.request.contextPath}/process'" tabindex="0" role="button" aria-label="รายละเอียดการดำเนินการ">
                    <div class="card-icon-wrapper">
                        <i class="fa-solid fa-bars-progress" aria-hidden="true"></i>
                    </div>
                    <span class="card-title">รายละเอียดการดำเนินการ</span>
                    <span class="card-subtitle">Process Details</span>
                </div>
            <% } %>

            <% if (AuthUtil.isAllowedForPage(currentRole, "thirdPartyLinks")) { %>
                <div class="card" onclick="location.href='${pageContext.request.contextPath}/thirdPartyLinks'" tabindex="0" role="button" aria-label="จัดการลิงก์บุคคลภายนอก">
                    <div class="card-icon-wrapper">
                        <i class="fa-solid fa-link" aria-hidden="true"></i>
                    </div>
                    <span class="card-title">จัดการลิงก์บุคคลภายนอก</span>
                    <span class="card-subtitle">Third-Party Link Management</span>
                </div>
            <% } %>

            <% if (AuthUtil.isAllowedForPage(currentRole, "dashboard")) { %>
                <div class="card" onclick="location.href='${pageContext.request.contextPath}/Dashboard.jsp'" tabindex="0" role="button" aria-label="แดชบอร์ด">
                    <div class="card-icon-wrapper">
                        <i class="fa-solid fa-chart-line" aria-hidden="true"></i>
                    </div>
                    <span class="card-title">แดชบอร์ด</span>
                    <span class="card-subtitle">Dashboard &amp; Analytics</span>
                </div>
            <% } %>

            <% if (AuthUtil.isAllowedForPage(currentRole, "memberManage")) { %>
                <div class="card" onclick="location.href='${pageContext.request.contextPath}/memberManage'" tabindex="0" role="button" aria-label="จัดการสมาชิก">
                    <div class="card-icon-wrapper">
                        <i class="fa-solid fa-users-gear" aria-hidden="true"></i>
                    </div>
                    <span class="card-title">จัดการสมาชิก</span>
                    <span class="card-subtitle">Member Management</span>
                </div>
            <% } %>

            <% if (AuthUtil.isAllowedForPage(currentRole, "mailLog")) { %>
                <div class="card" onclick="location.href='${pageContext.request.contextPath}/mailLog'" tabindex="0" role="button" aria-label="บันทึกการส่งอีเมล">
                    <div class="card-icon-wrapper">
                        <i class="fa-solid fa-envelope-open-text" aria-hidden="true"></i>
                    </div>
                    <span class="card-title">บันทึกการส่งอีเมล</span>
                    <span class="card-subtitle">Email Log Records</span>
                </div>
            <% } %>

        </div>
    </div>

    <!-- Floating Action Button: ประวัติฟอร์มที่จบแล้ว -->
    <a href="${pageContext.request.contextPath}/history.jsp" class="history-fab" title="ประวัติฟอร์มที่จบแล้ว" aria-label="ดูประวัติฟอร์มที่ดำเนินการเสร็จแล้ว">
        <i class="fa-solid fa-clock-rotate-left" aria-hidden="true"></i>
        <span>ประวัติ</span>
    </a>

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

        // Keyboard accessibility for cards
        document.addEventListener('DOMContentLoaded', function() {
            const cards = document.querySelectorAll('.card');
            cards.forEach(function(card) {
                card.addEventListener('keydown', function(e) {
                    if (e.key === 'Enter' || e.key === ' ') {
                        e.preventDefault();
                        const onclickAttr = card.getAttribute('onclick');
                        if (onclickAttr) {
                            const match = onclickAttr.match(/location\.href='([^']+)'/);
                            if (match && match[1]) {
                                window.location.href = match[1];
                            }
                        }
                    }
                });
            });
        });
    </script>
    <%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>
