package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartyAcceptancePageTest extends TestCase {

    public void testAcceptanceFlowCreatesLinkAndHidesApprovalComments() throws Exception {
        String migration = read("sql/2026-06-11_third_party_acceptance.sql");
        String workflowDao = read("src/main/java/com/slf/dao/ThirdPartyWorkflowDAO.java");
        String acceptanceDao = read("src/main/java/com/slf/dao/ThirdPartyAcceptanceDAO.java");
        String publicPage = read("src/main/webapp/thirdpartyAcceptance.jsp");
        String ownerPage = read("src/main/webapp/third-party-request-new.jsp");
        String styles = read("src/main/webapp/css/styles.css");

        assertTrue(migration.contains("CREATE TABLE THIRD_PARTY_ACCEPTANCE_TOKEN"));
        assertTrue(migration.contains("CREATE TABLE THIRD_PARTY_ACCEPTANCE_RESULT"));
        assertTrue(workflowDao.contains("INSERT INTO THIRD_PARTY_ACCEPTANCE_TOKEN"));
        assertTrue(acceptanceDao.contains("EXTERNAL_ACCEPTED"));
        assertTrue(acceptanceDao.contains("PENDING_REVOKER"));

        assertTrue(publicPage.contains("ข้อมูลที่ท่านเคยกรอก"));
        assertTrue(publicPage.contains("รายละเอียดการดำเนินงาน"));
        assertTrue(publicPage.contains("name=\"satisfactionLevel\""));
        assertTrue(publicPage.contains("name=\"comment\""));
        assertFalse(publicPage.contains("ความเห็นหัวหน้าส่วน"));
        assertFalse(publicPage.contains("ความเห็น IT Director"));
        assertFalse(publicPage.contains("assignment"));

        assertTrue(ownerPage.contains("ลิงก์สำหรับตรวจรับและประเมิน"));
        assertTrue(ownerPage.contains("copyAcceptanceLink"));
        assertTrue(ownerPage.contains("owner-link-dashboard"));
        assertTrue(ownerPage.contains("owner-acceptance-panel"));
        assertTrue(ownerPage.contains("acceptance-link-card"));
        assertTrue(ownerPage.contains("acceptance-generated-link"));
        assertTrue(ownerPage.contains("owner-request-list-panel"));
        assertTrue(styles.contains("\"requests acceptance\""));
        assertTrue(styles.contains(".owner-link-dashboard .owner-request-list-panel"));
        assertTrue(styles.contains(".owner-link-dashboard .owner-acceptance-panel"));
        assertTrue(styles.contains(".owner-acceptance-panel .acceptance-link-card"));
        assertTrue(styles.contains(".owner-acceptance-panel .generated-link-box input"));
        assertTrue(styles.contains("text-overflow: ellipsis"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
