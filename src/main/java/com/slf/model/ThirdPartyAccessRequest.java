package com.slf.model;

public class ThirdPartyAccessRequest {
    private long accessRequestId;
    private int displayOrder;
    private String employeeCode;
    private String username;
    private String nationalId;
    private String fullNameTh;
    private String fullNameEn;
    private String positionName;
    private String mobilePhone;
    private String departmentName;
    private String email;
    private String systemName;
    private String requestedRole;

    public long getAccessRequestId() { return accessRequestId; }
    public void setAccessRequestId(long accessRequestId) { this.accessRequestId = accessRequestId; }
    public int getDisplayOrder() { return displayOrder; }
    public void setDisplayOrder(int displayOrder) { this.displayOrder = displayOrder; }
    public String getEmployeeCode() { return employeeCode; }
    public void setEmployeeCode(String employeeCode) { this.employeeCode = employeeCode; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getNationalId() { return nationalId; }
    public void setNationalId(String nationalId) { this.nationalId = nationalId; }
    public String getFullNameTh() { return fullNameTh; }
    public void setFullNameTh(String fullNameTh) { this.fullNameTh = fullNameTh; }
    public String getFullNameEn() { return fullNameEn; }
    public void setFullNameEn(String fullNameEn) { this.fullNameEn = fullNameEn; }
    public String getPositionName() { return positionName; }
    public void setPositionName(String positionName) { this.positionName = positionName; }
    public String getMobilePhone() { return mobilePhone; }
    public void setMobilePhone(String mobilePhone) { this.mobilePhone = mobilePhone; }
    public String getDepartmentName() { return departmentName; }
    public void setDepartmentName(String departmentName) { this.departmentName = departmentName; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getSystemName() { return systemName; }
    public void setSystemName(String systemName) { this.systemName = systemName; }
    public String getRequestedRole() { return requestedRole; }
    public void setRequestedRole(String requestedRole) { this.requestedRole = requestedRole; }
}
