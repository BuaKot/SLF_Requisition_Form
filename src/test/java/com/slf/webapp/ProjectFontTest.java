package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ProjectFontTest extends TestCase {

    public void testAnuphanIsSelfHostedAndUsedAsProjectFont() throws Exception {
        String styles = read("src/main/webapp/css/styles.css");
        String pdfServlet = read("src/main/java/com/slf/controller/ExportPDFServlet.java");

        assertTrue(Files.exists(Paths.get(
            "src/main/webapp/css/fonts/Anuphan-VariableFont_wght.ttf")));
        assertTrue(Files.exists(Paths.get(
            "src/main/webapp/css/fonts/Anuphan-OFL.txt")));
        assertTrue(Files.exists(Paths.get(
            "src/main/resources/fonts/Anuphan-Regular.ttf")));
        assertTrue(styles.contains("font-family: 'Anuphan'"));
        assertTrue(styles.contains("--slf-font-family: 'Anuphan'"));
        assertTrue(pdfServlet.contains("/fonts/Anuphan-Regular.ttf"));
        assertTrue(pdfServlet.contains("font-family: 'Anuphan'"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
