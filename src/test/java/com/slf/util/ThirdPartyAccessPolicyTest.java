package com.slf.util;

import junit.framework.TestCase;

public class ThirdPartyAccessPolicyTest extends TestCase {

    public void testOnlyConfiguredEmployeeCanCreateOwnLinks() {
        assertTrue(ThirdPartyAccessPolicy.canCreateOwnLinks(Integer.valueOf(678)));
        assertFalse(ThirdPartyAccessPolicy.canCreateOwnLinks(Integer.valueOf(1001)));
        assertFalse(ThirdPartyAccessPolicy.canCreateOwnLinks(null));
    }

    public void testSubmissionVisibleOnlyToAdminOrMatchingOwner() {
        assertTrue(ThirdPartyAccessPolicy.canViewSubmission("Admin", Integer.valueOf(1001), null));
        assertTrue(ThirdPartyAccessPolicy.canViewSubmission("User", Integer.valueOf(678), Integer.valueOf(678)));
        assertFalse(ThirdPartyAccessPolicy.canViewSubmission("User", Integer.valueOf(678), Integer.valueOf(1001)));
        assertFalse(ThirdPartyAccessPolicy.canViewSubmission("User", Integer.valueOf(1001), Integer.valueOf(678)));
    }
}
