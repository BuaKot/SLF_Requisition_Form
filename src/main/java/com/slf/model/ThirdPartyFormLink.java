package com.slf.model;

import java.sql.Timestamp;

public class ThirdPartyFormLink {
    private long linkId;
    private String tokenHash;
    private String rawToken;
    private String status;
    private int maxSubmitCount;
    private int submitCount;
    private Integer createdBy;
    private String formCode;
    private Long requestId;
    private Integer createdByEmpId;
    private Timestamp createdAt;
    private Timestamp expiresAt;
    private Timestamp usedAt;
    private Timestamp revokedAt;
    private Integer revokedBy;
    private String note;
    private Long submissionId;
    private String submissionStatus;
    private Timestamp submittedAt;

    public long getLinkId() { return linkId; }
    public void setLinkId(long linkId) { this.linkId = linkId; }
    public String getTokenHash() { return tokenHash; }
    public void setTokenHash(String tokenHash) { this.tokenHash = tokenHash; }
    public String getRawToken() { return rawToken; }
    public void setRawToken(String rawToken) { this.rawToken = rawToken; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public int getMaxSubmitCount() { return maxSubmitCount; }
    public void setMaxSubmitCount(int maxSubmitCount) { this.maxSubmitCount = maxSubmitCount; }
    public int getSubmitCount() { return submitCount; }
    public void setSubmitCount(int submitCount) { this.submitCount = submitCount; }
    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }
    public String getFormCode() { return formCode; }
    public void setFormCode(String formCode) { this.formCode = formCode; }
    public Long getRequestId() { return requestId; }
    public void setRequestId(Long requestId) { this.requestId = requestId; }
    public Integer getCreatedByEmpId() { return createdByEmpId; }
    public void setCreatedByEmpId(Integer createdByEmpId) { this.createdByEmpId = createdByEmpId; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getExpiresAt() { return expiresAt; }
    public void setExpiresAt(Timestamp expiresAt) { this.expiresAt = expiresAt; }
    public Timestamp getUsedAt() { return usedAt; }
    public void setUsedAt(Timestamp usedAt) { this.usedAt = usedAt; }
    public Timestamp getRevokedAt() { return revokedAt; }
    public void setRevokedAt(Timestamp revokedAt) { this.revokedAt = revokedAt; }
    public Integer getRevokedBy() { return revokedBy; }
    public void setRevokedBy(Integer revokedBy) { this.revokedBy = revokedBy; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    public Long getSubmissionId() { return submissionId; }
    public void setSubmissionId(Long submissionId) { this.submissionId = submissionId; }
    public String getSubmissionStatus() { return submissionStatus; }
    public void setSubmissionStatus(String submissionStatus) { this.submissionStatus = submissionStatus; }
    public Timestamp getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(Timestamp submittedAt) { this.submittedAt = submittedAt; }
}
