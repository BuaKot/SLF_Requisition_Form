package com.slf.controller;

import com.slf.dao.ThirdPartyWorkflowDAO;
import java.sql.SQLException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpSession;

@WebServlet("/thirdParty/sectionHead/report")
public class ThirdPartySectionHeadReportServlet extends ThirdPartyFinalStageReviewServlet {
    private final ThirdPartyWorkflowDAO workflowDAO = new ThirdPartyWorkflowDAO();
    protected boolean authorized(HttpSession session) { return ThirdPartySectionHeadInboxServlet.isTechnical(session); }
    protected String expectedStatus() { return "PENDING_SECTION_HEAD_REPORT"; }
    protected String pageRole() { return "หัวหน้าส่วน"; }
    protected String pageTitle() { return "เขียนรายงานสรุป"; }
    protected String servletPath() { return "/thirdParty/sectionHead/report"; }
    protected String inboxPath() { return "/thirdParty/sectionHead"; }
    protected boolean showReportField() { return true; }
    protected boolean submit(long requestId, int actorEmpId, String report) throws SQLException {
        return workflowDAO.submitSectionHeadReport(requestId, actorEmpId, report);
    }
}
