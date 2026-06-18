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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css?v=20260618-2">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="view-third-party-history">
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
                            <a class="btn btn-secondary history-detail-button" href="${pageContext.request.contextPath}/thirdPartySubmission?requestId=<%= item.getRequestId() %>">
                                <i class="fa-solid fa-file-lines"></i><span class="history-detail-button-text">รายละเอียด</span>
                            </a>
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
