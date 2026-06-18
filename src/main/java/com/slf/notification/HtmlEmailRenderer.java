package com.slf.notification;

import com.slf.model.ApprovalHistoryEntry;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

/**
 * Gmail-safe HTML email renderer for IT requisition notifications.
 *
 * <p>Uses only inline CSS styles, table/div layout, no external CSS.
 * Designed to work in Gmail, Outlook, and mobile email clients.</p>
 *
 * <p>Plain-text fallback is provided via {@link #stripHtml(String)} for
 * multipart/alternative email content.</p>
 *
 * <p>This class is stateless and reuses the same business-logic helpers
 * from {@link EmailContentBuilder} where possible.</p>
 */
public final class HtmlEmailRenderer {

    private static final String FORM_DETAIL_PATH = "/detail.jsp?id=";

    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("dd/MM/yyyy HH:mm");

    // HTML entity constants for Java 8 compatibility
    private static final String AMP = "&" + "amp;";
    private static final String LT = "&" + "lt;";
    private static final String GT = "&" + "gt;";
    private static final String QUOT = "&" + "quot;";

    // Corporate color palette
    private static final String NAVY = "#1B2A4A";
    private static final String GOLD = "#C8962E";
    private static final String BG_LIGHT = "#F5F5F5";
    private static final String TEXT_DARK = "#333333";
    private static final String TEXT_MUTED = "#666666";
    private static final String SUCCESS = "#2E7D32";
    private static final String REJECTED = "#C62828";
    private static final String CURRENT_BLUE = "#1565C0";
    private static final String GRAY = "#BDBDBD";
    private static final String BORDER_LIGHT = "#E0E0E0";

    // Font stack
    private static final String FONT_STACK = "Arial, Tahoma, 'Sarabun', sans-serif";

    private HtmlEmailRenderer() {
        // utility class
    }

    // ---------------------------------------------------------------
    //  Public API
    // ---------------------------------------------------------------

