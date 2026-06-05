package com.slf.notification;

public class NotificationSendResult {
    private final boolean sent;
    private final String errorMessage;

    private NotificationSendResult(boolean sent, String errorMessage) {
        this.sent = sent;
        this.errorMessage = errorMessage;
    }

    public static NotificationSendResult sent() {
        return new NotificationSendResult(true, null);
    }

    public static NotificationSendResult skipped(String reason) {
        return new NotificationSendResult(false, reason);
    }

    public static NotificationSendResult failed(String errorMessage) {
        return new NotificationSendResult(false, errorMessage);
    }

    public boolean isSent() {
        return sent;
    }

    public String getErrorMessage() {
        return errorMessage;
    }
}
