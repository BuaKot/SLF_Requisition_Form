package com.slf.model;

import java.sql.Date;
import java.sql.Timestamp;

public class ThirdPartyRequest {
    private long requestId;
    private String formCode;
    private int internalOwnerEmpId;
    private String externalCompanyName;
    private String externalContactName;
    private String externalEmail;
    private String externalPhone;
    private String purpose;
    private String targetSystem;
    private Date accessStartDate;
    private Date accessEndDate;
    private String status;
    private Timestamp createdAt;
    private Timestamp submittedAt;
    private Timestamp updatedAt;
    private Long linkId;
    private String linkStatus;
    private Timestamp linkCreatedAt;
    private Timestamp linkExpiresAt;
    private Timestamp linkUsedAt;
    private String rawToken;
    private Long submissionId;

    public long getRequestId() { return requestId; }
    public void setRequestId(long requestId) { this.requestId = requestId; }
    public String getFormCode() { return formCode; }
    public void setFormCode(String formCode) { this.formCode = formCode; }
    public int getInternalOwnerEmpId() { return internalOwnerEmpId; }
    public void setInternalOwnerEmpId(int internalOwnerEmpId) { this.internalOwnerEmpId = internalOwnerEmpId; }
    public String getExternalCompanyName() { return externalCompanyName; }
    public void setExternalCompanyName(String externalCompanyName) { this.externalCompanyName = externalCompanyName; }
    public String getExternalContactName() { return externalContactName; }
    public void setExternalContactName(String externalContactName) { this.externalContactName = externalContactName; }
    public String getExternalEmail() { return externalEmail; }
    public void setExternalEmail(String externalEmail) { this.externalEmail = externalEmail; }
    public String getExternalPhone() { return externalPhone; }
    public void setExternalPhone(String externalPhone) { this.externalPhone = externalPhone; }
    public String getPurpose() { return purpose; }
    public void setPurpose(String purpose) { this.purpose = purpose; }
    public String getTargetSystem() { return targetSystem; }
    public void setTargetSystem(String targetSystem) { this.targetSystem = targetSystem; }
    public Date getAccessStartDate() { return accessStartDate; }
    public void setAccessStartDate(Date accessStartDate) { this.accessStartDate = accessStartDate; }
    public Date getAccessEndDate() { return accessEndDate; }
    public void setAccessEndDate(Date accessEndDate) { this.accessEndDate = accessEndDate; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(Timestamp submittedAt) { this.submittedAt = submittedAt; }
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
    public Long getLinkId() { return linkId; }
    public void setLinkId(Long linkId) { this.linkId = linkId; }
    public String getLinkStatus() { return linkStatus; }
    public void setLinkStatus(String linkStatus) { this.linkStatus = linkStatus; }
    public Timestamp getLinkCreatedAt() { return linkCreatedAt; }
    public void setLinkCreatedAt(Timestamp linkCreatedAt) { this.linkCreatedAt = linkCreatedAt; }
    public Timestamp getLinkExpiresAt() { return linkExpiresAt; }
    public void setLinkExpiresAt(Timestamp linkExpiresAt) { this.linkExpiresAt = linkExpiresAt; }
    public Timestamp getLinkUsedAt() { return linkUsedAt; }
    public void setLinkUsedAt(Timestamp linkUsedAt) { this.linkUsedAt = linkUsedAt; }
    public String getRawToken() { return rawToken; }
    public void setRawToken(String rawToken) { this.rawToken = rawToken; }
    public Long getSubmissionId() { return submissionId; }
    public void setSubmissionId(Long submissionId) { this.submissionId = submissionId; }
}