    /**
     * Renders a full HTML IT requisition email with card layout, workflow
     * timeline, approval history, and action button.
     *
     * @param formId          requisition form ID
     * @param title           request topic / title (may be null)
     * @param requesterEmpId  employee ID of the requester
     * @param stateStep       current workflow state (0..5, or negative for rejected)
     * @param comment         reviewer comment (may be null)
     * @param recipientRole   role string for the recipient (e.g. "DIRECTOR", "REQUESTER")
     * @param approvalHistory list of completed approval rows (may be empty)
     * @param appBaseUrl      configured application base URL (may be null, falls back to relative path)
     * @return HTML email body string
     */
    public static String renderITRequisitionEmail(int formId, String title, int requesterEmpId,
                                                  int stateStep, String comment, String recipientRole,
                                                  List<ApprovalHistoryEntry> approvalHistory,
                                                  String appBaseUrl) {
        StringBuilder html = new StringBuilder();

        String routePath = FORM_DETAIL_PATH + formId;
        String fullUrl = buildFullUrl(appBaseUrl, routePath);

        // Logo image URL (only if base URL is configured)
        String logoUrl = appBaseUrl != null && !appBaseUrl.trim().isEmpty()
            ? buildFullUrl(appBaseUrl.trim(), "/images/SLF_logo.png") : null;

        html.append("<!DOCTYPE html>\n");
        html.append("<html lang=\"th\">\n");
        html.append("<head><meta charset=\"UTF-8\"><meta name=\"viewport\" content=\"width=device-width,initial-scale=1.0\"></head>\n");
        html.append("<body style=\"margin:0;padding:0;background-color:").append(BG_LIGHT).append(";font-family:").append(FONT_STACK).append(";\">\n");

        // Outer table wrapper (Gmail-safe)
        html.append("<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"background-color:").append(BG_LIGHT).append(";\">\n");
        html.append("<tr><td align=\"center\" style=\"padding:24px 10px;\">\n");

        // Main container card — wider 680px
        html.append("<table width=\"100%\" style=\"max-width:680px;background-color:#ffffff;border-radius:8px;overflow:hidden;\">\n");

        // ════════════════════════════════════════
        //  HEADER — Navy bar with logo, title, badge
        // ════════════════════════════════════════
        html.append("<tr><td style=\"background-color:").append(NAVY).append(";padding:28px 32px;\">\n");

        // Header inner table: 3 columns (logo | center title | badge)
        html.append("<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\">\n");
        html.append("<tr>\n");

        // Left: Logo
        html.append("<td width=\"60\" valign=\"middle\" style=\"text-align:left;\">\n");
        if (logoUrl != null) {
            html.append("<img src=\"").append(escapeHtml(logoUrl)).append("\" alt=\"\u0E01\u0E22\u0E28 | Student Loan Fund\" width=\"48\" height=\"48\" style=\"display:block;border:0;\" />\n");
        }
        // Always show text logo fallback
        html.append("<div style=\"color:#ffffff;font-size:13px;font-weight:bold;line-height:1.3;\">\u0E01\u0E22\u0E28<br><span style=\"font-weight:normal;font-size:10px;\">Student Loan Fund</span></div>\n");
        html.append("</td>\n");

        // Center: Title + subtitle
        html.append("<td valign=\"middle\" style=\"text-align:center;\">\n");
        html.append("<div style=\"color:#ffffff;font-size:18px;font-weight:bold;\">SLF Requisition Form</div>\n");
        html.append("<div style=\"color:#ffffff;font-size:13px;margin-top:2px;opacity:0.8;\">\u0E41\u0E1A\u0E1A\u0E1F\u0E2D\u0E23\u0E4C\u0E21\u0E04\u0E33\u0E02\u0E2D #").append(formId).append("</div>\n");
        html.append("</td>\n");

        // Right: Status badge
        html.append("<td width=\"100\" valign=\"middle\" style=\"text-align:right;\">\n");
        html.append(statusBadgeHtml(stateStep));
        html.append("</td>\n");

        html.append("</tr>\n");
        html.append("</table>\n");
        html.append("</td></tr>\n");

        // ════════════════════════════════════════
        //  BODY — Section cards
        // ════════════════════════════════════════

        // ── Request Summary ──
        html.append("<tr><td style=\"padding:28px 32px 0 32px;\">\n");
        html.append(sectionCard("\u0E2A\u0E23\u0E38\u0E1B\u0E04\u0E33\u0E02\u0E2D (Request Summary)",
                summaryTableHtml(formId, title, requesterEmpId)));
        html.append("</td></tr>\n");

        // ── Next Action ──
        String actionMessage = EmailContentBuilder.resolveRoleActionMessage(recipientRole, stateStep);
        html.append("<tr><td style=\"padding:16px 32px 0 32px;\">\n");
        html.append(accentCard(GOLD, "\u0E01\u0E32\u0E23\u0E14\u0E33\u0E40\u0E19\u0E34\u0E19\u0E01\u0E32\u0E23\u0E17\u0E35\u0E48\u0E15\u0E49\u0E2D\u0E07\u0E01\u0E32\u0E23 (Next Action)",
                "<div style=\"font-size:14px;color:" + TEXT_DARK + ";font-weight:bold;\">" + escapeHtml(actionMessage) + "</div>"));
        html.append("</td></tr>\n");

        // ── Current Step ──
        html.append("<tr><td style=\"padding:16px 32px 0 32px;\">\n");
        html.append(accentCard(NAVY, "\u0E02\u0E31\u0E49\u0E19\u0E15\u0E2D\u0E19\u0E1B\u0E31\u0E08\u0E08\u0E38\u0E1A\u0E31\u0E19 (Current Step)",
                currentStatusHtml(stateStep)));
        html.append("</td></tr>\n");

        // ── Workflow Timeline ──
        html.append("<tr><td style=\"padding:16px 32px 0 32px;\">\n");
        html.append(sectionCard("\u0E2A\u0E16\u0E32\u0E19\u0E30\u0E01\u0E32\u0E23\u0E14\u0E33\u0E40\u0E19\u0E34\u0E19\u0E01\u0E32\u0E23 (Workflow Timeline)",
                renderHorizontalTimelineHtml(stateStep)));
        html.append("</td></tr>\n");

        // ── Approval History ──
        if (approvalHistory != null && !approvalHistory.isEmpty()) {
            html.append("<tr><td style=\"padding:16px 32px 0 32px;\">\n");
            html.append(sectionCard("\u0E1B\u0E23\u0E30\u0E27\u0E31\u0E15\u0E34\u0E01\u0E32\u0E23\u0E2D\u0E19\u0E38\u0E21\u0E31\u0E15\u0E34 (Approval History)",
                    approvalHistoryHtml(approvalHistory)));
            html.append("</td></tr>\n");
        }

        // ── Rejection Details ──
        if (stateStep < 0) {
            html.append("<tr><td style=\"padding:16px 32px 0 32px;\">\n");
            html.append(sectionCard("\u0E23\u0E32\u0E22\u0E25\u0E30\u0E40\u0E2D\u0E35\u0E22\u0E14\u0E01\u0E32\u0E23\u0E1B\u0E0F\u0E34\u0E40\u0E2A\u0E18 (Rejection Details)",
                    rejectionDetailsHtml(stateStep, comment)));
            html.append("</td></tr>\n");
        }

        // ── Action Button ──
        html.append("<tr><td style=\"padding:32px 32px 36px 32px;text-align:center;\">\n");
        html.append(actionButtonHtml(fullUrl));
        html.append("</td></tr>\n");

        // ── Footer ──
        html.append("<tr><td style=\"background-color:").append(BG_LIGHT).append(";padding:20px 32px;border-top:1px solid ").append(BORDER_LIGHT).append(";\">\n");
        html.append("<div style=\"font-size:12px;color:").append(TEXT_MUTED).append(";text-align:center;\">");
        html.append("\u0E19\u0E35\u0E49\u0E40\u0E1B\u0E47\u0E19\u0E02\u0E49\u0E2D\u0E04\u0E27\u0E32\u0E21\u0E2D\u0E31\u0E15\u0E42\u0E19\u0E21\u0E31\u0E15\u0E34\u0E08\u0E32\u0E01\u0E23\u0E30\u0E1A\u0E1A SLF Requisition Form");
        html.append("<br>\u0E01\u0E23\u0E38\u0E13\u0E32\u0E2D\u0E48\u0E32\u0E19\u0E41\u0E25\u0E30\u0E14\u0E33\u0E40\u0E19\u0E34\u0E19\u0E01\u0E32\u0E23\u0E15\u0E32\u0E21\u0E25\u0E34\u0E07\u0E04\u0E4C\u0E14\u0E49\u0E32\u0E19\u0E1A\u0E19");
        html.append("</div>\n");
        html.append("</td></tr>\n");

        html.append("</table>\n"); // end main container
        html.append("</td></tr>\n");
        html.append("</table>\n"); // end outer wrapper
        html.append("</body>\n</html>");

        return html.toString();
    }

