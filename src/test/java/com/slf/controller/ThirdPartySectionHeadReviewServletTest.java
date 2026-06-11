package com.slf.controller;

import junit.framework.TestCase;

public class ThirdPartySectionHeadReviewServletTest extends TestCase {

    public void testOnlyTechnicalPositionIsAccepted() {
        assertTrue(ThirdPartySectionHeadReviewServlet.isTechnicalPosition("Technical"));
        assertTrue(ThirdPartySectionHeadReviewServlet.isTechnicalPosition(" technical "));
        assertFalse(ThirdPartySectionHeadReviewServlet.isTechnicalPosition("Infrastructure"));
        assertFalse(ThirdPartySectionHeadReviewServlet.isTechnicalPosition(null));
    }

    public void testReviewerMustBeDifferentFromOperators() {
        ThirdPartySectionHeadReviewServlet.validateReviewerAssignments(301, 301, 302);
        ThirdPartySectionHeadReviewServlet.validateReviewerAssignments(301, 302, 303);

        assertInvalidAssignments(301, 302, 301);
        assertInvalidAssignments(301, 302, 302);
    }

    private static void assertInvalidAssignments(int grantOperator, int revokeOperator, int reviewer) {
        try {
            ThirdPartySectionHeadReviewServlet.validateReviewerAssignments(
                grantOperator, revokeOperator, reviewer);
            fail("Expected invalid reviewer assignment");
        } catch (IllegalArgumentException expected) {
            assertTrue(expected.getMessage().contains("ผู้ตรวจทาน"));
        }
    }
}
