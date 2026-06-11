package com.slf.controller;

import junit.framework.TestCase;

public class ThirdPartyOperatorReviewServletTest extends TestCase {

    public void testOnlyInfrastructurePositionIsAccepted() {
        assertTrue(ThirdPartyOperatorInboxServlet.isInfrastructurePosition("Infrastructure"));
        assertTrue(ThirdPartyOperatorInboxServlet.isInfrastructurePosition(" infrastructure "));
        assertFalse(ThirdPartyOperatorInboxServlet.isInfrastructurePosition("Technical"));
        assertFalse(ThirdPartyOperatorInboxServlet.isInfrastructurePosition(null));
    }

    public void testOperationDetailIsRequired() {
        assertEquals("ดำเนินการแล้ว", ThirdPartyOperatorReviewServlet.requireDetail(" ดำเนินการแล้ว "));
        try {
            ThirdPartyOperatorReviewServlet.requireDetail("");
            fail("Expected empty detail to be rejected");
        } catch (IllegalArgumentException expected) {
            assertTrue(expected.getMessage().contains("รายละเอียด"));
        }
    }
}
