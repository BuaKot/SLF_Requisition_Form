package com.slf.webapp;

import junit.framework.TestCase;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

public class LoginCustomCaptchaPageTest extends TestCase {

    public void testLoginPageUsesConditionalJavaCaptchaChallenge() throws Exception {
        String source = new String(
            Files.readAllBytes(Paths.get("src/main/webapp/login.jsp")),
            StandardCharsets.UTF_8
        );

        assertTrue(source.contains("boolean captchaRequired = \"1\".equals(request.getParameter(\"captchaRequired\"))"));
        assertTrue(source.contains("captchaRequired ? JavaCaptchaService.createChallenge(request) : null"));
        assertTrue(source.contains("<% if (captchaRequired) { %>"));
        assertTrue(source.contains("JavaCaptchaService.createChallenge(request)"));
        assertTrue(source.contains("CaptchaChallenge"));
        assertTrue(source.contains("name=\"captchaToken\""));
        assertTrue(source.contains("name=\"captchaAnswer\""));
        assertTrue(source.contains("captcha.getImageDataUrl()"));
        assertTrue(source.contains("captcha-panel"));
        assertTrue(source.contains("captcha-visual"));
        assertTrue(source.contains("captcha-input-wrap"));
        assertTrue(source.contains("waitSeconds"));
        assertTrue(source.contains("loginCountdown"));
        assertTrue(source.contains("data-wait-seconds"));
    }
}
