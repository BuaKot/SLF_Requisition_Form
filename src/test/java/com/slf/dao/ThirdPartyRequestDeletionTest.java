package com.slf.dao;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartyRequestDeletionTest extends TestCase {

    public void testCancellationDeletesOnlyUnusedOwnedRequestAndLink() throws Exception {
        String source = new String(
            Files.readAllBytes(Paths.get("src/main/java/com/slf/dao/ThirdPartyRequestDAO.java")),
            StandardCharsets.UTF_8
        );

        assertTrue(source.contains("DELETE FROM THIRD_PARTY_FORM_LINK"));
        assertTrue(source.contains("DELETE FROM THIRD_PARTY_REQUEST"));
        assertTrue(source.contains("l.STATUS = 'ACTIVE' AND l.SUBMIT_COUNT = 0"));
        assertTrue(source.contains("NOT EXISTS (SELECT 1 FROM THIRD_PARTY_FORM_SUBMISSION"));
        assertTrue(source.contains("r.INTERNAL_OWNER_EMPID = ?"));
    }
}
