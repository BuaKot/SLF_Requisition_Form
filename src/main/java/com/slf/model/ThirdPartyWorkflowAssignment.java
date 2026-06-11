package com.slf.model;

import java.sql.Timestamp;

public class ThirdPartyWorkflowAssignment {
    private String assignmentRole;
    private int assignedEmpId;
    private String assignedEmpName;
    private int assignedByEmpId;
    private String assignedByEmpName;
    private Timestamp assignedAt;

    public String getAssignmentRole() { return assignmentRole; }
    public void setAssignmentRole(String assignmentRole) { this.assignmentRole = assignmentRole; }
    public int getAssignedEmpId() { return assignedEmpId; }
    public void setAssignedEmpId(int assignedEmpId) { this.assignedEmpId = assignedEmpId; }
    public String getAssignedEmpName() { return assignedEmpName; }
    public void setAssignedEmpName(String assignedEmpName) { this.assignedEmpName = assignedEmpName; }
    public int getAssignedByEmpId() { return assignedByEmpId; }
    public void setAssignedByEmpId(int assignedByEmpId) { this.assignedByEmpId = assignedByEmpId; }
    public String getAssignedByEmpName() { return assignedByEmpName; }
    public void setAssignedByEmpName(String assignedByEmpName) { this.assignedByEmpName = assignedByEmpName; }
    public Timestamp getAssignedAt() { return assignedAt; }
    public void setAssignedAt(Timestamp assignedAt) { this.assignedAt = assignedAt; }
}
