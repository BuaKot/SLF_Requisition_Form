package com.slf.notification;

import com.slf.model.EmailNotificationLogEntry;
import java.sql.Timestamp;

public class EmailNotificationDispatcher {
    static final int MAX_ATTEMPTS = 5;
    private static final int BATCH_SIZE = 20;

    private final EmailNotificationLogDAO logDAO;
    private final GmailNotificationService mailService;

    public EmailNotificationDispatcher() {
        this(new EmailNotificationLogDAO(), new GmailNotificationService());
    }

    EmailNotificationDispatcher(EmailNotificationLogDAO logDAO, GmailNotificationService mailService) {
        this.logDAO = logDAO;
        this.mailService = mailService;
    }

    public void dispatchBatch() {
        for (int index = 0; index < BATCH_SIZE; index++) {
            try {
                Long logId = logDAO.findNextDueId(MAX_ATTEMPTS);
                if (logId == null || !logDAO.claimForSending(logId.longValue(), MAX_ATTEMPTS)) {
                    return;
                }

                EmailNotificationLogEntry entry = logDAO.findById(logId.longValue());
                if (entry == null) {
                    continue;
                }

                NotificationSendResult result = mailService.sendEmailNotification(
                    entry.getSubject(), entry.getBody(), entry.getRecipientEmail()
                );
                if (result.isSent()) {
                    logDAO.markSent(entry.getEmailLogId());
                } else if (result.isSkipped()) {
                    logDAO.markSkipped(entry.getEmailLogId(), result.getErrorMessage());
                } else {
                    Timestamp nextAttempt = entry.getSendAttempt() >= MAX_ATTEMPTS
                        ? null
                        : new Timestamp(System.currentTimeMillis() + retryDelayMillis(entry.getSendAttempt()));
                    logDAO.markFailed(entry.getEmailLogId(), result.getErrorMessage(), nextAttempt);
                }
            } catch (Exception e) {
                System.err.println("Email notification dispatcher failed: " + e.getMessage());
                return;
            }
        }
    }

    static long retryDelayMillis(int sendAttempt) {
        int exponent = Math.max(0, Math.min(6, sendAttempt - 1));
        return Math.min(3_600_000L, 60_000L * (1L << exponent));
    }
}
