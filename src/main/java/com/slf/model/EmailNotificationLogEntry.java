package com.slf.model;

import java.sql.Timestamp;

public class EmailNotificationLogEntry {
    private long emailLogId;
    private String formType;
    private Long referenceId;
    private int formId;
    private String eventType;
    private String recipientEmail;
    private String recipientName;
    private String recipientPosition;
    private String recipientSection;
    private String recipientPhone;
    private String subject;
    private String body;
    private String status;
    private int sendAttempt;
    private Timestamp createdAt;
    private Timestamp lastAttemptAt;
    private Timestamp nextAttemptAt;
    private Timestamp sentAt;
    private String errorMessage;

    public long getEmailLogId() { return emailLogId; }
    public void setEmailLogId(long emailLogId) { this.emailLogId = emailLogId; }
    public String getFormType() { return formType; }
    public void setFormType(String formType) { this.formType = formType; }
    public Long getReferenceId() { return referenceId; }
    public void setReferenceId(Long referenceId) { this.referenceId = referenceId; }
    public int getFormId() { return formId; }
    public void setFormId(int formId) { this.formId = formId; }
    public String getEventType() { return eventType; }
    public void setEventType(String eventType) { this.eventType = eventType; }
    public String getRecipientEmail() { return recipientEmail; }
    public void setRecipientEmail(String recipientEmail) { this.recipientEmail = recipientEmail; }
    public String getRecipientName() { return recipientName; }
    public void setRecipientName(String recipientName) { this.recipientName = recipientName; }
    public String getRecipientPosition() { return recipientPosition; }
    public void setRecipientPosition(String recipientPosition) { this.recipientPosition = recipientPosition; }
    public String getRecipientSection() { return recipientSection; }
    public void setRecipientSection(String recipientSection) { this.recipientSection = recipientSection; }
    public String getRecipientPhone() { return recipientPhone; }
    public void setRecipientPhone(String recipientPhone) { this.recipientPhone = recipientPhone; }
    public String getSubject() { return subject; }
    public void setSubject(String subject) { this.subject = subject; }
    public String getBody() { return body; }
    public void setBody(String body) { this.body = body; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public int getSendAttempt() { return sendAttempt; }
    public void setSendAttempt(int sendAttempt) { this.sendAttempt = sendAttempt; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getLastAttemptAt() { return lastAttemptAt; }
    public void setLastAttemptAt(Timestamp lastAttemptAt) { this.lastAttemptAt = lastAttemptAt; }
    public Timestamp getNextAttemptAt() { return nextAttemptAt; }
    public void setNextAttemptAt(Timestamp nextAttemptAt) { this.nextAttemptAt = nextAttemptAt; }
    public Timestamp getSentAt() { return sentAt; }
    public void setSentAt(Timestamp sentAt) { this.sentAt = sentAt; }
    public String getErrorMessage() { return errorMessage; }
    public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }
}
