<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.slf.util.SecurityUtil" %>

<%
    if (session.getAttribute("loggedInEmpId") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> formList = (List<Map<String, Object>>) request.getAttribute("formList");
    if (formList == null) formList = new ArrayList<>();

    int currentPage = request.getAttribute("currentPage") != null ? (Integer) request.getAttribute("currentPage") : 1;
    int pageSize    = request.getAttribute("pageSize")    != null ? (Integer) request.getAttribute("pageSize")    : 50;
    String showParam = request.getAttribute("showParam")  != null ? (String) request.getAttribute("showParam")   : "pending";
    String sortParam = request.getAttribute("sortParam")  != null ? (String) request.getAttribute("sortParam")   : "asc";
    boolean hasData  = !formList.isEmpty();
    boolean alreadyProcessed = "already_processed".equals(request.getParameter("error"));
    String csrfToken = SecurityUtil.ensureCsrfToken(request);
%>

<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>รายการใบขอให้ดำเนินการด้านเทคโนโลยีสารสนเทศที่ส่งแล้ว</title>
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/images/cropped-logo-192x192.png">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    
    <style>
        /* Modern UI Styles mapped directly onto the master corporate template specs */
        .submit-container-layout {
            width: min(1240px, calc(100% - 28px));
            margin: 24px auto;
            display: flex;
            flex-direction: column;
            gap: 20px;
        }
        
        .submit-alert-banner {
            border: 1px solid #f4b8b8;
            background: #fdecec;
            color: #b42318;
            border-radius: 8px;
            padding: 14px 16px;
            font-weight: 900;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        /* Metric KPI Summary Ribbon Blocks */
        .dashboard-kpi-grid {
            display: grid;
            grid-template-columns: repeat(5, minmax(0, 1fr));
            gap: 12px;
            width: 100%;
        }

        .kpi-card {
            background: #ffffff;
            border: 1px solid #d7e5f4;
            border-radius: 8px;
            padding: 14px 18px;
            display: flex;
            flex-direction: column;
            gap: 4px;
            cursor: pointer;
            box-shadow: 0 4px 12px rgba(50, 114, 187, 0.03);
            transition: all 0.2s cubic-bezier(0.25, 0.8, 0.25, 1);
        }

        .kpi-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(50, 114, 187, 0.08);
            border-color: #3272BB;
        }

        .kpi-card.active {
            border-color: #003366;
            background-color: #f4f8fc;
            box-shadow: inset 0 0 0 1px #003366;
        }

        .kpi-title {
            color: #52677d;
            font-size: 15px;
            font-weight: 800;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .kpi-value {
            color: #003366;
            font-size: 28px;
            font-weight: 900;
            line-height: 1.1;
        }

        /* Specific State Border/Color Coding overrides matching metrics branding */
        .kpi-card.sc-total .kpi-value { color: #003366; }
        .kpi-card.sc-pending { border-left: 4px solid #3272BB; }
        .kpi-card.sc-pending .kpi-value { color: #3272BB; }
        .kpi-card.sc-overdue { border-left: 4px solid #925400; }
        .kpi-card.sc-overdue .kpi-value { color: #925400; }
        .kpi-card.sc-rejected { border-left: 4px solid #b42318; }
        .kpi-card.sc-rejected .kpi-value { color: #b42318; }
        .kpi-card.sc-approved { border-left: 4px solid #087443; }
        .kpi-card.sc-approved .kpi-value { color: #087443; }

        /* Modern Filter Controls Panel Elements */
        .workspace-filter-toolbar {
            background: rgba(255, 255, 255, 0.9);
            border: 1px solid #d7e5f4;
            border-radius: 8px;
            padding: 16px;
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
        }

        .toolbar-left, .toolbar-right {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }

        .search-control-box {
            position: relative;
            min-width: 280px;
        }

        .search-control-box i.fa-magnifying-glass {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: #a0aec0;
        }

        .search-control-box input {
            width: 100%;
            padding: 10px 40px 10px 36px;
            border: 1px solid #c7d7e6;
            border-radius: 8px;
            min-height: 42px;
            font: inherit;
        }

        .search-clear {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            border: none;
            background: none;
            color: #a0aec0;
            cursor: pointer;
            display: none;
        }

        .search-control-box.has-text .search-clear {
            display: block;
        }

        /* Checkbox Toggles UI Custom Styling Setup */
        .interactive-checkbox-group {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .custom-checkbox-label {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 15px;
            font-weight: 800;
            color: #003366;
            cursor: pointer;
        }

        /* Legacy Compatibility Overrides for Back Button Navigation Suite Requirements */
        .submit-home-button {
            min-height: 40px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 13px;
            border: 1px solid #c5d4e2;
            border-radius: 8px;
            background: #f5f9fc;
            color: #003f73;
            text-decoration: none;
            font-size: 15px;
            font-weight: 800;
            white-space: nowrap;
        }
        .submit-home-button:hover {
            border-color: #3272bb;
            background: #e8f3fb;
        }
        .submit-filter-separator {
            width: 1px;
            height: 30px;
            background: #d8e2eb;
            margin: 0 4px;
        }

        /* Robust Modernized Requisition Flow Worklist Cards */
        .submissions-worklist {
            display: flex;
            flex-direction: column;
            gap: 14px;
            width: 100%;
        }

        .requisition-row-card {
            background: #ffffff;
            border: 1px solid #d7e5f4;
            border-radius: 8px;
            padding: 20px;
            display: grid;
            grid-template-columns: minmax(240px, 1.2fr) minmax(320px, 1.8fr) auto;
            gap: 24px;
            align-items: center;
            box-shadow: 0 4px 14px rgba(0, 51, 102, 0.03);
            transition: all 0.2s ease;
        }

        .requisition-row-card:hover {
            border-color: #3272BB;
            box-shadow: 0 8px 24px rgba(0, 51, 102, 0.07);
            transform: translateY(-1px);
        }

        .meta-identity-block {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .id-title-lockup {
            display: flex;
            flex-direction: column;
            gap: 2px;
        }

        .req-id-badge {
            font-family: monospace;
            font-weight: 900;
            color: #3272BB;
            font-size: 15px;
        }

        .req-title-link {
            color: #003366;
            font-size: 18px;
            font-weight: 900;
            text-decoration: none;
            line-height: 1.3;
        }

        .req-title-link:hover {
            color: #3272BB;
        }

        .status-tags-group {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }

        /* Beautiful Linear Progress Timeline Blueprint Mapping */
        .timeline-progress-track {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            position: relative;
            width: 100%;
        }

        .timeline-milestone {
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            position: relative;
            gap: 4px;
        }

        /* Step Connective Track Lines */
        .timeline-milestone:not(:last-child)::after {
            content: "";
            position: absolute;
            left: 50%;
            top: 14px;
            width: 100%;
            height: 3px;
            background: #e2e8f0;
            z-index: 1;
        }

        .timeline-milestone.done:not(:last-child)::after {
            background: #28a745;
        }

        .timeline-milestone.reject:not(:last-child)::after {
            background: #dc2626;
        }

        .milestone-node {
            width: 28px;
            height: 28px;
            border-radius: 999px;
            background: #edf2f7;
            color: #718096;
            display: grid;
            place-items: center;
            font-size: 11px;
            position: relative;
            z-index: 2;
        }

        .timeline-milestone.done .milestone-node { background: #28a745; color: #ffffff; }
        .timeline-milestone.pending .milestone-node { background: #e8f2fb; color: #3272BB; border: 2px solid #3272BB; }
        .timeline-milestone.reject .milestone-node { background: #dc2626; color: #ffffff; }

        .milestone-caption { font-size: 14px; font-weight: 800; color: #4a5568; }
        .milestone-timestamp { font-size: 12px; color: #a0aec0; font-weight: bold; }

        /* Grid Row Control Buttons Layout Configuration */
        .action-controls-block {
            display: flex;
            flex-direction: column;
            gap: 8px;
            min-width: 160px;
        }

        .action-row-btn {
            border: 1px solid #d7e5f4;
            border-radius: 6px;
            min-height: 36px;
            padding: 6px 12px;
            font-size: 14px;
            font-weight: 800;
            font-family: inherit;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            text-decoration: none;
            transition: all 0.15s ease;
        }

        .action-row-btn.primary-action-btn { background: #003366; color: #ffffff; border-color: #003366; }
        .action-row-btn.primary-action-btn:hover { background: #3272BB; border-color: #3272BB; }
        .action-row-btn.secondary-action-btn { background: #f0f6fc; color: #003366; }
        .action-row-btn.secondary-action-btn:hover { background: #e8f2fb; }
        
        /* State Indicators Modifiers styling definitions */
        .action-row-btn:disabled { opacity: 0.6; cursor: not-allowed !important; }

        .empty-state-card, .search-not-found-card {
            background: #ffffff;
            border: 1px solid #d7e5f4;
            border-radius: 8px;
            padding: 48px;
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 14px;
            box-shadow: 0 10px 24px rgba(50, 114, 187, 0.04);
        }

        .empty-state-card i { font-size: 48px; color: #3272BB; }
        .search-not-found-card i { font-size: 48px; color: #a0aec0; }

        /* Adaptive Media Constraints Layout Flow System Rules */
        @media (max-width: 980px) {
            .requisition-row-card {
                grid-template-columns: 1fr;
                gap: 18px;
            }
            .dashboard-kpi-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            .dashboard-kpi-grid .sc-total {
                grid-column: span 2;
            }
        }
    </style>
</head>

<body>

<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>

<div id="main" class="enterprise-index-shell">

    <%@ include file="/WEB-INF/jspf/topbar.jspf" %>

    <div class="topbar-back-row">
        <a href="${pageContext.request.contextPath}">
            <i class="fa-solid fa-house"></i> กลับหน้าแรกหลักระบบงาน
        </a>
    </div>

    <section class="enterprise-hero">
        <div class="enterprise-hero-copy">
            <p class="enterprise-eyebrow"><i class="fa-solid fa-server"></i> IT SERVICE MANAGEMENT CENTRE</p>
            <h1>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินกู้ยืมเพื่อการศึกษา</h1>
            <p class="enterprise-hero-lead">ติดตาม ตรวจสอบ และอนุมัติสถานะคำขอรับบริการด้านเทคโนโลยีสารสนเทศ อุปกรณ์ฮาร์ดแวร์ และระบบเครือข่ายสิทธิ์การเข้าใช้งานภายในองค์กร</p>
        </div>
    </section>

    <div class="submit-container-layout">

        <% if (alreadyProcessed) { %>
        <div class="submit-alert-banner">
            <i class="fa-solid fa-triangle-exclamation"></i> 
            <span>ใบคำร้องขอชิ้นนี้ได้รับการประมวลผลเสร็จสิ้นผ่าน Workflow ไปก่อนหน้านี้เรียกว่าเสร็จแล้ว</span>
        </div>
        <% } %>

        <section class="dashboard-kpi-grid">
            <div class="kpi-card sc-total" data-filter="all" title="แสดงผลคำขอยื่นทั้งหมด">
                <div class="kpi-title"><i class="fa-solid fa-layer-group"></i> ทั้งหมด</div>
                <div class="kpi-value">${cntTotal}</div>
            </div>
            <div class="kpi-card sc-pending" data-filter="pending" title="ตัวกรอง: เฉพาะรอดำเนินการ">
                <div class="kpi-title"><i class="fa-solid fa-hourglass-half"></i> รอดำเนินการ</div>
                <div class="kpi-value">${cntPending}</div>
            </div>
            <div class="kpi-card sc-overdue" data-filter="overdue" title="ตัวกรอง: เฉพาะรายการหมดเขตกำหนด">
                <div class="kpi-title"><i class="fa-solid fa-circle-exclamation"></i> หมดเขต</div>
                <div class="kpi-value">${cntOverdue}</div>
            </div>
            <div class="kpi-card sc-rejected" data-filter="rejected" title="ตัวกรอง: เฉพาะรายการที่ไม่ผ่านอนุมัติ">
                <div class="kpi-title"><i class="fa-solid fa-square-xmark"></i> ไม่ผ่าน</div>
                <div class="kpi-value">${cntRejected}</div>
            </div>
            <div class="kpi-card sc-approved" data-filter="approved" title="ตัวกรอง: เฉพาะรายการยืนยันเสร็จสิ้นผลตรวจรับ">
                <div class="kpi-title"><i class="fa-solid fa-square-check"></i> ยืนยันผลแล้ว</div>
                <div class="kpi-value">${cntApproved}</div>
            </div>
        </section>

        <section class="workspace-filter-toolbar">
            <div class="toolbar-left">
                <a class="submit-home-button form-type-action secondary" style="min-height:42px; font-size:15px; display: inline-flex; align-items: center; gap: 8px;" href="${pageContext.request.contextPath}/it-requisition-form-detail.jsp">
                    <i class="fa-solid fa-arrow-left"></i> รายละเอียดฟอร์ม
                </a>
                <span class="submit-filter-separator" aria-hidden="true"></span>
                <div class="interactive-checkbox-group">
                    <label class="custom-checkbox-label">
                        <input type="checkbox" value="pending" checked style="width:16px; height:16px;"> รอดำเนินการ
                    </label>
                    <label class="custom-checkbox-label" style="color:#925400;">
                        <input type="checkbox" value="overdue" checked style="width:16px; height:16px;"> หมดเขต
                    </label>
                    <label class="custom-checkbox-label" style="color:#b42318;">
                        <input type="checkbox" value="rejected" checked style="width:16px; height:16px;"> ไม่ผ่านการอนุมัติ
                    </label>
                    <label class="custom-checkbox-label" style="color:#087443;">
                        <input type="checkbox" value="approved" checked style="width:16px; height:16px;"> อนุมัติแล้ว
                    </label>
                </div>
            </div>

            <div class="toolbar-right">
                <div class="search-control-box" id="searchWrap">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <input type="text" id="searchInput" placeholder="พิมพ์ ค้นหาเลขที่คำขอ หรือ ชื่อฟอร์ม..." autocomplete="off">
                    <button type="button" class="search-clear" id="searchClear"><i class="fa-solid fa-circle-xmark"></i></button>
                </div>

                <div class="sort-controls" style="margin-left:4px;">
                    <button id="sortAscBtn" class="sort-btn active" onclick="setSortOrder('deadline','asc')" title="เรียงลำดับ Deadline เก่ามาใหม่"><i class="fa-solid fa-arrow-up"></i></button>
                    <button id="sortDescBtn" class="sort-btn" onclick="setSortOrder('deadline','desc')" title="เรียงลำดับ Deadline ใหม่มาเก่า"><i class="fa-solid fa-arrow-down"></i></button>
                    <button id="sortIdAscBtn" class="sort-btn" onclick="setSortOrder('formid','asc')" title="เรียงเลขอ้างอิงจากน้อยไปมาก"><i class="fa-solid fa-arrow-up"></i></button>
                    <button id="sortIdDescBtn" class="sort-btn" onclick="setSortOrder('formid','desc')" title="เรียงเลขอ้างอิงจากมากไปน้อย"><i class="fa-solid fa-arrow-down"></i></button>
                </div>
            </div>
        </section>

        <section class="submissions-worklist">

<%
    String[] stepLabels = { "ผอ.ฝ่าย", "ความเห็นเทคนิค", "ผอ.ฝ่าย IT", "งานดำเนินการ" };
    java.text.SimpleDateFormat sdfStep = new java.text.SimpleDateFormat("dd/MM HH:mm");

    for (Map<String, Object> row : formList) {
        int formId    = (Integer) row.get("FORMID");
        String title  = (String)  row.get("TITLEFORM");
        String titleEsc = SecurityUtil.escapeHtml(title);
        int stateStep = (Integer) row.get("STATE_STEP");
        boolean isEdited = (Integer) row.get("IS_EDITED") == 1;

        java.sql.Date deadlineDate = (java.sql.Date) row.get("DEADLINE");
        java.time.LocalDate today = java.time.LocalDate.now();
        boolean isOverdue = (deadlineDate != null && deadlineDate.toLocalDate().isBefore(today));

        boolean[] done   = new boolean[4];
        boolean[] reject = new boolean[4];

        if (stateStep >= 0) {
            done[0] = stateStep >= 1;
            done[1] = stateStep >= 2;
            done[2] = stateStep >= 3;
            done[3] = stateStep >= 4;
        }

        if (stateStep == -1) {
            reject[0] = true; reject[1] = true; reject[2] = true; reject[3] = true;
        } else if (stateStep == -2) {
            done[0] = true;  reject[1] = true; reject[2] = true; reject[3] = true;
        } else if (stateStep == -3) {
            done[0] = true;  done[1] = true;  reject[2] = true; reject[3] = true;
        } else if (stateStep == -4) {
            done[0] = true;  done[1] = true;  done[2] = true;  reject[3] = true;
        }

        boolean canConfirm = (stateStep == 4);
        boolean isConfirmed = (stateStep >= 5);

        java.sql.Timestamp[] stepTs = {
            (java.sql.Timestamp) row.get("TS1"),
            (java.sql.Timestamp) row.get("TS2"),
            (java.sql.Timestamp) row.get("TS3"),
            (java.sql.Timestamp) row.get("TS4")
        };
        String[] stepTimes = new String[4];
        for (int ti = 0; ti < 4; ti++) {
            stepTimes[ti] = (stepTs[ti] != null) ? sdfStep.format(stepTs[ti]) : "";
        }

        String rowStatus;
        String rowStatusLabel;
        String badgeCssClass;
        if      (stateStep < 0) { rowStatus = "rejected"; rowStatusLabel = "ไม่ผ่านการอนุมัติ"; badgeCssClass = "status-badge danger"; }
        else if (isConfirmed)   { rowStatus = "approved"; rowStatusLabel = "ยืนยันผลรับเรียบร้อย"; badgeCssClass = "status-badge ok"; }
        else if (isOverdue)     { rowStatus = "overdue";  rowStatusLabel = "เกินกำหนดเวลา"; badgeCssClass = "status-badge wait"; }
        else                    { rowStatus = "pending";  rowStatusLabel = "กำลังรอดำเนินงาน"; badgeCssClass = "status-badge info"; }

        String rowDeadline = (deadlineDate != null) ? deadlineDate.toString() : "9999-12-31";
        String deadlineDisplay = "-";
        if (deadlineDate != null) {
            java.time.LocalDate dl = deadlineDate.toLocalDate();
            deadlineDisplay = String.format("%02d/%02d/%d", dl.getDayOfMonth(), dl.getMonthValue(), dl.getYear() + 543);
        }
%>

            <div class="requisition-row-card"
                 data-status="<%= rowStatus %>"
                 data-deadline="<%= rowDeadline %>"
                 data-formid="<%= formId %>"
                 data-title="<%= titleEsc %>">

                <div class="meta-identity-block">
                    <div class="id-title-lockup">
                        <span class="req-id-badge"><i class="fa-solid fa-hashtag"></i> <%= formId %></span>
                        <a href="detail.jsp?id=<%= formId %>&from=submit" class="req-title-link" title="<%= titleEsc %>">
                            <%= titleEsc %>
                        </a>
                    </div>
                    <div class="status-tags-group">
                        <span class="status-badge info" style="background:#f4f8fc; border:1px solid #c8dced; font-size:13px; font-weight:800; color:#003366;">
                            <i class="fa-regular fa-calendar-check"></i> กำหนดวัน: <%= deadlineDisplay %>
                        </span>
                        <span class="<%= badgeCssClass %>" style="font-size:13px;"><%= rowStatusLabel %></span>
                    </div>
                </div>

                <div class="timeline-container-cell">
                    <div class="timeline-progress-track">
                    <%
                    for (int i = 0; i < 4; i++) {
                        String stepClass = reject[i] ? "reject" : (done[i] ? "done" : (stateStep == i ? "pending" : "waiting"));
                        String iconCls   = reject[i] ? "fa-solid fa-xmark" : (done[i] ? "fa-solid fa-check" : "fa-solid fa-minus");
                    %>
                        <div class="timeline-milestone <%= stepClass %>">
                            <span class="milestone-node"><i class="<%= iconCls %>"></i></span>
                            <span class="milestone-caption"><%= stepLabels[i] %></span>
                            <% if (!stepTimes[i].isEmpty()) { %>
                            <span class="milestone-timestamp"><i class="fa-regular fa-clock" style="font-size:10px;"></i> <%= stepTimes[i] %></span>
                            <% } %>
                        </div>
                    <%
                    }
                    %>
                    </div>
                </div>

                <div class="action-controls-block">
                    <a href="detail.jsp?id=<%= formId %>" class="action-row-btn secondary-action-btn">
                        <i class="fa-solid fa-magnifying-glass-chart"></i> รายละเอียดคำขอ
                    </a>
                    
                    <% if (stateStep < 0) { 
                           if (!isEdited) { %>
                                <a href="${pageContext.request.contextPath}/editForm?formId=<%= formId %>" style="text-decoration:none; display:grid;">
                                    <button type="button" class="action-row-btn primary-action-btn"><i class="fa-solid fa-pen-to-square"></i> แก้ไขฟอร์มใหม่</button>
                                </a>
                           <% } else { %>
                                <button type="button" class="action-row-btn" disabled style="background:#e5e7eb; color:#9ca3af; border-color:#e5e7eb;"><i class="fa-solid fa-ban"></i> สิ้นสุดกระบวนการ</button>
                           <% } 
                       } else if (isConfirmed) { %>
                            <button type="button" class="action-row-btn" disabled style="background:#e6f4ea; color:#137a42; border-color:#e6f4ea;"><i class="fa-solid fa-circle-check"></i> ตรวจรับเสร็จสิ้น</button>
                       <% } else if (isOverdue) { %>
                            <button type="button" class="action-row-btn overdue-btn" data-formid="<%= formId %>" style="background:#fff9e6; border-color:#ffeeba; color:#b7791f;">
                                <i class="fa-solid fa-calendar-plus"></i> ขยายเวลาเพิ่ม
                            </button>
                       <% } else { %>
                            <button type="button" class="action-row-btn primary-action-btn confirm-btn"
                                    data-formid="<%= formId %>"
                                    data-expectedstep="<%= stateStep %>"
                                    <% if (!canConfirm) { %> disabled style="background:#edf2f7; color:#a0aec0; border-color:#edf2f7;" <% } %>>
                                <i class="fa-solid fa-signature"></i> <%= canConfirm ? "ยืนยันผลตรวจรับ" : "กำลังดำเนินงาน" %>
                            </button>
                       <% } %>
                </div>
            </div>

<%
    } // END LOOP FOR SUBMISSION ITEM CARD

    if (!hasData) {
%>
        <div class="empty-state-card">
            <i class="fa-solid fa-folder-open"></i>
            <h3 style="color:#003366; margin:0; font-size:24px;">ไม่พบประวัติใบคำร้องของคุณ</h3>
            <p style="color:#52677d; margin:0; font-size:16px;">ระบบไม่มีรายการบันทึกส่งฟอร์มในระบบย่อย ณ หมวดหมู่นี้ คุณสามารถสร้างคำขอใหม่ได้ผ่านปุ่มดำเนินการหลัก</p>
            <a href="${pageContext.request.contextPath}/it-requisition-form-detail.jsp" class="form-type-action" style="margin-top:6px;">
                <i class="fa-solid fa-plus"></i> เริ่มต้นสร้างแบบฟอร์มขอรับบริการใหม่
            </a>
        </div>
<%
    }
%>
        <div class="search-not-found-card" id="emptySearch" style="display:none;">
            <i class="fa-solid fa-filter-circle-xmark"></i>
            <h3 style="color:#003366; margin:0; font-size:22px;">ไม่พบข้อมูลรายการตรวจค้นหาที่ระบุ</h3>
            <p style="color:#52677d; margin:0; font-size:16px;">โปรดตรวจสอบคำสำคัญ หรือ ตัวเลขเลขอ้างอิงดัชนีฟอร์มคำขอใหม่อีกครั้ง</p>
        </div>
        </section>

        <div class="workspace-filter-toolbar" style="justify-content: center; padding: 12px 24px;">
            <div style="display:flex; align-items:center; gap:16px;">
                <% if (currentPage > 1) { %>
                    <a href="?page=<%= currentPage - 1 %>&show=<%= java.net.URLEncoder.encode(showParam, "UTF-8") %>&sort=<%= sortParam %>" style="text-decoration:none;">
                        <button type="button" class="action-row-btn secondary-action-btn"><i class="fa-solid fa-angle-left"></i> ก่อนหน้า</button>
                    </a>
                <% } %>
                
                <span style="font-weight:900; color:#003366; font-size:16px;">หน้าสรุปบัญชี <%= currentPage %></span>
                
                <% if (formList.size() == pageSize) { %>
                    <a href="?page=<%= currentPage + 1 %>&show=<%= java.net.URLEncoder.encode(showParam, "UTF-8") %>&sort=<%= sortParam %>" style="text-decoration:none;">
                        <button type="button" class="action-row-btn secondary-action-btn">ถัดไป <i class="fa-solid fa-angle-right"></i></button>
                    </a>
                <% } %>
            </div>
        </div>

    </div>

    <%@ include file="/WEB-INF/jspf/footer.jspf" %>
</div>

<div id="confirmPopup" class="modal-overlay" style="display:none;">
    <div class="modal-box">
        <span class="modal-close" onclick="closePopup()">&times;</span>
        <h2 style="color:#003366; font-size:24px; margin:0 0 10px;"><i class="fa-solid fa-file-signature" style="color:#3272BB; margin-right:6px;"></i> ยืนยันผลตรวจสอบระบบ</h2>
        <p style="color:#52677d; font-size:15px; text-align:left; margin-bottom:12px;">กรุณากรอกรายละเอียดบันทึกความเห็นผลตรวจรับ หรือหมายเหตุทางเทคนิคเพิ่มเติมเพื่อบันทึกประวัติลงฐานข้อมูล:</p>
        <textarea id="popupDetail" class="form-field textarea" style="width:100%; border-radius:8px; padding:12px; font-family:inherit; min-height:100px; margin-bottom:16px;" placeholder="กรอกข้อความความเห็นการส่งมอบงาน หรือรายละเอียดประกอบเพิ่ม..."></textarea>
        <div style="display:flex; justify-content:center; gap:10px;">
            <button id="popupConfirm" class="modal-ok-btn" style="margin:0;"><i class="fa-solid fa-check"></i> ยืนยันข้อมูล</button>
            <button onclick="closePopup()" class="form-type-action secondary" style="min-height:40px;"><i class="fa-solid fa-xmark"></i> ยกเลิกบันทึก</button>
        </div>
    </div>
</div>

<div id="deadlinePopup" class="modal-overlay" style="display:none;">
    <div class="modal-box">
        <span class="modal-close" onclick="closeDeadlinePopup()">&times;</span>
        <h2 style="color:#003366; font-size:24px; margin:0 0 10px;"><i class="fa-solid fa-calendar-plus" style="color:#3272BB; margin-right:6px;"></i> ขยายกรอบเวลา Deadline คำขอหลัก</h2>
        <p style="color:#52677d; font-size:15px; text-align:left; margin-bottom:12px;">กรุณาระบุและระบุเลือกวันที่สิ้นสุดกรอบระยะเวลากำหนดงานใหม่สำหรับฟอร์มข้อรับบริการชิ้นนี้:</p>
        <input type="date" id="popupNewDeadline" style="width:100%; border:1px solid #c7d7e6; border-radius:8px; min-height:44px; padding:10px; font-family:inherit; margin-bottom:18px;">
        <div style="display:flex; justify-content:center; gap:10px;">
            <button id="deadlineConfirm" class="modal-ok-btn" style="margin:0;"><i class="fa-solid fa-floppy-disk"></i> อัปเดตขยายเวลา</button>
            <button onclick="closeDeadlinePopup()" class="form-type-action secondary" style="min-height:40px;"><i class="fa-solid fa-xmark"></i> ปิดหน้าต่าง</button>
        </div>
    </div>
</div>

<script>
let currentButton = null;
let currentOverdueButton = null;
const contextPath = "<%= request.getContextPath() %>";
const csrfToken = "<%= SecurityUtil.escapeHtml(csrfToken) %>";

let sortOrder = (new URLSearchParams(window.location.search).get('sort') || 'asc');
let sortField = (new URLSearchParams(window.location.search).get('sortby') || 'deadline');

function applySort() {
    const list = document.querySelector('.submissions-worklist');
    const cards = Array.from(list.querySelectorAll('.requisition-row-card'));
    cards.sort(function(a, b) {
        if (sortField === 'formid') {
            const ia = parseInt(a.dataset.formid) || 0;
            const ib = parseInt(b.dataset.formid) || 0;
            return sortOrder === 'asc' ? ia - ib : ib - ia;
        } else {
            const da = a.dataset.deadline || '9999-12-31';
            const db = b.dataset.deadline || '9999-12-31';
            if (sortOrder === 'asc') return da < db ? -1 : da > db ? 1 : 0;
            return da > db ? -1 : da < db ? 1 : 0;
        }
    });
    cards.forEach(function(c) { list.insertBefore(c, document.getElementById('emptySearch')); });
}

function updateSortButtons() {
    document.getElementById('sortAscBtn').classList.toggle('active',    sortField === 'deadline' && sortOrder === 'asc');
    document.getElementById('sortDescBtn').classList.toggle('active',   sortField === 'deadline' && sortOrder === 'desc');
    document.getElementById('sortIdAscBtn').classList.toggle('active',  sortField === 'formid'   && sortOrder === 'asc');
    document.getElementById('sortIdDescBtn').classList.toggle('active', sortField === 'formid'   && sortOrder === 'desc');
}

function setSortOrder(field, order) {
    sortField = field;
    sortOrder = order;
    updateSortButtons();
    const sp = new URLSearchParams(window.location.search);
    sp.set('sort', order);
    sp.set('sortby', field);
    history.replaceState(null, '', '?' + sp.toString());
    applySort();
}

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
    const initParams = new URLSearchParams(window.location.search);
    const initShow   = (initParams.get('show') || 'pending,overdue,rejected,approved').split(',').map(function(s) { return s.trim(); });
    
    document.querySelectorAll('.kpi-card').forEach(function(card) {
        const f = card.dataset.filter;
        if (f === 'all') {
            if (initShow.length === 4) card.classList.add('active');
        } else if (initShow.length === 1 && initShow[0] === f) {
            card.classList.add('active');
        }
    });

    document.querySelectorAll('.kpi-card').forEach(function(card) {
        card.addEventListener('click', function() {
            const f = this.dataset.filter;
            const sp = new URLSearchParams(window.location.search);
            if (f === 'all') {
                sp.set('show', 'pending,overdue,rejected,approved');
            } else {
                sp.set('show', f);
            }
            sp.set('page', '1');
            window.location.href = '?' + sp.toString();
        });
    });

    const searchInput = document.getElementById('searchInput');
    const searchWrap  = document.getElementById('searchWrap');
    const searchClear = document.getElementById('searchClear');
    const emptySearch = document.getElementById('emptySearch');

    function runSearch() {
        const q = searchInput.value.trim().toLowerCase();
        searchWrap.classList.toggle('has-text', q.length > 0);
        let visible = 0;
        document.querySelectorAll('.requisition-row-card').forEach(function(c) {
            const t = (c.dataset.title || '').toLowerCase();
            const id = (c.dataset.formid || '').toString();
            const match = q === '' || t.includes(q) || id.includes(q);
            c.style.display = match ? 'grid' : 'none';
            if (match) visible++;
        });
        emptySearch.style.display = (q !== '' && visible === 0) ? 'block' : 'none';
    }

    searchInput.addEventListener('input', runSearch);
    searchClear.addEventListener('click', function() {
        searchInput.value = '';
        runSearch();
        searchInput.focus();
    });

    document.querySelectorAll(".confirm-btn").forEach(button => {
        if (button.closest("a")) return;
        button.addEventListener("click", function () {
            if (this.disabled) {
                alert("ยังไม่สามารถดำเนินการยืนยันคำสั่งได้ เนื่องจากขั้นตอนตามสิทธิ์ไม่สมบูรณ์");
                return;
            }
            currentButton = this;
            document.getElementById("confirmPopup").style.display = "flex";
        });
    });

    document.getElementById("popupConfirm").addEventListener("click", function () {
        let detail = document.getElementById("popupDetail").value.trim();
        if (detail === "") {
            alert("กรุณาระบุรายละเอียด / ข้อความก่อนดำเนินการกดส่งยืนยัน");
            return;
        }
        if (currentButton) {
            const form = document.createElement("form");
            form.method = "POST";
            form.action = contextPath + "/SubmitApprovalServlet";
            const fields = {
                formId: currentButton.dataset.formid,
                action: "approve",
                expectedStep: currentButton.dataset.expectedstep,
                redirectPage: "submit",
                comment: detail,
                csrfToken: csrfToken
            };
            Object.keys(fields).forEach(function (name) {
                const input = document.createElement("input");
                input.type = "hidden";
                input.name = name;
                input.value = fields[name];
                form.appendChild(input);
            });
            document.body.appendChild(form);
            form.submit();
        }
    });

    document.querySelectorAll(".overdue-btn").forEach(function (btn) {
        btn.addEventListener("click", function () {
            currentOverdueButton = this;
            const today = new Date().toISOString().split("T")[0];
            const input = document.getElementById("popupNewDeadline");
            input.min = today;
            input.value = "";
            document.getElementById("deadlinePopup").style.display = "flex";
        });
    });

    document.getElementById("deadlineConfirm").addEventListener("click", function () {
        const newDeadline = document.getElementById("popupNewDeadline").value;
        if (!newDeadline) {
            alert("กรุณาระบุเลือกกำหนดนัดสิ้นสุดวันที่ข้อตกลงชิ้นใหม่");
            return;
        }
        if (currentOverdueButton) {
            const form = document.createElement("form");
            form.method = "POST";
            form.action = contextPath + "/ExtendDeadlineServlet";
            const fields = {
                formId: currentOverdueButton.dataset.formid,
                newDeadline: newDeadline,
                csrfToken: csrfToken
            };
            Object.keys(fields).forEach(function (name) {
                const input = document.createElement("input");
                input.type = "hidden";
                input.name = name;
                input.value = fields[name];
                form.appendChild(input);
            });
            document.body.appendChild(form);
            form.submit();
        }
    });

    document.querySelectorAll('.interactive-checkbox-group input').forEach(function(cb) {
        cb.checked = initShow.includes(cb.value);
    });
    updateSortButtons();
    applySort();

    document.querySelectorAll('.interactive-checkbox-group input').forEach(function(cb) {
        cb.addEventListener('change', function() {
            const checked = Array.from(document.querySelectorAll('.interactive-checkbox-group input:checked'))
                .map(function(c) { return c.value; });
            const sp = new URLSearchParams(window.location.search);
            sp.set('show', checked.length > 0 ? checked.join(',') : 'none');
            sp.set('page', '1');
            window.location.href = '?' + sp.toString();
        });
    });
});

function closePopup() {
    document.getElementById("confirmPopup").style.display = "none";
    document.getElementById("popupDetail").value = "";
}

function closeDeadlinePopup() {
    document.getElementById("deadlinePopup").style.display = "none";
    document.getElementById("popupNewDeadline").value = "";
}
</script>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>