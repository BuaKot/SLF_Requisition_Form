package com.slf.controller;

import com.slf.dao.ThirdPartyAcceptanceDAO;
import com.slf.dao.ThirdPartyFormSubmissionDAO;
import com.slf.dao.ThirdPartyRequestDAO;
import com.slf.dao.ThirdPartyWorkflowDAO;
import com.slf.model.ThirdPartyAccessRequest;
import com.slf.model.ThirdPartyFormSubmission;
import com.slf.model.ThirdPartyRequest;
import com.slf.model.ThirdPartyWorkflowActionEntry;
import com.slf.util.ThirdPartyAccessPolicy;
import java.io.IOException;
import java.io.OutputStream;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.xhtmlrenderer.pdf.ITextRenderer;

@WebServlet("/thirdParty/exportPdf")
public class ThirdPartyExportPDFServlet extends HttpServlet {
    private final ThirdPartyAcceptanceDAO acceptanceDAO = new ThirdPartyAcceptanceDAO();
    private final ThirdPartyFormSubmissionDAO submissionDAO = new ThirdPartyFormSubmissionDAO();
    private final ThirdPartyRequestDAO requestDAO = new ThirdPartyRequestDAO();
    private final ThirdPartyWorkflowDAO workflowDAO = new ThirdPartyWorkflowDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        long submissionId;
        try {
            submissionId = parseSubmissionId(request.getParameter("submissionId"));
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
            return;
        }

