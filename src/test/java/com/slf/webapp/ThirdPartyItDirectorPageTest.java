package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartyItDirectorPageTest extends TestCase {

    public void testItDirectorWorkflowPagesAndTransitionAreConnected() throws Exception {
        String index = read("src/main/webapp/index.jsp");
        String inbox = read("src/main/webapp/WEB-INF/third-party-it-director-inbox.jsp");
        String review = read("src/main/webapp/WEB-INF/third-party-it-director-review.jsp");
        String workflowDao = read("src/main/java/com/slf/dao/ThirdPartyWorkflowDAO.java");

        assertTrue(index.contains("/thirdParty/itDirector"));
        assertTrue(inbox.contains("/thirdParty/itDirector/review?id="));
        assertTrue(inbox.contains("<a class=\"item\""));
        assertFalse(inbox.contains("String[] buttons="));
        assertFalse(inbox.contains("class=\"btn btn-primary primary-action\""));
        assertTrue(review.contains("ความเห็นหัวหน้าส่วน"));
        assertTrue(review.contains("assignmentLabel"));
        assertTrue(review.contains("name=\"comment\""));
        assertTrue(review.contains("value=\"approve\""));
        assertTrue(review.contains("value=\"reject\""));
        assertTrue(review.contains("e.persisted"));

        assertTrue(workflowDao.contains("IT_DIRECTOR_APPROVED"));
        assertTrue(workflowDao.contains("IT_DIRECTOR_REJECTED"));
        assertTrue(workflowDao.contains("PENDING_OPERATOR"));
        assertTrue(workflowDao.contains("REJECTED"));
        assertTrue(workflowDao.contains("WHERE REQUEST_ID = ? AND STATUS = 'PENDING_IT_DIRECTOR'"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
