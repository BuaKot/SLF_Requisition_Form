package com.slf.notification;

import com.slf.model.ApprovalHistoryEntry;
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
        String subject1 = ApprovalNotificationService.buildApprovalResultSubject(42, 3);
        assertTrue("Subject should contain form ID", subject1.contains("#42"));
        assertTrue("Subject should contain Technician label for state 3", subject1.contains("Technician"));

        String subject2 = ApprovalNotificationService.buildApprovalResultSubject(42, -2);
        assertTrue("Subject should contain form ID", subject2.contains("#42"));
        assertTrue("Subject should contain rejection label", subject2.contains("ถูกปฏิเสธ"));
        assertTrue("Subject should mention Technical", subject2.contains("Technical"));
    }

    public void testSubmittedNotificationOnlyEnqueuesRecipients() {
        FakeRecipientResolver resolver = new FakeRecipientResolver();
        RecordingLogDAO logDAO = new RecordingLogDAO(false, false);
        ApprovalNotificationService service = new FakeService(resolver, null, logDAO);

        service.notifyFormSubmitted(42, 1001, "VPN access");

        assertEquals(2, logDAO.recipients.size());
        assertEquals("director@example.com", logDAO.recipients.get(0));
        assertEquals("requester@example.com", logDAO.recipients.get(1));
    }

    public void testRequesterStillEnqueuesWhenDirectorLogFails() {
        FakeRecipientResolver resolver = new FakeRecipientResolver();
        RecordingLogDAO logDAO = new RecordingLogDAO(true, false);
        ApprovalNotificationService service = new FakeService(resolver, null, logDAO);

        service.notifyFormSubmitted(42, 1001, "VPN access");

        assertEquals(1, logDAO.recipients.size());
        assertEquals("requester@example.com", logDAO.recipients.get(0));
    }

    public void testSubmittedBodyContainsFormIdAndHtmlStructure() {
        FakeRecipientResolver resolver = new FakeRecipientResolver();
        RecordingLogDAO logDAO = new RecordingLogDAO(false, false);
        FakeService service = new FakeService(resolver, null, logDAO);

        service.notifyFormSubmitted(42, 1001, "VPN access");

        assertNotNull(logDAO.lastSubject);
        assertNotNull(logDAO.lastBody);
        assertTrue("Body should start with DOCTYPE for HTML", logDAO.lastBody.startsWith("<!DOCTYPE"));
        assertTrue("Body should contain form ID", logDAO.lastBody.contains("#42"));
        assertTrue("Body should contain workflow timeline HTML class", logDAO.lastBody.contains("Workflow Timeline"));
        assertTrue("Body should contain next action section", logDAO.lastBody.contains("Next Action"));
    }

    public void testSubmittedSubjectContainsFormId() {
        FakeRecipientResolver resolver = new FakeRecipientResolver();
        RecordingLogDAO logDAO = new RecordingLogDAO(false, false);
        FakeService service = new FakeService(resolver, null, logDAO);

        service.notifyFormSubmitted(42, 1001, "VPN access");

        assertNotNull(logDAO.lastSubject);
        assertTrue("Subject should contain form ID", logDAO.lastSubject.contains("#42"));
        assertTrue("Subject should contain Thai status label", logDAO.lastSubject.contains("รอ Director อนุมัติ"));
    }

    // ---------------------------------------------------------------
    //  Helper: FakeService that overrides loadApprovalHistory
    //  to avoid real database access in tests.
    // ---------------------------------------------------------------

    private static class FakeService extends ApprovalNotificationService {
        FakeService(ApprovalNotificationRecipientResolver resolver,
                    GmailNotificationService mailService,
                    EmailNotificationLogDAO logDAO) {
            super(resolver, mailService, logDAO);
        }

        @Override
        List<ApprovalHistoryEntry> loadApprovalHistory(int formId) throws SQLException {
            return new ArrayList<>();
        }
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
        private final boolean overrideCalls;
        private int calls;
        private String lastSubject;
        private String lastBody;

        RecordingLogDAO(boolean failFirst, boolean overrideCalls) {
            this.failFirst = failFirst;
            this.overrideCalls = overrideCalls;
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
            lastSubject = subject;
            lastBody = body;
            return true;
        }
    }
}