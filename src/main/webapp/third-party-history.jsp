<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.URLEncoder,java.text.SimpleDateFormat,java.sql.Timestamp,java.util.ArrayList,java.util.Collections,java.util.LinkedHashMap,java.util.List,java.util.Map" %>
<%@ page import="com.slf.model.ThirdPartyRequest" %>
<%@ page import="com.slf.model.ThirdPartyWorkflowActionEntry" %>
<%@ page import="com.slf.util.NavigationUtil" %>
<%@ page import="com.slf.util.ThirdPartyAccessPolicy" %>
<%!
    private String h(Object value) {
        if (value == null) return "";
        return String.valueOf(value).replace("&", "&amp;").replace("<", "&lt;")
            .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
    private String display(Object value) {
        return value == null || String.valueOf(value).trim().isEmpty() ? "-" : h(value);
    }
    private int currentStepIndex(String status) {
        if ("LINK_CREATED".equals(status)) return 0;
        if ("PENDING_SECTION_HEAD".equals(status)) return 1;
        if ("PENDING_IT_DIRECTOR".equals(status)) return 2;
        if ("PENDING_OPERATOR".equals(status)) return 3;
        if ("PENDING_EXTERNAL_ACCEPTANCE".equals(status)) return 4;
        if ("PENDING_REVOKER".equals(status)) return 5;
        if ("PENDING_REVOKE_REVIEWER".equals(status)) return 6;
        if ("PENDING_SECTION_HEAD_REPORT".equals(status)) return 7;
        if ("PENDING_FINAL_CERTIFICATION".equals(status)) return 8;
        if ("COMPLETED".equals(status)) return 9;
        if ("REJECTED".equals(status)) return 2;
        return 0;
    }
    private String serviceStatusText(String status) {
        if ("REJECTED".equals(status)) return "ไม่อนุมัติ";
        if ("COMPLETED".equals(status)) return "เสร็จสิ้น";
        if ("PENDING_EXTERNAL_ACCEPTANCE".equals(status) || "PENDING_REVOKER".equals(status)) return "กำลังใช้งาน";
        if ("PENDING_REVOKE_REVIEWER".equals(status)) return "กำลังระงับสิทธิ์";
        if ("PENDING_SECTION_HEAD_REPORT".equals(status) || "PENDING_FINAL_CERTIFICATION".equals(status)) return "กำลังรับรอง";
        return "กำลังดำเนินการ";
    }
    private String serviceStatusClass(String status) {
        if ("REJECTED".equals(status) || "PENDING_REVOKE_REVIEWER".equals(status)) return "danger";
        if ("COMPLETED".equals(status) || "PENDING_EXTERNAL_ACCEPTANCE".equals(status) || "PENDING_REVOKER".equals(status)) return "active";
        if ("PENDING_SECTION_HEAD_REPORT".equals(status) || "PENDING_FINAL_CERTIFICATION".equals(status)) return "certify";
        return "progress";
    }
    private ThirdPartyWorkflowActionEntry findTimelineAction(
            List<ThirdPartyWorkflowActionEntry> actions, String[] actionTypes) {
        if (actions == null) return null;
        for (ThirdPartyWorkflowActionEntry action : actions) {
            for (String actionType : actionTypes) {
                if (actionType.equals(action.getActionType())) return action;
            }
        }
        return null;
    }
    private boolean rejectedTimelineAction(ThirdPartyWorkflowActionEntry action) {
        return action != null && action.getActionType() != null
            && action.getActionType().endsWith("_REJECTED");
    }
    private List<ThirdPartyWorkflowActionEntry> relatedPeople(List<ThirdPartyWorkflowActionEntry> actions) {
        LinkedHashMap<String, ThirdPartyWorkflowActionEntry> people =
            new LinkedHashMap<String, ThirdPartyWorkflowActionEntry>();
        if (actions == null) return new ArrayList<ThirdPartyWorkflowActionEntry>();
        for (int i = actions.size() - 1; i >= 0; i--) {
            ThirdPartyWorkflowActionEntry action = actions.get(i);
            String name = action.getActorEmpName();
            if (name != null && !name.trim().isEmpty() && !people.containsKey(name.trim())) {
                people.put(name.trim(), action);
            }
        }
        return new ArrayList<ThirdPartyWorkflowActionEntry>(people.values());
    }
    private String historyUrl(String contextPath, String filter, String search, int page) {
        try {
            return contextPath + "/thirdParty/history?filter=" + URLEncoder.encode(filter, "UTF-8")
                + "&q=" + URLEncoder.encode(search, "UTF-8") + "&page=" + page;
        } catch (Exception e) {
            return contextPath + "/thirdParty/history";
        }
    }
%>
<%
    String position = (String) session.getAttribute("position");
    if (!ThirdPartyAccessPolicy.canViewHistory(position, ThirdPartyAccessPolicy.sessionEmpId(session))) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }
    List<ThirdPartyRequest> items = (List<ThirdPartyRequest>) request.getAttribute("thirdPartyRequests");
    if (items == null) items = Collections.emptyList();
    Map<Long, List<ThirdPartyWorkflowActionEntry>> actionHistory =
        (Map<Long, List<ThirdPartyWorkflowActionEntry>>) request.getAttribute("thirdPartyHistoryActions");
    if (actionHistory == null) actionHistory = Collections.emptyMap();
    boolean adminView = Boolean.TRUE.equals(request.getAttribute("thirdPartyHistoryAdminView"));
    String historyFilter = (String) request.getAttribute("thirdPartyHistoryFilter");
    if (historyFilter == null) historyFilter = "all";
    String historySearch = (String) request.getAttribute("thirdPartyHistorySearch");
    if (historySearch == null) historySearch = "";
    int historyPage = request.getAttribute("thirdPartyHistoryPage") == null
        ? 1 : ((Integer) request.getAttribute("thirdPartyHistoryPage")).intValue();
    boolean historyHasNextPage = Boolean.TRUE.equals(request.getAttribute("thirdPartyHistoryHasNextPage"));
    NavigationUtil.BackLink thirdPartyHistoryBack = NavigationUtil.thirdPartyHistoryBack(request.getContextPath(), adminView);
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
    SimpleDateFormat stepTime = new SimpleDateFormat("dd/MM HH:mm");
    String[] timelineLabels = {
        "ส่งฟอร์ม", "หัวหน้ากลุ่มงาน", "ผอ.IT", "ดำเนินการ", "ตรวจรับ",
        "ยกเลิกสิทธิ์", "ตรวจทาน", "สรุปรายงาน", "รับรอง"
    };
    String[] nextStepTexts = {
        "รอผู้ขอกรอกฟอร์ม", "รอหัวหน้าส่วนพิจารณา", "อยู่ระหว่างการอนุมัติ",
        "อยู่ระหว่างการดำเนินการ", "อยู่ระหว่างตรวจรับ", "อยู่ระหว่างยกเลิกสิทธิ์",
        "อยู่ระหว่างตรวจทาน", "อยู่ระหว่างสรุปรายงาน", "อยู่ระหว่างรับรอง", "รับรองเรียบร้อยแล้ว"
    };
    String[][] timelineActionTypes = {
        {"EXTERNAL_SUBMITTED"}, {"SECTION_HEAD_SUBMITTED"},
        {"IT_DIRECTOR_APPROVED", "IT_DIRECTOR_REJECTED"}, {"OPERATOR_COMPLETED"},
        {"EXTERNAL_ACCEPTED", "EXTERNAL_REJECTED", "EXTERNAL_ACCEPTANCE_EXPIRED"},
        {"REVOKER_COMPLETED"}, {"REVOKE_REVIEWER_APPROVED"}, {"SECTION_HEAD_REPORTED"}, {"FINAL_CERTIFIED"}
    };
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ประวัติ Third-party Form</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        .third-party-history-page{padding-left:clamp(12px,2vw,30px);padding-right:clamp(12px,2vw,30px)}
        .third-party-history-page .third-party-page-head,.history-filter-panel,.history-table-panel{width:100%;max-width:none;box-sizing:border-box}
        .history-filter-panel{margin:0 auto 18px;padding:13px 16px;border:1px solid #dbe5ef;border-radius:14px;background:#fff;box-shadow:0 8px 24px rgba(24,55,85,.05);font-size:13px}
        .history-filter-bar{display:flex;gap:10px;align-items:center;flex-wrap:wrap}
        .history-filter{border:1px solid #d6e1ec;border-radius:999px;background:#fff;padding:7px 13px;color:#52606d;text-decoration:none;white-space:nowrap;font-size:13px}
        .history-filter.selected{border-color:#3272bb;background:#eaf4ff;color:#003f73;font-weight:800}
        .history-search-form{display:flex;gap:8px;flex:1;min-width:300px}
        .history-search{width:100%;min-width:0;border:1px solid #d6e1ec;border-radius:999px;padding:8px 13px;font:inherit;font-size:13px}
        .history-search-form .btn{padding:7px 12px;font-size:12px}
        .history-result-count{margin-left:auto;color:#64748b;font-size:11px;font-weight:700;white-space:nowrap}
        .history-table-panel{padding:0;overflow:hidden}
        .history-table-scroll{overflow:visible;border-radius:14px}
        .history-table{width:100%;table-layout:fixed;border-collapse:separate;border-spacing:0;color:#24364b}
        .history-table th{padding:13px 9px;background:#f7f9fc;border-bottom:1px solid #dbe5ef;color:#66768a;font-size:11px;font-weight:900;text-align:left;white-space:nowrap}
        .history-table th:nth-child(1){width:13%}
        .history-table th:nth-child(2){width:13%}
        .history-table th:nth-child(3){width:18%}
        .history-table th:nth-child(4),.history-table th:nth-child(5){width:9%}
        .history-table th:nth-child(6){width:27%}
        .history-table th:nth-child(7){width:11%}
        .history-table th:first-child{border-radius:14px 0 0 0}
        .history-table th:last-child{border-radius:0 14px 0 0;text-align:center}
        .history-table td{padding:14px 9px;border-bottom:1px solid #e4ebf2;background:#fff;vertical-align:middle;min-width:0}
        .history-table tbody tr:last-child td{border-bottom:0}
        .history-table tbody tr:hover td{background:#fbfdff}
        .history-requester strong{display:block;color:#102f50;font-size:14px}
        .history-requester span{display:block;margin-top:3px;color:#8492a5;font-size:11px}
        .history-status{display:inline-flex;align-items:center;gap:6px;padding:5px 10px;border-radius:999px;font-size:12px;font-weight:900;white-space:nowrap}
        .history-status::before{content:"";width:7px;height:7px;border-radius:50%;background:currentColor}
        .history-status.progress{background:#fff5cc;color:#9a6b00}
        .history-status.active{background:#dcf7e8;color:#197344}
        .history-status.danger{background:#ffe3e3;color:#b4232d}
        .history-status.certify{background:#e3edff;color:#285db5}
        .history-step-wrap{position:relative;display:inline-block}
        .history-people-cell{min-width:0;overflow:hidden}
        .history-people-wrap{position:relative;display:block;width:100%;max-width:100%;min-width:0;overflow:hidden}
        .history-step-pill{display:block;width:100%;padding:7px 6px;border-radius:8px;font-size:11px;font-weight:900;text-align:center;white-space:normal;line-height:1.25}
        .history-step-pill.step-0,.history-step-pill.step-1,.history-step-pill.step-2{background:#fff4c7;color:#8f6500}
        .history-step-pill.step-3{background:#ffe8cf;color:#a95200}
        .history-step-pill.step-4,.history-step-pill.step-6{background:#dceeff;color:#1e6095}
        .history-step-pill.step-5{background:#ffe0cc;color:#b74600}
        .history-step-pill.step-7{background:#eee3ff;color:#6840a6}
        .history-step-pill.step-8{background:#e6e5ff;color:#4b49a6}
        .history-step-pill.step-9{background:#dcf7e8;color:#197344}
        .history-tooltip{position:fixed;z-index:1000;left:50%;top:50%;width:620px;max-width:calc(100vw - 30px);padding:14px;border:1px solid #d6e1ec;border-radius:12px;background:#fff;box-shadow:0 14px 35px rgba(15,44,73,.18);opacity:0;visibility:hidden;transform:translate(-50%,6px);transition:opacity .16s ease,visibility .16s ease;pointer-events:none}
        .history-step-wrap:hover .history-tooltip,.history-step-wrap:focus-within .history-tooltip,.history-people-wrap:hover .history-people-tooltip,.history-people-wrap:focus-within .history-people-tooltip{opacity:1;visibility:visible;transform:translate(-50%,0)}
        .history-mini-timeline{display:grid;grid-template-columns:repeat(9,minmax(0,1fr));gap:3px}
        .history-mini-step{text-align:center;color:#8796a5;font-size:10px;font-weight:800}
        .history-mini-node{display:grid;place-items:center;width:23px;height:23px;margin:0 auto 5px;border-radius:50%;background:#edf2f7;color:#718096}
        .history-mini-step.done .history-mini-node{background:#24a653;color:#fff}
        .history-mini-step.current .history-mini-node{background:#e8f2fb;color:#3272bb;box-shadow:0 0 0 2px #3272bb}
        .history-mini-step.current{color:#153e69}
        .history-mini-step.rejected .history-mini-node{background:#dc3545;color:#fff}
        .history-mini-step.rejected{color:#a51f2d}
        .history-mini-label{display:block;line-height:1.15}
        .history-mini-time{display:block;margin-top:3px;color:#9aa8b6;font-size:9px}
        .history-people{display:flex;align-items:center;gap:4px;width:100%;max-width:100%;min-width:0;overflow:hidden}
        .history-person{min-width:0;flex:0 0 auto;max-width:190px;padding:5px 6px;border:1px solid #d8e2ec;border-radius:7px;background:#fff;line-height:1.1}
        .history-person strong,.history-person span{display:block}
        .history-person strong{overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
        .history-person span{overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
        .history-person strong{font-size:11px;color:#24364b}
        .history-person span{margin-top:3px;font-size:9px;color:#8796a5}
        .history-person-more{display:none;place-items:center;flex:0 0 29px;width:29px;height:29px;border-radius:50%;background:#edf3f9;color:#526b84;font-size:10px;font-weight:900}
        .history-people-tooltip{position:fixed;z-index:1001;left:50%;top:50%;width:260px;max-width:calc(100vw - 30px);padding:8px;border:1px solid #d6e1ec;border-radius:10px;background:#fff;box-shadow:0 14px 35px rgba(15,44,73,.18);opacity:0;visibility:hidden;transform:translate(-50%,6px);transition:opacity .16s ease,visibility .16s ease;pointer-events:none}
        .history-people-tooltip .history-person{max-width:none;margin:5px}
        .history-date{font-size:12px;font-weight:800;white-space:nowrap}
        .history-detail-cell{text-align:center;white-space:nowrap;overflow:hidden}
        .history-action-stack{display:inline-flex;flex-direction:column;align-items:stretch;gap:6px;max-width:100%}
        .history-detail-button{display:inline-flex;max-width:100%;padding:5px 7px;font-size:12px;line-height:1;gap:4px;box-sizing:border-box;overflow:hidden}
        .history-pdf-button{background:#003f73;color:#fff}
        .history-detail-button i{font-size:11px}
        .history-detail-button-text{white-space:nowrap}
        .history-pagination{display:flex;align-items:center;justify-content:center;gap:12px;margin-top:20px}
        .history-pagination-label{font-weight:800;color:#52606d}
        @media(max-width:820px){
            .history-search-form{order:3;min-width:100%;width:100%}
            .history-result-count{margin-left:0}
            .history-table{min-width:760px}
            .history-table-scroll{overflow-x:auto}
        }
        @media(max-width:1180px){
            .history-detail-button{width:30px;height:30px;padding:0;justify-content:center;border-radius:8px}
            .history-detail-button i{font-size:12px}
            .history-detail-button-text{display:none}
            .history-action-stack{align-items:center}
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
<div id="main">
    <%@ include file="/WEB-INF/jspf/topbar.jspf" %>
    <main class="third-party-request-page third-party-history-page">
        <section class="third-party-page-head third-party-toolbar-head">
            <div>
                <p class="eyebrow">Third-party Forms</p>
                <h1>ประวัติคำขอผู้ให้บริการภายนอก</h1>
                <p><%= adminView ? "แสดงคำขอทั้งหมดสำหรับผู้ดูแลระบบ" : "แสดงคำขอทั้งหมดที่ดูแลโดย Employee #678" %></p>
            </div>
            <a class="btn btn-secondary detail-back-button" href="<%= h(thirdPartyHistoryBack.getHref()) %>">
                <i class="fa-solid fa-arrow-left"></i> <%= h(thirdPartyHistoryBack.getLabel()) %>
            </a>
        </section>

        <section class="history-filter-panel" aria-label="ตัวกรองประวัติคำขอ">
            <div class="history-filter-bar">
                <a class="history-filter <%= "all".equals(historyFilter) ? "selected" : "" %>" href="<%= historyUrl(request.getContextPath(), "all", historySearch, 1) %>">ทั้งหมด</a>
                <a class="history-filter <%= "waiting".equals(historyFilter) ? "selected" : "" %>" href="<%= historyUrl(request.getContextPath(), "waiting", historySearch, 1) %>">กำลังดำเนินการ</a>
                <a class="history-filter <%= "completed".equals(historyFilter) ? "selected" : "" %>" href="<%= historyUrl(request.getContextPath(), "completed", historySearch, 1) %>">เสร็จสิ้น</a>
                <a class="history-filter <%= "rejected".equals(historyFilter) ? "selected" : "" %>" href="<%= historyUrl(request.getContextPath(), "rejected", historySearch, 1) %>">ไม่อนุมัติ</a>
                <form class="history-search-form" method="get" action="${pageContext.request.contextPath}/thirdParty/history">
                    <input type="hidden" name="filter" value="<%= h(historyFilter) %>">
                    <input class="history-search" name="q" type="search" value="<%= h(historySearch) %>" placeholder="ค้นหา Request ID / ผู้ขอ / บริษัท / ระบบ">
                    <button class="btn btn-secondary" type="submit"><i class="fa-solid fa-magnifying-glass"></i> ค้นหา</button>
                </form>
                <span class="history-result-count"><%= items.size() %> รายการในหน้านี้</span>
            </div>
        </section>

        <section class="third-party-panel history-table-panel">
            <% if (items.isEmpty()) { %>
                <div class="empty-link-state">
                    <i class="fa-solid fa-clock-rotate-left"></i>
                    <h2>ยังไม่มีประวัติ Third-party Form</h2>
                </div>
            <% } else { %>
            <div class="history-table-scroll">
                <table class="history-table">
                    <thead><tr>
                        <th>สถานะ</th><th>ผู้ขอใช้บริการ</th><th>ขั้นตอน</th><th>วันที่เริ่มต้น</th>
                        <th>วันที่สิ้นสุด</th><th>ผู้เกี่ยวข้อง</th><th></th>
                    </tr></thead>
                    <tbody>
                    <% for (ThirdPartyRequest item : items) {
                        List<ThirdPartyWorkflowActionEntry> itemActions = actionHistory.get(Long.valueOf(item.getRequestId()));
                        if (itemActions == null) itemActions = Collections.emptyList();
                        List<ThirdPartyWorkflowActionEntry> people = relatedPeople(itemActions);
                        int activeStep = currentStepIndex(item.getStatus());
                        int rejectionIndex = -1;
                        for (int ri = 0; ri < timelineActionTypes.length; ri++) {
                            if (rejectedTimelineAction(findTimelineAction(itemActions, timelineActionTypes[ri]))) {
                                rejectionIndex = ri;
                                break;
                            }
                        }
                        if (rejectionIndex < 0 && "REJECTED".equals(item.getStatus())) rejectionIndex = activeStep;
                    %>
                    <tr>
                        <td><span class="history-status <%= serviceStatusClass(item.getStatus()) %>"><%= serviceStatusText(item.getStatus()) %></span></td>
                        <td class="history-requester">
                            <strong><%= display(item.getExternalContactName()) %></strong>
                            <span>คำขอ #<%= item.getRequestId() %><%= adminView ? " · Owner #" + item.getInternalOwnerEmpId() : "" %></span>
                        </td>
                        <td class="history-people-cell">
                            <div class="history-step-wrap" tabindex="0">
                                <span class="history-step-pill step-<%= activeStep %>"><%= "REJECTED".equals(item.getStatus()) ? "ไม่อนุมัติ" : nextStepTexts[activeStep] %></span>
                                <div class="history-tooltip" role="tooltip">
                                    <div class="history-mini-timeline">
                                    <% for (int stepIndex = 0; stepIndex < timelineLabels.length; stepIndex++) {
                                        ThirdPartyWorkflowActionEntry stepAction = findTimelineAction(itemActions, timelineActionTypes[stepIndex]);
                                        boolean rejectedStep = rejectionIndex >= 0 && stepIndex == rejectionIndex;
                                        boolean done = !rejectedStep && (stepAction != null || stepIndex < activeStep || "COMPLETED".equals(item.getStatus()));
                                        boolean current = !rejectedStep && stepIndex == activeStep && !"COMPLETED".equals(item.getStatus()) && !"REJECTED".equals(item.getStatus());
                                        Timestamp actedAt = stepAction == null ? null : stepAction.getActedAt();
                                        if (stepIndex == 0 && actedAt == null) actedAt = item.getSubmittedAt();
                                    %>
                                        <div class="history-mini-step <%= rejectedStep ? "rejected" : done ? "done" : current ? "current" : "" %>">
                                            <span class="history-mini-node"><i class="fa-solid <%= rejectedStep ? "fa-xmark" : done ? "fa-check" : current ? "fa-hourglass-half" : "fa-minus" %>"></i></span>
                                            <span class="history-mini-label"><%= timelineLabels[stepIndex] %></span>
                                            <span class="history-mini-time"><%= actedAt == null ? (current ? "กำลังดำเนินการ" : "-") : stepTime.format(actedAt) %></span>
                                        </div>
                                    <% } %>
                                    </div>
                                </div>
                            </div>
                        </td>
                        <td class="history-date"><%= item.getAccessStartDate() == null ? "-" : dateFormat.format(item.getAccessStartDate()) %></td>
                        <td class="history-date"><%= item.getAccessEndDate() == null ? "-" : dateFormat.format(item.getAccessEndDate()) %></td>
                        <td>
                            <% if (people.isEmpty()) { %><span class="history-date">-</span><% } else { %>
                            <div class="history-people-wrap" tabindex="0">
                                <div class="history-people">
                                    <% for (int pi = 0; pi < people.size(); pi++) {
                                        ThirdPartyWorkflowActionEntry person = people.get(pi); %>
                                    <span class="history-person history-person-item"><strong><%= display(person.getActorEmpName()) %></strong><span><%= display(person.getActorPosition()) %></span></span>
                                    <% } %>
                                    <span class="history-person-more" aria-label="ผู้เกี่ยวข้องเพิ่มเติม"></span>
                                </div>
                                <% if (people.size() > 1) { %>
                                <div class="history-people-tooltip" role="tooltip">
                                    <% for (ThirdPartyWorkflowActionEntry person : people) { %>
                                    <div class="history-person"><strong><%= display(person.getActorEmpName()) %></strong><span><%= display(person.getActorPosition()) %></span></div>
                                    <% } %>
                                </div>
                                <% } %>
                            </div>
                            <% } %>
                        </td>
                        <td class="history-detail-cell">
                            <% if (item.getSubmissionId() != null) { %>
                            <div class="history-action-stack">
                            <a class="btn btn-secondary history-detail-button" href="${pageContext.request.contextPath}/thirdPartySubmission?id=<%= item.getSubmissionId() %>">
                                <i class="fa-solid fa-file-lines"></i><span class="history-detail-button-text">รายละเอียด</span>
                            </a>
                                <% if ("COMPLETED".equals(item.getStatus())) { %>
                                <a class="btn history-detail-button history-pdf-button" target="_blank" rel="noopener"
                                   href="${pageContext.request.contextPath}/thirdParty/exportPdf?submissionId=<%= item.getSubmissionId() %>">
                                    <i class="fa-solid fa-file-pdf"></i><span class="history-detail-button-text">PDF</span>
                                </a>
                                <% } %>
                            </div>
                            <% } else { %>-<% } %>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </section>

        <% if (historyPage > 1 || historyHasNextPage) { %>
        <nav class="history-pagination" aria-label="หน้าประวัติคำขอ">
            <% if (historyPage > 1) { %><a class="btn btn-secondary" href="<%= historyUrl(request.getContextPath(), historyFilter, historySearch, historyPage - 1) %>"><i class="fa-solid fa-arrow-left"></i> ก่อนหน้า</a><% } %>
            <span class="history-pagination-label">หน้า <%= historyPage %></span>
            <% if (historyHasNextPage) { %><a class="btn btn-secondary" href="<%= historyUrl(request.getContextPath(), historyFilter, historySearch, historyPage + 1) %>">ถัดไป <i class="fa-solid fa-arrow-right"></i></a><% } %>
        </nav>
        <% } %>
    </main>
    <%@ include file="/WEB-INF/jspf/footer.jspf" %>
</div>
<script>
function toggleNav(){
    var s=document.getElementById("mySidebar"),m=document.getElementById("main"),o=s.style.width==="250px";
    s.style.width=o?"0":"250px";m.style.marginLeft=o?"0":"250px";m.style.width=o?"100%":"calc(100% - 250px)";
}
document.querySelectorAll(".history-step-wrap,.history-people-wrap").forEach(function(trigger){
    function positionTooltip(){
        var tip=trigger.querySelector('[role="tooltip"]'),rect=trigger.getBoundingClientRect();
        if(!tip)return;
        var half=Math.min(tip.offsetWidth/2,(window.innerWidth-30)/2);
        var center=Math.max(half+15,Math.min(window.innerWidth-half-15,rect.left+rect.width/2));
        var below=rect.bottom+9,above=rect.top-tip.offsetHeight-9;
        tip.style.left=center+"px";
        tip.style.top=(below+tip.offsetHeight<window.innerHeight||above<15?below:above)+"px";
    }
    trigger.addEventListener("mouseenter",positionTooltip);
    trigger.addEventListener("focusin",positionTooltip);
});
function fitRelatedPeople(){
    document.querySelectorAll(".history-people").forEach(function(row){
        var people=Array.from(row.querySelectorAll(".history-person-item")),more=row.querySelector(".history-person-more");
        if(!more)return;
        people.forEach(function(person){person.style.display="";person.style.maxWidth="";});
        more.style.display="none";
        more.textContent="";
        var cell=row.closest(".history-people-cell");
        var gap=parseFloat(getComputedStyle(row).gap)||0,total=0,visible=0;
        var available=Math.min(row.clientWidth,cell?cell.clientWidth:row.clientWidth);
        for(var index=0;index<people.length;index++){
            var person=people[index];
            var width=person.getBoundingClientRect().width;
            if(total+(index?gap:0)+width<=available){
                total+=(index?gap:0)+width;
                visible++;
            }else break;
        }
        if(visible===people.length)return;
        var counterWidth=29+gap;
        total=0;
        visible=0;
        for(var index=0;index<people.length;index++){
            var person=people[index];
            var width=person.getBoundingClientRect().width;
            if(total+(index?gap:0)+width+counterWidth<=available){
                total+=(index?gap:0)+width;
                visible++;
            }else break;
        }
        if(visible===0&&people.length){
            visible=1;
            people[0].style.maxWidth=Math.max(50,available-counterWidth)+"px";
        }
        people.forEach(function(person,index){person.style.display=index<visible?"":"none";});
        more.textContent="+"+(people.length-visible);
        more.style.display="grid";
    });
}
fitRelatedPeople();
window.addEventListener("resize",fitRelatedPeople);
</script>
</body>
</html>
