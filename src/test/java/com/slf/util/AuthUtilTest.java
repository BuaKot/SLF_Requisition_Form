package com.slf.util;

import junit.framework.TestCase;

public class AuthUtilTest extends TestCase {

    public void testDashboardAllowsOnlyAdminRole() {
        assertTrue(AuthUtil.isAllowedForPage("Admin", "dashboard"));
        assertFalse(AuthUtil.isAllowedForPage("Director", "dashboard"));
        assertFalse(AuthUtil.isAllowedForPage("Technical", "dashboard"));
    }

    public void testMemberManageAllowsOnlyAdminRole() {
        assertTrue(AuthUtil.isAllowedForPage("Admin", "memberManage"));
        assertTrue(AuthUtil.isAllowedForPage("admin", "memberManage"));
        assertFalse(AuthUtil.isAllowedForPage("Director", "memberManage"));
        assertFalse(AuthUtil.isAllowedForPage("Technical", "memberManage"));
        assertFalse(AuthUtil.isAllowedForPage("Infrastructure", "memberManage"));
    }

    public void testMailLogAllowsOnlyAdminRole() {
        assertTrue(AuthUtil.isAllowedForPage("Admin", "mailLog"));
        assertTrue(AuthUtil.isAllowedForPage("admin", "mailLog"));
        assertFalse(AuthUtil.isAllowedForPage("Director", "mailLog"));
        assertFalse(AuthUtil.isAllowedForPage("Technical", "mailLog"));
    }

    public void testThirdPartyLinksAllowsOnlyAdminRole() {
        assertTrue(AuthUtil.isAllowedForPage("Admin", "thirdPartyLinks"));
        assertTrue(AuthUtil.isAllowedForPage("admin", "thirdPartyLinks"));
        assertFalse(AuthUtil.isAllowedForPage("Director", "thirdPartyLinks"));
        assertFalse(AuthUtil.isAllowedForPage("Technical", "thirdPartyLinks"));
    }

    public void testThirdPartySubmissionPassesFilterForOwnerCheckInServlet() {
        assertTrue(AuthUtil.isAllowedForPage("Admin", "thirdPartySubmission"));
        assertTrue(AuthUtil.isAllowedForPage("Director", "thirdPartySubmission"));
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
