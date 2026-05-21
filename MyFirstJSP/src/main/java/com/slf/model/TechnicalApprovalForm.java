package com.slf.model;

public class TechnicalApprovalForm {
    private int formId;
    private String requesterName;
    private String departmentName;
    private String sectionName;
    private String deadline;
    private String titleForm;
    private String approvalStatus;

    public int getFormId() { return formId; }
    public void setFormId(int formId) { this.formId = formId; }

    public String getRequesterName() { return requesterName; }
    public void setRequesterName(String requesterName) { this.requesterName = requesterName; }

    public String getDepartmentName() { return departmentName; }
    public void setDepartmentName(String departmentName) { this.departmentName = departmentName; }

    public String getSectionName() { return sectionName; }
    public void setSectionName(String sectionName) { this.sectionName = sectionName; }

    public String getDeadline() { return deadline; }
    public void setDeadline(String deadline) { this.deadline = deadline; }

    public String getTitleForm() { return titleForm; }
    public void setTitleForm(String titleForm) { this.titleForm = titleForm; }

    public String getApprovalStatus() { return approvalStatus; }
    public void setApprovalStatus(String approvalStatus) { this.approvalStatus = approvalStatus; }

    public boolean isApproved() {
        String status = normalizeStatus();
        return status.equals("approved")
            || status.equals("approve")
            || status.equals("it_reviewed")
            || status.equals("it_director_approved")
            || status.equals("operated")
            || status.equals("success")
            || status.equals("completed")
            || status.equals("อนุมัติ")
            || status.equals("เสร็จสิ้น")
            || status.equals("1");
    }

    public boolean isTechnicalComplete() {
        return isApproved();
    }

    private String normalizeStatus() {
        if (approvalStatus == null) return "";
        return approvalStatus.trim().toLowerCase();
    }
}