package com.slf.controller;

import junit.framework.TestCase;

public class ThirdPartyFinalStageReviewServletTest extends TestCase {

    public void testSummaryReportIsRequiredAndTrimmed() {
        assertEquals("สรุปผลเรียบร้อย",
            ThirdPartyFinalStageReviewServlet.requireReport(" สรุปผลเรียบร้อย "));
        try {
            ThirdPartyFinalStageReviewServlet.requireReport("");
            fail("Expected empty report to be rejected");
        } catch (IllegalArgumentException expected) {
            assertTrue(expected.getMessage().contains("รายงานสรุป"));
        }
    }
}
