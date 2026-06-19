package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartyRequestedSystemPageTest extends TestCase {

    public void testRequestedSystemIsCollectedAndPersistedSeparatelyFromProject() throws Exception {
        String form = read("src/main/webapp/WEB-INF/views/ThirdPartyForm.jsp");
        String model = read("src/main/java/com/slf/model/ThirdPartyFormSubmission.java");
        String servlet = read("src/main/java/com/slf/controller/ThirdPartySubmitServlet.java");
        String dao = read("src/main/java/com/slf/dao/ThirdPartyFormSubmissionDAO.java");

        assertTrue(form.contains("id=\"requestedSystem\" name=\"requestedSystem\""));
        assertTrue(form.contains("name=\"requestedSystem\" type=\"text\" maxlength=\"500\""));
        assertTrue(model.contains("getRequestedSystem()"));
        assertTrue(servlet.contains("request.getParameter(\"requestedSystem\")"));
        assertTrue(servlet.contains("requireText(submission.getRequestedSystem()"));
        assertTrue(dao.contains("REQUESTED_SYSTEM, REASON_OBJECTIVE, PROJECT_NAME"));
        assertTrue(dao.contains("insert.setString(9, submission.getRequestedSystem())"));
        assertTrue(dao.contains("updateRequest.setString(6, submission.getRequestedSystem())"));
    }

    public void testRequestedSystemAppearsAtEveryReviewStage() throws Exception {
        String[] pages = {
            "ThirdPartySubmission.jsp",
            "ThirdPartySectionHeadReview.jsp",
            "ThirdPartyItDirectorReview.jsp",
            "ThirdPartyOperatorReview.jsp",
            "ThirdPartyAssignedCompletionReview.jsp",
            "ThirdPartyAcceptance.jsp",
            "ThirdPartyFinalStageReview.jsp"
        };
        for (String page : pages) {
            String source = read("src/main/webapp/WEB-INF/views/" + page);
            assertTrue(page + " must display the requested system",
                source.contains("submission.getRequestedSystem()"));
        }
    }

    public void testPdfIncludesRequestedSystemProjectAndSubmittedUserList() throws Exception {
        String page = read("src/main/webapp/WEB-INF/views/ThirdPartyPdf.jsp");
        String css = read("src/main/webapp/css/styles.css");

        assertTrue(page.contains("display(submission.getRequestedSystem())"));
        assertTrue(page.contains("display(submission.getProjectName())"));
        assertTrue(page.contains("รายชื่อเพื่อขอรับสิทธิการเข้าถึง สำหรับผู้ให้บริการภายนอก (เพิ่มเติม)"));
        assertTrue(page.contains("item.getEmployeeCode()"));
        assertTrue(page.contains("item.getNationalId()"));
        assertTrue(page.contains("item.getRequestedRole()"));
        assertFalse(page.contains("<th>ลายเซ็น</th>"));
        assertTrue(page.contains("<th colspan=\"12\" class=\"access-list-table-title\">"));
        assertTrue(page.contains("หน้าที่ 3/3"));
        assertTrue(css.contains("@page page-third-party-access-list"));
        assertTrue(css.contains("size: A4 landscape"));
    }

    public void testSqlChangeIsRecorded() throws Exception {
        String log = read("docs/sql-removal-log.md");
        assertTrue(log.contains("2026-06-18_third_party_requested_system.sql"));
        assertTrue(log.contains("ADD (REQUESTED_SYSTEM VARCHAR2(500 CHAR))"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
