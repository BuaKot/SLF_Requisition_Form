package com.slf.notification;

public class NotificationSendResult {
    public enum Status {
        SENT, SKIPPED, FAILED
    }

    private final Status status;
    private final String errorMessage;

    private NotificationSendResult(Status status, String errorMessage) {
        this.status = status;
        this.errorMessage = errorMessage;
    }

    public static NotificationSendResult sent() {
        return new NotificationSendResult(Status.SENT, null);
    }

    public static NotificationSendResult skipped(String reason) {
        return new NotificationSendResult(Status.SKIPPED, reason);
    }

    public static NotificationSendResult failed(String errorMessage) {
        return new NotificationSendResult(Status.FAILED, errorMessage);
    }

    public boolean isSent() {
        return status == Status.SENT;
    }

    public boolean isSkipped() {
        return status == Status.SKIPPED;
    }

    public Status getStatus() {
        return status;
    }

    public String getErrorMessage() {
        return errorMessage;
    }
}
