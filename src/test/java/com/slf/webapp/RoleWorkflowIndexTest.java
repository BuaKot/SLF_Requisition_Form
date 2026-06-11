package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class RoleWorkflowIndexTest extends TestCase {

    public void testIndexProvidesRoleWorkflowEntrances() throws Exception {
        String index = read("src/main/webapp/index.jsp");
        String inbox = read("src/main/webapp/WEB-INF/third-party-section-head-inbox.jsp");
        String servlet = read("src/main/java/com/slf/controller/ThirdPartySectionHeadInboxServlet.java");

        assertTrue(index.contains("hasRoleWorkMenu"));
        assertTrue(index.contains("/technicalApprove"));
        assertTrue(index.contains("/itDirectorApprove"));
        assertTrue(index.contains("/process"));
        assertTrue(index.contains("/thirdParty/sectionHead"));
        assertTrue(index.contains("isTechnical"));
        assertTrue(index.contains("ยังไม่เปิดใช้งาน"));

        assertTrue(inbox.contains("/thirdParty/sectionHead/review?id="));
        assertTrue(inbox.contains("คำขอที่รอพิจารณา"));
        assertTrue(inbox.contains("พิจารณาคำขอ"));
        assertTrue(servlet.contains("ThirdPartySectionHeadReviewServlet.isTechnicalPosition"));
        assertTrue(servlet.contains("PENDING_SECTION_HEAD"));
        assertTrue(servlet.contains("/WEB-INF/third-party-section-head-inbox.jsp"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
