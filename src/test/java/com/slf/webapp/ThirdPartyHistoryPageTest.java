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
        assertTrue(page.contains("link-card-actions clean-actions history-card-top-actions"));
        assertTrue(page.contains(".third-party-history-card{display:block}"));
        assertFalse(page.contains("dateTime.format(item.getUpdatedAt())"));
        assertFalse(page.contains("dateTime.format(item.getSubmittedAt())"));
        assertTrue(page.contains("history-workflow-track"));
        assertTrue(page.contains("grid-template-columns:repeat(9,minmax(0,1fr))"));
        assertFalse(page.contains("overflow-x:auto"));
        assertFalse(page.contains("min-width:1080px"));
        assertTrue(page.contains("timelineActionTypes"));
        assertTrue(page.contains("SECTION_HEAD_SUBMITTED"));
        assertTrue(page.contains("FINAL_CERTIFIED"));
        assertTrue(page.contains("fa-hourglass-half"));
        assertTrue(page.contains("รอผู้ขอภายนอกกรอกฟอร์ม"));
        assertFalse(page.contains("รอผู้ให้บริการกรอก"));
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
        assertTrue(workflowDao.contains("SELECT a.REQUEST_ID, a.ACTION_TYPE, a.ACTED_AT"));
        assertFalse(workflowDao.contains(
            "SELECT a.REQUEST_ID, a.ACTION_TYPE, a.FROM_STATUS, a.TO_STATUS"));
    }

    public void testHistoryQueryUsesLeanProjectionAndDatabasePagination() throws Exception {
        String requestDao = read("src/main/java/com/slf/dao/ThirdPartyRequestDAO.java");
        assertTrue(requestDao.contains("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY"));
        assertTrue(requestDao.contains("mapHistoryRequest(rs)"));
        assertTrue(requestDao.contains("TO_CHAR(r.REQUEST_ID) LIKE ?"));
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
