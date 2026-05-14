package com.slf.model;
public class Department {
    private int deptID;
    private String deptHeadID;
    private String deptName;
    public Department(int deptID, String deptHeadID, String deptName) {
        this.deptID = deptID;
        this.deptName = deptName;
        this.deptHeadID = deptHeadID;
    }
    public int getDeptId() { return deptID; }
    public String getDeptHeadId() { return deptHeadID; }
    public String getDeptName() { return deptName; }
}