    // ---------------------------------------------------------------
    //  Card helpers
    // ---------------------------------------------------------------

    /** Standard card with white bg inside. */
    private static String sectionCard(String title, String contentHtml) {
        StringBuilder card = new StringBuilder();
        card.append("<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"background-color:").append(BG_LIGHT).append(";border-radius:6px;\">\n");
        card.append("<tr><td style=\"background-color:").append(NAVY).append(";color:#ffffff;font-size:14px;font-weight:bold;padding:10px 14px;border-radius:6px 6px 0 0;\">")
            .append(title).append("</td></tr>\n");
        card.append("<tr><td style=\"font-size:14px;color:").append(TEXT_DARK).append(";padding:14px;\">").append(contentHtml).append("</td></tr>\n");
        card.append("</table>\n");
        return card.toString();
    }

    /** Accent card with a colored left border. */
    private static String accentCard(String accentColor, String title, String contentHtml) {
        StringBuilder card = new StringBuilder();
        card.append("<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"background-color:").append(BG_LIGHT).append(";border-radius:6px;\">\n");
        card.append("<tr><td width=\"4\" style=\"background-color:").append(accentColor).append(";border-radius:6px 0 0 6px;\"></td>\n");
        card.append("<td style=\"padding:12px 14px;\">\n");
        card.append("<div style=\"font-size:13px;font-weight:bold;color:").append(TEXT_MUTED).append(";margin-bottom:4px;\">").append(title).append("</div>\n");
        card.append("<div style=\"font-size:14px;color:").append(TEXT_DARK).append(";\">").append(contentHtml).append("</div>\n");
        card.append("</td></tr>\n");
        card.append("</table>\n");
        return card.toString();
    }

