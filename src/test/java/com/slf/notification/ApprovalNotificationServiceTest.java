package com.slf.notification;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

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

    public void testSubmittedNotificationOnlyEnqueuesRecipients() {
        FakeRecipientResolver resolver = new FakeRecipientResolver();
        RecordingLogDAO logDAO = new RecordingLogDAO(false);
        ApprovalNotificationService service = new ApprovalNotificationService(resolver, null, logDAO);

        service.notifyFormSubmitted(42, 1001, "VPN access");

        assertEquals(2, logDAO.recipients.size());
        assertEquals("director@example.com", logDAO.recipients.get(0));
        assertEquals("requester@example.com", logDAO.recipients.get(1));
    }

    public void testRequesterStillEnqueuesWhenDirectorLogFails() {
        FakeRecipientResolver resolver = new FakeRecipientResolver();
        RecordingLogDAO logDAO = new RecordingLogDAO(true);
        ApprovalNotificationService service = new ApprovalNotificationService(resolver, null, logDAO);

        service.notifyFormSubmitted(42, 1001, "VPN access");

        assertEquals(1, logDAO.recipients.size());
        assertEquals("requester@example.com", logDAO.recipients.get(0));
    }

    private static class FakeRecipientResolver extends ApprovalNotificationRecipientResolver {
        @Override
        public ApprovalNotificationRecipient resolveInitialDirector(int formId) {
            return new ApprovalNotificationRecipient(Integer.valueOf(2001), "director@example.com", "Director");
        }

        @Override
        public ApprovalNotificationRecipient resolveRequester(int formId) {
            return new ApprovalNotificationRecipient(Integer.valueOf(1001), "requester@example.com", "Requester");
        }
    }

    private static class RecordingLogDAO extends EmailNotificationLogDAO {
        private final List<String> recipients = new ArrayList<>();
        private final boolean failFirst;
        private int calls;

        RecordingLogDAO(boolean failFirst) {
            this.failFirst = failFirst;
        }

        @Override
        public boolean enqueueIfAbsent(int formId, Integer approvalId, String eventType, Integer recipientEmpId,
                                       String recipientEmail, String subject, String body, Integer createdBy,
                                       String dedupeKey) throws SQLException {
            calls++;
            if (failFirst && calls == 1) {
                throw new SQLException("simulated log failure");
            }
            recipients.add(recipientEmail);
            return true;
        }
    }
}
