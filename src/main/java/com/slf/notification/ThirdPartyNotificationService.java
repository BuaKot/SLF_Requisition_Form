package com.slf.notification;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ThirdPartyNotificationService {
    static final String FORM_TYPE = "THIRD_PARTY";
    private static final int THIRD_PARTY_FORM_ID_PLACEHOLDER = 0;

    private final ThirdPartyNotificationRecipientResolver recipientResolver;
    private final EmailNotificationLogDAO logDAO;

    public ThirdPartyNotificationService() {
        this(new ThirdPartyNotificationRecipientResolver(), new EmailNotificationLogDAO());
    }

    ThirdPartyNotificationService(ThirdPartyNotificationRecipientResolver recipientResolver,
                                  EmailNotificationLogDAO logDAO) {
        this.recipientResolver = recipientResolver;
        this.logDAO = logDAO;
    }

    public void notifyExternalSubmitted(long requestId, Integer createdBy) {
        List<RecipientTarget> targets = new ArrayList<RecipientTarget>();
        try {
            for (ApprovalNotificationRecipient recipient : recipientResolver.resolveTechnicalRecipients()) {
                targets.add(new RecipientTarget("TECHNICAL", recipient));
            }
            targets.add(new RecipientTarget("OWNER", recipientResolver.resolveInternalOwner(requestId)));
        } catch (Exception e) {
            logEnqueueFailure("third-party external submitted recipients", requestId, e);
            return;
        }
        enqueueMany(requestId, "THIRD_PARTY_SUBMITTED", targets,
            "[SLF] Third-party request #" + requestId + " submitted",
            "A third-party access request was submitted and is waiting for Technical review.",
            createdBy, null);
    }

    public void notifySectionHeadSubmitted(long requestId, int actorEmpId, String comment) {
        enqueueManyFromResolver(requestId, "THIRD_PARTY_SECTION_HEAD_SUBMITTED", "IT_DIRECTOR",
            "[SLF] Third-party request #" + requestId + " waiting for IT Director",
            "A third-party access request was reviewed by Technical and is waiting for IT Director decision.",
            Integer.valueOf(actorEmpId), comment, new RecipientSupplier() {
                public List<ApprovalNotificationRecipient> get() throws SQLException {
                    return recipientResolver.resolveItDirectorRecipients();
                }
            });
    }

    public void notifyItDirectorDecision(long requestId, int actorEmpId, boolean approved, String comment) {
        if (approved) {
            enqueueManyFromResolver(requestId, "THIRD_PARTY_IT_DIRECTOR_APPROVED", "GRANT_OPERATOR",
                "[SLF] Third-party request #" + requestId + " approved for operation",
                "A third-party access request was approved by IT Director and is waiting for access setup.",
                Integer.valueOf(actorEmpId), comment, new RecipientSupplier() {
                    public List<ApprovalNotificationRecipient> get() throws SQLException {
                        return recipientResolver.resolveAssignmentRecipients(requestId, "GRANT_OPERATOR");
                    }
                });
            return;
        }

        List<RecipientTarget> targets = new ArrayList<RecipientTarget>();
        try {
            targets.add(new RecipientTarget("EXTERNAL", recipientResolver.resolveExternalRequester(requestId)));
            targets.add(new RecipientTarget("OWNER", recipientResolver.resolveInternalOwner(requestId)));
        } catch (Exception e) {
            logEnqueueFailure("third-party IT Director rejection recipients", requestId, e);
            return;
        }
        enqueueMany(requestId, "THIRD_PARTY_IT_DIRECTOR_REJECTED", targets,
            "[SLF] Third-party request #" + requestId + " rejected",
            "A third-party access request was rejected by IT Director.",
            Integer.valueOf(actorEmpId), comment);
    }

    public void notifyOperatorCompleted(long requestId, int actorEmpId, String detail, String acceptanceLink) {
        String body = "Access setup for the third-party request was completed."
            + "\n\nAcceptance link: " + nullToDash(acceptanceLink);
        enqueueOneFromResolver(requestId, "THIRD_PARTY_OPERATOR_COMPLETED", "EXTERNAL",
            "[SLF] Third-party request #" + requestId + " waiting for acceptance",
            body, Integer.valueOf(actorEmpId), detail, new SingleRecipientSupplier() {
                public ApprovalNotificationRecipient get() throws SQLException {
                    return recipientResolver.resolveExternalRequester(requestId);
                }
            });
    }

    public void notifyExternalAccepted(long requestId) {
        notifyRevocationNeeded(requestId, "THIRD_PARTY_EXTERNAL_ACCEPTED",
            "External requester accepted the completed work. The request is waiting for access revocation.");
    }

    public void notifyExternalAcceptanceExpired(long requestId) {
        notifyRevocationNeeded(requestId, "THIRD_PARTY_ACCEPTANCE_EXPIRED",
            "External acceptance period expired. The request is waiting for access revocation.");
    }

    public void notifyRevokerCompleted(long requestId, int actorEmpId, String detail) {
        enqueueManyFromResolver(requestId, "THIRD_PARTY_REVOKER_COMPLETED", "REVOKE_REVIEWER",
            "[SLF] Third-party request #" + requestId + " waiting for revoke review",
            "Access revocation was completed and is waiting for reviewer verification.",
            Integer.valueOf(actorEmpId), detail, new RecipientSupplier() {
                public List<ApprovalNotificationRecipient> get() throws SQLException {
                    return recipientResolver.resolveAssignmentRecipients(requestId, "REVOKE_REVIEWER");
                }
            });
    }

    public void notifyRevokeReviewerCompleted(long requestId, int actorEmpId, String detail) {
        enqueueManyFromResolver(requestId, "THIRD_PARTY_REVOKE_REVIEWED", "TECHNICAL",
            "[SLF] Third-party request #" + requestId + " waiting for Technical report",
            "Access revocation was reviewed and is waiting for Technical summary report.",
            Integer.valueOf(actorEmpId), detail, new RecipientSupplier() {
                public List<ApprovalNotificationRecipient> get() throws SQLException {
                    return recipientResolver.resolveTechnicalRecipients();
                }
            });
    }

    public void notifySectionHeadReported(long requestId, int actorEmpId, String report) {
        enqueueManyFromResolver(requestId, "THIRD_PARTY_SECTION_HEAD_REPORTED", "IT_DIRECTOR",
            "[SLF] Third-party request #" + requestId + " waiting for final certification",
            "Technical submitted the summary report and the request is waiting for final certification.",
            Integer.valueOf(actorEmpId), report, new RecipientSupplier() {
                public List<ApprovalNotificationRecipient> get() throws SQLException {
                    return recipientResolver.resolveItDirectorRecipients();
                }
            });
    }

    public void notifyFinalCertified(long requestId, int actorEmpId) {
        List<RecipientTarget> targets = new ArrayList<RecipientTarget>();
        try {
            targets.add(new RecipientTarget("EXTERNAL", recipientResolver.resolveExternalRequester(requestId)));
            targets.add(new RecipientTarget("OWNER", recipientResolver.resolveInternalOwner(requestId)));
        } catch (Exception e) {
            logEnqueueFailure("third-party final certification recipients", requestId, e);
            return;
        }
        enqueueMany(requestId, "THIRD_PARTY_COMPLETED", targets,
            "[SLF] Third-party request #" + requestId + " completed",
            "A third-party access request workflow was completed.",
            Integer.valueOf(actorEmpId), null);
    }

    private void notifyRevocationNeeded(final long requestId, String eventType, String bodyLead) {
        enqueueManyFromResolver(requestId, eventType, "REVOKE_OPERATOR",
            "[SLF] Third-party request #" + requestId + " waiting for revocation",
            bodyLead, null, null, new RecipientSupplier() {
                public List<ApprovalNotificationRecipient> get() throws SQLException {
                    return recipientResolver.resolveAssignmentRecipients(requestId, "REVOKE_OPERATOR");
                }
            });
    }

    private void enqueueManyFromResolver(long requestId, String eventType, String recipientRole,
                                         String subject, String bodyLead, Integer createdBy,
                                         String comment, RecipientSupplier supplier) {
        List<RecipientTarget> targets = new ArrayList<RecipientTarget>();
        try {
            for (ApprovalNotificationRecipient recipient : supplier.get()) {
                targets.add(new RecipientTarget(recipientRole, recipient));
            }
        } catch (Exception e) {
            logEnqueueFailure(eventType + " recipients", requestId, e);
            return;
        }
        enqueueMany(requestId, eventType, targets, subject, bodyLead, createdBy, comment);
    }

    private void enqueueOneFromResolver(long requestId, String eventType, String recipientRole,
                                        String subject, String bodyLead, Integer createdBy,
                                        String comment, SingleRecipientSupplier supplier) {
        try {
            enqueueMany(requestId, eventType,
                java.util.Collections.singletonList(new RecipientTarget(recipientRole, supplier.get())),
                subject, bodyLead, createdBy, comment);
        } catch (Exception e) {
            logEnqueueFailure(eventType + " recipient", requestId, e);
        }
    }

    private void enqueueMany(long requestId, String eventType, List<RecipientTarget> targets,
                             String subject, String bodyLead, Integer createdBy, String comment) {
        if (targets == null) return;
        java.util.Set<String> seenEmails = new java.util.HashSet<String>();
        for (RecipientTarget target : targets) {
            ApprovalNotificationRecipient recipient = target == null ? null : target.recipient;
            if (recipient == null || !NotificationRecipientResolver.hasEmailShape(recipient.getEmail())) {
                continue;
            }
            String recipientEmail = recipient.getEmail().trim();
            String dedupeEmail = recipientEmail.toLowerCase(java.util.Locale.ROOT);
            if (!seenEmails.add(dedupeEmail)) {
                continue;
            }
            try {
                String body = buildBody(requestId, bodyLead, comment);
                logDAO.enqueueIfAbsent(
                    FORM_TYPE,
                    Long.valueOf(requestId),
                    THIRD_PARTY_FORM_ID_PLACEHOLDER,
                    null,
                    eventType,
                    recipient.getEmpId(),
                    recipientEmail,
                    subject,
                    body,
                    createdBy,
                    FORM_TYPE + ":" + eventType + ":" + target.role + ":" + requestId + ":" + recipientEmail
                );
            } catch (Exception e) {
                logEnqueueFailure(eventType + " notification", requestId, e);
            }
        }
    }

    private static String buildBody(long requestId, String bodyLead, String comment) {
        return EmailContentBuilder.buildThirdPartyBody(requestId, bodyLead, comment, null);
    }

    private static String nullToDash(String value) {
        String trimmed = GmailNotificationConfig.trimToNull(value);
        return trimmed == null ? "-" : trimmed;
    }

    private static void logEnqueueFailure(String notificationType, long requestId, Exception exception) {
        System.err.println(
            "Unable to enqueue " + notificationType + " notification for third-party request " + requestId
                + ": " + exception.getMessage()
        );
    }

    private interface RecipientSupplier {
        List<ApprovalNotificationRecipient> get() throws SQLException;
    }

    private interface SingleRecipientSupplier {
        ApprovalNotificationRecipient get() throws SQLException;
    }

    private static class RecipientTarget {
        private final String role;
        private final ApprovalNotificationRecipient recipient;

        RecipientTarget(String role, ApprovalNotificationRecipient recipient) {
            this.role = role;
            this.recipient = recipient;
        }
    }
}
