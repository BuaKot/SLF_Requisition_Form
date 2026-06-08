package com.slf.controller;

import junit.framework.TestCase;

public class ThirdPartySubmissionServletTest extends TestCase {

    public void testParsesPositiveSubmissionId() {
        assertEquals(12L, ThirdPartySubmissionServlet.parseSubmissionId(" 12 "));
    }

    public void testRejectsMissingOrInvalidSubmissionId() {
        assertInvalid(null);
        assertInvalid("0");
        assertInvalid("-1");
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
