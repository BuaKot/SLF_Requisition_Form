package com.slf.model;

import java.sql.Date;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class ThirdPartyFormSubmission {
    private long submissionId;
    private long linkId;
    private String documentReceiveNo;
    private Date filledDate;
    private String fullNameTh;
    private String fullNameEn;
    private String organization;
    private String phone;
    private String email;
    private String reasonObjective;
    private String projectName;
    private Date accessStartDate;
    private Date accessEndDate;
    private String status;
    private Timestamp createdAt;
    private Integer reviewedBy;
    private Timestamp reviewedAt;
    private Integer importedFormId;
    private String internalNote;
    private boolean consentAccepted;
    private String consentVersion;
    private Timestamp consentAcceptedAt;
    private String consentIpAddress;
    private String consentUserAgent;
    private String linkStatus;
    private Timestamp linkCreatedAt;
    private Timestamp linkExpiresAt;
    private String linkNote;
    private List<ThirdPartyAccessRequest> accessRequests = new ArrayList<>();

    public long getSubmissionId() { return submissionId; }
    public void setSubmissionId(long submissionId) { this.submissionId = submissionId; }
    public long getLinkId() { return linkId; }
    public void setLinkId(long linkId) { this.linkId = linkId; }
    public String getDocumentReceiveNo() { return documentReceiveNo; }
    public void setDocumentReceiveNo(String documentReceiveNo) { this.documentReceiveNo = documentReceiveNo; }
    public Date getFilledDate() { return filledDate; }
    public void setFilledDate(Date filledDate) { this.filledDate = filledDate; }
    public String getFullNameTh() { return fullNameTh; }
    public void setFullNameTh(String fullNameTh) { this.fullNameTh = fullNameTh; }
    public String getFullNameEn() { return fullNameEn; }
    public void setFullNameEn(String fullNameEn) { this.fullNameEn = fullNameEn; }
    public String getOrganization() { return organization; }
    public void setOrganization(String organization) { this.organization = organization; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getReasonObjective() { return reasonObjective; }
    public void setReasonObjective(String reasonObjective) { this.reasonObjective = reasonObjective; }
    public String getProjectName() { return projectName; }
    public void setProjectName(String projectName) { this.projectName = projectName; }
    public Date getAccessStartDate() { return accessStartDate; }
    public void setAccessStartDate(Date accessStartDate) { this.accessStartDate = accessStartDate; }
    public Date getAccessEndDate() { return accessEndDate; }
    public void setAccessEndDate(Date accessEndDate) { this.accessEndDate = accessEndDate; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Integer getReviewedBy() { return reviewedBy; }
    public void setReviewedBy(Integer reviewedBy) { this.reviewedBy = reviewedBy; }
    public Timestamp getReviewedAt() { return reviewedAt; }
    public void setReviewedAt(Timestamp reviewedAt) { this.reviewedAt = reviewedAt; }
    public Integer getImportedFormId() { return importedFormId; }
    public void setImportedFormId(Integer importedFormId) { this.importedFormId = importedFormId; }
    public String getInternalNote() { return internalNote; }
    public void setInternalNote(String internalNote) { this.internalNote = internalNote; }
    public boolean isConsentAccepted() { return consentAccepted; }
    public void setConsentAccepted(boolean consentAccepted) { this.consentAccepted = consentAccepted; }
    public String getConsentVersion() { return consentVersion; }
    public void setConsentVersion(String consentVersion) { this.consentVersion = consentVersion; }
    public Timestamp getConsentAcceptedAt() { return consentAcceptedAt; }
    public void setConsentAcceptedAt(Timestamp consentAcceptedAt) { this.consentAcceptedAt = consentAcceptedAt; }
    public String getConsentIpAddress() { return consentIpAddress; }
    public void setConsentIpAddress(String consentIpAddress) { this.consentIpAddress = consentIpAddress; }
    public String getConsentUserAgent() { return consentUserAgent; }
    public void setConsentUserAgent(String consentUserAgent) { this.consentUserAgent = consentUserAgent; }
    public String getLinkStatus() { return linkStatus; }
    public void setLinkStatus(String linkStatus) { this.linkStatus = linkStatus; }
    public Timestamp getLinkCreatedAt() { return linkCreatedAt; }
    public void setLinkCreatedAt(Timestamp linkCreatedAt) { this.linkCreatedAt = linkCreatedAt; }
    public Timestamp getLinkExpiresAt() { return linkExpiresAt; }
    public void setLinkExpiresAt(Timestamp linkExpiresAt) { this.linkExpiresAt = linkExpiresAt; }
    public String getLinkNote() { return linkNote; }
    public void setLinkNote(String linkNote) { this.linkNote = linkNote; }
    public List<ThirdPartyAccessRequest> getAccessRequests() { return accessRequests; }
    public void setAccessRequests(List<ThirdPartyAccessRequest> accessRequests) {
        this.accessRequests = accessRequests == null ? new ArrayList<ThirdPartyAccessRequest>() : accessRequests;
    }
}
