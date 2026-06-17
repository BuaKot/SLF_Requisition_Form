package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

import junit.framework.TestCase;

public class LoginPageIconAndCountdownTest extends TestCase {

    public void testLoginPageUsesLocalSvgIconsInsteadOfPlaceholderLetters() throws Exception {
        String source = readLoginPage();

        assertTrue(source.contains("icon-user"));
        assertTrue(source.contains("icon-lock"));
        assertTrue(source.contains("icon-alert"));
        assertTrue(source.contains("<svg"));
        assertFalse(source.contains(">U</i>"));
        assertFalse(source.contains(">L</i>"));
    }

    public void testCooldownTimerTicksDownOnTheClient() throws Exception {
        String source = readLoginPage();

        assertTrue(source.contains("setInterval"));
        assertTrue(source.contains("loginCountdown"));
        assertTrue(source.contains("data-wait-seconds"));
        assertTrue(source.contains("remaining -= 1"));
        assertTrue(source.contains("clearInterval"));
    }

    private String readLoginPage() throws Exception {
        return new String(
            Files.readAllBytes(Paths.get("src/main/webapp/WEB-INF/views/Login.jsp")),
            StandardCharsets.UTF_8
        );
    }
}
