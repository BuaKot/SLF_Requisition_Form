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

    <style>
        :root {
            --color-primary: #003366;
            --color-primary-hover: #001f3f;
            --color-accent: #3272BB;
            --color-accent-light: #e6f0fa;
            --color-banner-start: #C3EAFF;
            --color-banner-end: #e6f4fc;
            --color-white: #ffffff;
            --color-bg: #f7f9fc;
            --color-text: #1e293b;
            --color-text-secondary: #475569;
            --color-border: #e2e8f0;
            --shadow-xs: 0 1px 2px rgba(0,0,0,0.03);
            --shadow-sm: 0 4px 6px rgba(0,0,0,0.04);
            --shadow-md: 0 6px 14px rgba(0,0,0,0.06);
            --shadow-lg: 0 12px 24px rgba(0,0,0,0.08);
            --shadow-hover: 0 16px 32px rgba(0,51,102,0.12);
            --radius-sm: 8px;
            --radius-md: 12px;
            --radius-lg: 16px;
            --radius-full: 999px;
            --transition-base: 0.2s ease;
        }

        * { box-sizing: border-box; }

        body {
            font-family: 'Sarabun', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background-color: var(--color-bg);
            display: flex;
            flex-direction: column;
            min-height: 100vh;
            color: var(--color-text);
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
            line-height: 1.5;
        }

        /* ───── Banner ───── */
        .banner {
            background: linear-gradient(160deg, #d4edff 0%, var(--color-banner-start) 40%, var(--color-banner-end) 100%);
            padding: clamp(32px, 5vw, 48px) 24px;
            text-align: center;
            color: var(--color-primary);
            border-bottom: 1px solid rgba(50,114,187,0.12);
            position: relative;
            min-height: 150px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            overflow: hidden;
            word-break: break-word;
        }

        .banner::before {
            content: '';
            position: absolute;
            top: -50px;
            right: -50px;
            width: 160px;
            height: 160px;
            background: radial-gradient(circle, rgba(50,114,187,0.07) 0%, transparent 70%);
            border-radius: 50%;
            pointer-events: none;
        }

        .banner-content {
            position: relative;
            z-index: 1;
            max-width: 750px;
            width: 100%;
        }

        .banner h1 {
            font-size: clamp(1rem, 3.5vw, 1.35rem);
            margin: 0 0 4px;
            font-weight: 500;
            letter-spacing: 0.01em;
            white-space: normal;
            overflow-wrap: break-word;
            word-break: break-word;
            line-height: 1.5;
        }

        .banner h1:first-child {
            font-size: clamp(0.85rem, 3vw, 1.1rem);
            font-weight: 400;
            color: #1a4d80;
            margin-bottom: 4px;
        }

        .banner h1:last-of-type {
            font-weight: 700;
            color: var(--color-primary);
            margin-bottom: 8px;
        }

        .banner-divider {
            width: 360px;
            height: 2px;
            background: var(--color-accent);
            margin: 8px auto 14px;
            border-radius: 1px;
            opacity: 0.6;
        }

        .user-badge {
            background-color: var(--color-white);
            color: var(--color-primary);
            padding: 8px 18px;
            border-radius: var(--radius-full);
            display: inline-flex;
            align-items: center;
            flex-wrap: wrap;
            justify-content: center;
            margin-top: 6px;
            font-size: 0.88rem;
            font-weight: 500;
            border: 1px solid rgba(50,114,187,0.2);
            box-shadow: var(--shadow-xs);
            white-space: normal;
            word-break: break-word;
        }

        .role-badge {
            background-color: var(--color-primary);
            color: #fff;
            padding: 3px 12px;
            border-radius: var(--radius-full);
            font-weight: 600;
            margin-left: 6px;
            font-size: 0.88rem;
            white-space: nowrap;
        }

        /* ───── Grid ───── */
        .admin-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 20px;
            padding: 32px 24px 50px;
            max-width: 1300px;
            margin: 0 auto;
            width: 100%;
        }

        /* ───── Card ───── */
        .card {
            background: var(--color-white);
            border: 1px solid var(--color-border);
            border-radius: var(--radius-md);
            padding: 28px 16px 22px;
            text-align: center;
            cursor: pointer;
            transition: all var(--transition-base);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 230px;
            box-shadow: var(--shadow-sm);
            position: relative;
            text-decoration: none;
            color: inherit;
            outline-offset: 2px;
        }

        .card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: var(--color-accent);
            border-radius: var(--radius-md) var(--radius-md) 0 0;
            transform: scaleX(0);
            transform-origin: center;
            transition: transform 0.25s ease;
        }

        .card:hover::before {
            transform: scaleX(1);
        }

        .card:hover {
            border-color: var(--color-accent);
            box-shadow: var(--shadow-hover);
            transform: translateY(-5px);
        }

        .card:active {
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }

        .card:focus-visible {
            outline: 3px solid var(--color-accent);
            outline-offset: 3px;
        }

        .card-icon-wrapper {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: var(--color-accent-light);
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 16px;
            transition: all var(--transition-base);
        }

        .card:hover .card-icon-wrapper {
            background: #e0eef9;
            transform: scale(1.06);
        }

        .card i {
            font-size: 38px;
            color: var(--color-accent);
            transition: color var(--transition-base);
        }

        .card:hover i {
            color: var(--color-primary);
        }

        .card-title {
            font-weight: 600;
            font-size: 1.05rem;
            color: var(--color-text);
            margin: 0 0 4px;
            line-height: 1.3;
        }

        .card-subtitle {
            font-weight: 400;
            font-size: 0.78rem;
            color: var(--color-text-secondary);
            margin-top: 2px;
            line-height: 1.3;
            display: block;
        }

        /* ───── FAB ───── */
        .history-fab {
            position: fixed;
            bottom: 28px;
            right: 28px;
            display: flex;
            align-items: center;
            gap: 10px;
            background: var(--color-primary);
            color: #fff;
            text-decoration: none;
            padding: 12px 22px;
            border-radius: var(--radius-full);
            font-size: 0.92rem;
            font-family: 'Sarabun', 'Segoe UI', sans-serif;
            font-weight: 600;
            box-shadow: 0 4px 18px rgba(0,51,102,0.25);
            transition: all var(--transition-base);
            z-index: 999;
            white-space: nowrap;
            border: none;
        }

        .history-fab:hover {
            background: var(--color-primary-hover);
            box-shadow: 0 8px 24px rgba(0,51,102,0.35);
            transform: translateY(-2px);
        }

        .history-fab:focus-visible {
            outline: 3px solid var(--color-accent);
            outline-offset: 3px;
        }

        .history-fab i {
            font-size: 17px;
            flex-shrink: 0;
        }

        /* ───── Responsive ───── */
        @media (max-width: 768px) {
            .admin-grid {
                grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
                gap: 16px;
                padding: 24px 16px 40px;
            }
            .card {
                min-height: 200px;
                padding: 22px 12px 18px;
            }
            .card-icon-wrapper {
                width: 64px;
                height: 64px;
                margin-bottom: 12px;
            }
            .card i {
                font-size: 30px;
            }
            .card-title {
                font-size: 0.95rem;
            }
            .banner {
                min-height: 130px;
                padding: 24px 16px;
            }
            .history-fab {
                bottom: 20px;
                right: 16px;
                padding: 10px 18px;
                font-size: 0.85rem;
            }
        }

        @media (max-width: 480px) {
            .admin-grid {
                grid-template-columns: 1fr;
                gap: 14px;
                padding: 18px 12px 36px;
            }
            .card {
                min-height: 170px;
                padding: 20px 12px 16px;
            }
            .card-icon-wrapper {
                width: 56px;
                height: 56px;
            }
            .card i {
                font-size: 26px;
            }
            .card-title {
                font-size: 0.9rem;
            }
            .banner {
                min-height: 120px;
                padding: 20px 12px;
            }
            .history-fab {
                bottom: 16px;
                right: 12px;
                padding: 9px 16px;
                font-size: 0.8rem;
                gap: 7px;
            }
            .user-badge {
                font-size: 0.78rem;
            }
            .role-badge {
                font-size: 0.78rem;
                padding: 2px 10px;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            .card, .card::before, .card-icon-wrapper, .card i, .history-fab {
                transition: none !important;
            }
            .card:hover {
                transform: none;
            }
            .history-fab:hover {
                transform: none;
            }
        }

        @media print {
            .history-fab, .sidebar, #mySidebar {
                display: none !important;
            }
            .admin-grid {
                gap: 10px;
                padding: 10px;
            }
            .card {
                box-shadow: none;
                border: 1px solid #ccc;
                break-inside: avoid;
            }
        }
    </style>
</head>

<body>
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