package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ApprovalListConsistencyTest extends TestCase {

    public void testApprovalPagesUseSharedTemplateWithoutAdminBackLinks() throws Exception {
        String[] pages = {"DirectorApprove.jsp", "ITDirectorApprove.jsp", "TechnicalApprove.jsp", "Process.jsp"};
        for (String page : pages) {
            String source = read("src/main/webapp/" + page);
            assertTrue(page + " should use shared template", source.contains("/WEB-INF/approvalList.jsp"));
            assertFalse(page + " should not link to Admin.jsp", source.contains("Admin.jsp"));
        }
    }

    public void testHistoryUsesCurrentSharedSidebar() throws Exception {
        String history = read("src/main/webapp/history.jsp");
        assertTrue(history.contains("<%@ include file=\"/WEB-INF/sidebar.jsp\" %>"));
        assertFalse(history.contains("class=\"admin-tab\">"));
        assertTrue(history.contains("history-home-button"));
        assertTrue(history.contains("ประวัติรายการที่ฉันอนุมัติ"));
        assertTrue(history.contains("MY_AI.REVIEWER_EMPID = ?"));
        assertTrue(history.contains("&from=history"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
