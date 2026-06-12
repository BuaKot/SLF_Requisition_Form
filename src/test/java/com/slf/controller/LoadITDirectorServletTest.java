package com.slf.controller;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class LoadITDirectorServletTest extends TestCase {

    public void testITDirectorInboxFiltersByAssignedDepartmentHead() throws Exception {
        String source = new String(
            Files.readAllBytes(Paths.get("src/main/java/com/slf/controller/LoadITDirectorServlet.java")),
            StandardCharsets.UTF_8
        );

        assertTrue(source.contains("LEFT JOIN SECTION assigned_s ON r.ASSIGN_SECID = assigned_s.SECID"));
        assertTrue(source.contains("LEFT JOIN DEPARTMENT assigned_d ON assigned_s.DEPTID = assigned_d.DEPTID"));
        assertTrue(source.contains("AND assigned_d.DEPTHEAD_EMPID = ?"));
    }
}
