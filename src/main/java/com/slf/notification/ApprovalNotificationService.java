package com.slf.notification;

import com.slf.dao.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ApprovalNotificationService {
    private final ApprovalNotificationRecipientResolver recipientResolver;
    private final GmailNotificationService mailService;
    private final EmailNotificationLogDAO logDAO;

    public ApprovalNotificationService() {
        this(new ApprovalNotificationRecipientResolver(), new GmailNotificationService(), new EmailNotificationLogDAO());
    }

    ApprovalNotificationService(ApprovalNotificationRecipientResolver recipientResolver,
                                GmailNotificationService mailService,
                                EmailNotificationLogDAO logDAO) {
        this.recipientResolver = recipientResolver;
        this.mailService = mailService;
        this.logDAO = logDAO;
    }

    public void notifyFormSubmitted(int formId, int requesterEmpId, String requestTopic) {
        try {
            ApprovalNotificationRecipient recipient = recipientResolver.resolveInitialDirector(formId);
            String subject = buildPendingStepSubject(formId, 0);
            String body = buildPendingStepBody(formId, requesterEmpId, requestTopic, 0, null);
            sendAndLog(formId, null, "FORM_SUBMITTED", recipient, subject, body, requesterEmpId,
                "FORM_SUBMITTED:" + formId);
        } catch (Exception e) {
            System.err.println("Unable to send submitted approval notification: " + e.getMessage());
        }
    }

    public void notifyApprovalTransition(int formId, int reviewerEmpId, int newStep,
                                         Integer assignedDeveloperId, String comment) {
        try {
            FormSummary summary = loadFormSummary(formId);
            ApprovalNotificationRecipient recipient = recipientResolver.resolveNextApprover(
                formId,
                newStep,
                assignedDeveloperId
            );

            String eventType = eventTypeForStep(newStep);
            String subject = newStep < 0 || newStep >= 5
                ? buildApprovalResultSubject(formId, newStep)
                : buildPendingStepSubject(formId, newStep);
            String body = newStep < 0 || newStep >= 5
                ? buildApprovalResultBody(formId, summary.requesterEmpId, summary.title, newStep, comment)
                : buildPendingStepBody(formId, summary.requesterEmpId, summary.title, newStep, comment);

            sendAndLog(formId, null, eventType, recipient, subject, body, reviewerEmpId,
                eventType + ":" + formId + ":" + newStep);
        } catch (Exception e) {
            System.err.println("Unable to send approval notification: " + e.getMessage());
        }
    }

    public static String buildApprovalResultSubject(int formId, int stateStep) {
        return "[SLF] Requisition form #" + formId + " " + describeApprovalResult(stateStep);
    }

    public static String describeApprovalResult(int stateStep) {
        switch (stateStep) {
            case 1:
                return "approved by Director";
            case 2:
                return "approved by Technical";
            case 3:
                return "approved by IT Director";
            case 4:
                return "completed by Assigned Staff";
            case 5:
                return "confirmed by Requester";
            case -1:
                return "rejected by Director";
            case -2:
                return "rejected by Technical";
            case -3:
                return "rejected by IT Director";
            case -4:
                return "rejected by Assigned Staff";
            case -5:
                return "rejected by Requester";
            default:
                return "updated";
        }
    }

    public static String describePendingStep(int stateStep) {
        switch (stateStep) {
            case 0:
                return "Director";
            case 1:
                return "Technical";
            case 2:
                return "IT Director";
            case 3:
                return "Assigned Staff";
            case 4:
                return "Requester confirmation";
            case 5:
                return "Completed";
            default:
                return "Unknown";
        }
    }

    static String buildPendingStepSubject(int formId, int stateStep) {
        if (stateStep == 4) {
            return "[SLF] Requisition form #" + formId + " waiting for requester confirmation";
        }
        return "[SLF] Requisition form #" + formId + " pending " + describePendingStep(stateStep) + " approval";
    }

    private String buildPendingStepBody(int formId, int requesterEmpId, String requestTopic,
                                        int stateStep, String comment) {
        StringBuilder body = new StringBuilder();
        body.append("A requisition form is waiting for your action.").append("\n\n");
        body.append("Form ID: ").append(formId).append("\n");
        body.append("Requester EMPID: ").append(requesterEmpId).append("\n");
        appendTopic(body, requestTopic);
        body.append("Current step: ").append(describePendingStep(stateStep)).append("\n");
        appendComment(body, comment);
        body.append("\nOpen the SLF Requisition Form system to review it.");
        return body.toString();
    }

    private String buildApprovalResultBody(int formId, int requesterEmpId, String requestTopic,
                                           int stateStep, String comment) {
        StringBuilder body = new StringBuilder();
        body.append("A requisition form status was updated.").append("\n\n");
        body.append("Form ID: ").append(formId).append("\n");
        body.append("Requester EMPID: ").append(requesterEmpId).append("\n");
        appendTopic(body, requestTopic);
        body.append("Result: ").append(describeApprovalResult(stateStep)).append("\n");
        appendComment(body, comment);
        body.append("\nOpen the SLF Requisition Form system to view details.");
        return body.toString();
    }

    private void sendAndLog(int formId, Integer approvalId, String eventType,
                            ApprovalNotificationRecipient recipient, String subject, String body,
                            int createdBy, String dedupeKey) throws SQLException {
        if (recipient == null || !NotificationRecipientResolver.hasEmailShape(recipient.getEmail())) {
            System.out.println("Gmail notification skipped: no enabled recipient email for " + eventType + " form " + formId);
            return;
        }

        long logId = logDAO.createPendingLog(
            formId,
            approvalId,
            eventType,
            recipient.getEmpId(),
            recipient.getEmail(),
            subject,
            body,
            Integer.valueOf(createdBy),
            dedupeKey + ":" + recipient.getEmail()
        );

        NotificationSendResult result = mailService.sendEmailNotification(subject, body, recipient.getEmail());
        if (result.isSent()) {
            logDAO.markSent(logId);
        } else {
            logDAO.markFailed(logId, result.getErrorMessage());
        }
    }

    private FormSummary loadFormSummary(int formId) throws SQLException {
        String sql = "SELECT EMPID, TITLEFORM FROM REQUISITIONFORM WHERE FORMID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, formId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new FormSummary(rs.getInt("EMPID"), rs.getString("TITLEFORM"));
                }
            }
        }
        return new FormSummary(0, null);
    }

    private static String eventTypeForStep(int newStep) {
        if (newStep < 0) {
            return "APPROVAL_REJECTED";
        }
        if (newStep == 4) {
            return "WORK_COMPLETED";
        }
        if (newStep >= 5) {
            return "REQUESTER_CONFIRMED";
        }
        return "APPROVAL_NEXT_STEP";
    }

    private static void appendTopic(StringBuilder body, String requestTopic) {
        String topic = GmailNotificationConfig.trimToNull(requestTopic);
        if (topic != null) {
            body.append("Topic: ").append(topic).append("\n");
        }
    }

    private static void appendComment(StringBuilder body, String comment) {
        String trimmed = GmailNotificationConfig.trimToNull(comment);
        if (trimmed != null) {
            body.append("Comment: ").append(trimmed).append("\n");
        }
    }

    private static class FormSummary {
        private final int requesterEmpId;
        private final String title;

        private FormSummary(int requesterEmpId, String title) {
            this.requesterEmpId = requesterEmpId;
            this.title = title;
        }
    }
}
