package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartySectionHeadReviewPageTest extends TestCase {

    public void testReviewPageContainsAssignmentsAndIsNotLinkedFromNavigation() throws Exception {
        String page = read("src/main/webapp/WEB-INF/third-party-section-head-review.jsp");
        String servlet = read("src/main/java/com/slf/controller/ThirdPartySectionHeadReviewServlet.java");
        String index = read("src/main/webapp/index.jsp");
        String sidebar = read("src/main/webapp/WEB-INF/jspf/sidebar.jspf");

        assertTrue(page.contains("thirdParty/sectionHead/review"));
        assertTrue(page.contains("grantOperatorEmpId"));
        assertTrue(page.contains("separateRevoker"));
        assertTrue(page.contains("revokeOperatorEmpId"));
        assertTrue(page.contains("revokeReviewerEmpId"));
        assertTrue(page.contains("ส่งต่อให้ IT Director"));
        assertTrue(page.contains("รอหัวหน้าส่วนพิจารณา"));
        assertTrue(page.contains("workflowStatusText(thirdPartyRequest.getStatus())"));
        assertTrue(page.contains("event.persisted"));
        assertTrue(page.contains("window.location.replace"));
        assertTrue(servlet.contains("no-store, no-cache, must-revalidate, max-age=0"));
        assertTrue(servlet.contains("if (!\"PENDING_SECTION_HEAD\".equals(thirdPartyRequest.getStatus()))"));
        assertTrue(servlet.contains("response.sendRedirect(request.getContextPath() + \"/thirdParty/sectionHead\")"));
        assertFalse(index.contains("thirdParty/sectionHead/review"));
        assertFalse(sidebar.contains("thirdParty/sectionHead/review"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
