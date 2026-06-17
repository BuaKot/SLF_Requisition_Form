<%@ page isELIgnored="false" %>
<!-- zennnne แก้ — ลบ checkAuth.jsp include ออกจาก login page (เป็นสาเหตุ redirect loop) -->
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.slf.security.CaptchaChallenge" %>
<%@ page import="com.slf.security.JavaCaptchaService" %>
<%
    boolean captchaRequired = "1".equals(request.getParameter("captchaRequired"))
        || Boolean.TRUE.equals(session.getAttribute("captchaRequired"));
    CaptchaChallenge captcha = captchaRequired ? JavaCaptchaService.createChallenge(request) : null;
    
    // ---- FIXED COOLDOWN LOGIC ----
    int waitSeconds = 0;
    // First check the session for an active (non‑expired) cooldown
    Long expiry = (Long) session.getAttribute("loginWaitExpiry");
    if (expiry != null && System.currentTimeMillis() < expiry) {
        // Active cooldown – calculate remaining seconds
        waitSeconds = (int) ((expiry - System.currentTimeMillis()) / 1000);
        if (waitSeconds <= 0) {
            waitSeconds = 0;
            session.removeAttribute("loginWaitExpiry");
            session.removeAttribute("loginWaitSeconds");
        }
    } else if (expiry != null) {
        // Expired cooldown – clean up session
        session.removeAttribute("loginWaitExpiry");
        session.removeAttribute("loginWaitSeconds");
    } else {
        // No session expiry, fall back to URL parameter (for the first redirect)
        try {
            waitSeconds = Integer.parseInt(request.getParameter("waitSeconds"));
        } catch (Exception ignored) {
            waitSeconds = 0;
        }
        // Also honour the old session attribute (backwards compatibility)
        if (waitSeconds <= 0 && session.getAttribute("loginWaitSeconds") instanceof Integer) {
            waitSeconds = ((Integer) session.getAttribute("loginWaitSeconds")).intValue();
            session.removeAttribute("loginWaitSeconds");
        }
    }
%>