    // ---------------------------------------------------------------
    //  Request Summary
    // ---------------------------------------------------------------

    private static String summaryTableHtml(int formId, String title, int requesterEmpId) {
        StringBuilder table = new StringBuilder();
        table.append("<table width=\"100%\" cellpadding=\"4\" cellspacing=\"0\" style=\"font-size:14px;\">\n");
        table.append("<tr><td style=\"color:").append(TEXT_MUTED).append(";width:110px;\">Form ID</td>")
            .append("<td style=\"color:").append(TEXT_DARK).append(";font-weight:bold;\">#").append(formId).append("</td></tr>\n");
        // Topic with fallback
        String topicText = (title != null && !title.trim().isEmpty()) ? escapeHtml(title.trim()) : "\u0E44\u0E21\u0E48\u0E44\u0E14\u0E49\u0E23\u0E30\u0E1A\u0E38\u0E2B\u0E31\u0E27\u0E02\u0E49\u0E2D";
        table.append("<tr><td style=\"color:").append(TEXT_MUTED).append(";\">\u0E2B\u0E31\u0E27\u0E02\u0E49\u0E2D (Topic)</td>")
            .append("<td style=\"color:").append(TEXT_DARK).append(";\">").append(topicText).append("</td></tr>\n");
        // Requester
        table.append("<tr><td style=\"color:").append(TEXT_MUTED).append(";\">\u0E1C\u0E39\u0E49\u0E02\u0E2D (Requester)</td>")
            .append("<td style=\"color:").append(TEXT_DARK).append(";\">EMP ").append(requesterEmpId).append("</td></tr>\n");
        table.append("</table>\n");
        return table.toString();
    }

    // ---------------------------------------------------------------
    //  Status badge
    // ---------------------------------------------------------------

    private static String statusBadgeHtml(int stateStep) {
        String label = EmailContentBuilder.resolveWorkflowStepLabel(stateStep);
        String bgColor;
        if (stateStep == 5) {
            bgColor = SUCCESS;
        } else if (stateStep < 0) {
            bgColor = REJECTED;
        } else if (stateStep <= 3) {
            bgColor = GOLD;
        } else {
            bgColor = CURRENT_BLUE;
        }
        return "<span style=\"display:inline-block;background-color:" + bgColor
            + ";color:#ffffff;font-size:11px;font-weight:bold;padding:4px 12px;border-radius:12px;white-space:nowrap;\">"
            + escapeHtml(label) + "</span>\n";
    }

    // ---------------------------------------------------------------
    //  Current status
    // ---------------------------------------------------------------

    private static String currentStatusHtml(int stateStep) {
        String label = EmailContentBuilder.resolveWorkflowStepLabel(stateStep);
        String dotColor = (stateStep == 5) ? SUCCESS : (stateStep < 0) ? REJECTED : CURRENT_BLUE;
        return "<div style=\"font-size:15px;font-weight:bold;color:" + TEXT_DARK + ";\">"
            + "<span style=\"color:" + dotColor + ";font-size:18px;margin-right:6px;\">\u25CF</span>"
            + escapeHtml(label) + "</div>\n";
    }

    // ---------------------------------------------------------------
    //  Workflow timeline — horizontal tracking layout
    // ---------------------------------------------------------------

