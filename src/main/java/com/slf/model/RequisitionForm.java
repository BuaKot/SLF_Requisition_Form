package com.slf.model;

import java.util.List;

public class RequisitionForm {
    private String name;
    private String section;
    private String department;
    private String phone;
    private String date;
    private String deadline;
    private String requestTopic;
    private List<RequestItem> items;
    private int empID;
    private int formId;
    private boolean technicalApprovalRequired;   // NEW: multi‑tier approval flag

    // Getters and setters
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getSection() { return section; }
    public void setSection(String section) { this.section = section; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }

    public String getDeadline() { return deadline; }
    public void setDeadline(String deadline) { this.deadline = deadline; }

    public String getRequestTopic() { return requestTopic; }
    public void setRequestTopic(String requestTopic) { this.requestTopic = requestTopic; }

    public List<RequestItem> getItems() { return items; }
    public void setItems(List<RequestItem> items) { this.items = items; }

    public int getEmpID() { return empID; }
    public void setEmpID(int empID) { this.empID = empID; }

    public int getFormId() { return formId; }
    public void setFormId(int formId) { this.formId = formId; }

    public boolean isTechnicalApprovalRequired() { return technicalApprovalRequired; }
    public void setTechnicalApprovalRequired(boolean technicalApprovalRequired) {
        this.technicalApprovalRequired = technicalApprovalRequired;
    }
}