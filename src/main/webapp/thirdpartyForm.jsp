<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.slf.model.ThirdPartyFormLink" %>
<%@ page import="com.slf.model.ThirdPartyRequest" %>
<%!
    private String h(Object input) {
        if (input == null) return "";
        return String.valueOf(input)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }

    private boolean hasText(Object input) {
        return input != null && String.valueOf(input).trim().length() > 0;
    }
%>
<%
    ThirdPartyFormLink link = (ThirdPartyFormLink) request.getAttribute("thirdPartyLink");
    ThirdPartyRequest thirdPartyRequest = (ThirdPartyRequest) request.getAttribute("thirdPartyRequest");
    String token = (String) request.getAttribute("token");
    String consentVersion = (String) request.getAttribute("consentVersion");
    String invalidLinkMessage = (String) request.getAttribute("invalidLinkMessage");
    boolean valid = link != null && consentVersion != null && invalidLinkMessage == null;
    boolean hasRequestSummary = thirdPartyRequest != null
        && (hasText(thirdPartyRequest.getExternalCompanyName())
            || hasText(thirdPartyRequest.getExternalContactName())
            || hasText(thirdPartyRequest.getExternalEmail())
            || hasText(thirdPartyRequest.getExternalPhone())
            || hasText(thirdPartyRequest.getPurpose())
            || hasText(thirdPartyRequest.getTargetSystem()));
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>แบบฟอร์มผู้ให้บริการภายนอก</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/images/cropped-logo-192x192.png">
</head>
<body class="external-form-body">
<main class="external-form-page">
    <header class="external-form-header">
        <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo">
        <div>
            <p class="eyebrow">กองทุนเงินให้กู้ยืมเพื่อการศึกษา</p>
            <h1>แบบฟอร์มการขอลงทะเบียนผู้ใช้ระบบงานสารสนเทศ สำหรับผู้ให้บริการภายนอก</h1>
            <p>กรุณากรอกข้อมูลให้ครบถ้วน ลิงก์นี้ใช้ได้เฉพาะรายการที่ได้รับอนุญาตเท่านั้น</p>
        </div>
    </header>

    <% if (!valid) { %>
        <section class="external-panel invalid-token-panel">
            <div class="invalid-token-icon">!</div>
            <h2>ไม่สามารถเปิดแบบฟอร์มได้</h2>
            <p><%= h(invalidLinkMessage) %></p>
            <p class="muted-text">หากต้องการใช้งาน กรุณาติดต่อเจ้าหน้าที่ผู้ส่งลิงก์เพื่อขอลิงก์ใหม่</p>
        </section>
    <% } else { %>
        <% if (hasRequestSummary) { %>
            <section class="external-panel">
                <h2>ข้อมูลคำขอเบื้องต้น</h2>
                <div class="summary-grid">
                    <div><span>บริษัท/หน่วยงาน</span><strong><%= h(thirdPartyRequest.getExternalCompanyName()) %></strong></div>
                    <div><span>ผู้ติดต่อ</span><strong><%= h(thirdPartyRequest.getExternalContactName()) %></strong></div>
                    <div><span>Email</span><strong><%= h(thirdPartyRequest.getExternalEmail()) %></strong></div>
                    <div><span>เบอร์โทร</span><strong><%= h(thirdPartyRequest.getExternalPhone()) %></strong></div>
                    <div class="full"><span>ระบบงานที่ต้องการให้เข้าถึง</span><strong><%= h(thirdPartyRequest.getTargetSystem()) %></strong></div>
                    <div class="full"><span>วัตถุประสงค์</span><strong><%= h(thirdPartyRequest.getPurpose()) %></strong></div>
                </div>
            </section>
        <% } %>

        <section class="external-panel">
            <h2>ข้อมูลผู้กรอกแบบฟอร์ม</h2>
            <form method="post" action="${pageContext.request.contextPath}/thirdparty/submit">
                <input type="hidden" name="token" value="<%= h(token) %>">
                <input type="hidden" name="consentVersion" value="<%= h(consentVersion) %>">
                <div class="third-party-form-grid">
                    <div class="form-field">
                        <label for="fullNameTh">ชื่อ-สกุล ภาษาไทย</label>
                        <input id="fullNameTh" name="fullNameTh" type="text" maxlength="255" required
                               value="<%= h(thirdPartyRequest == null ? null : thirdPartyRequest.getExternalContactName()) %>">
                    </div>
                    <div class="form-field">
                        <label for="fullNameEn">ชื่อ-สกุล ภาษาอังกฤษ</label>
                        <input id="fullNameEn" name="fullNameEn" type="text" maxlength="255">
                    </div>
                    <div class="form-field">
                        <label for="organization">บริษัท/หน่วยงาน</label>
                        <input id="organization" name="organization" type="text" maxlength="255" required
                               value="<%= h(thirdPartyRequest == null ? null : thirdPartyRequest.getExternalCompanyName()) %>">
                    </div>
                    <div class="form-field">
                        <label for="phone">เบอร์โทร</label>
                        <input id="phone" name="phone" type="tel" maxlength="50" required
                               value="<%= h(thirdPartyRequest == null ? null : thirdPartyRequest.getExternalPhone()) %>">
                    </div>
                    <div class="form-field">
                        <label for="email">Email</label>
                        <input id="email" name="email" type="email" maxlength="320" required
                               value="<%= h(thirdPartyRequest == null ? null : thirdPartyRequest.getExternalEmail()) %>">
                    </div>
                    <div class="form-field full">
                        <label for="reasonObjective">เหตุผลและวัตถุประสงค์การขอใช้งาน</label>
                        <textarea id="reasonObjective" name="reasonObjective" required><%= h(thirdPartyRequest == null ? null : thirdPartyRequest.getPurpose()) %></textarea>
                    </div>
                    <div class="form-field full">
                        <label for="projectName">ระบบงาน/โครงการที่เกี่ยวข้อง</label>
                        <input id="projectName" name="projectName" type="text" maxlength="500"
                               value="<%= h(thirdPartyRequest == null ? null : thirdPartyRequest.getTargetSystem()) %>">
                    </div>
                    <div class="form-field">
                        <label for="accessStartDate">วันที่เริ่มต้นการใช้งาน</label>
                        <input id="accessStartDate" name="accessStartDate" type="date" required
                               value="<%= thirdPartyRequest == null || thirdPartyRequest.getAccessStartDate() == null ? "" : h(thirdPartyRequest.getAccessStartDate()) %>">
                    </div>
                    <div class="form-field">
                        <label for="accessEndDate">วันที่สิ้นสุดการใช้งาน</label>
                        <input id="accessEndDate" name="accessEndDate" type="date" required
                               value="<%= thirdPartyRequest == null || thirdPartyRequest.getAccessEndDate() == null ? "" : h(thirdPartyRequest.getAccessEndDate()) %>">
                    </div>
                </div>
                <p class="muted-text">เมื่อส่งแบบฟอร์มแล้ว ลิงก์นี้จะถูกเปลี่ยนสถานะเป็นใช้แล้วและไม่สามารถส่งซ้ำได้</p>
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
                    <input id="consentAccepted" name="consentAccepted" type="checkbox" value="accepted" required>
                    <label for="consentAccepted">ข้าพเจ้าได้อ่าน เข้าใจ และยินยอมรับเงื่อนไขตามหนังสือยินยอมฉบับ</label>
                </div>
                <div class="form-actions">
                    <button class="btn btn-primary" type="submit">ส่งแบบฟอร์ม</button>
                </div>
            </form>
        </section>
    <% } %>
