package com.slf.notification;

import com.slf.model.ApprovalHistoryEntry;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

/**
 * Reusable plain-text email content builder for IT requisition and third-party
 * email notifications.
 *
 * <p>This class is intentionally stateless and contains only business logic
 * and presentation helpers. It does <strong>not</strong> access the database,
 * configuration, or servlet context. Approval history data must be loaded by
 * the service layer and passed in as {@link ApprovalHistoryEntry} lists.</p>
 *
 * <p>Design is prepared for future HTML migration: the same business logic
 * methods (resolveStepLabel, resolveRoleAction, etc.) can be reused by an
 * HTML template renderer.</p>
 */
public final class EmailContentBuilder {

    private static final String SEPARATOR = "\n═══════════════════════════════════════\n";
    private static final String FORM_DETAIL_PATH = "/detail.jsp?id=";

    private EmailContentBuilder() {
        // utility class
    }

    // ---------------------------------------------------------------
    //  Public API
    // ---------------------------------------------------------------

    /**
     * Builds an IT requisition subject line containing form ID and current step status.
     */
    public static String buildITRequisitionSubject(int formId, int stateStep) {
        return "[SLF] แบบฟอร์มคำขอ #" + formId + ": " + resolveWorkflowStepLabel(stateStep);
    }

    /**
     * Builds a full plain-text IT requisition email body with all sections.
     *
     * @param formId          requisition form ID
     * @param title           request topic / title
     * @param requesterEmpId  employee ID of the requester
     * @param stateStep       current workflow state (0..5, or negative for rejected)
     * @param comment         reviewer comment (may be null)
     * @param recipientRole   role string for the recipient (e.g. "DIRECTOR", "REQUESTER")
     * @param approvalHistory list of completed approval rows (may be empty)
     * @return formatted plain-text email body
     */
    public static String buildITRequisitionBody(int formId, String title, int requesterEmpId,
                                                int stateStep, String comment, String recipientRole,
                                                List<ApprovalHistoryEntry> approvalHistory) {
        StringBuilder body = new StringBuilder();

        // --- Section: Request Summary ---
        body.append(SEPARATOR);
        body.append("\uD83D\uDCCB สรุปคำขอ (Request Summary)\n");  // 📋
        body.append(SEPARATOR);
        body.append("หมายเลขคำขอ (Form ID): #").append(formId).append("\n");
        appendIfNotNull(body, "หัวข้อ (Topic)", title);
        body.append("ผู้ขอ (Requester): ").append(requesterEmpId).append("\n");

        // --- Section: Next Action ---
        body.append(SEPARATOR);
        body.append("\uD83D\uDCCC การดำเนินการที่ต้องการ (Next Action)\n");  // 📌
        body.append(SEPARATOR);
        body.append(resolveRoleActionMessage(recipientRole, stateStep)).append("\n");

        // --- Section: Current Step ---
        body.append(SEPARATOR);
        body.append("\uD83D\uDD04 ขั้นตอนปัจจุบัน (Current Step)\n");  // 🔄
        body.append(SEPARATOR);
        body.append(resolveWorkflowStepLabel(stateStep)).append("\n");

        // --- Section: Workflow Timeline ---
        body.append(SEPARATOR);
        body.append("\uD83D\uDCCA สถานะการดำเนินการ (Workflow Timeline)\n");  // 📊
        body.append(SEPARATOR);
        body.append(buildWorkflowTimeline(stateStep));

        // --- Section: Approval History ---
        if (approvalHistory != null && !approvalHistory.isEmpty()) {
            body.append(SEPARATOR);
            body.append("\uD83D\uDCDC ประวัติการอนุมัติ (Approval History)\n");  // 📜
            body.append(SEPARATOR);
            body.append(buildApprovalHistorySection(approvalHistory));
        }

        // --- Section: Rejection Details ---
        if (stateStep < 0) {
            body.append(SEPARATOR);
            body.append("\u274C รายละเอียดการปฏิเสธ (Rejection Details)\n");  // ❌
            body.append(SEPARATOR);
            body.append(buildRejectionDetailsSection(stateStep, comment));
        }

        // --- Section: Route Link ---
        body.append(SEPARATOR);
        body.append("\uD83D\uDD17 เปิดในระบบ SLF Requisition Form\n");  // 🔗
        body.append(SEPARATOR);
        body.append("ไปที่: ").append(resolveRoutePath(formId)).append("\n");

        return body.toString();
    }

    /**
     * Builds a third-party subject line.
     */
    public static String buildThirdPartySubject(long requestId, String statusLabel) {
        return "[SLF] คำขอ Third-Party #" + requestId + ": "
            + (statusLabel != null ? statusLabel : "มีการเปลี่ยนแปลง");
    }

