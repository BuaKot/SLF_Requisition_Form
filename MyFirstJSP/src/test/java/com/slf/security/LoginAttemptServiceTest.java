package com.slf.security;

import junit.framework.TestCase;

public class LoginAttemptServiceTest extends TestCase {

    public void testRequiresCaptchaAfterFourFailures() {
        LoginAttemptService service = new LoginAttemptService();

        service.recordFailure("10.0.0.1", "1001");
        service.recordFailure("10.0.0.1", "1001");
        service.recordFailure("10.0.0.1", "1001");
        assertFalse(service.isCaptchaRequired("10.0.0.1", "1001"));

        service.recordFailure("10.0.0.1", "1001");
        assertTrue(service.isCaptchaRequired("10.0.0.1", "1001"));
    }

    public void testRequiresDelayAfterSixFailures() {
        LoginAttemptService service = new LoginAttemptService();

        for (int index = 0; index < 5; index++) {
            service.recordFailure("10.0.0.1", "1001");
        }
        assertFalse(service.isDelayRequired("10.0.0.1", "1001"));

        service.recordFailure("10.0.0.1", "1001");
        assertTrue(service.isDelayRequired("10.0.0.1", "1001"));
        assertTrue(service.getRemainingDelaySeconds("10.0.0.1", "1001") > 0);
    }

    public void testSuccessClearsFailureCounter() {
        LoginAttemptService service = new LoginAttemptService();

        service.recordFailure("10.0.0.1", "1001");
        service.recordFailure("10.0.0.1", "1001");
        service.recordFailure("10.0.0.1", "1001");
        service.recordFailure("10.0.0.1", "1001");
        service.recordFailure("10.0.0.1", "1001");
        service.recordFailure("10.0.0.1", "1001");
        service.recordSuccess("10.0.0.1", "1001");

        assertFalse(service.isCaptchaRequired("10.0.0.1", "1001"));
        assertFalse(service.isDelayRequired("10.0.0.1", "1001"));
    }
}
