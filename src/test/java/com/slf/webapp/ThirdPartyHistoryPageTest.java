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
        assertTrue(page.contains("รอผู้ขอภายนอกกรอกฟอร์ม"));
        assertFalse(page.contains("รอผู้ให้บริการกรอก"));
    }

    public void testHistoryServletScopesAdminAndOwnerViews() throws Exception {
        String servlet = read("src/main/java/com/slf/controller/ThirdPartyHistoryServlet.java");
        assertTrue(servlet.contains("canViewHistory"));
        assertTrue(servlet.contains("adminView ? null : empId"));
        assertTrue(servlet.contains("/third-party-history.jsp"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
