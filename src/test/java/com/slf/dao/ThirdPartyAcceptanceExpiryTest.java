package com.slf.dao;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartyAcceptanceExpiryTest extends TestCase {

    public void testExpiredAcceptanceAdvancesToRevokerAndWritesAuditAction() throws Exception {
        String dao = read("src/main/java/com/slf/dao/ThirdPartyAcceptanceDAO.java");
        String listener = read("src/main/java/com/slf/controller/ThirdPartyAcceptanceExpiryListener.java");

        assertTrue(dao.contains("advanceExpiredAcceptances"));
        assertTrue(dao.contains("SET STATUS = 'EXPIRED', RAW_TOKEN = NULL"));
        assertTrue(dao.contains("SET STATUS = 'PENDING_REVOKER'"));
        assertTrue(dao.contains("'EXTERNAL_ACCEPTANCE_EXPIRED'"));
        assertTrue(dao.contains("FOR UPDATE OF r.STATUS, t.STATUS SKIP LOCKED"));
        assertTrue(listener.contains("@WebListener"));
        assertTrue(listener.contains("60L, TimeUnit.SECONDS"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
