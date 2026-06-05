package com.slf.model;

public class MemberProfile {
    private int empId;
    private String empName;
    private String position;
    private int secId;
    private String secName;
    private int deptId;
    private String deptName;
    private String phone;
    private String email;
    private boolean emailNotificationEnabled = true;
    private boolean active;

    public int getEmpId() { return empId; }
    public void setEmpId(int empId) { this.empId = empId; }

    public String getEmpName() { return empName; }
    public void setEmpName(String empName) { this.empName = empName; }

    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }

    public int getSecId() { return secId; }
    public void setSecId(int secId) { this.secId = secId; }

    public String getSecName() { return secName; }
    public void setSecName(String secName) { this.secName = secName; }

    public int getDeptId() { return deptId; }
    public void setDeptId(int deptId) { this.deptId = deptId; }

    public String getDeptName() { return deptName; }
    public void setDeptName(String deptName) { this.deptName = deptName; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public boolean isEmailNotificationEnabled() { return emailNotificationEnabled; }
    public void setEmailNotificationEnabled(boolean emailNotificationEnabled) { this.emailNotificationEnabled = emailNotificationEnabled; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}
