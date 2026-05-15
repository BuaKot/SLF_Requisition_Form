package com.slf.model;

public class Employee {
    private int empId;
    private String empName;
    private String position;
    private int secId;
    private String phone;

    public Employee() {}

    // Getters and Setters (the GET and SET buttons)
    public int getEmpId() { return empId; }
    public void setEmpId(int empId) { this.empId = empId; }

    public String getEmpName() { return empName; }
    public void setEmpName(String empName) { this.empName = empName; }

    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }

    public int getSecId() { return secId; }
    public void setSecId(int secId) { this.secId = secId; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
}