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
    public String js(Object input) {
        if (input == null) return "";
        return String.valueOf(input).replace("\\", "\\\\").replace("\"", "\\\"")
            .replace("\r", "\\r").replace("\n", "\\n").replace("<", "\\u003c");
    }
    public String paramAt(javax.servlet.http.HttpServletRequest request, String name, int index) {
        String[] values = request.getParameterValues(name);
        return values != null && index >= 0 && index < values.length ? values[index] : "";
    }
%>
<%
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0L);
    ThirdPartyFormLink link = (ThirdPartyFormLink) request.getAttribute("thirdPartyLink");
    String consentVersion = (String) request.getAttribute("consentVersion");
    String token = (String) request.getAttribute("token");
    String invalidLinkMessage = (String) request.getAttribute("invalidLinkMessage");
    String formError = (String) request.getAttribute("formError");
    boolean valid = link != null && consentVersion != null && invalidLinkMessage == null;
    String[] accessEmployeeCodes = request.getParameterValues("accessEmployeeCode");
    int submittedAccessCount = accessEmployeeCodes == null ? 0 : accessEmployeeCodes.length;
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
        input, textarea, select { width: 100%; border: 1px solid #c7d7e6; border-radius: 7px; padding: 10px 12px; font-family: inherit; font-size: 15px; background: #fff; }
        textarea { min-height: 120px; resize: vertical; }
        .actions { display: flex; justify-content: flex-end; margin-top: 18px; }
        .btn { border: 0; border-radius: 7px; min-height: 42px; padding: 0 18px; font-family: inherit; font-weight: 800; cursor: pointer; }
        .btn-primary { background: #003366; color: #fff; }
        .hint { margin-top: 10px; color: #64748b; font-size: 13px; }
        .consent { grid-column: 1 / -1; border: 1px solid #c7d7e6; border-radius: 7px; overflow: hidden; margin-top: 4px; }
        .consent-head { background: #edf5fc; padding: 13px 16px; color: #003366; font-weight: 800; }
        .consent-body { max-height: 420px; overflow-y: auto; padding: 16px; line-height: 1.65; }
        .consent-text { margin: 0; white-space: pre-wrap; }
        .consent-note, .consent-extra { margin: 14px 0 0; color: #52677b; font-size: 13px; line-height: 1.6; }
        .consent-check { display: flex; align-items: flex-start; gap: 10px; margin-top: 14px; padding: 14px; border: 1px solid #b9cfe2; border-radius: 7px; background: #f7fbff; }
        .consent-check input { width: 18px; height: 18px; margin-top: 2px; flex: 0 0 auto; }
        .consent-check label { margin: 0; line-height: 1.55; cursor: pointer; }
        .access-section { margin-top: 22px; padding-top: 20px; border-top: 1px solid #d9e6f2; }
        .access-head { display: flex; align-items: center; justify-content: space-between; gap: 12px; margin-bottom: 12px; }
        .access-head h2 { margin: 0; color: #003366; font-size: 20px; }
        .access-card { border: 1px solid #c7d7e6; border-radius: 7px; padding: 16px; margin-bottom: 14px; background: #fbfdff; }
        .access-card-head { display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px; }
        .access-number { color: #003366; font-weight: 800; }
        .btn-add { background: #e8f2fb; color: #003366; }
        .btn-remove { background: #fdecec; color: #b42318; min-height: 34px; padding: 0 12px; }
        .table-note { color: #52677b; font-size: 13px; line-height: 1.6; margin: 4px 0 16px; }
        .error-popup-overlay { position: fixed; inset: 0; z-index: 2000; display: flex; align-items: center; justify-content: center; padding: 18px; background: rgba(15,35,55,.58); }
        .error-popup-overlay[hidden] { display: none; }
        .error-popup { width: min(520px,100%); background:#fff; border-radius:14px; padding:28px; text-align:center; box-shadow:0 24px 64px rgba(0,30,60,.28); }
        .error-popup-icon { width:62px; height:62px; margin:0 auto 16px; display:grid; place-items:center; border-radius:50%; background:#fdecec; color:#b42318; font-size:30px; font-weight:900; }
        .error-popup h2 { margin:0 0 10px; color:#b42318; }
        .error-popup p { margin:0 0 22px; color:#52677d; line-height:1.65; }
        .error-popup button { border:0; border-radius:8px; min-height:44px; padding:0 26px; background:#003f7d; color:#fff; font:inherit; font-weight:800; cursor:pointer; }
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
                <input type="hidden" name="consentVersion" value="<%= h(consentVersion) %>">
                <div class="grid">
                    <div>
                        <label for="fullNameTh">ชื่อ-สกุล ภาษาไทย</label>
                        <input id="fullNameTh" name="fullNameTh" type="text" maxlength="255" value="<%= h(request.getParameter("fullNameTh")) %>" required>
                    </div>
                    <div>
                        <label for="fullNameEn">ชื่อ-สกุล ภาษาอังกฤษ</label>
                        <input id="fullNameEn" name="fullNameEn" type="text" maxlength="255" value="<%= h(request.getParameter("fullNameEn")) %>" required>
                    </div>
                    <div>
                        <label for="organization">หน่วยงาน</label>
                        <input id="organization" name="organization" type="text" maxlength="255" value="<%= h(request.getParameter("organization")) %>" required>
                    </div>
                    <div>
                        <label for="phone">เบอร์โทรศัพท์</label>
                        <input id="phone" name="phone" type="tel" maxlength="50" value="<%= h(request.getParameter("phone")) %>" required>
                    </div>
                    <div class="full">
                        <label for="email">Email</label>
                        <input id="email" name="email" type="email" maxlength="320" value="<%= h(request.getParameter("email")) %>" required>
                    </div>
                    <div class="full">
                        <label for="reasonObjective">เหตุผลและวัตถุประสงค์การขอ</label>
                        <textarea id="reasonObjective" name="reasonObjective" required><%= h(request.getParameter("reasonObjective")) %></textarea>
                    </div>
                    <div class="full">
                        <label for="projectName">เพื่อใช้ในโครงการ</label>
                        <input id="projectName" name="projectName" type="text" maxlength="500" value="<%= h(request.getParameter("projectName")) %>">
                    </div>
                    <div>
                        <label for="accessStartDate">วันที่เริ่มต้นใช้ระบบงาน</label>
                        <input id="accessStartDate" name="accessStartDate" type="date" value="<%= h(request.getParameter("accessStartDate")) %>" required>
                    </div>
                    <div>
                        <label for="accessEndDate">ถึงวันที่</label>
                        <input id="accessEndDate" name="accessEndDate" type="date" value="<%= h(request.getParameter("accessEndDate")) %>" required>
                    </div>
                </div>
                <div class="hint">ลิงก์นี้ใช้ส่งข้อมูลได้เพียง 1 ครั้ง และจะหมดอายุภายใน 24 ชั่วโมงหลังสร้าง</div>
                <section class="access-section">
                    <div class="access-head">
                        <h2>รายชื่อผู้ขอรับสิทธิ์การเข้าถึง</h2>
                        <button class="btn btn-add" id="addAccessRequest" type="button">+ เพิ่มรายชื่อ</button>
                    </div>
                    <div class="table-note"><strong>หมายเหตุ*</strong> โปรดระบุเลขที่บัตรประชาชนหากขอใช้ระบบงานกองทุนเงินให้กู้ยืมเพื่อการศึกษาแบบดิจิทัล (DSL)</div>
                    <div id="accessRequestList"></div>
                </section>
                <div class="consent">
                    <div class="consent-head">หนังสือยินยอมรับเงื่อนไข นโยบายว่าด้วยการรักษาความลับระบบสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</div>
                    <div class="consent-body">
                        <p class="consent-text">ข้าพเจ้าขอรับรองว่าข้อมูลข้างต้น เป็นความจริงทุกประการ โดยจะไม่ใช้ เปิดเผย หรือเอาไปซึ่งข้อมูลไม่ว่าทั้งหมดหรือบางส่วนอันเป็นความลับของทางราชการ หรืออนุญาตให้บุคคลอื่นกระทำการดังกล่าว โดยไม่ได้รับความยินยอมจากกองทุนเงินให้กู้ยืมเพื่อการศึกษา เป็นลายลักษณ์อักษรไม่ว่าข้อมูลนั้นจะอยู่ในรูปแบบใด และจะปฏิบัติตามระเบียบข้อกำหนด นโยบายการรักษาความมั่นคงปลอดภัยด้านเทคโนโลยีสารสนเทศ และยินยอมรับเงื่อนไขตามที่กำหนด นโยบายว่าด้วยการรักษาความลับระบบสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา ทั้งนี้ ยินดีจะรับผิดชอบต่อความเสียหายที่เกิดขึ้นตามพระราชบัญญัติว่าด้วยการกระทำความผิดเกี่ยวกับคอมพิวเตอร์ พ.ศ. 2560 ข้าพเจ้ายอมรับข้อตกลงดังกล่าว และจะปฏิบัติตาม อย่างเคร่งครัด ทุกประการ</p>
                        <p class="consent-note">*<strong>หมายเหตุ ผู้ขอใช้บริการต้องลงนามในหนังสือยินยอมรับเงื่อนไข นโยบายว่าด้วยการรักษาความลับระบบสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</strong></p>
                        <p class="consent-extra">**กรณีที่ขอสิทธิ์การใช้งาน มากกว่า 1 คน ให้แนบเอกสารขอลงทะเบียนผู้ใช้ระบบงานสารสนเทศ (สำหรับบุคคลภายนอก)</p>
                    </div>
                </div>
                <div class="consent-check">
                    <input id="consentAccepted" name="consentAccepted" type="checkbox" value="accepted" <%= "accepted".equals(request.getParameter("consentAccepted")) ? "checked" : "" %> required>
                    <label for="consentAccepted">ข้าพเจ้าได้อ่าน เข้าใจ และยินยอมรับเงื่อนไขตามหนังสือยินยอมฉบับ</label>
                </div>
                <div class="actions">
                    <button class="btn btn-primary" type="submit">ส่งแบบฟอร์ม</button>
                </div>
            </form>
        </section>
    <% } %>
</main>
<% if (formError != null) { %>
<div class="error-popup-overlay" id="formErrorPopup">
    <section class="error-popup" role="alertdialog" aria-modal="true" aria-labelledby="formErrorTitle">
        <div class="error-popup-icon">!</div>
        <h2 id="formErrorTitle">กรุณาตรวจสอบข้อมูล</h2>
        <p><%= h(formError) %></p>
        <button id="closeFormError" type="button">กลับไปแก้ไขข้อมูล</button>
    </section>
</div>
<% } %>
<template id="accessRequestTemplate">
    <div class="access-card">
        <div class="access-card-head">
            <span class="access-number"></span>
            <button class="btn btn-remove" type="button">ลบรายชื่อ</button>
        </div>
        <div class="grid">
            <div><label>รหัสพนักงาน</label><input name="accessEmployeeCode" maxlength="100"></div>
            <div><label>ชื่อผู้ใช้งาน</label><input name="accessUsername" maxlength="150"></div>
            <div><label>เลขที่บัตรประชาชน</label><input name="accessNationalId" inputmode="numeric" maxlength="17" placeholder="ระบุเมื่อขอใช้ระบบ DSL"></div>
            <div><label>ชื่อ-สกุล (TH)</label><input name="accessFullNameTh" maxlength="255" required></div>
            <div><label>ชื่อ-สกุล (EN)</label><input name="accessFullNameEn" maxlength="255" required></div>
            <div><label>ตำแหน่ง</label><input name="accessPosition" maxlength="255" required></div>
            <div><label>เบอร์โทรศัพท์มือถือ</label><input name="accessMobile" type="tel" maxlength="50" required></div>
            <div><label>ฝ่าย/กลุ่มงาน</label><input name="accessDepartment" maxlength="255" required></div>
            <div><label>Email</label><input name="accessEmail" type="email" maxlength="320" required></div>
            <div><label>ระบบงาน</label><input name="accessSystem" maxlength="255" required></div>
            <div><label>สิทธิ์การใช้งาน (Role)</label><input name="accessRole" maxlength="1000" placeholder="เช่น ชื่อโปรแกรมย่อย ชื่อเมนู ชื่อรายงาน" required></div>
        </div>
    </div>
</template>
<script>
(function () {
    var list = document.getElementById("accessRequestList");
    var template = document.getElementById("accessRequestTemplate");
    var addButton = document.getElementById("addAccessRequest");
    if (!list || !template || !addButton) return;

    function refresh() {
        var cards = list.querySelectorAll(".access-card");
        cards.forEach(function (card, index) {
            card.querySelector(".access-number").textContent = "รายชื่อคนที่ " + (index + 1);
            card.querySelector(".btn-remove").disabled = cards.length === 1;
        });
        addButton.disabled = cards.length >= 20;
    }

    function addRow(values) {
        if (list.children.length >= 20) return;
        var card = template.content.firstElementChild.cloneNode(true);
        if (values) {
            Object.keys(values).forEach(function (name) {
                var input = card.querySelector('[name="' + name + '"]');
                if (input) input.value = values[name];
            });
        }
        card.querySelector(".btn-remove").addEventListener("click", function () {
            card.remove();
            refresh();
        });
        list.appendChild(card);
        refresh();
    }

    addButton.addEventListener("click", function () { addRow(); });
    var submittedRows = [
        <% for (int i = 0; i < submittedAccessCount; i++) { %>
        {
            accessEmployeeCode:"<%= js(paramAt(request, "accessEmployeeCode", i)) %>",
            accessUsername:"<%= js(paramAt(request, "accessUsername", i)) %>",
            accessNationalId:"<%= js(paramAt(request, "accessNationalId", i)) %>",
            accessFullNameTh:"<%= js(paramAt(request, "accessFullNameTh", i)) %>",
            accessFullNameEn:"<%= js(paramAt(request, "accessFullNameEn", i)) %>",
            accessPosition:"<%= js(paramAt(request, "accessPosition", i)) %>",
            accessMobile:"<%= js(paramAt(request, "accessMobile", i)) %>",
            accessDepartment:"<%= js(paramAt(request, "accessDepartment", i)) %>",
            accessEmail:"<%= js(paramAt(request, "accessEmail", i)) %>",
            accessSystem:"<%= js(paramAt(request, "accessSystem", i)) %>",
            accessRole:"<%= js(paramAt(request, "accessRole", i)) %>"
        }<%= i + 1 < submittedAccessCount ? "," : "" %>
        <% } %>
    ];
    if (submittedRows.length) submittedRows.forEach(addRow); else addRow();
}());

var closeFormError = document.getElementById("closeFormError");
if (closeFormError) {
    closeFormError.addEventListener("click", function () {
        document.getElementById("formErrorPopup").hidden = true;
    });
}

window.addEventListener("pageshow", function (event) {
    if (event.persisted) {
        window.location.reload();
    }
});
</script>
</body>
</html>
