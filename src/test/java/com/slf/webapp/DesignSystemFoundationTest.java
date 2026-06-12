package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class DesignSystemFoundationTest extends TestCase {

    public void testSharedStylesExposeDesignTokensAndReusableComponents() throws Exception {
        String styles = read("src/main/webapp/css/styles.css");

        assertTrue(styles.contains(":root"));
        assertTrue(styles.contains("--slf-color-primary"));
        assertTrue(styles.contains("--slf-space-4"));
        assertTrue(styles.contains("--slf-radius-md"));
        assertTrue(styles.contains("--slf-shadow-md"));
        assertTrue(styles.contains("--slf-focus-ring"));
        assertTrue(styles.contains("--slf-breakpoint-md"));

        assertTrue(styles.contains(".page-header"));
        assertTrue(styles.contains(".page-title"));
        assertTrue(styles.contains(".page-subtitle"));
        assertTrue(styles.contains(".panel"));
        assertTrue(styles.contains(".card"));
        assertTrue(styles.contains(".action-row"));
        assertTrue(styles.contains(".btn-primary"));
        assertTrue(styles.contains(".btn-secondary"));
        assertTrue(styles.contains(".status-badge"));
        assertTrue(styles.contains(".alert-success"));
        assertTrue(styles.contains(".alert-error"));
        assertTrue(styles.contains(".table-wrapper"));
        assertTrue(styles.contains(".form-field"));
        assertTrue(styles.contains(".empty-state"));
    }

    public void testSharedShellUsesAccessibleLandmarksAndFocusTargets() throws Exception {
        String topbar = read("src/main/webapp/WEB-INF/jspf/topbar.jspf");
        String sidebar = read("src/main/webapp/WEB-INF/jspf/sidebar.jspf");
        String footer = read("src/main/webapp/WEB-INF/jspf/footer.jspf");

        assertTrue(topbar.contains("role=\"banner\""));
        assertTrue(topbar.contains("aria-controls=\"mySidebar\""));
        assertTrue(sidebar.contains("role=\"navigation\""));
        assertTrue(sidebar.contains("aria-label=\"Primary navigation\""));
        assertTrue(footer.contains("app-footer-meta"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
