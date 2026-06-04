package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import junit.framework.TestCase;

public class LoginRouteConsistencyTest extends TestCase {

    public void testNoExternalLoginRedirectUsesLoginJsp() throws Exception {
        Path root = Paths.get("src/main");
        for (Path path : Files.walk(root).filter(Files::isRegularFile).toArray(Path[]::new)) {
            String normalized = path.toString().replace('\\', '/');
            if (normalized.endsWith("controller/LoadLoginServlet.java")) {
                continue;
            }

            String source = new String(Files.readAllBytes(path), StandardCharsets.UTF_8);
            assertFalse("Use /login instead of login.jsp in " + normalized,
                source.contains("sendRedirect(request.getContextPath() + \"/login.jsp"));
            assertFalse("Use /login instead of login.jsp in " + normalized,
                source.contains("href=\"login.jsp"));
            assertFalse("Use /login instead of login.jsp in " + normalized,
                source.contains("action=\"login.jsp"));
        }
    }
}
