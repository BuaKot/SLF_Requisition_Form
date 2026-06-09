<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.slf.model.ThirdPartyFormLink" %>
<%!
    public String h(Object input) {
        if (input == null) return "";
        return String.valueOf(input)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#x27;");
    }
%>
<%
    ThirdPartyFormLink link = (ThirdPartyFormLink) request.getAttribute("thirdPartyLink");
    String token = (String) request.getAttribute("token");
    String invalidLinkMessage = (String) request.getAttribute("invalidLinkMessage");
    boolean valid = link != null && invalidLinkMessage == null;
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Third-party Requisition Form</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/images/cropped-logo-192x192.png">
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; min-height: 100vh; background: #f4f8fc; color: #102a43; font-family: 'Sarabun', Tahoma, Arial, sans-serif; }
        .page { max-width: 980px; margin: 0 auto; padding: 36px 18px 52px; }
        .header { display: flex; align-items: center; gap: 16px; margin-bottom: 22px; }
        .header img { height: 62px; width: auto; }
        h1 { margin: 0; color: #003366; font-size: 28px; }
        .subtitle { margin: 6px 0 0; color: #60758a; }
        .panel { background: #fff; border: 1px solid #d9e6f2; border-radius: 10px; box-shadow: 0 8px 22px rgba(0, 51, 102, 0.08); padding: 22px; }
        .alert { background: #fdecec; border: 1px solid #f4b8b8; color: #b42318; border-radius: 8px; padding: 16px; font-weight: 800; }
        .grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 16px; }
        .full { grid-column: 1 / -1; }
        label { display: block; color: #003366; font-weight: 800; margin-bottom: 6px; }
        input, textarea { width: 100%; border: 1px solid #c7d7e6; border-radius: 7px; padding: 10px 12px; font-family: inherit; font-size: 15px; }
        textarea { min-height: 120px; resize: vertical; }
        .actions { display: flex; justify-content: flex-end; margin-top: 18px; }
        .btn { border: 0; border-radius: 7px; min-height: 42px; padding: 0 18px; font-family: inherit; font-weight: 800; cursor: pointer; }
        .btn-primary { background: #003366; color: #fff; }
        .hint { margin-top: 10px; color: #64748b; font-size: 13px; }
        @media (max-width: 720px) { .grid { grid-template-columns: 1fr; } .header { align-items: flex-start; } }
    </style>
</head>
<body>
<main class="page">
    <div class="header">
        <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo">
        <div>
            <h1>Third-party Requisition Form</h1>
            <p class="subtitle">แบบฟอร์มสำหรับบุคคลภายนอก</p>
        </div>
    </div>

    <% if (!valid) { %>
        <section class="panel">
            <div class="alert"><%= h(invalidLinkMessage) %></div>
        </section>
    <% } else { %>
        <section class="panel">
            <form method="post" action="${pageContext.request.contextPath}/thirdparty/submit">
                <input type="hidden" name="token" value="<%= h(token) %>">
                <div class="grid">
                    <div>
                        <label for="fullNameTh">ชื่อ-สกุล ภาษาไทย</label>
                        <input id="fullNameTh" name="fullNameTh" type="text" maxlength="255" required>
                    </div>
                    <div>
                        <label for="fullNameEn">ชื่อ-สกุล ภาษาอังกฤษ</label>
                        <input id="fullNameEn" name="fullNameEn" type="text" maxlength="255">
                    </div>
                    <div>
                        <label for="organization">หน่วยงาน</label>
                        <input id="organization" name="organization" type="text" maxlength="255" required>
                    </div>
                    <div>
                        <label for="phone">เบอร์โทรศัพท์</label>
                        <input id="phone" name="phone" type="tel" maxlength="50" required>
                    </div>
                    <div>
                        <label for="email">Email</label>
                        <input id="email" name="email" type="email" maxlength="320" required>
                    </div>
                    <div class="full">
                        <label for="reasonObjective">เหตุผลและวัตถุประสงค์การขอ</label>
                        <textarea id="reasonObjective" name="reasonObjective" required></textarea>
                    </div>
                    <div class="full">
                        <label for="projectName">เพื่อใช้ในโครงการ</label>
                        <input id="projectName" name="projectName" type="text" maxlength="500">
                    </div>
                    <div>
                        <label for="accessStartDate">วันที่เริ่มต้นใช้ระบบงาน</label>
                        <input id="accessStartDate" name="accessStartDate" type="date" required>
                    </div>
                    <div>
                        <label for="accessEndDate">ถึงวันที่</label>
                        <input id="accessEndDate" name="accessEndDate" type="date" required>
                    </div>
                </div>
                <div class="hint">ลิงก์นี้ใช้ส่งข้อมูลได้เพียง 1 ครั้ง และจะหมดอายุภายใน 24 ชั่วโมงหลังสร้าง</div>
                <div class="actions">
                    <button class="btn btn-primary" type="submit">ส่งแบบฟอร์ม</button>
                </div>
            </form>
        </section>
    <% } %>
</main>
</body>
</html>
