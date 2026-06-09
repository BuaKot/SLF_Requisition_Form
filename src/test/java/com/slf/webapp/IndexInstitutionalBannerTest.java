package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class IndexInstitutionalBannerTest extends TestCase {

    public void testIndexUsesInstitutionalBannerStructure() throws Exception {
        String source = new String(
            Files.readAllBytes(Paths.get("src/main/webapp/index.jsp")),
            StandardCharsets.UTF_8
        );

        assertTrue(source.contains("index-banner-inner"));
        assertTrue(source.contains("ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา"));
        assertTrue(source.contains("linear-gradient(180deg, #edf8ff 0%, #d8eefb 100%)"));
        assertTrue(source.contains(".index-banner::before"));
        assertTrue(source.contains(".index-banner::after"));
        assertFalse(source.contains("index-banner-logo"));
        assertFalse(source.contains("fa-building-columns"));
    }
}
