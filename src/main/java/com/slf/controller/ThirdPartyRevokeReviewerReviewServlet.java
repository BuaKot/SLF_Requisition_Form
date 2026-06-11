package com.slf.controller;

import com.slf.dao.ThirdPartyWorkflowDAO;
import java.sql.SQLException;
import javax.servlet.annotation.WebServlet;

@WebServlet("/thirdParty/revokeReviewer/review")
public class ThirdPartyRevokeReviewerReviewServlet extends ThirdPartyAssignedCompletionReviewServlet {
    private final ThirdPartyWorkflowDAO workflowDAO = new ThirdPartyWorkflowDAO();

    protected String expectedStatus() { return "PENDING_REVOKE_REVIEWER"; }
    protected String assignmentRole() { return "REVOKE_REVIEWER"; }
    protected String pageRole() { return "ผู้ตรวจทาน"; }
    protected String pageTitle() { return "ตรวจทานการยกเลิกสิทธิ์"; }
    protected String detailLabel() { return "รายละเอียดการตรวจทาน"; }
    protected String detailParameter() { return "reviewDetail"; }
    protected String servletPath() { return "/thirdParty/revokeReviewer/review"; }
    protected boolean submit(long requestId, int actorEmpId, String detail) throws SQLException {
        return workflowDAO.submitRevokeReviewerCompletion(requestId, actorEmpId, detail);
    }
}
