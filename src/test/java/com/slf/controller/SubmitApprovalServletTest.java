package com.slf.controller;

import junit.framework.TestCase;

public class SubmitApprovalServletTest extends TestCase {

    public void testApprovalRequestIsStaleWhenExpectedStepDiffersFromCurrentStep() {
        assertTrue(SubmitApprovalServlet.isStaleApprovalRequest(2, Integer.valueOf(1)));
    }

    public void testApprovalRequestIsCurrentWhenExpectedStepMatchesCurrentStep() {
        assertFalse(SubmitApprovalServlet.isStaleApprovalRequest(1, Integer.valueOf(1)));
    }

    public void testMissingExpectedStepIsTreatedAsStale() {
        assertTrue(SubmitApprovalServlet.isStaleApprovalRequest(1, null));
    }

    public void testParsesExpectedStep() {
        assertEquals(Integer.valueOf(2), SubmitApprovalServlet.parseExpectedStep(" 2 "));
    }

    public void testAllowsDirectorApproveServletRedirect() {
        assertEquals("directorApprove", SubmitApprovalServlet.sanitizeRedirectPage("directorApprove"));
    }

    public void testReviewerMatchIgnoresExpectedWhitespace() {
        assertTrue(SubmitApprovalServlet.matchesReviewer(" 54 ", 54));
    }

    public void testReviewerDoesNotMatchDifferentEmployee() {
        assertFalse(SubmitApprovalServlet.matchesReviewer("54", 301));
    }

    public void testRequesterMatchUsesRequesterEmpId() {
        assertTrue(SubmitApprovalServlet.matchesRequester(678, 678));
        assertFalse(SubmitApprovalServlet.matchesRequester(678, 54));
    }
}
