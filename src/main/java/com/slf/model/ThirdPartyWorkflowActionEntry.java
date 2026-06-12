package com.slf.model;

import java.sql.Timestamp;

public class ThirdPartyWorkflowActionEntry {
    private long requestId;
    private String actionType;
    private String fromStatus;
    private String toStatus;
    private String actorType;
    private Integer actorEmpId;
    private String actorEmpName;
    private String commentText;
    private Timestamp actedAt;

    public long getRequestId() { return requestId; }
    public void setRequestId(long requestId) { this.requestId = requestId; }
    public String getActionType() { return actionType; }
    public void setActionType(String actionType) { this.actionType = actionType; }
    public String getFromStatus() { return fromStatus; }
    public void setFromStatus(String fromStatus) { this.fromStatus = fromStatus; }
    public String getToStatus() { return toStatus; }
    public void setToStatus(String toStatus) { this.toStatus = toStatus; }
    public String getActorType() { return actorType; }
    public void setActorType(String actorType) { this.actorType = actorType; }
    public Integer getActorEmpId() { return actorEmpId; }
    public void setActorEmpId(Integer actorEmpId) { this.actorEmpId = actorEmpId; }
    public String getActorEmpName() { return actorEmpName; }
    public void setActorEmpName(String actorEmpName) { this.actorEmpName = actorEmpName; }
    public String getCommentText() { return commentText; }
    public void setCommentText(String commentText) { this.commentText = commentText; }
    public Timestamp getActedAt() { return actedAt; }
    public void setActedAt(Timestamp actedAt) { this.actedAt = actedAt; }
}