    private static String renderHorizontalTimelineHtml(int stateStep) {
        StringBuilder html = new StringBuilder();

        String[] stepLabels = {
            "Director",
            "Technical",
            "IT Director",
            "Technician",
            "Requestor",
            "Complete"
        };

        boolean rejected = stateStep < 0;
        int absoluteStep = rejected ? Math.abs(stateStep) - 1 : stateStep;

        // Outer table: single row with 6 cells
        html.append("<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\">\n");
        html.append("<tr>\n");

        for (int i = 0; i < stepLabels.length; i++) {
            int stepValue = i;
            String circleColor;
            String lineBefore = (i > 0) ? "block" : "none";
            String lineAfter = (i < stepLabels.length - 1) ? "block" : "none";
            String lineColor = GRAY;
            String statusIcon;
            boolean isBold = false;

            if (rejected && stepValue == absoluteStep) {
                circleColor = REJECTED;
                statusIcon = "\u2716";
            } else if (stepValue < absoluteStep || (stateStep == 5 && stepValue == 5)) {
                circleColor = SUCCESS;
                statusIcon = "\u2713";
                lineColor = SUCCESS;
            } else if (stepValue == absoluteStep && !rejected && stateStep != 5) {
                circleColor = CURRENT_BLUE;
                statusIcon = "\u25CF";
                isBold = true;
            } else {
                circleColor = GRAY;
                statusIcon = "\u25CB";
            }

            html.append("<td width=\"").append(100 / stepLabels.length).append("%\" align=\"center\" valign=\"top\" style=\"padding:4px 2px;\">\n");

            // Row: [thin line] [circle] [thin line]
            html.append("<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\">\n");
            html.append("<tr>\n");
            // Left connector (thin line between circles)
            html.append("<td width=\"").append(i == 0 ? "0" : "25").append("%\" style=\"text-align:center;\">\n");
            html.append("<div style=\"height:3px;background-color:").append(lineColor).append(";margin-top:13px;\"></div>\n");
            html.append("</td>\n");
            // Circle
            html.append("<td width=\"30\" style=\"text-align:center;\">\n");
            html.append("<div style=\"width:28px;height:28px;border-radius:14px;background-color:").append(circleColor)
                .append(";color:#ffffff;font-size:13px;line-height:28px;text-align:center;margin:0 auto;font-weight:bold;\">")
                .append(statusIcon).append("</div>\n");
            html.append("</td>\n");
            // Right connector
            html.append("<td width=\"").append(i == stepLabels.length - 1 ? "0" : "25").append("%\" style=\"text-align:center;\">\n");
            html.append("<div style=\"height:3px;background-color:").append(lineColor).append(";margin-top:13px;\"></div>\n");
            html.append("</td>\n");
            html.append("</tr>\n");
            html.append("</table>\n");

            // Label below circle
            html.append("<div style=\"font-size:12px;color:").append(circleColor).append(";font-weight:").append(isBold ? "bold" : "normal").append(";text-align:center;margin-top:4px;white-space:nowrap;\">")
                .append(escapeHtml(stepLabels[i])).append("</div>\n");

            html.append("</td>\n");
        }

        html.append("</tr>\n");
        html.append("</table>\n");
        return html.toString();
    }

    // ---------------------------------------------------------------
    //  Approval history
    // ---------------------------------------------------------------

