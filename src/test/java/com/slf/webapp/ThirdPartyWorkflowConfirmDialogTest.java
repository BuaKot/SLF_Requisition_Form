package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartyWorkflowConfirmDialogTest extends TestCase {

    public void testWorkflowReviewPagesUseSharedConfirmDialogInsteadOfBrowserConfirm() throws Exception {
        String[] pages = {
            "src/main/webapp/WEB-INF/views/ThirdPartySectionHeadReview.jsp",
            "src/main/webapp/WEB-INF/views/ThirdPartyItDirectorReview.jsp",
            "src/main/webapp/WEB-INF/views/ThirdPartyOperatorReview.jsp",
            "src/main/webapp/WEB-INF/views/ThirdPartyAssignedCompletionReview.jsp",
            "src/main/webapp/WEB-INF/views/ThirdPartyFinalStageReview.jsp"
        };
        for (String pagePath : pages) {
            String page = read(pagePath);
            assertTrue(pagePath, page.contains("data-workflow-confirm"));
            assertTrue(pagePath, page.contains("third-party-confirm-dialog.jspf"));
            assertFalse(pagePath, page.contains("return confirm("));
            assertFalse(pagePath, page.contains("window.confirm("));
        }

        String dialog = read("src/main/webapp/WEB-INF/jspf/third-party-confirm-dialog.jspf");
        assertTrue(dialog.contains("pageEncoding=\"UTF-8\""));
        assertFalse(dialog.contains("form.reportValidity()"));
        assertTrue(dialog.contains("validateForm(form)"));
        assertTrue(dialog.contains("showWorkflowValidation"));
        assertTrue(dialog.contains("workflow-inline-error"));
        assertTrue(dialog.contains("pendingTrigger.name"));
        assertTrue(dialog.contains("pendingForm.submit()"));
        assertTrue(dialog.contains("กำลังบันทึก..."));
        assertTrue(dialog.contains(">ยกเลิก</button>"));

        String sectionHead = read("src/main/webapp/WEB-INF/views/ThirdPartySectionHeadReview.jsp");
        assertTrue(sectionHead.contains("data-before-confirm=\"validateAssignments\""));
        assertFalse(sectionHead.contains("window.alert("));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
