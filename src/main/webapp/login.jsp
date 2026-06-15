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
    <style>
        :root {
            --brand-blue: var(--slf-color-accent);
            --brand-blue-dark: var(--slf-color-accent-600, #2563a6);
            --brand-blue-deep: var(--slf-color-primary);
            --text-main: var(--slf-color-text);
            --text-muted: var(--slf-color-text-muted);
            --line: var(--slf-color-border);
            --focus: var(--slf-color-accent);
            --danger: var(--slf-color-danger);
            --white: var(--slf-color-surface);
        }

        * {
            box-sizing: border-box;
        }

        body {
            min-height: 100vh;
            margin: 0;
            font-family: var(--slf-font-family);
            color: var(--text-main);
            background: var(--white);
        }

        .ui-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 1.2rem;
            height: 1.2rem;
            color: currentColor;
            line-height: 0;
        }

        .ui-icon svg {
            width: 100%;
            height: 100%;
            display: block;
            stroke: currentColor;
        }

        .login-shell {
            min-height: 100vh;
            display: grid;
            grid-template-columns: 38vw minmax(0, 1fr);
        }

        .brand-side {
            position: relative;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            padding: 44px 56px 54px;
            overflow: hidden;
            color: var(--white);
            text-align: center;
            background: linear-gradient(180deg, var(--brand-blue) 0%, var(--brand-blue-deep) 100%);
        }

        .brand-side::before {
            content: "";
            position: absolute;
            inset: 0;
            background:
                radial-gradient(circle at 30% 18%, rgba(255, 255, 255, 0.12), transparent 28%),
                linear-gradient(145deg, rgba(255, 255, 255, 0.08), transparent 42%);
            pointer-events: none;
        }

        .brand-content {
            position: relative;
            z-index: 1;
            width: 100%;
            max-width: 520px;
            transform: translateY(-12px);
        }

        .brand-logo {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 208px;
            height: 142px;
            margin-bottom: 22px;
        }

        .brand-logo img {
            width: 100%;
            height: 100%;
            object-fit: contain;
            filter: drop-shadow(0 18px 26px rgba(5, 31, 76, 0.22));
        }

        .brand-content h1 {
            margin: 0;
            font-size: clamp(1.78rem, 2.7vw, 2.6rem);
            line-height: 1.58;
            font-weight: 700;
            letter-spacing: 0;
        }

        .brand-content p {
            margin: 16px 0 0;
            font-size: clamp(1.05rem, 1.7vw, 1.45rem);
            font-weight: 600;
            line-height: 1.5;
        }

        .brand-footer {
            position: absolute;
            z-index: 1;
            left: 32px;
            right: 32px;
            bottom: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            color: rgba(255, 255, 255, 0.92);
            font-size: 0.98rem;
            font-weight: 600;
        }

        .form-side {
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            padding: 56px 72px;
            background: #ffffff;
        }

        .login-form-wrap {
            width: 100%;
            max-width: 760px;
        }

        .form-heading {
            margin-bottom: 30px;
        }

        .form-heading h2 {
            margin: 0;
            color: var(--text-main);
            font-size: clamp(1.8rem, 2.5vw, 2.25rem);
            font-weight: 700;
            line-height: 1.25;
        }

        .form-heading p {
            margin: 10px 0 0;
            color: var(--text-muted);
            font-size: 1.05rem;
            line-height: 1.7;
        }

        .form-row {
            margin-bottom: 26px;
        }

        .form-row label {
            display: block;
            margin-bottom: 12px;
            color: var(--text-main);
            font-size: 1.12rem;
            font-weight: 700;
        }

        .input-frame {
            position: relative;
        }

        .input-frame i {
            position: absolute;
            top: 50%;
            left: 20px;
            transform: translateY(-50%);
            color: #9aa5b4;
            font-size: 1.06rem;
        }

        .input-frame input {
            width: 100%;
            min-height: 58px;
            padding: 14px 22px 14px 54px;
            border: 1px solid var(--line);
            border-radius: 5px;
            background: #ffffff;
            color: var(--text-main);
            font-family: inherit;
            font-size: 1.04rem;
            outline: none;
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }

        .input-frame input::placeholder {
            color: var(--danger);
            text-align: right;
            opacity: 0.9;
        }

        .input-frame input:focus {
            border-color: var(--focus);
            box-shadow: 0 0 0 3px rgba(108, 184, 255, 0.18);
        }

        .error-msg {
            display: flex;
            align-items: center;
            gap: 10px;
            margin: 0 0 22px;
            padding: 13px 16px;
            border: 1px solid #ffc9ca;
            border-radius: 5px;
            background: #fff5f5;
            color: #c93438;
            font-size: 0.98rem;
            font-weight: 600;
        }

        .captcha-panel {
            margin: 0 0 26px;
            padding: 16px;
            border: 1px solid #cfe1f5;
            border-radius: 5px;
            background: #f8fbff;
        }

        .captcha-panel label {
            margin-bottom: 12px;
        }

        .captcha-visual {
            display: flex;
            align-items: center;
            gap: 18px;
            margin-bottom: 14px;
        }

        .captcha-visual img {
            width: 190px;
            height: 72px;
            border: 1px solid #d8e3ef;
            border-radius: 5px;
            background: #ffffff;
        }

        .captcha-input-wrap input {
            width: 100%;
            min-height: 52px;
            padding: 12px 16px;
            border: 1px solid var(--line);
            border-radius: 5px;
            font-family: inherit;
            font-size: 1.04rem;
            outline: none;
        }

        .captcha-input-wrap input:focus {
            border-color: var(--focus);
            box-shadow: 0 0 0 3px rgba(108, 184, 255, 0.18);
        }

        .cooldown-msg {
            display: flex;
            align-items: center;
            gap: 10px;
            margin: 0 0 22px;
            padding: 13px 16px;
            border: 1px solid #f4d38a;
            border-radius: 5px;
            background: #fff9e8;
            color: #8a6100;
            font-size: 0.98rem;
            font-weight: 700;
        }

        .form-actions {
            display: grid;
            grid-template-columns: minmax(0, 1fr) 250px;
            align-items: center;
            gap: 28px;
            margin-top: 6px;
        }

        .forgot-link {
            color: #616b78;
            font-size: 1rem;
            line-height: 1.6;
        }

        .forgot-link a {
            color: var(--brand-blue);
            font-weight: 700;
            text-decoration: none;
        }

        .forgot-link a:hover {
            text-decoration: underline;
        }

        .btn-login {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            width: 100%;
            min-height: 58px;
            border: 0;
            border-radius: 5px;
            background: #69a8d4;
            color: #ffffff;
            font-family: inherit;
            font-size: 1.16rem;
            font-weight: 700;
            cursor: pointer;
            transition: background 0.2s ease, transform 0.2s ease, box-shadow 0.2s ease;
        }

        .btn-login:hover {
            background: #2583c5;
            box-shadow: 0 12px 24px rgba(37, 131, 197, 0.18);
            transform: translateY(-1px);
        }

        .btn-login:active {
            transform: translateY(0);
        }

        .office-note {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-top: 46px;
            padding-top: 20px;
            border-top: 1px solid #eef1f5;
            color: #7b8491;
            font-size: 0.95rem;
            line-height: 1.6;
        }

        .office-note img {
            width: 34px;
            height: 34px;
            object-fit: contain;
        }

        @media (max-width: 1080px) {
            .login-shell {
                grid-template-columns: 42vw minmax(0, 1fr);
            }

            .brand-side {
                padding-inline: 34px;
            }

            .form-side {
                padding-inline: 46px;
            }
        }

        @media (max-width: 820px) {
            .login-shell {
                display: block;
            }

            .brand-side {
                min-height: 360px;
                padding: 40px 24px 64px;
            }

            .brand-content {
                transform: none;
            }

            .brand-logo {
                width: 164px;
                height: 112px;
                margin-bottom: 12px;
            }

            .brand-content h1 {
                font-size: 1.65rem;
            }

            .brand-content p {
                font-size: 1.04rem;
            }

            .form-side {
                min-height: auto;
                padding: 42px 24px 52px;
            }

            .form-actions {
                grid-template-columns: 1fr;
                gap: 18px;
            }

            .btn-login {
                max-width: none;
            }
        }

        @media (max-width: 520px) {
            .brand-side {
                min-height: 330px;
            }

            .brand-content h1 {
                font-size: 1.42rem;
            }

            .form-heading h2 {
                font-size: 1.58rem;
            }

            .form-row label {
                font-size: 1rem;
            }

            .input-frame input {
                min-height: 54px;
                font-size: 1rem;
            }
        }
    </style>
</head>
<body>
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