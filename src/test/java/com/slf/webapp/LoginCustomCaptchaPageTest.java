package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

import junit.framework.TestCase;

public class LoginCustomCaptchaPageTest extends TestCase {

    public void testLoginPageUsesConditionalJavaCaptchaChallenge() throws Exception {
        String source = new String(
            Files.readAllBytes(Paths.get("src/main/webapp/login.jsp")),
            StandardCharsets.UTF_8
        );

        assertTrue(source.contains("boolean captchaRequired = \"1\".equals(request.getParameter(\"captchaRequired\"))"));
        assertTrue(source.contains("captchaRequired ? JavaCaptchaService.createChallenge(request) : null"));
        assertTrue(source.contains("<% if (captchaRequired) { %>"));
        assertTrue(source.contains("CaptchaChallenge"));
        assertTrue(source.contains("name=\"captchaToken\""));
        assertTrue(source.contains("name=\"captchaAnswer\""));
        assertTrue(source.contains("captcha.getImageDataUrl()"));
        assertTrue(source.contains("captcha-panel"));
        assertTrue(source.contains("session.getAttribute(\"loginWaitSeconds\")"));
        assertTrue(source.contains("session.removeAttribute(\"loginWaitSeconds\")"));
        assertTrue(source.contains("cooldown-msg"));
        assertTrue(source.contains("data-wait-seconds"));
        assertTrue(source.contains("loginCountdown"));
    }
}
