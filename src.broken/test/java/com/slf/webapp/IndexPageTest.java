package com.slf.webapp;

import junit.framework.TestCase;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

public class IndexPageTest extends TestCase {

    public void testIndexPageDoesNotUseAdminOnlyGuard() throws Exception {
        String source = new String(
            Files.readAllBytes(Paths.get("src/main/webapp/index.jsp")),
            StandardCharsets.UTF_8
        );

        assertFalse(source.contains("checkAuth.jsp"));
    }
}
