package com.slf.dao;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartyFormSubmissionDAOTest extends TestCase {

    public void testFormatsDocumentReceiveNoFromSequence() {
        assertEquals("TP-000001", ThirdPartyFormSubmissionDAO.formatDocumentReceiveNo(1L));
        assertEquals("TP-000123", ThirdPartyFormSubmissionDAO.formatDocumentReceiveNo(123L));
    }

    public void testDetailQueryOnlySelectsDisplayedSubmissionFields() throws Exception {
        String source = new String(
            Files.readAllBytes(Paths.get("src/main/java/com/slf/dao/ThirdPartyFormSubmissionDAO.java")),
            StandardCharsets.UTF_8
        );
        String detailMethod = source.substring(
            source.indexOf("public ThirdPartyFormSubmission findDetailById"),
            source.indexOf("public void submitOnce")
        );
        assertTrue(detailMethod.contains("findDetailAccessRequests"));
        assertTrue(detailMethod.contains("s.CONSENT_ACCEPTED"));
        assertFalse(detailMethod.contains("s.FULL_NAME_TH"));
        assertFalse(detailMethod.contains("s.EMAIL"));
        assertFalse(detailMethod.contains("LINK_STATUS"));
    }
}
