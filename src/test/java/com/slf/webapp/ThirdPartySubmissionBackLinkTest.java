package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartySubmissionBackLinkTest extends TestCase {

    public void testBackLinkUsesAuthorizedServletDestination() throws Exception {
        String page = new String(
            Files.readAllBytes(Paths.get("src/main/webapp/ThirdPartySubmission.jsp")),
            StandardCharsets.UTF_8
        );

        assertTrue(page.contains("thirdPartySubmissionBackUrl"));
        assertTrue(page.contains("href=\"<%= h(backUrl) %>\""));
        assertTrue(page.contains("ประวัติการดำเนินงาน"));
        assertTrue(page.contains("approvalHistory"));
        assertTrue(page.contains("actionTitle(actionType)"));
        assertTrue(page.contains("actorLabel(action)"));
        assertTrue(page.contains("ผู้อำนวยการฝ่ายเทคโนโลยีสารสนเทศ ไม่อนุมัติ"));
        assertTrue(page.contains(".approval-card.rejected"));
        assertTrue(page.contains("รายงานเพื่อโปรดทราบ"));
        assertTrue(page.contains("acceptanceScore"));
        assertFalse(page.contains("acceptanceResult.getSatisfactionLevel()"));
        assertTrue(page.contains("? \"ส่งเมื่อ\" : \"อนุมัติเมื่อ\""));
        assertFalse(page.contains("\"EXTERNAL_SUBMITTED\".equals(actionType)"));
        assertFalse(page.contains("href=\"${pageContext.request.contextPath}/thirdPartyLinks\""));
    }

    public void testCompletedSubmissionShowsPdfExportActionOnlyWhenAllowed() throws Exception {
        String page = new String(
            Files.readAllBytes(Paths.get("src/main/webapp/ThirdPartySubmission.jsp")),
            StandardCharsets.UTF_8
        );
        String servlet = new String(
            Files.readAllBytes(Paths.get("src/main/java/com/slf/controller/ThirdPartySubmissionServlet.java")),
            StandardCharsets.UTF_8
        );

        assertTrue(servlet.contains("thirdPartyCompleted"));
        assertTrue(servlet.contains("FINAL_CERTIFIED"));
        assertTrue(page.contains("thirdPartyCompleted"));
        assertTrue(page.contains("/thirdParty/exportPdf?submissionId="));
        assertTrue(page.contains("third-party-pdf-button"));
    }
}
