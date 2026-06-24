package com.slf.notification;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import junit.framework.TestCase;

public class ThirdPartyNotificationServiceTest extends TestCase {

    public void testExternalSubmissionEnqueuesTechnicalAndOwnerNotifications() {
        RecordingResolver resolver = new RecordingResolver();
        RecordingLogDAO logDAO = new RecordingLogDAO();
        ThirdPartyNotificationService service = new ThirdPartyNotificationService(resolver, logDAO);

        service.notifyExternalSubmitted(77L, null);

        assertEquals(3, logDAO.records.size());
        assertEquals("technical1@example.com", logDAO.records.get(0).recipientEmail);
        assertEquals("technical2@example.com", logDAO.records.get(1).recipientEmail);
        assertEquals("owner@example.com", logDAO.records.get(2).recipientEmail);
        assertEquals("THIRD_PARTY", logDAO.records.get(0).formType);
        assertEquals(Long.valueOf(77L), logDAO.records.get(0).referenceId);
        assertEquals("THIRD_PARTY_SUBMITTED", logDAO.records.get(0).eventType);
        assertTrue(logDAO.records.get(0).dedupeKey.contains("THIRD_PARTY_SUBMITTED:TECHNICAL:77"));
    }

    public void testOperatorCompletionSendsAcceptanceLinkToExternalRequester() {
        RecordingResolver resolver = new RecordingResolver();
        RecordingLogDAO logDAO = new RecordingLogDAO();
        ThirdPartyNotificationService service = new ThirdPartyNotificationService(resolver, logDAO);

        service.notifyOperatorCompleted(77L, 3001, "user created", "https://example.test/thirdparty/accept?token=abc-token");

        assertEquals(1, logDAO.records.size());
        Record record = logDAO.records.get(0);
        assertEquals("external@example.com", record.recipientEmail);
        assertEquals("THIRD_PARTY_OPERATOR_COMPLETED", record.eventType);
        assertTrue(record.body.contains("https://example.test/thirdparty/accept?token=abc-token"));
        assertTrue(record.subject.contains("#77"));
        assertEquals(Integer.valueOf(3001), record.createdBy);
    }

    public void testItDirectorApprovalNotifiesAssignedGrantOperator() {
        RecordingResolver resolver = new RecordingResolver();
        RecordingLogDAO logDAO = new RecordingLogDAO();
        ThirdPartyNotificationService service = new ThirdPartyNotificationService(resolver, logDAO);

        service.notifyItDirectorDecision(77L, 2001, true, "approved");

        assertEquals(1, logDAO.records.size());
        assertEquals("grant@example.com", logDAO.records.get(0).recipientEmail);
        assertEquals("THIRD_PARTY_IT_DIRECTOR_APPROVED", logDAO.records.get(0).eventType);
    }

    private static class RecordingResolver extends ThirdPartyNotificationRecipientResolver {
        @Override
        public List<ApprovalNotificationRecipient> resolveTechnicalRecipients() {
            return Arrays.asList(
                new ApprovalNotificationRecipient(Integer.valueOf(1001), "technical1@example.com", "Technical One"),
                new ApprovalNotificationRecipient(Integer.valueOf(1002), "technical2@example.com", "Technical Two")
            );
        }

        @Override
        public List<ApprovalNotificationRecipient> resolveItDirectorRecipients() {
            return Arrays.asList(
                new ApprovalNotificationRecipient(Integer.valueOf(2001), "itdirector@example.com", "IT Director")
            );
        }

        @Override
        public List<ApprovalNotificationRecipient> resolveAssignmentRecipients(long requestId, String... roles) {
            if (roles.length == 1 && "GRANT_OPERATOR".equals(roles[0])) {
                return Arrays.asList(
                    new ApprovalNotificationRecipient(Integer.valueOf(3001), "grant@example.com", "Grant Operator")
                );
            }
            return new ArrayList<ApprovalNotificationRecipient>();
        }

        @Override
        public ApprovalNotificationRecipient resolveInternalOwner(long requestId) {
            return new ApprovalNotificationRecipient(Integer.valueOf(4001), "owner@example.com", "Owner");
        }

        @Override
        public ApprovalNotificationRecipient resolveExternalRequester(long requestId) {
            return new ApprovalNotificationRecipient(null, "external@example.com", "External Requester");
        }
    }

    private static class RecordingLogDAO extends EmailNotificationLogDAO {
        private final List<Record> records = new ArrayList<Record>();

        @Override
        public boolean enqueueIfAbsent(String formType, Long referenceId, int formId, Integer approvalId,
                                       String eventType, Integer recipientEmpId, String recipientEmail,
                                       String subject, String body, Integer createdBy, String dedupeKey)
                throws SQLException {
            records.add(new Record(formType, referenceId, eventType, recipientEmail, subject, body,
                createdBy, dedupeKey));
            return true;
        }
    }

    private static class Record {
        private final String formType;
        private final Long referenceId;
        private final String eventType;
        private final String recipientEmail;
        private final String subject;
        private final String body;
        private final Integer createdBy;
        private final String dedupeKey;

        Record(String formType, Long referenceId, String eventType, String recipientEmail,
               String subject, String body, Integer createdBy, String dedupeKey) {
            this.formType = formType;
            this.referenceId = referenceId;
            this.eventType = eventType;
            this.recipientEmail = recipientEmail;
            this.subject = subject;
            this.body = body;
            this.createdBy = createdBy;
            this.dedupeKey = dedupeKey;
        }
    }
}
