package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

import junit.framework.TestCase;

public class WarContextPathTest extends TestCase {

    public void testWarFinalNameMatchesExpectedLocalContextPath() throws Exception {
        String source = new String(
            Files.readAllBytes(Paths.get("pom.xml")),
            StandardCharsets.UTF_8
        );

        assertTrue(source.contains("<finalName>SLF_Requisition_Form</finalName>"));
    }
}
