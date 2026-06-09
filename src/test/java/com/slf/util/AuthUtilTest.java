package com.slf.util;

import junit.framework.TestCase;

public class AuthUtilTest extends TestCase {

    public void testApprovalOnlyRolesHaveDedicatedApprovalPages() {
        assertTrue(AuthUtil.isApprovalOnlyRole("Director"));
        assertTrue(AuthUtil.isApprovalOnlyRole("IT Director"));
        assertFalse(AuthUtil.isApprovalOnlyRole("Admin"));
        assertEquals("/directorApprove", AuthUtil.approvalPageForRole("Director"));
        assertEquals("/itDirectorApprove", AuthUtil.approvalPageForRole("ITDirector"));
    }

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
        assertTrue(AuthUtil.isAllowedForPage("Admin", "thirdPartySubmission"));
        assertFalse(AuthUtil.isAllowedForPage("Director", "thirdPartySubmission"));
    }

    public void testAdminPageAllowsOnlyAdmin() {
        assertTrue(AuthUtil.isAllowedForPage("admin", "adminPage"));
        assertFalse(AuthUtil.isAllowedForPage("Technical", "adminPage"));
        assertFalse(AuthUtil.isAllowedForPage("Infrastructure", "adminPage"));
        assertFalse(AuthUtil.isAllowedForPage("Reseach", "adminPage"));
        assertFalse(AuthUtil.isAllowedForPage("Director", "adminPage"));
        assertFalse(AuthUtil.isAllowedForPage("ITDirector", "adminPage"));
        assertFalse(AuthUtil.isAllowedForPage("IT Director", "adminPage"));
    }

    public void testHistoryAllowsWorkflowRolesButNotRegularEmployee() {
        assertTrue(AuthUtil.isAllowedForPage("Admin", "history"));
        assertTrue(AuthUtil.isAllowedForPage("Director", "history"));
        assertTrue(AuthUtil.isAllowedForPage("Technical", "history"));
        assertTrue(AuthUtil.isAllowedForPage("Development", "history"));
        assertFalse(AuthUtil.isAllowedForPage("Employee", "history"));
    }
}
