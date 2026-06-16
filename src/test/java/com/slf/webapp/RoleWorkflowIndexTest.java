package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class RoleWorkflowIndexTest extends TestCase {

    public void testIndexProvidesRoleWorkflowEntrances() throws Exception {
        String index = read("src/main/webapp/index.jsp");
        String sidebar = read("src/main/webapp/WEB-INF/jspf/sidebar.jspf");
        String inbox = read("src/main/webapp/WEB-INF/third-party-section-head-inbox.jsp");
        String servlet = read("src/main/java/com/slf/controller/ThirdPartySectionHeadInboxServlet.java");

        assertTrue(index.contains("hasRoleWorkMenu"));
        assertTrue(index.contains("canAccessOperationalStage"));
        assertTrue(index.contains("boolean hasRoleWorkMenu = isDirector || isTechnical || isItDirector || canAccessOperationalStage;"));
        assertTrue(index.contains("if (isDirector || isItDirector)"));
        assertTrue(index.contains("if (isTechnical)"));
        assertTrue(index.contains("technical-workflow-actions"));
        assertTrue(index.contains("technical-approval-action"));
        assertTrue(index.contains("technical-process-action"));
        assertTrue(index.contains("/technicalApprove"));
        assertTrue(index.contains("/itDirectorApprove"));
        assertTrue(index.contains("/process"));
        assertTrue(index.contains("รายการรอดำเนินการ"));
        assertTrue(sidebar.contains("_sidebarCanAccessProcess"));
        assertTrue(sidebar.contains("&& !_sidebarCanAccessProcess"));
        assertTrue(index.contains("/thirdParty/sectionHead"));
        assertTrue(index.contains("/thirdParty/itDirector"));
        assertTrue(index.contains("/thirdParty/operator"));
        assertTrue(index.contains("isTechnical"));

        assertTrue(inbox.contains("/thirdParty/sectionHead/review?id="));
        assertTrue(inbox.contains("<a class=\"item\""));
        assertFalse(inbox.contains("String[] buttons="));
        assertFalse(inbox.contains("class=\"btn btn-primary primary-action\""));
        assertTrue(inbox.contains("/thirdParty/sectionHead/report?id="));
        assertTrue(inbox.contains("คำขอรอพิจารณา"));
        assertTrue(inbox.contains("คำขอรอเขียนรายงานสรุป"));
        assertTrue(servlet.contains("ThirdPartySectionHeadReviewServlet.isTechnicalPosition"));
        assertTrue(servlet.contains("PENDING_SECTION_HEAD"));
        assertTrue(servlet.contains("PENDING_SECTION_HEAD_REPORT"));
        assertTrue(servlet.contains("/WEB-INF/third-party-section-head-inbox.jsp"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
