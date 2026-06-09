package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

import junit.framework.TestCase;

public class JspScriptletVariableTest extends TestCase {

    public void testCheckAuthUsesNamespacedVariablesToAvoidIncludeCollisions() throws Exception {
        String source = new String(
            Files.readAllBytes(Paths.get("src/main/webapp/WEB-INF/checkAuth.jsp")),
            StandardCharsets.UTF_8
        );

        assertFalse(source.contains("String currentRole ="));
        assertTrue(source.contains("String _authCurrentRole ="));
    }

    public void testSidebarUsesNamespacedVariablesToAvoidIncludeCollisions() throws Exception {
        String source = new String(
            Files.readAllBytes(Paths.get("src/main/webapp/WEB-INF/sidebar.jsp")),
            StandardCharsets.UTF_8
        );

        assertTrue(source.contains("String _sidebarPosition ="));
        assertTrue(source.contains("boolean _sidebarShowAdmin ="));
        assertTrue(source.contains("boolean _sidebarApprovalOnlyRole ="));
        assertFalse(source.contains("String position ="));
        assertFalse(source.contains("boolean showAdmin ="));
        assertFalse(source.contains("boolean approvalOnlyRole ="));
    }
}
