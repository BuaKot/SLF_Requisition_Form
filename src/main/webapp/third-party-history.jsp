<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.URLEncoder,java.text.SimpleDateFormat,java.sql.Timestamp,java.util.Collections,java.util.List,java.util.Map" %>
<%@ page import="com.slf.model.ThirdPartyRequest" %>
<%@ page import="com.slf.model.ThirdPartyWorkflowActionEntry" %>
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
    private String statusText(String status) {
        if ("LINK_CREATED".equals(status)) return "รอผู้ขอภายนอกกรอกฟอร์ม";
        if ("PENDING_SECTION_HEAD".equals(status)) return "รอหัวหน้าส่วนพิจารณา";
        if ("PENDING_IT_DIRECTOR".equals(status)) return "รอ IT Director อนุมัติ";
        if ("PENDING_OPERATOR".equals(status)) return "รอผู้ดำเนินการ";
        if ("PENDING_EXTERNAL_ACCEPTANCE".equals(status)) return "รอผู้ขอภายนอกตรวจรับ";
        if ("PENDING_REVOKER".equals(status)) return "รอผู้ยกเลิกสิทธิ์";
        if ("PENDING_REVOKE_REVIEWER".equals(status)) return "รอผู้ตรวจทาน";
        if ("PENDING_SECTION_HEAD_REPORT".equals(status)) return "รอหัวหน้าส่วนสรุปรายงาน";
        if ("PENDING_FINAL_CERTIFICATION".equals(status)) return "รอ IT Director รับรอง";
        if ("COMPLETED".equals(status)) return "เสร็จสิ้น";
        if ("REJECTED".equals(status)) return "ไม่อนุมัติ";
        return status == null ? "-" : status;
    }
    private String category(String status) {
        if ("COMPLETED".equals(status)) return "completed";
        if ("REJECTED".equals(status)) return "rejected";
        return "waiting";
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
    private boolean warningTimelineAction(ThirdPartyWorkflowActionEntry action) {
        return action != null && "EXTERNAL_ACCEPTANCE_EXPIRED".equals(action.getActionType());
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
    boolean historyHasNextPage =
        Boolean.TRUE.equals(request.getAttribute("thirdPartyHistoryHasNextPage"));
    SimpleDateFormat stepTime = new SimpleDateFormat("dd/MM HH:mm");
    String[] timelineLabels = {
        "ส่งฟอร์ม", "หัวหน้ากลุ่มงาน", "ผอ.IT", "ดำเนินการ", "ตรวจรับ",
        "ยกเลิกสิทธิ์", "ตรวจทาน", "สรุปรายงาน", "รับรอง"
    };
    String[][] timelineActionTypes = {
        {"EXTERNAL_SUBMITTED"},
        {"SECTION_HEAD_SUBMITTED"},
        {"IT_DIRECTOR_APPROVED", "IT_DIRECTOR_REJECTED"},
        {"OPERATOR_COMPLETED"},
        {"EXTERNAL_ACCEPTED", "EXTERNAL_REJECTED", "EXTERNAL_ACCEPTANCE_EXPIRED"},
        {"REVOKER_COMPLETED"},
        {"REVOKE_REVIEWER_APPROVED"},
        {"SECTION_HEAD_REPORTED"},
        {"FINAL_CERTIFIED"}
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
        .history-filter-bar{display:flex;gap:10px;align-items:center;flex-wrap:wrap;margin-bottom:18px}
        .history-filter{border:2px solid #d8e2eb;border-radius:999px;background:#fff;padding:8px 14px;cursor:pointer;font:inherit;color:#52606d;text-decoration:none}
        .history-filter.selected{border-color:#3272bb;background:#eaf4ff;color:#003f73;font-weight:700}
        .history-search{flex:1;min-width:220px;border:2px solid #d8e2eb;border-radius:999px;padding:9px 15px;font:inherit}
        .history-result-count{margin-left:auto;color:#52606d}
        .history-search-form{display:flex;gap:8px;flex:1;min-width:280px}
        .history-search-form .history-search{min-width:0}
        .history-pagination{display:flex;align-items:center;justify-content:center;gap:12px;margin-top:20px}
        .history-pagination-label{font-weight:800;color:#52606d}
        .third-party-history-card{display:block}
        .history-owner{font-size:13px;color:#65758b;margin-top:5px}
        .history-card-top-actions{align-items:center;justify-content:flex-end;margin-top:0}

        /* Timeline state UI: matched with IT requisition state style in the reference image */
        .history-workflow{margin-top:18px;padding:16px 0 6px;border-top:1px solid #dce8f3;overflow:hidden}
        .history-workflow-track{display:grid;grid-template-columns:repeat(9,minmax(0,1fr));width:100%;padding:0 4px}        .history-workflow-step{position:relative;min-width:0;text-align:center;color:#4a5568}
        .history-workflow-step:not(:first-child)::before{content:"";position:absolute;top:14px;right:50%;width:100%;height:4px;background:#e2e8f0;z-index:1}
        .history-workflow-node{position:relative;z-index:2;width:30px;height:30px;margin:0 auto 7px;border:0;border-radius:999px;display:grid;place-items:center;background:#edf2f7;color:#718096;font-size:12px;box-shadow:0 0 0 2px #fff}
        .history-workflow-label{display:block;padding:0 3px;font-size:13px;font-weight:900;line-height:1.2;overflow-wrap:anywhere;color:#4a5568}
        .history-workflow-time{display:block;margin-top:3px;padding:0 2px;font-size:11px;line-height:1.2;overflow-wrap:anywhere;color:#8796a5;font-weight:800}

        .history-workflow-step.completed::before{background:#28a745}
        .history-workflow-step.completed .history-workflow-node{background:#28a745;color:#fff}
        .history-workflow-step.completed .history-workflow-label{color:#4a5568}

        .history-workflow-step.current::before{background:#28a745}
        .history-workflow-step.current .history-workflow-node{background:#e8f2fb;color:#3272BB;box-shadow:0 0 0 2px #3272BB}
        .history-workflow-step.current .history-workflow-label{color:#003366}

        .history-workflow-step.rejected::before{background:#dc2626}
        .history-workflow-step.rejected .history-workflow-node{background:#dc2626;color:#fff}
        .history-workflow-step.rejected .history-workflow-label{color:#4a5568}

        .history-workflow-step.warning::before{background:#f2a900}
        .history-workflow-step.warning .history-workflow-node{background:#f2a900;color:#fff}
        .history-workflow-step.warning .history-workflow-label{color:#925400}

        @media(max-width:820px){
            .history-card-top-actions{justify-content:flex-start;width:100%}
            .history-workflow{margin-left:-14px;margin-right:-14px;padding-left:8px;padding-right:8px}
            .history-workflow-track{min-width:760px;padding:0}
            .history-workflow-step:not(:first-child)::before{top:14px;height:3px}
            .history-workflow-node{width:28px;height:28px;margin-bottom:5px;font-size:11px}
            .history-workflow-label{padding:0 1px;font-size:10px}
            .history-workflow-time{padding:0 1px;font-size:9px}
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
<div id="main">
    <%@ include file="/WEB-INF/jspf/topbar.jspf" %>
    <main class="third-party-request-page">
        <section class="third-party-page-head third-party-toolbar-head">
            <div>
                <p class="eyebrow">Third-party Forms</p>
                <h1>ประวัติคำขอผู้ให้บริการภายนอก</h1>
                <p><%= adminView ? "แสดงคำขอทั้งหมดสำหรับผู้ดูแลระบบ" : "แสดงคำขอทั้งหมดที่ดูแลโดย Employee #678" %></p>
            </div>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/<%= adminView ? "Admin.jsp" : "thirdParty/request/new" %>">
                <i class="fa-solid fa-arrow-left"></i> กลับ
            </a>
        </section>

        <section class="third-party-panel">
            <div class="history-filter-bar">
                <a class="history-filter <%= "all".equals(historyFilter) ? "selected" : "" %>"
                   href="<%= historyUrl(request.getContextPath(), "all", historySearch, 1) %>">ทั้งหมด</a>
                <a class="history-filter <%= "waiting".equals(historyFilter) ? "selected" : "" %>"
                   href="<%= historyUrl(request.getContextPath(), "waiting", historySearch, 1) %>">กำลังดำเนินการ</a>
                <a class="history-filter <%= "completed".equals(historyFilter) ? "selected" : "" %>"
                   href="<%= historyUrl(request.getContextPath(), "completed", historySearch, 1) %>">เสร็จสิ้น</a>
                <a class="history-filter <%= "rejected".equals(historyFilter) ? "selected" : "" %>"
                   href="<%= historyUrl(request.getContextPath(), "rejected", historySearch, 1) %>">ไม่อนุมัติ</a>

                <form class="history-search-form" method="get" action="${pageContext.request.contextPath}/thirdParty/history">
                    <input type="hidden" name="filter" value="<%= h(historyFilter) %>">
                    <input class="history-search" name="q" type="search" value="<%= h(historySearch) %>"
                           placeholder="ค้นหา Request ID / ผู้ขอ / บริษัท / ระบบ">
                    <button class="btn btn-secondary" type="submit"><i class="fa-solid fa-magnifying-glass"></i> ค้นหา</button>
                </form>

                <span class="history-result-count"><%= items.size() %> รายการในหน้านี้</span>
            </div>

            <% if (items.isEmpty()) { %>
                <div class="empty-link-state">
                    <i class="fa-solid fa-clock-rotate-left"></i>
                    <h2>ยังไม่มีประวัติ Third-party Form</h2>
                </div>
            <% } else { %>
            <div class="third-party-link-list compact-list" id="historyList">
                <% for (ThirdPartyRequest item : items) { %>
                <article class="third-party-link-card compact-card third-party-history-card">
                    <div class="link-card-main">
                        <div class="link-card-title-row">
                            <div>
                                <h2>คำขอ #<%= item.getRequestId() %></h2>
                                <% if (adminView) { %>
                                    <p class="history-owner">เจ้าของภายใน Employee #<%= item.getInternalOwnerEmpId() %></p>
                                <% } %>
                            </div>

                            <div class="link-card-actions clean-actions history-card-top-actions">
                                <span class="status-badge <%= "completed".equals(category(item.getStatus())) ? "ok" : ("rejected".equals(category(item.getStatus())) ? "danger" : "wait") %>">
                                    <%= h(statusText(item.getStatus())) %>
                                </span>

                                <% if (item.getSubmissionId() != null) { %>
                                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/thirdPartySubmission?id=<%= item.getSubmissionId() %>">
                                    <i class="fa-solid fa-file-lines"></i> รายละเอียด
                                </a>
                                <% } %>
                            </div>
                        </div>

                        <div class="status-strip">
                            <div><span>ผู้ขอ</span><strong><%= display(item.getExternalContactName()) %></strong></div>
                            <div><span>บริษัท/หน่วยงาน</span><strong><%= display(item.getExternalCompanyName()) %></strong></div>
                            <div><span>ระบบ/โครงการ</span><strong><%= display(item.getTargetSystem()) %></strong></div>
                        </div>

                        <%
                            List<ThirdPartyWorkflowActionEntry> itemActions =
                                actionHistory.get(Long.valueOf(item.getRequestId()));
                            int activeStep = currentStepIndex(item.getStatus());

                            int rejectionIndex = -1;
                            for (int ri = 0; ri < timelineActionTypes.length; ri++) {
                                ThirdPartyWorkflowActionEntry rejectAction =
                                    findTimelineAction(itemActions, timelineActionTypes[ri]);
                                if (rejectedTimelineAction(rejectAction)) {
                                    rejectionIndex = ri;
                                    break;
                                }
                            }
                            if (rejectionIndex < 0 && "REJECTED".equals(item.getStatus())) {
                                rejectionIndex = activeStep;
                            }
                        %>

                        <div class="history-workflow" aria-label="ขั้นตอนคำขอ">
                            <div class="history-workflow-track">
                            <% for (int stepIndex = 0; stepIndex < timelineLabels.length; stepIndex++) {
                                ThirdPartyWorkflowActionEntry stepAction =
                                    findTimelineAction(itemActions, timelineActionTypes[stepIndex]);

                                boolean rejectedStep = rejectionIndex >= 0 && stepIndex >= rejectionIndex;
                                boolean warningStep = !rejectedStep && warningTimelineAction(stepAction);
                                boolean completedStep = !rejectedStep && !warningStep
                                    && (stepAction != null || stepIndex < activeStep || "COMPLETED".equals(item.getStatus()));
                                boolean currentStep = !rejectedStep && !warningStep
                                    && stepIndex == activeStep && !"COMPLETED".equals(item.getStatus());

                                String stepClass = rejectedStep ? "rejected" : warningStep ? "warning"
                                    : completedStep ? "completed" : currentStep ? "current" : "pending";

                                Timestamp actedAt = stepAction == null ? null : stepAction.getActedAt();
                                if (stepIndex == 0 && actedAt == null) actedAt = item.getSubmittedAt();

                                String iconClass = rejectedStep ? "fa-xmark" : warningStep ? "fa-triangle-exclamation"
                                : completedStep ? "fa-check" : currentStep ? "fa-hourglass-half" : "fa-minus";
                            %>
                                <div class="history-workflow-step <%= stepClass %>">
                                    <span class="history-workflow-node">
                                        <i class="fa-solid <%= iconClass %>"></i>
                                    </span>
                                    <span class="history-workflow-label"><%= timelineLabels[stepIndex] %></span>
                                    <span class="history-workflow-time">
                                        <%= actedAt == null ? (currentStep ? "กำลังดำเนินการ" : "-") : stepTime.format(actedAt) %>
                                    </span>
                                </div>
                            <% } %>
                            </div>
                        </div>
                    </div>
                </article>
                <% } %>
            </div>

            <% if (historyPage > 1 || historyHasNextPage) { %>
            <nav class="history-pagination" aria-label="หน้าประวัติคำขอ">
                <% if (historyPage > 1) { %>
                <a class="btn btn-secondary" href="<%= historyUrl(request.getContextPath(), historyFilter, historySearch, historyPage - 1) %>">
                    <i class="fa-solid fa-arrow-left"></i> ก่อนหน้า
                </a>
                <% } %>

                <span class="history-pagination-label">หน้า <%= historyPage %></span>

                <% if (historyHasNextPage) { %>
                <a class="btn btn-secondary" href="<%= historyUrl(request.getContextPath(), historyFilter, historySearch, historyPage + 1) %>">
                    ถัดไป <i class="fa-solid fa-arrow-right"></i>
                </a>
                <% } %>
            </nav>
            <% } %>
            <% } %>
        </section>
    </main>

    <%@ include file="/WEB-INF/jspf/footer.jspf" %>
</div>

<script>
function toggleNav(){
    var s=document.getElementById("mySidebar"),
        m=document.getElementById("main"),
        o=s.style.width==="250px";
    s.style.width=o?"0":"250px";
    m.style.marginLeft=o?"0":"250px";
    m.style.width=o?"100%":"calc(100% - 250px)";
}
</script>
</body>
</html>