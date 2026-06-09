package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class DetailBackNavigationTest extends TestCase {

    public void testDetailReturnsToKnownSourcePage() throws Exception {
        String source = new String(
            Files.readAllBytes(Paths.get("src/main/webapp/detail.jsp")),
            StandardCharsets.UTF_8
        );

        assertTrue(source.contains("request.getParameter(\"from\")"));
        assertTrue(source.contains("\"history\".equals(fromPage) ? \"history.jsp\" : \"submit\""));
        assertTrue(source.contains("กลับหน้าประวัติ"));
        assertTrue(source.contains("กลับหน้าฟอร์มที่ส่งแล้ว"));
        assertTrue(source.contains("VIEWER_AI.REVIEWER_EMPID = ?"));
        assertTrue(source.contains("RF.EMPID = ? OR EXISTS"));
    }
}