    /**
     * Builds a third-party email body with request ID and status.
     */
    public static String buildThirdPartyBody(long requestId, String bodyLead,
                                              String comment, String statusLabel) {
        StringBuilder body = new StringBuilder();
        body.append(SEPARATOR);
        body.append("\uD83D\uDCCB สรุปคำขอ (Request Summary)\n");
        body.append(SEPARATOR);
        body.append("รหัสคำขอ (Request ID): #").append(requestId).append("\n");
        if (statusLabel != null) {
            body.append("สถานะ: ").append(statusLabel).append("\n");
        }

        if (bodyLead != null && !bodyLead.trim().isEmpty()) {
            body.append(SEPARATOR);
            body.append("\uD83D\uDCCC การดำเนินการ (Action Needed)\n");
            body.append(SEPARATOR);
            body.append(bodyLead.trim()).append("\n");
        }

        appendIfNotNull(body, "หมายเหตุ (Comment)", comment);

        body.append(SEPARATOR);
        body.append("\uD83D\uDD17 เปิดในระบบ SLF Requisition Form\n");
        body.append(SEPARATOR);
        body.append("ไปที่: /third-party-form-detail.jsp?id=").append(requestId).append("\n");

        return body.toString();
    }

    // ---------------------------------------------------------------
    //  Step label helpers
    // ---------------------------------------------------------------

    /**
     * Returns a Thai workflow step label for the given state.
     * Used for "Current Step" section and subject lines.
     */
    public static String resolveWorkflowStepLabel(int stateStep) {
        switch (stateStep) {
            case 0:
                return "รอ Director อนุมัติ";
            case 1:
                return "รอ Technical หรือหัวหน้าส่วนงานอนุมัติ";
            case 2:
                return "รอ IT Director อนุมัติ";
            case 3:
                return "รอ Technician ดำเนินการ";
            case 4:
                return "รอ Requestor ยืนยันรับงาน";
            case 5:
                return "เสร็จสมบูรณ์";
            case -1:
                return "ถูกปฏิเสธโดย Director";
            case -2:
                return "ถูกปฏิเสธโดย Technical";
            case -3:
                return "ถูกปฏิเสธโดย IT Director";
            case -4:
                return "ถูกปฏิเสธโดย Technician";
            case -5:
                return "ถูกปฏิเสธโดย Requestor";
            default:
                return "มีการเปลี่ยนแปลง (สถานะ: " + stateStep + ")";
        }
    }

    /**
     * Returns the role that should act next for the given state.
     */
    public static String resolveNextActorLabel(int stateStep) {
        switch (stateStep) {
            case 0:
                return "Director";
            case 1:
                return "Technical / หัวหน้าส่วนงาน";
            case 2:
                return "IT Director";
            case 3:
                return "Technician";
            case 4:
                return "Requestor";
            case 5:
                return "-";
            case -1:
            case -2:
            case -3:
            case -4:
            case -5:
                return "Requestor (แจ้งผลการปฏิเสธ)";
            default:
                return "ผู้เกี่ยวข้อง";
        }
    }

    // ---------------------------------------------------------------
    //  Role action messages
    // ---------------------------------------------------------------

    /**
     * Returns a Thai action message tailored to the recipient role and current state.
     */
    public static String resolveRoleActionMessage(String role, int stateStep) {
        if (role == null) {
            return "กรุณาตรวจสอบคำขอนี้";
        }
        String normalizedRole = role.trim().toUpperCase();

        switch (normalizedRole) {
            case "REQUESTER":
                if (stateStep == 5) {
                    return "เรียน ผู้ขอ: คำขอของคุณได้รับการดำเนินการครบถ้วนแล้ว";
                }
                if (stateStep < 0) {
                    return "เรียน ผู้ขอ: คำขอของคุณถูกปฏิเสธ กรุณาตรวจสอบรายละเอียดด้านล่าง";
                }
                return "เรียน ผู้ขอ: สถานะคำขอของคุณมีการเปลี่ยนแปลง กรุณาตรวจสอบ";

            case "DIRECTOR":
                return "Director: กรุณาตรวจสอบและอนุมัติคำขอนี้";

            case "TECHNICAL":
                if (stateStep == 1) {
                    return "Technical / หัวหน้าส่วนงาน: กรุณาตรวจสอบและอนุมัติคำขอนี้";
                }
                return "Technical: กรุณาตรวจสอบคำขอนี้";

            case "IT_DIRECTOR":
                return "IT Director: กรุณาตรวจสอบและอนุมัติคำขอนี้";

            case "TECHNICIAN":
                return "Technician: กรุณาดำเนินการตามคำขอนี้";

            case "ASSIGNED_STAFF":
                return "ผู้รับผิดชอบ: กรุณาดำเนินการตามคำขอนี้";

            case "ADMIN":
            case "SUPPORT":
                return "Admin/Support: สถานะคำขอมีการเปลี่ยนแปลง กรุณาตรวจสอบ";

            default:
                return "กรุณาตรวจสอบคำขอนี้";
        }
    }

    // ---------------------------------------------------------------
    //  Workflow timeline
    // ---------------------------------------------------------------

