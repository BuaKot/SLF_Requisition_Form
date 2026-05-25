package com.slf.controller;

import junit.framework.TestCase;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

public class MemberManageServletTest extends TestCase {

    public void testDefaultStatusFilterShowsAllMembers() throws Exception {
        String source = new String(
            Files.readAllBytes(Paths.get("src/main/java/com/slf/controller/MemberManageServlet.java")),
            StandardCharsets.UTF_8
        );

        assertTrue(source.contains("status = \"all\";"));
        assertFalse(source.contains("status = \"active\";"));
    }
}
