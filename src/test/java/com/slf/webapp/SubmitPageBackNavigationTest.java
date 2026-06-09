package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class SubmitPageBackNavigationTest extends TestCase {

    public void testSubmitPageHasHomeButtonAndPassesSourceToDetail() throws Exception {
        String source = new String(
            Files.readAllBytes(Paths.get("src/main/webapp/submit.jsp")),
            StandardCharsets.UTF_8
        );

        assertTrue(source.contains("submit-home-button"));
        assertTrue(source.contains("<i class=\"fa-solid fa-arrow-left\"></i> หน้าหลัก"));
        assertTrue(source.contains("&from=submit"));
    }
}
