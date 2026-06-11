package com.slf.controller;

import com.slf.dao.ThirdPartyWorkflowDAO;
import java.sql.SQLException;
import javax.servlet.annotation.WebServlet;

@WebServlet("/thirdParty/revoker/review")
public class ThirdPartyRevokerReviewServlet extends ThirdPartyAssignedCompletionReviewServlet {
    private final ThirdPartyWorkflowDAO workflowDAO = new ThirdPartyWorkflowDAO();

    protected String expectedStatus() { return "PENDING_REVOKER"; }
    protected String assignmentRole() { return "REVOKE_OPERATOR"; }
    protected String pageRole() { return "ผู้ยกเลิกสิทธิ์"; }
    protected String pageTitle() { return "ดำเนินการยกเลิกสิทธิ์"; }
    protected String detailLabel() { return "รายละเอียดการยกเลิกสิทธิ์"; }
    protected String detailParameter() { return "revocationDetail"; }
    protected String servletPath() { return "/thirdParty/revoker/review"; }
    protected boolean submit(long requestId, int actorEmpId, String detail) throws SQLException {
        return workflowDAO.submitRevokerCompletion(requestId, actorEmpId, detail);
    }
}
