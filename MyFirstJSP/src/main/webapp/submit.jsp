<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    /* ===============================
       SESSION CHECK
    =============================== */
    Object empObj = session.getAttribute("empid");

    if (empObj == null) {
        empObj = session.getAttribute("loggedInEmpId");
    }

    if (empObj == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    int empid = Integer.parseInt(empObj.toString());

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    boolean hasData = false;
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Submit Requisition Form</title>

    <!-- CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/submit.css">

    <!-- ICON -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flaticon@3/flaticon.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/4.0.0/uicons-regular-rounded/css/uicons-regular-rounded.css">
    <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/4.0.0/uicons-bold-straight/css/uicons-bold-straight.css">
    <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/4.0.0/uicons-regular-straight/css/uicons-regular-straight.css">
    <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/4.0.0/uicons-solid-rounded/css/uicons-solid-rounded.css">
</head>

<body>

<!-- ===============================
     SIDEBAR
================================ -->
<div id="mySidebar" class="sidebar">
    <a href="javascript:void(0)" class="closebtn" onclick="toggleNav()">&times;</a>
    <a href="${pageContext.request.contextPath}" style="font-size:20px">หน้าหลัก</a>
    <a href="${pageContext.request.contextPath}/submit.jsp" style="font-size:20px">ฟอร์มที่ส่งแล้ว</a>
    <a href="${pageContext.request.contextPath}/newForm" style="font-size:20px">สร้างฟอร์มใหม่</a>
    <a href="${pageContext.request.contextPath}/Admin.jsp" class="admin-tab">
        <i class="fa fa-circle-user" style="font-size:36px;padding-right:25%"></i>Admin
    </a>
</div>

<div id="main">

    <!-- HEADER -->
    <div class="sticky-bar">
        <i id="menuBtn"
           class="fa fa-bars"
           onclick="toggleNav()"
           style="font-size:36px; cursor:pointer; padding-left:5px; padding-right:5px;">
        </i>

        <img src="${pageContext.request.contextPath}/images/MoF.png"
             alt="MoF Logo"
             style="height:48px; padding-left:10px; padding-right:5px">

        <img src="${pageContext.request.contextPath}/images/SLF_logo.png"
             alt="SLF Logo"
             style="height:48px; padding-left:5px; padding-right:5px">

        <div style="margin-left:auto;display:flex;align-items:center">
            <i class="fa fa-circle-user" style="font-size:24px;padding-left:10px;"></i>
            <p style="margin-left:5px;margin-right:15px">
                EMPID : <%= empid %> | สอบถามข้อมูลเพิ่มเติม ติดต่อ 411
            </p>
        </div>
    </div>

    <!-- TITLE -->
    <div class="blue-title">
        <h1 style="margin-block-start:0.1em; margin-block-end:0.1em;color:#003366">
            ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินกู้ยืมเพื่อการศึกษา
        </h1>

        <h2 style="margin-block-start:0.1em; margin-block-end:0.1em;color:#003366">
            ใบขอให้ดำเนินการ / Requisition Form
        </h2>
    </div>

    <!-- HEADER TABLE -->
    <section class="progress-header">

        <div class="header-item">
            <i class="fi fi-rr-form"></i>
            <span>จำนวนใบขอให้ดำเนินการทั้งหมด</span>
        </div>

        <div class="header-item">
            <i class="fi fi-bs-user"></i>
            <span>ผู้อำนวยการฝ่าย</span>
        </div>

        <div class="header-item">
            <i class="fi fi-rr-it-alt"></i>
            <span>ความเห็นและการอนุมัติเชิงเทคนิค</span>
        </div>

        <div class="header-item">
            <i class="fi fi-bs-user"></i>
            <span>ผู้อำนวยการฝ่ายเทคโนโลยีสารสนเทศ</span>
        </div>

        <div class="header-item">
            <i class="fa-solid fa-gears"></i>
            <span>ขั้นตอนการดำเนินการ</span>
        </div>

        <div class="header-item">
            <i class="fi fi-rr-confirmed-user"></i>
            <span>ผลตรวจรับ</span>
        </div>

    </section>
<!-- REQUEST LIST -->
<section class="request-list">

<%
/* ===============================
   REQUEST LIST (STATE_STEP +/-)
   4 STEP SYSTEM
================================ */
try {

    Class.forName("oracle.jdbc.driver.OracleDriver");

    conn = DriverManager.getConnection(
        "jdbc:oracle:thin:@172.25.18.186:1521:XE",
        "C##DEVUSER",
        "mypassword"
    );

    /*
     * STATE_STEP:
     *
     *  0 = Pending
     *  1 = ผ่าน STEP 1
     *  2 = ผ่าน STEP 2
     *  3 = ผ่าน STEP 3
     *  4 = ผ่าน STEP 4
     *
     * -1 = ไม่ผ่าน STEP 1
     * -2 = ไม่ผ่าน STEP 2
     * -3 = ไม่ผ่าน STEP 3
     * -4 = ไม่ผ่าน STEP 4
     */
    String sql =
        "SELECT RF.FORMID, RF.TITLEFORM, " +
        "NVL(( " +
        "   SELECT AI.STATE_STEP " +
        "   FROM APPROVALINFO AI " +
        "   WHERE AI.FORMID = RF.FORMID " +
        "   ORDER BY AI.APPROVALID DESC " +
        "   FETCH FIRST 1 ROWS ONLY " +
        "), 0) AS STATE_STEP " +
        "FROM REQUISITIONFORM RF " +
        "WHERE RF.EMPID = ? " +
        "ORDER BY RF.FORMID DESC";

    pstmt = conn.prepareStatement(sql);
    pstmt.setInt(1, empid);

    rs = pstmt.executeQuery();

    while (rs.next()) {

        hasData = true;

        /* ===============================
           GET DATA
        =============================== */
        int formId = rs.getInt("FORMID");
        String title = rs.getString("TITLEFORM");
        int stateStep = rs.getInt("STATE_STEP");

        /* ===============================
           STATUS FLAGS
        =============================== */
        boolean director1 = false;
        boolean technical = false;
        boolean director2 = false;
        boolean process = false;

        boolean director1Reject = false;
        boolean technicalReject = false;
        boolean director2Reject = false;
        boolean processReject = false;

        /* ===============================
           PASS FLOW
        =============================== */
        if (stateStep >= 0) {

            director1 = stateStep >= 1;
            technical = stateStep >= 2;
            director2 = stateStep >= 3;
            process   = stateStep >= 4;

        }

        /* ===============================
           REJECT FLOW
        =============================== */
        if (stateStep == -1) {

            director1Reject = true;
            technicalReject = true;
            director2Reject = true;
            processReject   = true;

        } else if (stateStep == -2) {

            director1 = true;

            technicalReject = true;
            director2Reject = true;
            processReject   = true;

        } else if (stateStep == -3) {

            director1 = true;
            technical = true;

            director2Reject = true;
            processReject   = true;

        } else if (stateStep == -4) {

            director1 = true;
            technical = true;
            director2 = true;

            processReject = true;

        }

        /*
         * ยืนยันผลได้เมื่อผ่าน STEP 4 เท่านั้น
         */
        boolean canConfirm = (stateStep == 4);

%>

        <div class="request-row">

            <!-- ===============================
                 FORM BUTTON
            =============================== -->
            <div class="request-col">
                <a href="detail.jsp?formId=<%= formId %>" style="text-decoration:none;">
                    <button type="button" class="request-btn">
                        <%= title %> ที่ <%= formId %>
                    </button>
                </a>
            </div>

            <!-- ===============================
                 STEP 1 : DIRECTOR
            =============================== -->
            <div class="status-col">
                <i class="<%=
                    director1Reject
                        ? "fi fi-sr-cross-circle status-red"
                        : director1
                            ? "fi fi-sr-user-trust status-green"
                            : "fi fi-sr-pending status-yellow"
                %>"></i>
            </div>

            <!-- ===============================
                 STEP 2 : TECHNICAL
            =============================== -->
            <div class="status-col">
                <i class="<%=
                    technicalReject
                        ? "fi fi-sr-cross-circle status-red"
                        : technical
                            ? "fi fi-sr-user-trust status-green"
                            : "fi fi-sr-pending status-yellow"
                %>"></i>
            </div>

            <!-- ===============================
                 STEP 3 : IT DIRECTOR
            =============================== -->
            <div class="status-col">
                <i class="<%=
                    director2Reject
                        ? "fi fi-sr-cross-circle status-red"
                        : director2
                            ? "fi fi-sr-user-trust status-green"
                            : "fi fi-sr-pending status-yellow"
                %>"></i>
            </div>

            <!-- ===============================
                 STEP 4 : PROCESS
            =============================== -->
            <div class="status-col">
                <i class="<%=
                    processReject
                        ? "fi fi-sr-cross-circle status-red"
                        : process
                            ? "fi fi-sr-user-trust status-green"
                            : "fi fi-sr-pending status-yellow"
                %>"></i>
            </div>

            <!-- ===============================
                 FINAL CONFIRM BUTTON
            =============================== -->
            <div class="confirm-col">
                <button class="confirm-btn
                    <%= stateStep < 0 ? " rejected-btn" : "" %>"
                    data-formid="<%= formId %>"

                    <% if (!canConfirm) { %>
                        disabled
                        style="cursor:not-allowed;"
                    <% } %>>

                    <%=
                        stateStep < 0
                            ? "ไม่ผ่าน"
                            : canConfirm
                                ? "ยืนยันผล"
                                : "รอดำเนินการ"
                    %>

                </button>
            </div>

        </div>

<%
    } // END WHILE


    /* ===============================
       NO DATA
    =============================== */
    if (!hasData) {
%>

        <div style="text-align:center; padding:40px;">
            <h3>ยังไม่มีฟอร์มคำร้องของคุณ</h3>

            <a href="${pageContext.request.contextPath}/newForm">
                <button class="request-btn">
                    + สร้างฟอร์มใหม่
                </button>
            </a>
        </div>

<%
    }

} catch (Exception e) {
%>

        <div style="color:red; text-align:center; padding:20px;">
            <h3>เกิดข้อผิดพลาด</h3>
            <p><%= e.getMessage() %></p>
        </div>

<%
    e.printStackTrace();

} finally {

    try {
        if (rs != null) rs.close();
    } catch (Exception ignored) {}

    try {
        if (pstmt != null) pstmt.close();
    } catch (Exception ignored) {}

    try {
        if (conn != null) conn.close();
    } catch (Exception ignored) {}

}
%>

</section>

</div>

<!-- POPUP -->
<div id="confirmPopup" class="popup-overlay">
    <div class="popup-box">
        <h3>ยืนยันผล</h3>
        <p>กรุณาระบุรายละเอียดก่อนยืนยันผลรายการนี้</p>

        <textarea id="popupDetail"
                  class="popup-textarea"
                  placeholder="กรอกรายละเอียด / หมายเหตุ..."></textarea>

        <div class="popup-buttons">
            <button id="popupConfirm" class="popup-confirm-btn">ยืนยัน</button>
            <button onclick="closePopup()" class="popup-cancel-btn">ยกเลิก</button>
        </div>
    </div>
</div>

<script>
let currentButton = null;

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

document.addEventListener("DOMContentLoaded", function () {

    document.querySelectorAll(".confirm-btn").forEach(button => {

        button.addEventListener("click", function () {

            if (this.disabled) {
                alert("ยังไม่สามารถยืนยันผลได้ เนื่องจากขั้นตอนยังไม่เสร็จ");
                return;
            }

            currentButton = this;

            document.getElementById("confirmPopup").style.display = "flex";
        });

    });

    document.getElementById("popupConfirm").addEventListener("click", function () {

        let detail = document.getElementById("popupDetail").value.trim();

        if (detail === "") {
            alert("กรุณากรอกรายละเอียดก่อนยืนยันผล");
            return;
        }

        if (currentButton) {
            currentButton.innerText = "ยืนยันแล้ว";
            currentButton.disabled = true;
            currentButton.classList.add("confirmed");
        }

        closePopup();
    });

});

function closePopup() {
    document.getElementById("confirmPopup").style.display = "none";
    document.getElementById("popupDetail").value = "";
}
</script>

</body>
</html>