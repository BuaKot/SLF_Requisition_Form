package com.slf.notification;

import junit.framework.TestCase;

public class GmailNotificationServiceTest extends TestCase {

    public void testSubmittedNotificationTextIncludesFormDetails() {
        GmailNotificationService service = new GmailNotificationService(
            new GmailNotificationConfig(
                false,
                "smtp.gmail.com",
                587,
                false,
                "sender@example.com",
                "app-password",
                "sender@example.com",
                "to@example.com"
            )
        );

        assertEquals("[SLF] New requisition form #42", service.buildSubmittedSubject(42));

        String body = service.buildSubmittedBody(42, 1001, "VPN access");
        assertTrue(body.contains("Form ID: 42"));
        assertTrue(body.contains("Requester EMPID: 1001"));
        assertTrue(body.contains("Topic: VPN access"));
    }

    public void testSkipsWhenSmtpPasswordIsMissing() {
        GmailNotificationService service = new GmailNotificationService(
            new GmailNotificationConfig(
                true,
                "smtp.gmail.com",
                587,
                false,
                "sender@example.com",
                null,
                "sender@example.com",
                "to@example.com"
            )
        );

        NotificationSendResult result = service.sendFormSubmittedNotification(42, 1001, "VPN access");

        assertFalse(result.isSent());
        assertTrue(result.isSkipped());
        assertEquals(NotificationSendResult.Status.SKIPPED, result.getStatus());
        assertTrue(result.getErrorMessage().contains("slf.mail.password"));
    }
}
