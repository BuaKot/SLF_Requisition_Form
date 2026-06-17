package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class AdminNavigationThaiLabelsTest extends TestCase {

    public void testAdminPageUsesSharedNavigationFragments() throws Exception {
        String page = read("src/main/webapp/WEB-INF/views/Admin.jsp");
        assertTrue(page.contains("/WEB-INF/jspf/sidebar.jspf"));
        assertTrue(page.contains("/WEB-INF/jspf/topbar.jspf"));
    }

    public void testSidebarUsesContextAwareMenu() throws Exception {
        String sidebar = read("src/main/webapp/WEB-INF/jspf/sidebar.jspf");
        assertTrue(sidebar.contains("_sidebarIsIndex"));
        assertTrue(sidebar.contains("_sidebarIsItFlow"));
        assertTrue(sidebar.contains("_sidebarIsRequisitionApprovalDetail"));
        assertTrue(sidebar.contains("_sidebarIsThirdPartyFlow"));
        assertTrue(sidebar.contains("/emailNotifications"));
        assertTrue(sidebar.contains("sidebar-submenu"));
        assertTrue(sidebar.contains("classList.toggle(\"open\")"));
        assertTrue(sidebar.contains("/third-party-form-detail.jsp"));
        assertTrue(sidebar.contains("/technicalApprove"));
        assertTrue(sidebar.contains("/process"));
        assertFalse(sidebar.contains("/newForm"));
        assertFalse(sidebar.contains(">Dashboard</a>"));
        assertFalse(sidebar.contains(">mailLog</a>"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
