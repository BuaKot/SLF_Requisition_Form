package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartyHistoryPageTest extends TestCase {

    public void testHistoryPageHasFiltersSearchAndSubmissionLink() throws Exception {
        String page = read("src/main/webapp/third-party-history.jsp");
        assertTrue(page.contains("historyUrl(request.getContextPath(), \"waiting\""));
        assertTrue(page.contains("historyUrl(request.getContextPath(), \"completed\""));
        assertTrue(page.contains("historyUrl(request.getContextPath(), \"rejected\""));
        assertTrue(page.contains("name=\"q\""));
        assertTrue(page.contains("history-pagination"));
        assertTrue(page.contains("thirdPartySubmission?id="));
        assertTrue(page.contains("history-filter-panel"));
        assertTrue(page.contains("third-party-panel history-table-panel"));
        assertTrue(page.contains("class=\"history-table\""));
        assertTrue(page.contains("<th>สถานะ</th>"));
        assertTrue(page.contains("<th>ผู้ขอใช้บริการ</th>"));
        assertTrue(page.contains("<th>ขั้นตอน</th>"));
        assertTrue(page.contains("<th>ผู้เกี่ยวข้อง</th>"));
        assertTrue(page.contains("history-step-pill"));
        assertTrue(page.contains("history-mini-timeline"));
        assertTrue(page.contains("history-people-tooltip"));
        assertTrue(page.contains("history-person-item"));
        assertTrue(page.contains("history-person-more"));
        assertTrue(page.contains("function fitRelatedPeople()"));
        assertFalse(page.contains("Math.min(2, people.size())"));
        assertTrue(page.contains("item.getAccessStartDate()"));
        assertTrue(page.contains("item.getAccessEndDate()"));
        assertTrue(page.contains("grid-template-columns:repeat(9,minmax(0,1fr))"));
        assertTrue(page.contains("overflow-x:auto"));
        assertTrue(page.contains("timelineActionTypes"));
        assertTrue(page.contains("SECTION_HEAD_SUBMITTED"));
        assertTrue(page.contains("FINAL_CERTIFIED"));
        assertTrue(page.contains("fa-hourglass-half"));
        assertTrue(page.contains("กำลังใช้งาน"));
        assertTrue(page.contains("กำลังระงับสิทธิ์"));
        assertTrue(page.contains("กำลังรับรอง"));
    }

    public void testHistoryServletScopesAdminAndOwnerViews() throws Exception {
        String servlet = read("src/main/java/com/slf/controller/ThirdPartyHistoryServlet.java");
        String workflowDao = read("src/main/java/com/slf/dao/ThirdPartyWorkflowDAO.java");
        assertTrue(servlet.contains("canViewHistory"));
        assertTrue(servlet.contains("adminView ? null : empId"));
        assertTrue(servlet.contains("findActionHistoryForRequests"));
        assertTrue(servlet.contains("thirdPartyHistoryActions"));
        assertTrue(servlet.contains("PAGE_SIZE + 1"));
        assertTrue(servlet.contains("thirdPartyHistoryHasNextPage"));
        assertTrue(servlet.contains("/third-party-history.jsp"));
        assertTrue(workflowDao.contains("a.REQUEST_ID IN ("));
        assertTrue(workflowDao.contains("a.ACTION_TYPE <> 'WORKFLOW_MIGRATED'"));
        assertTrue(workflowDao.contains("SELECT a.REQUEST_ID, a.ACTION_TYPE, a.ACTOR_TYPE, a.ACTOR_EMPID"));
        assertTrue(workflowDao.contains("ACTOR_EMPNAME"));
        assertTrue(workflowDao.contains("ACTOR_POSITION"));
        assertFalse(workflowDao.contains(
            "SELECT a.REQUEST_ID, a.ACTION_TYPE, a.FROM_STATUS, a.TO_STATUS"));
    }

    public void testHistoryUsesWorkflowSequenceAndCompletedPdfExportOnly() throws Exception {
        String page = read("src/main/webapp/third-party-history.jsp");
        String workflowDao = read("src/main/java/com/slf/dao/ThirdPartyWorkflowDAO.java");

        assertTrue(workflowDao.contains("workflowActionOrderSql"));
        assertTrue(workflowDao.contains("WHEN 'REVOKER_COMPLETED' THEN 6"));
        assertTrue(workflowDao.contains("WHEN 'REVOKE_REVIEWER_APPROVED' THEN 7"));
        assertTrue(workflowDao.contains("WHEN 'SECTION_HEAD_REPORTED' THEN 8"));
        assertTrue(workflowDao.contains("WHEN 'FINAL_CERTIFIED' THEN 9"));
        assertTrue(workflowDao.contains("ACTOR_POSITION"));
        assertTrue(workflowDao.contains("entry.setActorPosition"));
        assertTrue(page.contains("\"COMPLETED\".equals(item.getStatus())"));
        assertTrue(page.contains("/thirdParty/exportPdf?submissionId="));
        assertTrue(page.contains("history-pdf-button"));
    }

    public void testHistoryQueryUsesLeanProjectionAndDatabasePagination() throws Exception {
        String requestDao = read("src/main/java/com/slf/dao/ThirdPartyRequestDAO.java");
        assertTrue(requestDao.contains("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY"));
        assertTrue(requestDao.contains("mapHistoryRequest(rs)"));
        assertTrue(requestDao.contains("TO_CHAR(r.REQUEST_ID) LIKE ?"));
        assertTrue(requestDao.contains("r.ACCESS_START_DATE, r.ACCESS_END_DATE"));
        String historyMethod = requestDao.substring(
            requestDao.indexOf("public List<ThirdPartyRequest> findHistory(Integer ownerEmpId, String category"),
            requestDao.indexOf("public List<ThirdPartyRequest> findByStatus"));
        assertFalse(historyMethod.contains("RAW_TOKEN"));
        assertFalse(historyMethod.contains("EXTERNAL_EMAIL"));
        assertFalse(historyMethod.contains("LINK_STATUS"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
