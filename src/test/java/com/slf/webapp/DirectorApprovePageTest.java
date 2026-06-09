package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class DirectorApprovePageTest extends TestCase {

    public void testDirectorApprovalPageUsesHomeAndHistoryNavigation() throws Exception {
        String page = new String(
            Files.readAllBytes(Paths.get("src/main/webapp/DirectorApprove.jsp")),
            StandardCharsets.UTF_8
        );
        String sharedPage = new String(
            Files.readAllBytes(Paths.get("src/main/webapp/WEB-INF/approvalList.jsp")),
            StandardCharsets.UTF_8
        );

        assertFalse(page.contains("Admin.jsp"));
        assertTrue(page.contains("/WEB-INF/approvalList.jsp"));
        assertTrue(sharedPage.contains("/history.jsp"));
        assertTrue(sharedPage.contains("ไม่มีรายการรอดำเนินการ"));
        assertTrue(sharedPage.contains("requisition-card"));
    }
}