    private static String approvalHistoryHtml(List<ApprovalHistoryEntry> history) {
        if (history == null || history.isEmpty()) {
            return "<div style=\"font-size:13px;color:" + TEXT_MUTED + ";\">- \u0E22\u0E31\u0E07\u0E44\u0E21\u0E48\u0E21\u0E35\u0E1B\u0E23\u0E30\u0E27\u0E31\u0E15\u0E34\u0E01\u0E32\u0E23\u0E2D\u0E19\u0E38\u0E21\u0E31\u0E15\u0E34</div>\n";
        }

        StringBuilder html = new StringBuilder();
        html.append("<table width=\"100%\" cellpadding=\"6\" cellspacing=\"0\" style=\"font-size:13px;\">\n");
        html.append("<tr style=\"background-color:").append(NAVY).append(";\">");
        html.append("<th style=\"text-align:left;padding:8px;color:#ffffff;\">\u0E02\u0E31\u0E49\u0E19\u0E15\u0E2D\u0E19</th>");
        html.append("<th style=\"text-align:left;padding:8px;color:#ffffff;\">\u0E1C\u0E39\u0E49\u0E14\u0E33\u0E40\u0E19\u0E34\u0E19\u0E01\u0E32\u0E23</th>");
        html.append("<th style=\"text-align:left;padding:8px;color:#ffffff;\">\u0E27\u0E31\u0E19\u0E17\u0E35\u0E48</th>");
        html.append("</tr>\n");

        String altColor = "#F9F9F9";
        for (int i = 0; i < history.size(); i++) {
            ApprovalHistoryEntry entry = history.get(i);
            String rowBg = (i % 2 == 0) ? "#ffffff" : altColor;
            String rowStyle = "background-color:" + rowBg + ";border-bottom:1px solid " + BORDER_LIGHT + ";";

            html.append("<tr style=\"").append(rowStyle).append("\">");
            html.append("<td style=\"padding:8px;\">").append(escapeHtml(entry.getActionLabel())).append("</td>");
            html.append("<td style=\"padding:8px;\">");
            if (entry.getReviewerEmpId() != null) {
                html.append("EMP ").append(entry.getReviewerEmpId());
            } else {
                html.append("-");
            }
            html.append("</td>");
            html.append("<td style=\"padding:8px;\">");
            if (entry.getApprovedDate() != null) {
                html.append(DATE_FORMAT.format(new Date(entry.getApprovedDate().getTime())));
            } else {
                html.append("-");
            }
            html.append("</td>");
            html.append("</tr>\n");
            if (entry.getComment() != null && !entry.getComment().trim().isEmpty()) {
                String commentStyle = "background-color:" + rowBg + ";border-bottom:1px solid " + BORDER_LIGHT + ";";
                html.append("<tr style=\"").append(commentStyle).append("\">");
                html.append("<td colspan=\"3\" style=\"padding:2px 8px 6px 8px;font-style:italic;color:").append(TEXT_MUTED).append(";\">");
                html.append("\u0E2B\u0E21\u0E32\u0E22\u0E40\u0E2B\u0E15\u0E38: ").append(escapeHtml(entry.getComment().trim()));
                html.append("</td></tr>\n");
            }
        }

        html.append("</table>\n");
        return html.toString();
    }

    // ---------------------------------------------------------------
    //  Rejection details
    // ---------------------------------------------------------------

    private static String rejectionDetailsHtml(int stateStep, String comment) {
        String rejectedBy = "\u0E1C\u0E39\u0E49\u0E40\u0E01\u0E35\u0E48\u0E22\u0E27\u0E02\u0E49\u0E2D\u0E07";
        switch (stateStep) {
            case -1: rejectedBy = "Director"; break;
            case -2: rejectedBy = "Technical / \u0E2B\u0E31\u0E27\u0E2B\u0E19\u0E49\u0E32\u0E2A\u0E48\u0E27\u0E19\u0E07\u0E32\u0E19"; break;
            case -3: rejectedBy = "IT Director"; break;
            case -4: rejectedBy = "Technician"; break;
            case -5: rejectedBy = "Requestor"; break;
            default: break;
        }

        StringBuilder html = new StringBuilder();
        html.append("<div style=\"background-color:#FFF5F5;border:1px solid #FCC;border-radius:6px;padding:12px;\">\n");
        html.append("<div style=\"font-size:14px;color:").append(REJECTED).append(";font-weight:bold;\">")
            .append("\u274C \u0E02\u0E31\u0E49\u0E19\u0E15\u0E2D\u0E19\u0E17\u0E35\u0E48\u0E16\u0E39\u0E01\u0E1B\u0E0F\u0E34\u0E40\u0E2A\u0E18: ")
            .append(escapeHtml(rejectedBy)).append("</div>\n");
        if (comment != null && !comment.trim().isEmpty()) {
            html.append("<div style=\"font-size:13px;color:").append(TEXT_DARK).append(";margin-top:6px;\">")
                .append("\u0E2B\u0E21\u0E32\u0E22\u0E40\u0E2B\u0E15\u0E38: ").append(escapeHtml(comment.trim()))
                .append("</div>\n");
        }
        html.append("</div>\n");
        return html.toString();
    }

    // ---------------------------------------------------------------
    //  Action button (static navy, no hover)
    // ---------------------------------------------------------------

