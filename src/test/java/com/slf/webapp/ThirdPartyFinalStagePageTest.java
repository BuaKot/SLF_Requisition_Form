package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartyFinalStagePageTest extends TestCase {

    public void testSectionHeadReportAndFinalCertificationAreConnected() throws Exception {
        String sectionInbox = read("src/main/webapp/WEB-INF/third-party-section-head-inbox.jsp");
        String directorInbox = read("src/main/webapp/WEB-INF/third-party-it-director-inbox.jsp");
        String review = read("src/main/webapp/WEB-INF/third-party-final-stage-review.jsp");
        String workflowDao = read("src/main/java/com/slf/dao/ThirdPartyWorkflowDAO.java");

        assertTrue(sectionInbox.contains("/thirdParty/sectionHead/report?id="));
        assertTrue(directorInbox.contains("/thirdParty/itDirector/certify?id="));
        assertTrue(review.contains("name=\"summaryReport\""));
        assertTrue(review.contains("ผลตรวจรับและประเมิน"));
        assertTrue(review.contains("รายละเอียดการตรวจทาน"));
        assertTrue(review.contains("รายงานสรุปหัวหน้าส่วน"));
        assertTrue(review.contains("ผู้ได้รับมอบหมาย"));
        assertTrue(review.contains("อนุมัติและเซ็นรับรองแบบฟอร์ม"));
        assertFalse(review.contains("value=\"reject\""));

        assertTrue(workflowDao.contains("SECTION_HEAD_REPORTED"));
        assertTrue(workflowDao.contains("PENDING_FINAL_CERTIFICATION"));
        assertTrue(workflowDao.contains("FINAL_CERTIFIED"));
        assertTrue(workflowDao.contains("SET STATUS = 'COMPLETED'"));
        assertTrue(workflowDao.contains("COMMENT_TEXT, ACTED_AT)"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
