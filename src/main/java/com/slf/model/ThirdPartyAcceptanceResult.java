package com.slf.model;

import java.sql.Timestamp;

public class ThirdPartyAcceptanceResult {
    private long requestId;
    private String commentText;
    private int satisfactionLevel;
    private Timestamp submittedAt;

    public long getRequestId() { return requestId; }
    public void setRequestId(long value) { requestId = value; }
    public String getCommentText() { return commentText; }
    public void setCommentText(String value) { commentText = value; }
    public int getSatisfactionLevel() { return satisfactionLevel; }
    public void setSatisfactionLevel(int value) { satisfactionLevel = value; }
    public Timestamp getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(Timestamp value) { submittedAt = value; }
}
