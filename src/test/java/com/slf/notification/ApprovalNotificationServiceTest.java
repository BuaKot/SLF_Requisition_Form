package com.slf.notification;

import junit.framework.TestCase;

public class ApprovalNotificationServiceTest extends TestCase {

    public void testActionTextUsesApprovedAndRejectedStates() {
        assertEquals("approved by Director", ApprovalNotificationService.describeApprovalResult(1));
        assertEquals("approved by Technical", ApprovalNotificationService.describeApprovalResult(2));
        assertEquals("approved by IT Director", ApprovalNotificationService.describeApprovalResult(3));
        assertEquals("completed by Assigned Staff", ApprovalNotificationService.describeApprovalResult(4));
        assertEquals("confirmed by Requester", ApprovalNotificationService.describeApprovalResult(5));

        assertEquals("rejected by Director", ApprovalNotificationService.describeApprovalResult(-1));
        assertEquals("rejected by Technical", ApprovalNotificationService.describeApprovalResult(-2));
        assertEquals("rejected by IT Director", ApprovalNotificationService.describeApprovalResult(-3));
        assertEquals("rejected by Assigned Staff", ApprovalNotificationService.describeApprovalResult(-4));
        assertEquals("rejected by Requester", ApprovalNotificationService.describeApprovalResult(-5));
    }

    public void testNextStepTextMatchesApprovalFlow() {
        assertEquals("Director", ApprovalNotificationService.describePendingStep(0));
        assertEquals("Technical", ApprovalNotificationService.describePendingStep(1));
        assertEquals("IT Director", ApprovalNotificationService.describePendingStep(2));
        assertEquals("Assigned Staff", ApprovalNotificationService.describePendingStep(3));
        assertEquals("Requester confirmation", ApprovalNotificationService.describePendingStep(4));
        assertEquals("Completed", ApprovalNotificationService.describePendingStep(5));
    }

    public void testBuildsRequesterResultSubject() {
        assertEquals(
            "[SLF] Requisition form #42 approved by IT Director",
            ApprovalNotificationService.buildApprovalResultSubject(42, 3)
        );
        assertEquals(
            "[SLF] Requisition form #42 rejected by Technical",
            ApprovalNotificationService.buildApprovalResultSubject(42, -2)
        );
    }
}
