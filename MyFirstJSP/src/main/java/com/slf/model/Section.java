package com.slf.model;
public class Section {
    private int secID;
    private int deptID;
    private String secName;
    private String sectionHeadEmpID;
    public Section(int secID, String secName, int deptID, String sectionHeadEmpID) {
        this.secID = secID;
        this.deptID = deptID;
        this.secName = secName;
        this.sectionHeadEmpID = sectionHeadEmpID;
    }
    public int getDeptId() { return deptID; }
    public int getSecId() { return secID; }
    public String getSectionHeadEmpID() { return sectionHeadEmpID; }
    public String getSecName() { return secName; }
}