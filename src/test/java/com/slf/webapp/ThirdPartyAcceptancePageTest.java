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
        String styles = read("src/main/webapp/css/styles.css").replace("\r\n", "\n");

        assertTrue(migration.contains("CREATE TABLE THIRD_PARTY_ACCEPTANCE_TOKEN"));
        assertTrue(migration.contains("CREATE TABLE THIRD_PARTY_ACCEPTANCE_RESULT"));
        assertTrue(workflowDao.contains("INSERT INTO THIRD_PARTY_ACCEPTANCE_TOKEN"));
        assertTrue(acceptanceDao.contains("EXTERNAL_ACCEPTED"));
        assertTrue(acceptanceDao.contains("PENDING_REVOKER"));

        assertTrue(publicPage.contains("name=\"satisfactionLevel\""));
        assertTrue(publicPage.contains("name=\"comment\""));
        assertFalse(publicPage.contains("assignment"));

        assertTrue(ownerPage.contains("ลิงก์ตรวจรับและประเมิน"));
        assertTrue(ownerPage.contains("copyMergedLink"));
        assertTrue(ownerPage.contains("copy-link-text"));
        assertTrue(ownerPage.contains("owner-link-dashboard"));
        assertTrue(ownerPage.contains("merged-link-grid"));
        assertTrue(ownerPage.contains("merged-link-box"));
        assertTrue(ownerPage.contains("blank-link-value"));
        assertTrue(ownerPage.contains("acceptanceTokensByRequestId"));
        assertTrue(ownerPage.contains("owner-request-list-panel"));
        assertTrue(styles.contains(".owner-link-dashboard .owner-request-list-panel"));
        assertTrue(styles.contains(".owner-link-dashboard .page-head-actions"));
        assertTrue(styles.contains(".owner-link-dashboard {\n    display: block;"));
        assertTrue(styles.contains("max-width: 1120px;"));
        assertTrue(styles.contains(".merged-link-grid"));
        assertTrue(styles.contains(".copy-link-text"));
        assertTrue(styles.contains("text-overflow: ellipsis"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
