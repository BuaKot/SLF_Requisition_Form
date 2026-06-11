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
        String styles = new String(
            Files.readAllBytes(Paths.get("src/main/webapp/css/styles.css")),
            StandardCharsets.UTF_8
        );

        assertTrue(source.contains("index-banner-inner"));
        assertTrue(source.contains("ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา"));
        assertTrue(styles.contains(".enterprise-hero::before"));
        assertTrue(styles.contains("linear-gradient(135deg, #073a73 0%, #0b559c 58%, #1766b8 100%)"));
        assertFalse(source.contains("index-banner-logo"));
        assertFalse(source.contains("fa-building-columns"));
    }
}
