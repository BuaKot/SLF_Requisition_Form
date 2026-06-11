package com.slf.model;

import java.sql.Timestamp;

public class ThirdPartyAcceptanceToken {
    private long acceptanceTokenId;
    private long requestId;
    private String rawToken;
    private String status;
    private Timestamp createdAt;
    private Timestamp expiresAt;
    private Timestamp usedAt;
    private String externalContactName;
    private String externalCompanyName;

    public long getAcceptanceTokenId() { return acceptanceTokenId; }
    public void setAcceptanceTokenId(long value) { acceptanceTokenId = value; }
    public long getRequestId() { return requestId; }
    public void setRequestId(long value) { requestId = value; }
    public String getRawToken() { return rawToken; }
    public void setRawToken(String value) { rawToken = value; }
    public String getStatus() { return status; }
    public void setStatus(String value) { status = value; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp value) { createdAt = value; }
    public Timestamp getExpiresAt() { return expiresAt; }
    public void setExpiresAt(Timestamp value) { expiresAt = value; }
    public Timestamp getUsedAt() { return usedAt; }
    public void setUsedAt(Timestamp value) { usedAt = value; }
    public String getExternalContactName() { return externalContactName; }
    public void setExternalContactName(String value) { externalContactName = value; }
    public String getExternalCompanyName() { return externalCompanyName; }
    public void setExternalCompanyName(String value) { externalCompanyName = value; }
}
