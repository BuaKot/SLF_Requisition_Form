package com.slf.controller;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class LoadProcessServletTest extends TestCase {

    public void testProcessInboxFiltersByAssignedDeveloperOrAssignedHeads() throws Exception {
        String source = new String(
            Files.readAllBytes(Paths.get("src/main/java/com/slf/controller/LoadProcessServlet.java")),
            StandardCharsets.UTF_8
        );

        assertTrue(source.contains("latest_dev AS"));
        assertTrue(source.contains("SELECT FORMID, DEV_EMPID"));
        assertTrue(source.contains("LEFT JOIN latest_dev ld ON ld.FORMID = r.FORMID AND ld.RN = 1"));
        assertTrue(source.contains("assigned_s.SECTIONHEAD_EMPID"));
        assertTrue(source.contains("assigned_d.DEPTHEAD_EMPID"));
        assertTrue(source.contains("(ld.DEV_EMPID = ? OR assigned_s.SECTIONHEAD_EMPID = ? OR assigned_d.DEPTHEAD_EMPID = ?)"));
    }
}
