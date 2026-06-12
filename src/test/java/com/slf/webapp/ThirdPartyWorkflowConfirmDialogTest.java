package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartyWorkflowConfirmDialogTest extends TestCase {

    public void testWorkflowReviewPagesUseSharedConfirmDialogInsteadOfBrowserConfirm() throws Exception {
        String[] pages = {
            "src/main/webapp/WEB-INF/third-party-section-head-review.jsp",
            "src/main/webapp/WEB-INF/third-party-it-director-review.jsp",
            "src/main/webapp/WEB-INF/third-party-operator-review.jsp",
            "src/main/webapp/WEB-INF/third-party-assigned-completion-review.jsp",
            "src/main/webapp/WEB-INF/third-party-final-stage-review.jsp"
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
        assertTrue(dialog.contains("form.reportValidity()"));
        assertTrue(dialog.contains("pendingTrigger.name"));
        assertTrue(dialog.contains("pendingForm.submit()"));
        assertTrue(dialog.contains("กำลังบันทึก..."));
        assertTrue(dialog.contains(">ยกเลิก</button>"));

        String sectionHead = read("src/main/webapp/WEB-INF/third-party-section-head-review.jsp");
        assertTrue(sectionHead.contains("data-confirm-title=\"ยืนยันการส่งคำขอ\""));
        assertTrue(sectionHead.contains("ผู้อำนวยการฝ่ายเทคโนโลยีสารสนเทศ พิจารณาต่อ"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
