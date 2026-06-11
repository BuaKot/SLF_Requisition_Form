package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartyRevocationWorkflowPageTest extends TestCase {

    public void testRevokerAndReviewerWorkflowPages() throws Exception {
        String inbox = read("src/main/webapp/WEB-INF/third-party-operator-inbox.jsp");
        String review = read("src/main/webapp/WEB-INF/third-party-assigned-completion-review.jsp");
        String workflowDao = read("src/main/java/com/slf/dao/ThirdPartyWorkflowDAO.java");
        String acceptanceDao = read("src/main/java/com/slf/dao/ThirdPartyAcceptanceDAO.java");

        assertTrue(inbox.contains("/thirdParty/revoker/review?id="));
        assertTrue(inbox.contains("/thirdParty/revokeReviewer/review?id="));
        assertTrue(review.contains("ความเห็นหัวหน้าส่วน"));
        assertTrue(review.contains("ความเห็น IT Director"));
        assertTrue(review.contains("รายละเอียดการให้สิทธิ์"));
        assertTrue(review.contains("ผลตรวจรับและประเมิน"));
        assertTrue(review.contains("รายละเอียดการยกเลิกสิทธิ์"));
        assertFalse(review.contains("value=\"reject\""));

        assertTrue(workflowDao.contains("REVOKER_COMPLETED"));
        assertTrue(workflowDao.contains("REVOKE_REVIEWER_APPROVED"));
        assertTrue(workflowDao.contains("PENDING_REVOKE_REVIEWER"));
        assertTrue(workflowDao.contains("PENDING_SECTION_HEAD_REPORT"));
        assertTrue(workflowDao.contains("a.ASSIGNMENT_ROLE = ? AND a.ASSIGNED_EMPID = ?"));
        assertTrue(acceptanceDao.contains("FROM THIRD_PARTY_ACCEPTANCE_RESULT WHERE REQUEST_ID = ?"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
