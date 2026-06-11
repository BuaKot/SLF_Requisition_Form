package com.slf.dao;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartyWorkflowStatusTest extends TestCase {

    public void testExternalSubmissionEntersSectionHeadWorkflow() throws Exception {
        String source = read("src/main/java/com/slf/dao/ThirdPartyFormSubmissionDAO.java");

        assertTrue(source.contains("STATUS = 'PENDING_SECTION_HEAD'"));
        assertTrue(source.contains("'EXTERNAL_SUBMITTED'"));
        assertTrue(source.contains("INSERT INTO THIRD_PARTY_WORKFLOW_ACTION"));
        assertFalse(source.contains("STATUS = 'SUBMITTED'"));
    }

    public void testCoordinatorPageDisplaysWorkflowStatuses() throws Exception {
        String page = read("src/main/webapp/third-party-request-new.jsp");

        assertTrue(page.contains("PENDING_SECTION_HEAD"));
        assertTrue(page.contains("PENDING_IT_DIRECTOR"));
        assertTrue(page.contains("PENDING_OPERATOR"));
        assertTrue(page.contains("PENDING_EXTERNAL_ACCEPTANCE"));
        assertTrue(page.contains("PENDING_REVOKER"));
        assertTrue(page.contains("PENDING_REVOKE_REVIEWER"));
        assertTrue(page.contains("PENDING_SECTION_HEAD_REPORT"));
        assertTrue(page.contains("PENDING_FINAL_CERTIFICATION"));
        assertTrue(page.contains("COMPLETED"));
        assertFalse(page.contains("\"APPROVED\".equals(status)"));
    }

    public void testWorkflowMigrationIncludesTablesStatusMigrationAndReadOnlyGrants() throws Exception {
        String migration = read("sql/2026-06-11_third_party_workflow.sql");

        assertTrue(migration.contains("CREATE TABLE THIRD_PARTY_WORKFLOW_ASSIGNMENT"));
        assertTrue(migration.contains("CREATE TABLE THIRD_PARTY_WORKFLOW_ACTION"));
        assertTrue(migration.contains("WHERE STATUS IN ('SUBMITTED', 'PENDING_REVIEW')"));
        assertTrue(migration.contains("'WORKFLOW_MIGRATED'"));
        assertTrue(migration.contains("'EXTERNAL_SUBMITTED'"));
        assertTrue(migration.contains("GRANT SELECT ON THIRD_PARTY_WORKFLOW_ASSIGNMENT TO SLF_READ_ROLE"));
        assertTrue(migration.contains("GRANT SELECT ON THIRD_PARTY_WORKFLOW_ACTION TO SLF_READ_ROLE"));

        String finalizeMigration = read("sql/2026-06-11_third_party_workflow_finalize.sql");
        assertTrue(finalizeMigration.contains("WHERE STATUS = 'SUBMITTED'"));
        assertFalse(finalizeMigration.contains("'SUBMITTED',"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