<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>เข้าสู่ระบบพนักงาน | กยศ.</title>
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/images/cropped-logo-192x192.png">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body class="view-login">
<main class="login-shell">
    <section class="brand-side" aria-label="ข้อมูลระบบ กยศ.">
        <div class="brand-content">
            <div class="brand-logo">
                <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="กยศ.">
            </div>
            <h1>ระบบกองทุนเงินให้กู้ยืม<br>เพื่อการศึกษาแบบดิจิทัล (กยศ.)</h1>
            <p>Digital Student Loan Fund System</p>
        </div>
        <div class="brand-footer">
            <i class="ui-icon icon-copyright" aria-hidden="true">
                <svg viewBox="0 0 24 24" fill="none" stroke-width="2">
                    <circle cx="12" cy="12" r="9"></circle>
                    <path d="M15 9.5A4 4 0 1 0 15 14.5"></path>
                </svg>
            </i>
            <span>All rights reserved © 2569 DSL</span>
        </div>
    </section>

    <section class="form-side" aria-label="เข้าสู่ระบบพนักงาน">
        <div class="login-form-wrap">
            <div class="form-heading">
                <h2>ลงชื่อเข้าใช้งาน</h2>
                <p>โปรดกรอกรายละเอียดของท่านในช่องด้านล่าง</p>
            </div>

            <% if (request.getParameter("error") != null) { %>
                <div class="error-msg">
                    <i class="ui-icon icon-alert" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke-width="2">
                            <circle cx="12" cy="12" r="9"></circle>
                            <path d="M12 7v6"></path>
                            <path d="M12 17h.01"></path>
                        </svg>
                    </i>
                    <span>รหัสผู้ใช้งานหรือรหัสผ่านไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง</span>
                </div>
            <% } %>

            <% if (waitSeconds > 0) { %>
                <div class="cooldown-msg" data-wait-seconds="<%= waitSeconds %>">
                    <i class="ui-icon icon-alert" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke-width="2">
                            <circle cx="12" cy="12" r="9"></circle>
                            <path d="M12 7v6"></path>
                            <path d="M12 17h.01"></path>
                        </svg>
                    </i>
                    <span>พยายามเข้าสู่ระบบหลายครั้ง กรุณารอ <strong id="loginCountdown"><%= waitSeconds %></strong> วินาทีก่อนลองใหม่</span>
                </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/processLogin" method="POST">
                <div class="form-row">
                    <label for="EMPID">รหัสผู้ใช้งาน</label>
                    <div class="input-frame">
                        <i class="ui-icon icon-user" aria-hidden="true">
                            <svg viewBox="0 0 24 24" fill="none" stroke-width="2">
                                <circle cx="12" cy="8" r="4"></circle>
                                <path d="M4 21c1.7-4 4.4-6 8-6s6.3 2 8 6"></path>
                            </svg>
                        </i>
                        <input id="EMPID" type="text" name="EMPID" required autocomplete="username" >
                    </div>
                </div>

                <div class="form-row">
                    <label for="PASSWORD">รหัสผ่าน</label>
                    <div class="input-frame">
                        <i class="ui-icon icon-lock" aria-hidden="true">
                            <svg viewBox="0 0 24 24" fill="none" stroke-width="2">
                                <rect x="5" y="10" width="14" height="10" rx="2"></rect>
                                <path d="M8 10V7a4 4 0 0 1 8 0v3"></path>
                            </svg>
                        </i>
                        <input id="PASSWORD" type="password" name="PASSWORD" required autocomplete="current-password">
                    </div>
                </div>

                <% if (captchaRequired) { %>
                    <div class="captcha-panel">
                        <label for="captchaAnswer">ยืนยันตัวอักษรในภาพ</label>
                        <% if (captcha != null && captcha.isAvailable()) { %>
                            <div class="captcha-visual">
                                <img src="<%= captcha.getImageDataUrl() %>" alt="CAPTCHA">
                            </div>
                            <input type="hidden" name="captchaToken" value="<%= captcha.getToken() %>">
                            <div class="captcha-input-wrap">
                                <input id="captchaAnswer" type="text" name="captchaAnswer" required autocomplete="off">
                            </div>
                        <% } else { %>
                            <div class="error-msg">
                                <i class="ui-icon icon-alert" aria-hidden="true">
                                    <svg viewBox="0 0 24 24" fill="none" stroke-width="2">
                                        <circle cx="12" cy="12" r="9"></circle>
                                        <path d="M12 7v6"></path>
                                        <path d="M12 17h.01"></path>
                                    </svg>
                                </i>
                                <span><%= captcha == null ? "ระบบ CAPTCHA ไม่พร้อมใช้งาน" : captcha.getMessage() %></span>
                            </div>
                        <% } %>
                    </div>
                <% } %>

                <div class="form-actions">
                    <div class="forgot-link">
                        ลืมรหัสผ่าน? <a href="#" onclick="return false;">คลิกที่นี่</a>
                    </div>
                    <button type="submit" class="btn-login">เข้าสู่ระบบ</button>
                </div>
            </form>

            <div class="office-note">
                <span>ระบบใบขอให้ดำเนินการสำหรับเจ้าหน้าที่ ฝ่ายเทคโนโลยีสารสนเทศ กยศ. สอบถามเพิ่มเติม โทร. 411</span>
            </div>
        </div>
    </section>
</main>

<script>
(function () {
    var cooldown = document.querySelector('.cooldown-msg[data-wait-seconds]');
    var countdown = document.getElementById('loginCountdown');
    if (!cooldown || !countdown) return;
    var remaining = parseInt(cooldown.getAttribute('data-wait-seconds'), 10);
    if (isNaN(remaining) || remaining <= 0) {
        cooldown.style.display = 'none';
        return;
    }
    var timer = setInterval(function () {
        remaining -= 1;
        if (remaining <= 0) {
            countdown.textContent = '0';
            cooldown.style.display = 'none';
            clearInterval(timer);
        } else {
            countdown.textContent = remaining;
        }
    }, 1000);
})();
</script>
</body>
</html>