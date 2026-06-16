package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartyPdfExportTest extends TestCase {

    public void testThirdPartyPdfExportHasOwnSecuredServlet() throws Exception {
        String servlet = read("src/main/java/com/slf/controller/ThirdPartyExportPDFServlet.java");
        String page = read("src/main/webapp/third-party-pdf.jsp");

        assertTrue(servlet.contains("@WebServlet(\"/thirdParty/exportPdf\")"));
        assertTrue(servlet.contains("parseSubmissionId"));
        assertTrue(servlet.contains("canViewSubmission"));
        assertTrue(servlet.contains("FINAL_CERTIFIED"));
        assertTrue(servlet.contains("/third-party-pdf.jsp"));
        assertTrue(servlet.contains("request.setAttribute(\"submission\""));
        assertFalse(servlet.contains("application/pdf"));
        assertFalse(servlet.contains("ITextRenderer"));
        assertTrue(servlet.contains("ThirdPartyFormSubmissionDAO"));
        assertTrue(servlet.contains("ThirdPartyWorkflowDAO"));
        assertTrue(servlet.contains("ThirdPartyRequestDAO"));
        assertTrue(page.contains("btn-print"));
        assertTrue(page.contains("window.print()"));
        assertTrue(page.contains("SLF-TP-001"));
        assertTrue(page.contains("workflow-form"));
        assertTrue(page.contains("findAction(approvalHistory"));
        assertTrue(page.contains("SECTION_HEAD_SUBMITTED"));
        assertTrue(page.contains("OPERATOR_COMPLETED"));
        assertTrue(page.contains("EXTERNAL_ACCEPTED"));
        assertTrue(page.contains("acceptanceScore == null ? \"-\" : acceptanceScore"));
        assertTrue(page.contains("workflowStepLabel(acceptanceAction == null ? \"EXTERNAL_ACCEPTED\""));
        assertFalse(page.contains("ส่วนที่ 4 ผลตรวจรับและประเมินความพึงพอใจ"));
        assertTrue(page.contains("workflow-rev"));
        assertTrue(page.contains("head-table"));
        assertFalse(page.contains("<table class=\"approval-matrix\">"));
        assertFalse(servlet.contains("RAW_TOKEN"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
