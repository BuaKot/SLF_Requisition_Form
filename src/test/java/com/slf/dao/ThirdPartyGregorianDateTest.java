package com.slf.dao;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartyGregorianDateTest extends TestCase {

    public void testThirdPartyDaosDoNotPassCalendarToOracleJdbc() throws Exception {
        String[] files = {
            "src/main/java/com/slf/dao/ThirdPartyAcceptanceDAO.java",
            "src/main/java/com/slf/dao/ThirdPartyAuditLogDAO.java",
            "src/main/java/com/slf/dao/ThirdPartyFormLinkDAO.java",
            "src/main/java/com/slf/dao/ThirdPartyFormSubmissionDAO.java",
            "src/main/java/com/slf/dao/ThirdPartyRequestDAO.java",
            "src/main/java/com/slf/dao/ThirdPartyWorkflowDAO.java"
        };
        for (String file : files) {
            String source = new String(Files.readAllBytes(Paths.get(file)), StandardCharsets.UTF_8);
            assertFalse(file, source.contains("BangkokTimeUtil.newCalendar()"));
        }
    }
}
