package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartyRequestActionsTest extends TestCase {

    public void testRequestActionsUseButtonsAndDescribeDeletion() throws Exception {
        String page = read("src/main/webapp/third-party-request-new.jsp");
        String styles = read("src/main/webapp/css/styles.css");

        assertTrue(page.contains("fa-trash-can"));
        assertTrue(page.contains("รอผู้ขอภายนอกกรอกฟอร์ม"));
        assertFalse(page.contains("รอผู้ให้บริการกรอก"));
        assertTrue(page.contains("ยกเลิกลิงก์"));
        assertTrue(page.contains("owner-request-card"));
        assertTrue(page.contains("link-card-actions clean-actions owner-request-card-actions"));
        assertTrue(page.contains("ผู้ขอใช้บริการ"));
        assertTrue(page.contains("item.getExternalContactName()"));
        assertFalse(page.contains("<span>ผู้ให้บริการ</span>"));
        assertTrue(page.contains("ถูกลบออกจากประวัติและฐานข้อมูล"));
        assertFalse(page.contains("thirdPartySubmission?id="));
        assertTrue(styles.contains(".third-party-request-page .btn"));
        assertTrue(styles.contains(".third-party-request-page .btn-primary"));
        assertTrue(styles.contains(".third-party-request-page .btn-secondary"));
        assertTrue(styles.contains(".owner-request-card"));
        assertTrue(styles.contains(".owner-request-card-actions"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
