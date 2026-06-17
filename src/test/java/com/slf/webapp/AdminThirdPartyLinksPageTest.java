package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class AdminThirdPartyLinksPageTest extends TestCase {

    public void testAdminPageUsesUpgradedCardLayoutAndFilters() throws Exception {
        String page = new String(
            Files.readAllBytes(Paths.get("src/main/webapp/WEB-INF/views/ThirdPartyLinks.jsp")),
            StandardCharsets.UTF_8
        );

        assertTrue(page.contains("admin-link-summary"));
        assertTrue(page.contains("filterLinks(this)"));
        assertTrue(page.contains("admin-link-card"));
        assertTrue(page.contains("Request ID"));
        assertTrue(page.contains("thirdPartySubmission?id="));
        assertFalse(page.contains("Token Hash"));
        assertFalse(page.contains("getTokenHash()"));
        assertFalse(page.contains("<table>"));
    }
}
