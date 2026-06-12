package com.slf.controller;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class LoadProcessServletTest extends TestCase {

    public void testProcessInboxFiltersByAssignedDeveloper() throws Exception {
        String source = new String(
            Files.readAllBytes(Paths.get("src/main/java/com/slf/controller/LoadProcessServlet.java")),
            StandardCharsets.UTF_8
        );

        assertTrue(source.contains("SELECT FORMID, STATE_STEP, DEV_EMPID"));
        assertTrue(source.contains("AND ls.DEV_EMPID = ?"));
        assertFalse(source.contains("AND d.DEPTHEAD_EMPID = ?"));
    }
}
