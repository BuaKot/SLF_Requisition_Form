package com.slf.controller;

import junit.framework.TestCase;

public class ThirdPartyAssignedCompletionReviewServletTest extends TestCase {

    public void testDetailIsRequiredAndTrimmed() {
        assertEquals("ดำเนินการเสร็จแล้ว",
            ThirdPartyAssignedCompletionReviewServlet.requireDetail(" ดำเนินการเสร็จแล้ว "));
        try {
            ThirdPartyAssignedCompletionReviewServlet.requireDetail(" ");
            fail("Expected empty detail to be rejected");
        } catch (IllegalArgumentException expected) {
            assertTrue(expected.getMessage().contains("รายละเอียด"));
        }
    }
}
