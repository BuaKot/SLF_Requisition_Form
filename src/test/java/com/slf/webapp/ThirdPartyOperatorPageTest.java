package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartyOperatorPageTest extends TestCase {

    public void testOperatorWorkflowIsAssignedAndHasNoRejectButton() throws Exception {
        String index = read("src/main/webapp/index.jsp");
        String inbox = read("src/main/webapp/WEB-INF/views/ThirdPartyOperatorInbox.jsp");
        String review = read("src/main/webapp/WEB-INF/views/ThirdPartyOperatorReview.jsp");
        String styles = read("src/main/webapp/css/styles.css");
        String requestDao = read("src/main/java/com/slf/dao/ThirdPartyRequestDAO.java");
        String workflowDao = read("src/main/java/com/slf/dao/ThirdPartyWorkflowDAO.java");

        assertTrue(index.contains("/thirdParty/operator"));
        assertTrue(inbox.contains("/thirdParty/operator/review?id="));
        assertTrue(inbox.contains("/thirdParty/revoker/review?id="));
        assertTrue(inbox.contains("/thirdParty/revokeReviewer/review?id="));
        assertTrue(inbox.contains("class=\"workflow-item <%= groupClasses[groupIndex] %>\""));
        assertTrue(inbox.contains("String[] groupClasses={\"grant\",\"revoke\",\"reviewer\"}"));
        assertTrue(styles.contains(".workflow-item.revoke"));
        assertFalse(inbox.contains("class=\"btn btn-primary primary-action\""));
        assertFalse(inbox.contains("class=\"workflow-open\""));
        assertTrue(review.contains("ความเห็นหัวหน้าส่วน"));
        assertTrue(review.contains("ความเห็น IT Director"));
        assertTrue(review.contains("name=\"operationDetail\""));
        assertTrue(review.contains("บันทึกและส่งตรวจรับ"));
        assertFalse(review.contains("value=\"reject\""));

        assertTrue(requestDao.contains("findAssignedByStatus"));
        assertTrue(requestDao.contains("a.ASSIGNMENT_ROLE = ? AND a.ASSIGNED_EMPID = ?"));
        assertTrue(workflowDao.contains("OPERATOR_COMPLETED"));
        assertTrue(workflowDao.contains("PENDING_EXTERNAL_ACCEPTANCE"));
        assertTrue(workflowDao.contains("INSERT INTO THIRD_PARTY_ACCEPTANCE_TOKEN"));
        assertTrue(workflowDao.contains("a.ASSIGNMENT_ROLE = 'GRANT_OPERATOR' AND a.ASSIGNED_EMPID = ?"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
