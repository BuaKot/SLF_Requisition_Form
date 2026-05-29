package com.slf.security;

import junit.framework.TestCase;

public class LoginAttemptServiceTest extends TestCase {

    public void testRequiresCaptchaAfterThreeFailures() {
        LoginAttemptService service = new LoginAttemptService();

        service.recordFailure("10.0.0.1", "1001");
        service.recordFailure("10.0.0.1", "1001");
        assertFalse(service.isCaptchaRequired("10.0.0.1", "1001"));

        service.recordFailure("10.0.0.1", "1001");
        assertTrue(service.isCaptchaRequired("10.0.0.1", "1001"));
    }

    public void testSuccessClearsFailureCounter() {
        LoginAttemptService service = new LoginAttemptService();

        service.recordFailure("10.0.0.1", "1001");
        service.recordFailure("10.0.0.1", "1001");
        service.recordFailure("10.0.0.1", "1001");
        service.recordSuccess("10.0.0.1", "1001");

        assertFalse(service.isCaptchaRequired("10.0.0.1", "1001"));
    }
}
