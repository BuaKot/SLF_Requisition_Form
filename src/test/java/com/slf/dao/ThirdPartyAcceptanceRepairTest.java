package com.slf.dao;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartyAcceptanceRepairTest extends TestCase {

    public void testPendingExternalAcceptanceWithoutTokenIsRepaired() throws Exception {
        String dao = read("src/main/java/com/slf/dao/ThirdPartyAcceptanceDAO.java");
        String servlet = read("src/main/java/com/slf/controller/ThirdPartyRequestServlet.java");
        assertTrue(dao.contains("repairMissingTokensForOwner"));
        assertTrue(dao.contains("r.STATUS = 'PENDING_EXTERNAL_ACCEPTANCE'"));
        assertTrue(dao.contains("NOT EXISTS (SELECT 1 FROM THIRD_PARTY_ACCEPTANCE_TOKEN"));
        assertTrue(servlet.contains("acceptanceDAO.repairMissingTokensForOwner"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
