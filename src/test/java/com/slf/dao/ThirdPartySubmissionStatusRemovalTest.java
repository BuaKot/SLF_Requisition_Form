package com.slf.dao;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartySubmissionStatusRemovalTest extends TestCase {

    public void testRequestStatusIsTheOnlyWorkflowStatus() throws Exception {
        String submissionDao = read("src/main/java/com/slf/dao/ThirdPartyFormSubmissionDAO.java");
        String linkDao = read("src/main/java/com/slf/dao/ThirdPartyFormLinkDAO.java");
        String page = read("src/main/webapp/WEB-INF/views/ThirdPartySubmission.jsp");
        String sqlRemovalLog = read("docs/sql-removal-log.md");

        assertFalse(submissionDao.contains("s.STATUS"));
        assertFalse(submissionDao.contains("ACCESS_END_DATE, STATUS, CREATED_AT"));
        assertFalse(submissionDao.contains("'PENDING_REVIEW'"));
        assertFalse(linkDao.contains("SUBMISSION_STATUS"));
        assertFalse(page.contains("สถานะ Submission"));
        assertFalse(Files.exists(Paths.get("sql")));
        assertTrue(sqlRemovalLog.contains("2026-06-12_drop_third_party_submission_status.sql"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
