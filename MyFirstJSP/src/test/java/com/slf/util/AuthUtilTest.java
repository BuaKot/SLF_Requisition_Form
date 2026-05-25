package com.slf.util;

import junit.framework.TestCase;

public class AuthUtilTest extends TestCase {

    public void testDashboardAllowsOnlyAdminRole() {
        assertTrue(AuthUtil.isAllowedForPage("Admin", "dashboard"));
        assertFalse(AuthUtil.isAllowedForPage("Director", "dashboard"));
        assertFalse(AuthUtil.isAllowedForPage("Technical", "dashboard"));
    }

    public void testAdminPageAllowsAllOperationalRolesCaseInsensitively() {
        assertTrue(AuthUtil.isAllowedForPage("admin", "adminPage"));
        assertTrue(AuthUtil.isAllowedForPage("Director", "adminPage"));
        assertTrue(AuthUtil.isAllowedForPage("Technical", "adminPage"));
        assertTrue(AuthUtil.isAllowedForPage("Infrastructure", "adminPage"));
        assertTrue(AuthUtil.isAllowedForPage("IT Director", "adminPage"));
        assertTrue(AuthUtil.isAllowedForPage("Reseach", "adminPage"));
    }
}
