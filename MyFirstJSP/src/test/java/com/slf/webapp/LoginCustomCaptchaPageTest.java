package com.slf.webapp;

import junit.framework.TestCase;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

public class LoginCustomCaptchaPageTest extends TestCase {

    public void testLoginPageUsesRustCaptchaChallenge() throws Exception {
        String source = new String(
            Files.readAllBytes(Paths.get("src/main/webapp/login.jsp")),
            StandardCharsets.UTF_8
        );

        assertTrue(source.contains("RustCaptchaClient"));
        assertTrue(source.contains("JavaCaptchaService.createChallenge(request)"));
        assertTrue(source.contains("CaptchaChallenge"));
        assertTrue(source.contains("name=\"captchaToken\""));
        assertTrue(source.contains("name=\"captchaAnswer\""));
        assertTrue(source.contains("captcha.getImageDataUrl()"));
    }
}