        HttpSession session = request.getSession(false);
        Integer empId = ThirdPartyAccessPolicy.sessionEmpId(session);
        String position = session == null ? null : (String) session.getAttribute("position");
        if (empId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            ThirdPartyFormSubmission submission = submissionDAO.findById(submissionId);
            if (submission == null || submission.getRequestId() == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            if (!ThirdPartyAccessPolicy.canViewSubmission(position, empId, submission.getInternalOwnerEmpId())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            ThirdPartyRequest thirdPartyRequest = requestDAO.findById(submission.getRequestId().longValue());
            List<ThirdPartyWorkflowActionEntry> workflow =
                workflowDAO.findActionHistory(submission.getRequestId().longValue());
            if (thirdPartyRequest == null || (!"COMPLETED".equals(thirdPartyRequest.getStatus())
                    && !hasFinalCertification(workflow))) {
                response.sendError(HttpServletResponse.SC_CONFLICT, "PDF export is available after completion only.");
                return;
            }

            Integer acceptanceScore = hasExternalAcceptance(workflow)
                ? acceptanceDAO.findSatisfactionLevelByRequestId(submission.getRequestId().longValue())
                : null;
            renderPdf(request, response, submission, thirdPartyRequest, workflow, acceptanceScore);
        } catch (SQLException e) {
            throw new ServletException("Unable to export third-party submission PDF", e);
        }
    }

    static long parseSubmissionId(String value) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException("Missing submissionId.");
        }
        long id = Long.parseLong(value.trim());
        if (id <= 0) {
            throw new IllegalArgumentException("Invalid submissionId.");
        }
        return id;
    }

    private void renderPdf(HttpServletRequest request, HttpServletResponse response,
                           ThirdPartyFormSubmission submission, ThirdPartyRequest thirdPartyRequest,
                           List<ThirdPartyWorkflowActionEntry> workflow, Integer acceptanceScore)
            throws ServletException, IOException {
        String fontPath = getServletContext().getRealPath("/WEB-INF/classes/fonts/Anuphan-Regular.ttf");
        String html = buildHtml(fontPath, submission, thirdPartyRequest, workflow, acceptanceScore);

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition",
            "inline; filename=\"ThirdParty_Submission_" + submission.getSubmissionId() + ".pdf\"");
        try (OutputStream os = response.getOutputStream()) {
            ITextRenderer renderer = new ITextRenderer();
            renderer.setDocumentFromString(html);
            renderer.layout();
            renderer.createPDF(os);
        } catch (Exception e) {
            throw new ServletException("Unable to render third-party PDF", e);
        }
    }

    private String buildHtml(String fontPath, ThirdPartyFormSubmission submission,
                             ThirdPartyRequest request, List<ThirdPartyWorkflowActionEntry> workflow,
                             Integer acceptanceScore) {
        SimpleDateFormat date = new SimpleDateFormat("dd/MM/yyyy");
        SimpleDateFormat dateTime = new SimpleDateFormat("dd/MM/yyyy HH:mm");
        String fontUrl = fontPath == null ? "" : "file:///" + fontPath.replace("\\", "/");
        StringBuilder html = new StringBuilder();
        html.append("<!DOCTYPE html><html><head><meta charset='UTF-8'/>")
            .append("<style>")
            .append("@page{size:a4;margin:14mm 14mm 18mm 14mm;}")
            .append("@font-face{font-family:'Anuphan';src:url('").append(fontUrl)
            .append("');-fs-pdf-font-embed:embed;-fs-pdf-font-encoding:Identity-H;}")
            .append("body{font-family: 'Anuphan',sans-serif;color:#102a43;font-size:12pt;line-height:1.45;}")
            .append(".top{border-bottom:3px solid #0d4b8f;padding-bottom:10px;margin-bottom:16px;}")
            .append(".org{font-size:11pt;color:#52606d;font-weight:700;}")
            .append("h1{font-size:18pt;color:#003366;margin:6px 0 2px;}")
            .append(".subtitle{color:#52606d;font-size:11pt;}")
            .append(".section{margin-top:14px;page-break-inside:avoid;}")
            .append(".section-title{font-size:13pt;color:#003366;font-weight:800;border-bottom:1px solid #d8e4ef;padding-bottom:4px;margin-bottom:8px;}")
            .append("table{width:100%;border-collapse:collapse;}td,th{border:1px solid #d8e4ef;padding:6px;vertical-align:top;}th{background:#eef5fb;color:#003366;text-align:left;font-weight:800;}")
            .append(".label{width:27%;font-weight:800;color:#334e68;background:#f7fbff;}")
            .append(".status{display:inline-block;padding:4px 9px;border-radius:999px;background:#dcf7e8;color:#197344;font-weight:800;}")
            .append(".small{font-size:10pt;color:#64748b;}")
            .append("</style></head><body>");

        html.append("<div class='top'>")
            .append("<div class='org'>Student Loan Fund / SLF Requisition Form</div>")
            .append("<h1>แบบฟอร์มการขอลงทะเบียนผู้ใช้ระบบงานสารสนเทศ สำหรับผู้ให้บริการภายนอก</h1>")
            .append("<div class='subtitle'>Third Party Registration Summary • Request #")
            .append(request.getRequestId()).append(" • Submission #").append(submission.getSubmissionId())
            .append("</div></div>");

        html.append("<div class='section'><div class='section-title'>Request Information</div><table>")
            .append(row("Status", "<span class='status'>COMPLETED</span>"))
            .append(row("Document No.", h(submission.getDocumentReceiveNo())))
            .append(row("Company / Organization", h(submission.getOrganization())))
            .append(row("External Contact", h(submission.getFullNameTh())))
            .append(row("Email", h(submission.getEmail())))
            .append(row("Phone", h(submission.getPhone())))
            .append(row("Target System", h(submission.getProjectName())))
            .append(row("Purpose", h(submission.getReasonObjective())))
            .append(row("Access Period", formatDate(submission.getAccessStartDate(), date)
                + " - " + formatDate(submission.getAccessEndDate(), date)))
            .append("</table></div>");

        html.append("<div class='section'><div class='section-title'>Access Users</div><table><thead><tr>")
            .append("<th>#</th><th>Name</th><th>Position</th><th>Department</th><th>Email</th><th>System / Role</th>")
            .append("</tr></thead><tbody>");
        for (ThirdPartyAccessRequest item : submission.getAccessRequests()) {
            html.append("<tr><td>").append(item.getDisplayOrder()).append("</td>")
                .append("<td>").append(h(item.getFullNameTh())).append("<br/><span class='small'>")
                .append(h(item.getUsername())).append("</span></td>")
                .append("<td>").append(h(item.getPositionName())).append("</td>")
                .append("<td>").append(h(item.getDepartmentName())).append("</td>")
                .append("<td>").append(h(item.getEmail())).append("</td>")
                .append("<td>").append(h(item.getSystemName())).append("<br/><span class='small'>")
                .append(h(item.getRequestedRole())).append("</span></td></tr>");
        }
        html.append("</tbody></table></div>");

        html.append("<div class='section'><div class='section-title'>Workflow History</div><table><thead><tr>")
            .append("<th>Step</th><th>Actor</th><th>Position</th><th>Action Time</th><th>Comment</th>")
            .append("</tr></thead><tbody>");
        for (ThirdPartyWorkflowActionEntry action : workflow) {
            html.append("<tr><td>").append(h(action.getActionType())).append("</td>")
                .append("<td>").append(h(actorName(action))).append("</td>")
                .append("<td>").append(h(action.getActorPosition())).append("</td>")
                .append("<td>").append(action.getActedAt() == null ? "-" : dateTime.format(action.getActedAt())).append("</td>")
                .append("<td>").append(h(action.getCommentText())).append("</td></tr>");
        }
        html.append("</tbody></table>");
        if (acceptanceScore != null) {
            html.append("<p class='small'>Acceptance satisfaction score: ").append(acceptanceScore).append("</p>");
        }
        html.append("</div></body></html>");
        return html.toString();
    }

    private static String row(String label, String value) {
        return "<tr><td class='label'>" + h(label) + "</td><td>" + (value == null || value.isEmpty() ? "-" : value) + "</td></tr>";
    }

    private static String formatDate(java.util.Date value, SimpleDateFormat formatter) {
        return value == null ? "-" : formatter.format(value);
    }

    private static String actorName(ThirdPartyWorkflowActionEntry action) {
        if (action == null) return "-";
        if (action.getActorEmpName() != null && !action.getActorEmpName().trim().isEmpty()) {
            return action.getActorEmpName();
        }
        if ("SYSTEM".equals(action.getActorType())) return "System";
        if ("EXTERNAL".equals(action.getActorType())) return "External requester";
        return action.getActorEmpId() == null ? "-" : "Employee #" + action.getActorEmpId();
    }

    private static boolean hasFinalCertification(List<ThirdPartyWorkflowActionEntry> workflow) {
        for (ThirdPartyWorkflowActionEntry action : workflow) {
            if ("FINAL_CERTIFIED".equals(action.getActionType())) return true;
        }
        return false;
    }

    private static boolean hasExternalAcceptance(List<ThirdPartyWorkflowActionEntry> workflow) {
        for (ThirdPartyWorkflowActionEntry action : workflow) {
            if ("EXTERNAL_ACCEPTED".equals(action.getActionType())) return true;
        }
        return false;
    }

    private static String h(Object input) {
        if (input == null) return "";
        return String.valueOf(input)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }
}
