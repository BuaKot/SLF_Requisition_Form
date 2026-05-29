package com.slf.webapp;

import junit.framework.TestCase;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

public class LoginPageTest extends TestCase {

    public void testLoginPageDoesNotIncludeAuthenticatedPageGuard() throws Exception {
        String source = new String(
            Files.readAllBytes(Paths.get("src/main/webapp/login.jsp")),
            StandardCharsets.UTF_8
        );

        assertFalse(source.contains("checkAuth.jsp"));
    }
}
