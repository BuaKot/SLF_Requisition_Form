package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

import junit.framework.TestCase;

public class LoginPagePerformanceTest extends TestCase {

    public void testLoginPageDoesNotBlockOnExternalAssets() throws Exception {
        String source = new String(
            Files.readAllBytes(Paths.get("src/main/webapp/login.jsp")),
            StandardCharsets.UTF_8
        );

        assertFalse(source.contains("https://"));
        assertFalse(source.contains("fonts.googleapis.com"));
        assertFalse(source.contains("cdnjs.cloudflare.com"));
        assertFalse(source.contains("font-awesome"));
    }
}
