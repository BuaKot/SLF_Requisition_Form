package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

import junit.framework.TestCase;

public class MailLogFormReferenceTest extends TestCase {

    public void testMailLogDisplaysFormTypeAwareReference() throws Exception {
        String page = new String(
            Files.readAllBytes(Paths.get("src/main/webapp/WEB-INF/views/MailLog.jsp")),
            StandardCharsets.UTF_8
        );

        assertTrue(page.contains("displayFormReference(EmailNotificationLogEntry log)"));
        assertTrue(page.contains("Third Party #"));
        assertTrue(page.contains("Requisition #"));
        assertTrue(page.contains("Form Type / Event"));
        assertTrue(page.contains("name=\"formType\""));
        assertTrue(page.contains("value=\"REQUISITION\""));
        assertTrue(page.contains("value=\"THIRD_PARTY\""));
    }
}
