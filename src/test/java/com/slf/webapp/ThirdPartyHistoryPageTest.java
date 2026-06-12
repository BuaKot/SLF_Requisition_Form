package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartyHistoryPageTest extends TestCase {

    public void testHistoryPageHasFiltersSearchAndSubmissionLink() throws Exception {
        String page = read("src/main/webapp/third-party-history.jsp");
        assertTrue(page.contains("data-filter=\"waiting\""));
        assertTrue(page.contains("data-filter=\"completed\""));
        assertTrue(page.contains("data-filter=\"rejected\""));
        assertTrue(page.contains("historySearch"));
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
        assertTrue(servlet.contains("/third-party-history.jsp"));
        assertTrue(workflowDao.contains("a.REQUEST_ID IN ("));
        assertTrue(workflowDao.contains("a.ACTION_TYPE <> 'WORKFLOW_MIGRATED'"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
