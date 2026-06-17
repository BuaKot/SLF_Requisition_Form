package com.slf.model;

import java.sql.Timestamp;

/**
 * DTO representing a single APPROVALINFO row for email timeline display.
 * Contains workflow state step, reviewer identifier, comment, approval date,
 * and a human-readable action label (e.g. "Director อนุมัติแล้ว").
 */
public class ApprovalHistoryEntry {
    private final int stateStep;
    private final Integer reviewerEmpId;
    private final String comment;
    private final Timestamp approvedDate;
    private final String actionLabel;

    public ApprovalHistoryEntry(int stateStep, Integer reviewerEmpId, String comment,
                                Timestamp approvedDate, String actionLabel) {
        this.stateStep = stateStep;
        this.reviewerEmpId = reviewerEmpId;
        this.comment = comment;
        this.approvedDate = approvedDate;
        this.actionLabel = actionLabel;
    }

    public int getStateStep() {
        return stateStep;
    }

    public Integer getReviewerEmpId() {
        return reviewerEmpId;
    }

    public String getComment() {
        return comment;
    }

    public Timestamp getApprovedDate() {
        return approvedDate;
    }

    public String getActionLabel() {
        return actionLabel;
    }
}