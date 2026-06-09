package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ApprovalOnlyHomePageTest extends TestCase {

    public void testHomeAndSidebarBranchForApprovalOnlyRoles() throws Exception {
        String index = read("src/main/webapp/index.jsp");
        String sidebar = read("src/main/webapp/WEB-INF/sidebar.jsp");

        assertTrue(index.contains("approvalOnlyRole"));
        assertTrue(index.contains("approval-only-actions"));
        assertTrue(index.contains("/history.jsp"));
        assertTrue(index.contains("index-history-fab"));
        assertTrue(index.contains("showTechnicalWork"));
        assertTrue(index.contains("showProcessWork"));
        assertFalse(sidebar.contains(">ประวัติรายการ</a>"));
        assertTrue(index.contains("ไปยังรายการรออนุมัติ"));
        assertTrue(sidebar.contains("_sidebarApprovalOnlyRole && _sidebarApprovalPage != null"));
        assertTrue(sidebar.contains("!_sidebarApprovalOnlyRole && (_sidebarShowAdmin || _sidebarShowDashboard)"));
        assertFalse(sidebar.contains("boolean approvalOnlyRole"));
        assertFalse(sidebar.contains("String approvalPage"));
        assertFalse(sidebar.contains("String approvalLabel"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