    private static String actionButtonHtml(String url) {
        StringBuilder btn = new StringBuilder();
        btn.append("<!--[if mso]>\n");
        btn.append("<v:roundrect xmlns:v=\"urn:schemas-microsoft-com:vml\" xmlns:w=\"urn:schemas-microsoft-com:office:word\" href=\"")
            .append(escapeHtml(url)).append("\" style=\"height:44px;v-text-anchor:middle;width:280px;\" arcsize=\"10%\" strokecolor=\"").append(NAVY).append("\" fillcolor=\"").append(NAVY).append("\">\n");
        btn.append("<w:anchorlock/><center style=\"color:#ffffff;font-family:").append(FONT_STACK).append(";font-size:15px;font-weight:bold;\">");
        btn.append("\u0E14\u0E39\u0E23\u0E32\u0E22\u0E25\u0E30\u0E40\u0E2D\u0E35\u0E22\u0E14\u0E04\u0E33\u0E02\u0E2D");
        btn.append("</center>\n");
        btn.append("</v:roundrect>\n");
        btn.append("<![endif]-->\n");
        btn.append("<!--[if !mso]><!-->\n");
        btn.append("<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\"><tr><td align=\"center\">\n");
        btn.append("<a href=\"").append(escapeHtml(url)).append("\" target=\"_blank\" style=\"display:inline-block;background-color:").append(NAVY).append(";color:#ffffff;text-decoration:none;font-size:15px;font-weight:bold;padding:12px 32px;border-radius:22px;\">");
        btn.append("\u0E14\u0E39\u0E23\u0E32\u0E22\u0E25\u0E30\u0E40\u0E2D\u0E35\u0E22\u0E14\u0E04\u0E33\u0E02\u0E2D");
        btn.append("</a>\n");
        btn.append("</td></tr></table>\n");
        btn.append("<!--<![endif]-->\n");
        return btn.toString();
    }

    // ---------------------------------------------------------------
    //  HTML stripping for plain-text fallback
    // ---------------------------------------------------------------

    /**
     * Strips HTML tags from the given string, producing a clean plain-text
     * version suitable for multipart/alternative email fallback.
     */
    public static String stripHtml(String html) {
        if (html == null) return "";
        String text = html;
        text = text.replaceAll("(?i)<br\\s*/?>", "\n");
        text = text.replaceAll("(?i)<(p|div|tr|li|h[1-6])(\\s[^>]*)?>", "\n");
        text = text.replaceAll("(?i)</(p|div|tr|li|h[1-6])>", "\n");
        text = text.replaceAll("<[^>]*>", "");
        text = text.replace("\u00A0", " ");
        text = text.replace(AMP, "&");
        text = text.replace(LT, "<");
        text = text.replace(GT, ">");
        text = text.replace(QUOT, "\"");
        text = text.replaceAll("&#\\d+;", "");
        text = text.replaceAll("\\n{3,}", "\n\n");
        text = text.trim();
        return text;
    }

    // ---------------------------------------------------------------
    //  URL building
    // ---------------------------------------------------------------

    /**
     * Builds a full URL from an optional base URL and a required relative path.
     * If base URL is null, returns the relative path only.
     */
    public static String buildFullUrl(String baseUrl, String relativePath) {
        if (baseUrl == null || baseUrl.trim().isEmpty()) {
            return relativePath != null ? relativePath : "";
        }
        String base = baseUrl.trim();
        while (base.endsWith("/")) {
            base = base.substring(0, base.length() - 1);
        }
        String path = (relativePath != null) ? relativePath.trim() : "";
        if (!path.startsWith("/")) {
            path = "/" + path;
        }
        return base + path;
    }

    // ---------------------------------------------------------------
    //  HTML escaping
    // ---------------------------------------------------------------

    private static String escapeHtml(String text) {
        if (text == null) return "";
        StringBuilder out = new StringBuilder(text.length());
        for (int i = 0; i < text.length(); i++) {
            char c = text.charAt(i);
            switch (c) {
                case '&': out.append(AMP); break;
                case '<': out.append(LT); break;
                case '>': out.append(GT); break;
                case '"': out.append(QUOT); break;
                case '\'': out.append("&#39;"); break;
                default: out.append(c);
            }
        }
        return out.toString();
    }
}