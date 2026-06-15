package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartyPdfExportTest extends TestCase {

    public void testThirdPartyPdfExportHasOwnSecuredServlet() throws Exception {
        String servlet = read("src/main/java/com/slf/controller/ThirdPartyExportPDFServlet.java");

        assertTrue(servlet.contains("@WebServlet(\"/thirdParty/exportPdf\")"));
        assertTrue(servlet.contains("parseSubmissionId"));
        assertTrue(servlet.contains("canViewSubmission"));
        assertTrue(servlet.contains("FINAL_CERTIFIED"));
        assertTrue(servlet.contains("application/pdf"));
        assertTrue(servlet.contains("ITextRenderer"));
        assertTrue(servlet.contains("ThirdPartyFormSubmissionDAO"));
        assertTrue(servlet.contains("ThirdPartyWorkflowDAO"));
        assertTrue(servlet.contains("ThirdPartyRequestDAO"));
        assertTrue(servlet.contains("font-family: 'Anuphan'"));
        assertFalse(servlet.contains("RAW_TOKEN"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
