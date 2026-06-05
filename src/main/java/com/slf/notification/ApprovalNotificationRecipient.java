package com.slf.notification;

public class ApprovalNotificationRecipient {
    private final Integer empId;
    private final String email;
    private final String name;

    public ApprovalNotificationRecipient(Integer empId, String email, String name) {
        this.empId = empId;
        this.email = email;
        this.name = name;
    }

    public Integer getEmpId() {
        return empId;
    }

    public String getEmail() {
        return email;
    }

    public String getName() {
        return name;
    }
}
