package com.slf.controller;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

import junit.framework.TestCase;

public class LoginProcessorServletTest extends TestCase {

    public void testSuccessfulLoginRedirectsToIndexForEveryRole() throws Exception {
        String source = new String(
            Files.readAllBytes(Paths.get("src/main/java/com/slf/controller/LoginProcessorServlet.java")),
            StandardCharsets.UTF_8
        );

        assertTrue(source.contains("response.sendRedirect(request.getContextPath() + \"/index.jsp\")"));
        assertFalse(source.contains("response.sendRedirect(request.getContextPath() + \"/Dashboard.jsp\")"));
    }
}
