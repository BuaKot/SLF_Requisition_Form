package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartyRequestActionsTest extends TestCase {

    public void testRequestActionsUseInlineCopyAndDescribeDeletion() throws Exception {
        String page = read("src/main/webapp/third-party-request-new.jsp");
        String styles = read("src/main/webapp/css/styles.css");

        assertTrue(page.contains("fa-trash-can"));
        assertTrue(page.contains("owner-request-card"));
        assertTrue(page.contains("link-card-actions clean-actions owner-request-card-actions"));
        assertTrue(page.contains("compact-note-requester"));
        assertTrue(page.contains("getExternalContactName() == null ? \"\""));
        assertTrue(page.contains("copy-link-text"));
        assertTrue(page.contains("copyMergedLink(this)"));
        assertTrue(page.contains("merged-link-meta-grid"));
        assertTrue(page.contains("item.getLinkExpiresAt()"));
        assertTrue(page.contains("item.getSubmittedAt()"));
        assertTrue(page.contains("คัดลอกลิ้งก์"));
        assertFalse(page.contains("/thirdParty/request/link?requestId="));
        assertFalse(page.contains("thirdPartySubmission?id="));

        assertTrue(styles.contains(".third-party-request-page .btn"));
        assertTrue(styles.contains(".third-party-request-page .btn-primary"));
        assertTrue(styles.contains(".third-party-request-page .btn-secondary"));
        assertTrue(styles.contains(".owner-request-card"));
        assertTrue(styles.contains(".owner-request-card-actions"));
        assertTrue(styles.contains(".owner-link-dashboard .owner-request-list-panel"));
        assertTrue(styles.contains(".copy-link-text"));
        assertTrue(styles.contains(".compact-note-requester"));
        assertTrue(styles.contains(".merged-link-meta-grid"));
        assertTrue(styles.contains("max-width: none"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
