package com.slf.controller;

import junit.framework.TestCase;

public class ThirdPartyItDirectorReviewServletTest extends TestCase {

    public void testItDirectorPositionAliasesAreAccepted() {
        assertTrue(ThirdPartyItDirectorInboxServlet.isItDirectorPosition("ITDirector"));
        assertTrue(ThirdPartyItDirectorInboxServlet.isItDirectorPosition(" IT Director "));
        assertFalse(ThirdPartyItDirectorInboxServlet.isItDirectorPosition("Technical"));
        assertFalse(ThirdPartyItDirectorInboxServlet.isItDirectorPosition(null));
    }

    public void testDecisionCommentIsRequired() {
        assertEquals("อนุมัติ", ThirdPartyItDirectorReviewServlet.requireComment(" อนุมัติ "));
        try {
            ThirdPartyItDirectorReviewServlet.requireComment(" ");
            fail("Expected empty comment to be rejected");
        } catch (IllegalArgumentException expected) {
            assertTrue(expected.getMessage().contains("ความเห็น"));
        }
    }
}
