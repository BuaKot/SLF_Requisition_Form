package com.slf.controller;

import com.slf.dao.ThirdPartyWorkflowDAO;
import java.sql.SQLException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpSession;

@WebServlet("/thirdParty/itDirector/certify")
public class ThirdPartyFinalCertificationServlet extends ThirdPartyFinalStageReviewServlet {
    private final ThirdPartyWorkflowDAO workflowDAO = new ThirdPartyWorkflowDAO();
    protected boolean authorized(HttpSession session) { return ThirdPartyItDirectorInboxServlet.isItDirector(session); }
    protected String expectedStatus() { return "PENDING_FINAL_CERTIFICATION"; }
    protected String pageRole() { return "IT Director"; }
    protected String pageTitle() { return "เซ็นรับรองแบบฟอร์ม"; }
    protected String servletPath() { return "/thirdParty/itDirector/certify"; }
    protected String inboxPath() { return "/thirdParty/itDirector"; }
    protected boolean showReportField() { return false; }
    protected boolean submit(long requestId, int actorEmpId, String report) throws SQLException {
        return workflowDAO.submitFinalCertification(requestId, actorEmpId);
    }
}
