<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*, com.slf.dao.DBConnection" %>
<head>
<style>
body {
    margin-left: 50px;
    margin-right: 50px;
    margin-top: 25px;
    margin-bottom: 25px;

}

.top-row {
    display: inline-block;
    margin-left: 30px;
}

.head-table {
    border-collapse: collapse;
    width: 100%;
}

td, th {
    border: 1px solid black;
    padding: 8px;
    vertical-align: middle; /* Keeps text centered with the logo height */
    text-align:center;
    vertical-align: middle;
}

/* Make the logo scale nicely to fit its column container tightly */
.logo {
    max-width: 100%;
    height: auto;
    display: block;
}

.invisible-header th {
    border: none !important;
    padding: 0 !important;
    font-size: 0 !important;
    color: transparent !important;
    background: transparent !important;
    height: 0 !important;
}

/* Base info layout rules */
.info-row-table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 15px;
    border: none;
}

.info-label {
    font-family: 'THSarabunNew', sans-serif;
    font-size: 16px;
    font-weight: bold;
    white-space: nowrap;
    padding: 6px 4px 2px 4px;
    vertical-align: bottom;
    border: none;
}

.info-value-field {
    font-family: 'THSarabunNew', sans-serif;
    font-size: 16px;
    padding: 6px 4px 1px 4px;
    vertical-align: bottom;
    border-top: none;
    border-left: none;
    border-right: none;
    border-bottom: 1px dotted #333;
    color: #002244;
}

.request-box {
    border: solid 1px black;
    margin-top: 15px;
    padding: 6px 4px 1px 4px;
    vertical-align: bottom;
}

</style>
</head>

<body>
    

    <div style='text-align:right; margin-bottom: 5px;'>
        <p class="top-row"><strong>ใบขอให้ดำเนินการ / Requisition Form</strong></p>
        <p class="top-row"><strong>SLF-RF-007 V1.0</strong></p>
    </div>

    <table class='head-table'>
        <tr class='invisible-header'>
            <th style="width: 15%;">1 (Logo Column)</th>
            <th style="width: 65%;">2 (Main Body Space)</th>
            <th style="width: 10%;">3</th>
            <th style="width: 10%;">4</th>
        </tr>
        <tr>
            <td rowspan="2" style="padding-top:40px;padding-bottom:40px">
                <img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo" class='logo'>
            </td>
            <td colspan="3" rowspan="1">
                <p>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินกู้ยืมเพื่อการศึกษา</p>
            </td>
        </tr>
        <tr>
            <td colspan="1" rowspan="1">
                <p>ใบขอให้ดำเนินการ / Requisition Form</p>
            </td>
            <td colspan="2" rowspan="1">
                <p>TOILET</p>
            </td>
        </tr>
    </table>

    <table class="info-row-table">
        <tr>
            <td class="info-label" style="width: 12%;">ผู้ขอ / Requestor</td>
            <td class="info-value-field" style="width: 48%;">full name</td>
            
            <td class="info-label" style="width: 5%; text-align: right;">ส่วน</td>
            <td class="info-value-field" style="width: 35%;">sec name</td>
        </tr>
    </table>
    
    <table class="info-row-table">
        <tr>
            <td class="info-label" style="width: 5%;">ฝ่าย</td>
            <td class="info-value-field" style="width: 45%;">dept name</td>
            
            <td class="info-label" style="width: 7%; text-align: right;">เบอร์ต่อ</td>
            <td class="info-value-field" style="width: 15%;">phone</td>
            
            <td class="info-label" style="width: 5%; text-align: right;">วันที่</td>
            <td class="info-value-field" style="width: 23%;">date</td>
        </tr>
    </table>

    <h2>ชื่อหัวข้อความต้องการ : Vis TOILET สำหรับพนักงานที่ไม่สามารถใช้ห้องน้ำได้</h2>

    <div class='request-box'>
        <h3>Request 1: ขอให้ซ่อม</h3>
        <p>วัตถุประสงค์/ความต้องการ: .........................................................</p>
        <p>วิธีการเดิมในปัจจุบัน: ...............................................................</p>
    </div>

</body>