    /**
     * Builds a plain-text workflow timeline showing all 6 steps with
     * status markers: [✅] completed, [🔄] current, [⬜] pending, [❌] rejected.
     */
    public static String buildWorkflowTimeline(int stateStep) {
        StringBuilder timeline = new StringBuilder();
        String[][] steps = {
            {"0", "Director อนุมัติแล้ว"},
            {"1", "Technical หรือหัวหน้าส่วนงานอนุมัติแล้ว"},
            {"2", "IT Director อนุมัติแล้ว"},
            {"3", "Technician ดำเนินการแล้ว"},
            {"4", "Requestor ยืนยันรับงานแล้ว"},
            {"5", "เสร็จสมบูรณ์"}
        };

        boolean rejected = stateStep < 0;
        int absoluteStep = rejected ? Math.abs(stateStep) - 1 : stateStep;

        for (int i = 0; i < steps.length; i++) {
            int stepValue = Integer.parseInt(steps[i][0]);

            if (rejected && stepValue == absoluteStep) {
                // The step that was rejected
                timeline.append("[❌] ถูกปฏิเสธ - ").append(steps[i][1]).append("\n");
            } else if (stepValue < absoluteStep || (stateStep == 5 && stepValue == 5)) {
                // Completed (including final completed state)
                timeline.append("[✅] ").append(steps[i][1]).append("\n");
            } else if (stepValue == absoluteStep && !rejected && stateStep != 5) {
                // Current step
                timeline.append("[🔄] ").append(resolvePendingStepLabel(stepValue)).append("\n");
            } else {
                // Pending
                timeline.append("[⬜] ").append(resolvePendingStepLabel(stepValue)).append("\n");
            }
        }

        return timeline.toString();
    }

    // ---------------------------------------------------------------
    //  Approval history
    // ---------------------------------------------------------------

    /**
     * Formats a list of approval history entries into a plain-text section.
     */
    public static String buildApprovalHistorySection(List<ApprovalHistoryEntry> history) {
        if (history == null || history.isEmpty()) {
            return "- ยังไม่มีประวัติการอนุมัติ\n";
        }

        StringBuilder section = new StringBuilder();
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");

        for (ApprovalHistoryEntry entry : history) {
            section.append("- ").append(entry.getActionLabel());
            section.append(" (โดย: ").append(entry.getReviewerDisplayName());
            if (entry.getApprovedDate() != null) {
                section.append(" เมื่อ: ").append(dateFormat.format(
                    new Date(entry.getApprovedDate().getTime())));
            }
            section.append(")");
            section.append("\n");
            if (entry.getComment() != null && !entry.getComment().trim().isEmpty()) {
                section.append("  หมายเหตุ: ").append(entry.getComment().trim()).append("\n");
            }
        }

        return section.toString();
    }

    // ---------------------------------------------------------------
    //  Rejection details
    // ---------------------------------------------------------------

    /**
     * Formats rejection details for a negative state step.
     */
    public static String buildRejectionDetailsSection(int stateStep, String comment) {
        StringBuilder section = new StringBuilder();
        String rejectedBy = "ผู้เกี่ยวข้อง";
        switch (stateStep) {
            case -1:
                rejectedBy = "Director";
                break;
            case -2:
                rejectedBy = "Technical / หัวหน้าส่วนงาน";
                break;
            case -3:
                rejectedBy = "IT Director";
                break;
            case -4:
                rejectedBy = "Technician";
                break;
            case -5:
                rejectedBy = "Requestor";
                break;
            default:
                break;
        }
        section.append("ขั้นตอนที่ถูกปฏิเสธ: ").append(rejectedBy).append("\n");
        if (comment != null && !comment.trim().isEmpty()) {
            section.append("หมายเหตุ: ").append(comment.trim()).append("\n");
        }
        return section.toString();
    }

    // ---------------------------------------------------------------
    //  Route link
    // ---------------------------------------------------------------

    /**
     * Returns a relative route path to the form detail page.
     * Uses the existing /detail.jsp route from PROJECT_CONTEXT.md.
     */
    public static String resolveRoutePath(int formId) {
        return FORM_DETAIL_PATH + formId;
    }

    // ---------------------------------------------------------------
    //  Internal helpers
    // ---------------------------------------------------------------

    /**
     * Returns a label for pending/future steps in the timeline.
     */
    private static String resolvePendingStepLabel(int stateStep) {
        switch (stateStep) {
            case 0:
                return "รอ Director อนุมัติ";
            case 1:
                return "รอ Technical หรือหัวหน้าส่วนงานอนุมัติ";
            case 2:
                return "รอ IT Director อนุมัติ";
            case 3:
                return "รอ Technician ดำเนินการ";
            case 4:
                return "รอ Requestor ยืนยันรับงาน";
            case 5:
                return "เสร็จสมบูรณ์";
            default:
                return "รอดำเนินการ";
        }
    }

    private static void appendIfNotNull(StringBuilder body, String label, String value) {
        if (value != null && !value.trim().isEmpty()) {
            body.append(label).append(": ").append(value.trim()).append("\n");
        }
    }
}