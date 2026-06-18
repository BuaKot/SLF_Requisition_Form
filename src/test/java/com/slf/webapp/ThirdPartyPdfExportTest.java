package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartyPdfExportTest extends TestCase {

    public void testThirdPartyPdfExportHasOwnSecuredServlet() throws Exception {
        String servlet = read("src/main/java/com/slf/controller/ThirdPartyExportPDFServlet.java");
        String page = read("src/main/webapp/WEB-INF/views/ThirdPartyPdf.jsp");

        // Servlet Checks (Unchanged)
        assertTrue(servlet.contains("@WebServlet(\"/thirdParty/exportPdf\")"));
        assertTrue(servlet.contains("parseSubmissionId"));
        assertTrue(servlet.contains("canViewSubmission"));
        assertTrue(servlet.contains("canViewAllSubmissions"));
        assertTrue(servlet.contains("submissionDAO.isOwnedBy"));
        assertTrue(servlet.indexOf("submissionDAO.isOwnedBy") < servlet.indexOf("submissionDAO.findById"));
        assertTrue(servlet.contains("FINAL_CERTIFIED"));
        assertTrue(servlet.contains("/WEB-INF/views/ThirdPartyPdf.jsp"));
        assertTrue(servlet.contains("request.setAttribute(\"submission\""));
        assertFalse(servlet.contains("application/pdf"));
        assertFalse(servlet.contains("ITextRenderer"));
        assertTrue(servlet.contains("ThirdPartyFormSubmissionDAO"));
        assertTrue(servlet.contains("ThirdPartyWorkflowDAO"));
        assertTrue(servlet.contains("ThirdPartyRequestDAO"));
        assertFalse(servlet.contains("RAW_TOKEN"));

        // JSP Page Checks (Updated to match the new exact-copy layout)
        assertTrue(page.contains("btn-print"));
        assertTrue(page.contains("window.print()"));
        
        // We replaced "workflow-form" and "head-table" with "matrix-table" and "header-container"
        assertTrue(page.contains("matrix-table"));
        assertTrue(page.contains("header-container"));
        
        // Workflow actions check
        assertTrue(page.contains("findAction(approvalHistory"));
        assertTrue(page.contains("SECTION_HEAD_SUBMITTED"));
        assertTrue(page.contains("OPERATOR_COMPLETED"));
        assertTrue(page.contains("EXTERNAL_ACCEPTED"));
        
        // We changed how acceptance score is rendered to use checkboxes
        assertTrue(page.contains("acceptanceScore != null && acceptanceScore =="));
        assertTrue(page.contains("isAccSat ? \"&#9745;\" : \"&#9744;\""));
        
        // Section 4 was added to the layout to match the document
        assertTrue(page.contains("ส่วนที่ 4 ผลตรวจรับและประเมินความพึงพอใจ"));
        
        // Document revision text uses doc-rev now instead of workflow-rev
        assertTrue(page.contains("doc-rev"));
        
        // Ensure old matrix styling is still gone
        assertFalse(page.contains("<table class=\"approval-matrix\">"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