</main>
<template id="accessRequestTemplate">
    <div class="access-card">
        <div class="access-card-head">
            <span class="access-number"></span>
            <button class="btn btn-remove" type="button">ลบรายชื่อ</button>
        </div>
        <div class="third-party-form-grid">
            <div class="form-field"><label>รหัสพนักงาน</label><input name="accessEmployeeCode" maxlength="100"></div>
            <div class="form-field"><label>ชื่อผู้ใช้งาน</label><input name="accessUsername" maxlength="150"></div>
            <div class="form-field"><label>เลขที่บัตรประชาชน</label><input name="accessNationalId" inputmode="numeric" maxlength="17" placeholder="ระบุเมื่อขอใช้ระบบ DSL"></div>
            <div class="form-field"><label>ชื่อ-สกุล (TH)</label><input name="accessFullNameTh" maxlength="255" required></div>
            <div class="form-field"><label>ชื่อ-สกุล (EN)</label><input name="accessFullNameEn" maxlength="255"></div>
            <div class="form-field"><label>ตำแหน่ง</label><input name="accessPosition" maxlength="255" required></div>
            <div class="form-field"><label>เบอร์โทรศัพท์มือถือ</label><input name="accessMobile" type="tel" maxlength="50" required></div>
            <div class="form-field"><label>ฝ่าย/กลุ่มงาน</label><input name="accessDepartment" maxlength="255" required></div>
            <div class="form-field"><label>Email</label><input name="accessEmail" type="email" maxlength="320" required></div>
            <div class="form-field"><label>ระบบงาน</label><input name="accessSystem" maxlength="255" required></div>
            <div class="form-field full"><label>สิทธิ์การใช้งาน (Role)</label><input name="accessRole" maxlength="1000" placeholder="เช่น ชื่อโปรแกรมย่อย ชื่อเมนู ชื่อรายงาน" required></div>
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

    function addRow() {
        if (list.children.length >= 20) return;
        var card = template.content.firstElementChild.cloneNode(true);
        card.querySelector(".btn-remove").addEventListener("click", function () {
            card.remove();
            refresh();
        });
        list.appendChild(card);
        refresh();
    }

    addButton.addEventListener("click", addRow);
    addRow();
}());
</script>
</body>
</html>
