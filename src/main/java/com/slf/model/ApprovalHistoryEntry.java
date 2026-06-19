package com.slf.model;

import java.sql.Timestamp;

/**
 * DTO representing a single APPROVALINFO row for email timeline display.
 * Contains workflow state step, reviewer identifier and name, comment, approval date,
 * and a human-readable action label (e.g. "Director อนุมัติแล้ว").
 */
public class ApprovalHistoryEntry {
    private final int stateStep;
    private final Integer reviewerEmpId;
    private final String reviewerName;
    private final String comment;
    private final Timestamp approvedDate;
    private final String actionLabel;

    public ApprovalHistoryEntry(int stateStep, Integer reviewerEmpId, String reviewerName,
                                String comment, Timestamp approvedDate, String actionLabel) {
        this.stateStep = stateStep;
        this.reviewerEmpId = reviewerEmpId;
        this.reviewerName = reviewerName;
        this.comment = comment;
        this.approvedDate = approvedDate;
        this.actionLabel = actionLabel;
    }

    // Backward-compatible constructor
    public ApprovalHistoryEntry(int stateStep, Integer reviewerEmpId, String comment,
                                Timestamp approvedDate, String actionLabel) {
        this(stateStep, reviewerEmpId, null, comment, approvedDate, actionLabel);
    }

    public int getStateStep() {
        return stateStep;
    }

    public Integer getReviewerEmpId() {
        return reviewerEmpId;
    }

    /**
     * Returns the reviewer's full name, or null if not loaded.
     */
    public String getReviewerName() {
        return reviewerName;
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

    /**
     * Returns the display name: reviewer name if available, otherwise "EMP [id]".
     */
    public String getReviewerDisplayName() {
        if (reviewerName != null && !reviewerName.trim().isEmpty()) {
            return reviewerName.trim();
        }
        if (reviewerEmpId != null) {
            return "EMP " + reviewerEmpId;
        }
        return "-";
    }
}