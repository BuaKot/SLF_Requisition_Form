package com.slf.controller;

import junit.framework.TestCase;

public class RequisitionOwnerDetailServletTest extends TestCase {
    public void testParsesPositiveFormId() {
        assertEquals(564, RequisitionOwnerDetailServlet.parseFormId(" 564 "));
    }

    public void testRejectsMissingAndInvalidFormIds() {
        assertInvalid(null);
        assertInvalid("");
        assertInvalid("abc");
        assertInvalid("0");
        assertInvalid("-1");
    }

    private static void assertInvalid(String value) {
        try {
            RequisitionOwnerDetailServlet.parseFormId(value);
            fail("Expected invalid form id: " + value);
        } catch (IllegalArgumentException expected) {
            // Expected.
        }
    }
}
