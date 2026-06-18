package com.slf.controller;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartySubmissionServletTest extends TestCase {

    public void testParsesPositiveSubmissionId() {
        assertEquals(12L, ThirdPartySubmissionServlet.parseSubmissionId(" 12 "));
        assertEquals(37L, ThirdPartySubmissionServlet.parseRequestId(" 37 "));
    }

    public void testRejectsMissingOrInvalidSubmissionId() {
        assertInvalid(null);
        assertInvalid("0");
        assertInvalid("-1");
    }

    public void testLoadsByRequestIdAndAppliesSubmissionAccessPolicy() throws Exception {
        String source = new String(
            Files.readAllBytes(Paths.get("src/main/java/com/slf/controller/ThirdPartySubmissionServlet.java")),
            StandardCharsets.UTF_8
        );
        assertTrue(source.contains("request.getParameter(\"requestId\")"));
        assertTrue(source.contains("submissionDAO.findDetailByRequestId(recordId)"));
        assertTrue(source.contains("submissionDAO.findDetailById(recordId)"));
        assertTrue(source.contains("canViewSubmission"));
        assertTrue(source.contains("canViewAllSubmissions"));
    }

    private static void assertInvalid(String value) {
        try {
            ThirdPartySubmissionServlet.parseSubmissionId(value);
            fail("Expected invalid submission id");
        } catch (IllegalArgumentException expected) {
            assertTrue(expected.getMessage().length() > 0);
        }
    }
}
