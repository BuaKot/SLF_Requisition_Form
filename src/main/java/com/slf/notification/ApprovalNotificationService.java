package com.slf.notification;

import com.slf.dao.DBConnection;
import com.slf.model.ApprovalHistoryEntry;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class ApprovalNotificationService {
    private final ApprovalNotificationRecipientResolver recipientResolver;
    private final EmailNotificationLogDAO logDAO;

    public ApprovalNotificationService() {
        this(new ApprovalNotificationRecipientResolver(), new EmailNotificationLogDAO());
    }

    ApprovalNotificationService(ApprovalNotificationRecipientResolver recipientResolver,
                                GmailNotificationService mailService,
                                EmailNotificationLogDAO logDAO) {
        this(recipientResolver, logDAO);
    }

    ApprovalNotificationService(ApprovalNotificationRecipientResolver recipientResolver,
                                EmailNotificationLogDAO logDAO) {
        this.recipientResolver = recipientResolver;
        this.logDAO = logDAO;
    }

    public void notifyFormSubmitted(int formId, int requesterEmpId, String requestTopic) {
        List<ApprovalHistoryEntry> approvalHistory;
        try {
            approvalHistory = loadApprovalHistory(formId);
        } catch (Exception e) {
            logEnqueueFailure("submitted history load", formId, e);
            approvalHistory = new ArrayList<>();
        }

        try {
            ApprovalNotificationRecipient director = recipientResolver.resolveInitialDirector(formId);
            String directorSubject = EmailContentBuilder.buildITRequisitionSubject(formId, 0);
            String directorBody = buildEmailBody(
                formId, requestTopic, requesterEmpId, 0, null, "DIRECTOR", approvalHistory);
            sendAndLog(formId, null, "FORM_SUBMITTED", director, directorSubject, directorBody, requesterEmpId,
                "FORM_SUBMITTED:DIRECTOR:" + formId);
        } catch (Exception e) {
            logEnqueueFailure("submitted director", formId, e);
        }
        try {
            ApprovalNotificationRecipient requester = recipientResolver.resolveRequester(formId);
            String requesterSubject = EmailContentBuilder.buildITRequisitionSubject(formId, 0);
            String requesterBody = buildEmailBody(
                formId, requestTopic, requesterEmpId, 0, null, "REQUESTER", approvalHistory);
            sendAndLog(formId, null, "FORM_SUBMITTED", requester, requesterSubject, requesterBody, requesterEmpId,
                "FORM_SUBMITTED:REQUESTER:" + formId);
        } catch (Exception e) {
            logEnqueueFailure("submitted requester", formId, e);
        }
    }

    public void notifyApprovalTransition(int formId, int reviewerEmpId, int newStep,
                                         Integer assignedDeveloperId, String comment) {
        FormSummary summary;
        try {
            summary = loadFormSummary(formId);
        } catch (Exception e) {
            logEnqueueFailure("approval transition summary", formId, e);
            return;
        }

        List<ApprovalHistoryEntry> approvalHistory;
        try {
            approvalHistory = loadApprovalHistory(formId);
        } catch (Exception e) {
            logEnqueueFailure("approval transition history load", formId, e);
            approvalHistory = new ArrayList<>();
        }

        ApprovalNotificationRecipient recipient = null;
        try {
            recipient = recipientResolver.resolveNextApprover(
                formId,
                newStep,
                assignedDeveloperId
            );

            String eventType = eventTypeForStep(newStep);
            String recipientRole = resolveRecipientRole(newStep);
            String subject = EmailContentBuilder.buildITRequisitionSubject(formId, newStep);
            String body = buildEmailBody(
                formId, summary.title, summary.requesterEmpId,
                newStep, comment, recipientRole, approvalHistory);

            sendAndLog(formId, null, eventType, recipient, subject, body, reviewerEmpId,
                eventType + ":" + formId + ":" + newStep);
        } catch (Exception e) {
            logEnqueueFailure("approval transition recipient", formId, e);
        }

        if (shouldNotifyRequesterSeparately(newStep, recipient, summary.requesterEmpId)) {
            try {
                String eventType = eventTypeForStep(newStep);
                String requesterRole = "REQUESTER";
                String subject = EmailContentBuilder.buildITRequisitionSubject(formId, newStep);
                String body = buildEmailBody(
                    formId, summary.title, summary.requesterEmpId,
                    newStep, comment, requesterRole, approvalHistory);
                ApprovalNotificationRecipient requester = recipientResolver.resolveRequester(formId);
                sendAndLog(formId, null, eventType, requester, subject, body, reviewerEmpId,
                    eventType + ":REQUESTER:" + formId + ":" + newStep);
            } catch (Exception e) {
                logEnqueueFailure("approval transition requester", formId, e);
            }
        }
    }

    /**
     * Loads approval history from APPROVALINFO for the given form.
     * Returns completed (non-negative) and rejected (negative) rows.
     * Package-private to allow test subclasses to override.
     */
    List<ApprovalHistoryEntry> loadApprovalHistory(int formId) throws SQLException {
        String sql =
            "SELECT a.STATE_STEP, a.REVIEWER_EMPID, a.IT_COMMENT, a.APPROVED_DATE, e.EMPNAME " +
            "FROM APPROVALINFO a " +
            "LEFT JOIN EMPLOYEE e ON e.EMPID = a.REVIEWER_EMPID " +
            "WHERE a.FORMID = ? " +
            "ORDER BY a.APPROVALID ASC";
        List<ApprovalHistoryEntry> history = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, formId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int stateStep = rs.getInt("STATE_STEP");
                    Integer reviewerEmpId = rs.getObject("REVIEWER_EMPID") != null
                        ? Integer.valueOf(rs.getInt("REVIEWER_EMPID")) : null;
                    String reviewerName = rs.getString("EMPNAME");
                    String comment = rs.getString("IT_COMMENT");
                    Timestamp approvedDate = rs.getTimestamp("APPROVED_DATE");
                    String actionLabel = buildActionLabel(stateStep);
                    history.add(new ApprovalHistoryEntry(
                        stateStep, reviewerEmpId, reviewerName, comment, approvedDate, actionLabel));
                }
            }
        }
        return history;
    }

    /**
     * Builds a human-readable action label for an APPROVALINFO state step.
     */
    private static String buildActionLabel(int stateStep) {
        switch (stateStep) {
            case 0:
                return "ส่งคำขอแล้ว (รอ Director)";
            case 1:
                return "Director อนุมัติแล้ว";
            case 2:
                return "Technical อนุมัติแล้ว";
            case 3:
                return "IT Director อนุมัติแล้ว";
            case 4:
                return "Technician ดำเนินการแล้ว";
            case 5:
                return "Requestor ยืนยันรับงานแล้ว";
            case -1:
                return "ถูกปฏิเสธโดย Director";
            case -2:
                return "ถูกปฏิเสธโดย Technical";
            case -3:
                return "ถูกปฏิเสธโดย IT Director";
            case -4:
                return "ถูกปฏิเสธโดย Technician";
            case -5:
                return "ถูกปฏิเสธโดย Requestor";
            default:
                return "มีการเปลี่ยนแปลง (สถานะ: " + stateStep + ")";
        }
    }

    /**
     * Maps a state step to a recipient role string understood by EmailContentBuilder.
     */
    private static String resolveRecipientRole(int stateStep) {
        if (stateStep < 0) {
            return "REQUESTER";
        }
        if (stateStep >= 5) {
            return "REQUESTER";
        }
        switch (stateStep) {
            case 0:
                return "DIRECTOR";
            case 1:
                return "TECHNICAL";
            case 2:
                return "IT_DIRECTOR";
            case 3:
                return "TECHNICIAN";
            case 4:
                return "REQUESTER";
            default:
                return null;
        }
    }

    // ---------------------------------------------------------------
    //  Legacy static methods (kept for backward compatibility)
    // ---------------------------------------------------------------

    /**
     * Legacy method kept for test compatibility.
     * @deprecated Use {@link EmailContentBuilder#buildITRequisitionSubject(int, int)} instead.
     */
    @Deprecated
    public static String buildApprovalResultSubject(int formId, int stateStep) {
        return EmailContentBuilder.buildITRequisitionSubject(formId, stateStep);
    }

    /**
     * Legacy method kept for test compatibility.
     * @deprecated Use {@link EmailContentBuilder#resolveWorkflowStepLabel(int)} instead.
     */
    @Deprecated
    public static String describeApprovalResult(int stateStep) {
        // Keep original English text for test compatibility
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

    /**
     * Legacy method kept for test compatibility.
     * @deprecated Use {@link EmailContentBuilder#resolveNextActorLabel(int)} instead.
     */
    @Deprecated
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

    /**
     * Legacy method kept for backward compatibility.
     * @deprecated Use {@link EmailContentBuilder#buildITRequisitionSubject(int, int)} instead.
     */
    @Deprecated
    static String buildPendingStepSubject(int formId, int stateStep) {
        return EmailContentBuilder.buildITRequisitionSubject(formId, stateStep);
    }

    /**
     * Legacy method kept for backward compatibility.
     */
    static String buildSubmittedRequesterSubject(int formId) {
        return EmailContentBuilder.buildITRequisitionSubject(formId, 0);
    }

    // ---------------------------------------------------------------
    //  Private body builders (delegate to EmailContentBuilder)
    // ---------------------------------------------------------------

    private String buildSubmittedRequesterBody(int formId, int requesterEmpId, String requestTopic) {
        return buildEmailBody(formId, requestTopic, requesterEmpId, 0, null, "REQUESTER", new ArrayList<>());
    }

    private String buildPendingStepBody(int formId, int requesterEmpId, String requestTopic,
                                        int stateStep, String comment) {
        String role = resolveRecipientRole(stateStep);
        List<ApprovalHistoryEntry> history;
        try {
            history = loadApprovalHistory(formId);
        } catch (Exception e) {
            history = new ArrayList<>();
        }
        return buildEmailBody(formId, requestTopic, requesterEmpId, stateStep, comment, role, history);
    }

    private String buildApprovalResultBody(int formId, int requesterEmpId, String requestTopic,
                                           int stateStep, String comment) {
        String role = stateStep < 0 || stateStep >= 5 ? "REQUESTER" : resolveRecipientRole(stateStep);
        List<ApprovalHistoryEntry> history;
        try {
            history = loadApprovalHistory(formId);
        } catch (Exception e) {
            history = new ArrayList<>();
        }
        return buildEmailBody(formId, requestTopic, requesterEmpId, stateStep, comment, role, history);
    }

    /**
     * Builds email body trying HTML first, falling back to plain text on failure.
     */
    private String buildEmailBody(int formId, String title, int requesterEmpId,
                                  int stateStep, String comment, String role,
                                  List<ApprovalHistoryEntry> history) {
        try {
            String appBaseUrl = getAppBaseUrl();
            return HtmlEmailRenderer.renderITRequisitionEmail(
                formId, title, requesterEmpId, stateStep, comment, role, history, appBaseUrl);
        } catch (Exception e) {
            // Fallback to plain text
            return EmailContentBuilder.buildITRequisitionBody(
                formId, title, requesterEmpId, stateStep, comment, role, history);
        }
    }

    /**
     * Resolves the application base URL from mail config.
     */
    private String getAppBaseUrl() {
        try {
            GmailNotificationConfig config = GmailNotificationConfig.fromEnvironment();
            return config.getAppBaseUrl();
        } catch (Exception e) {
            return null;
        }
    }

    private void sendAndLog(int formId, Integer approvalId, String eventType,
                            ApprovalNotificationRecipient recipient, String subject, String body,
                            int createdBy, String dedupeKey) throws SQLException {
        if (recipient == null || !NotificationRecipientResolver.hasEmailShape(recipient.getEmail())) {
            System.out.println("Gmail notification skipped: no enabled recipient email for " + eventType + " form " + formId);
            return;
        }

        logDAO.enqueueIfAbsent(
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

    private static boolean shouldNotifyRequesterSeparately(int newStep,
                                                           ApprovalNotificationRecipient recipient,
                                                           int requesterEmpId) {
        if (newStep <= 0 || newStep >= 4 || requesterEmpId <= 0) {
            return false;
        }
        return recipient == null || recipient.getEmpId() == null || recipient.getEmpId().intValue() != requesterEmpId;
    }

    private static String describeWaitingStep(int stateStep) {
        if (stateStep == 4) {
            return "waiting for Requester confirmation";
        }
        if (stateStep == 5) {
            return "Completed";
        }
        return "waiting for " + describePendingStep(stateStep) + " approve";
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

    private static void logEnqueueFailure(String notificationType, int formId, Exception exception) {
        System.err.println(
            "Unable to enqueue " + notificationType + " notification for form " + formId + ": "
                + exception.getMessage()
        );
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