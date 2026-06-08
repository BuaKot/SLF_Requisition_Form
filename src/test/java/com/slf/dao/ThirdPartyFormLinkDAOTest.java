package com.slf.dao;

import junit.framework.TestCase;

public class ThirdPartyFormLinkDAOTest extends TestCase {

    public void testNormalizeActionAllowsOnlyKnownActions() {
        assertEquals("generate", ThirdPartyFormLinkDAO.normalizeAction(" generate "));
        assertEquals("revoke", ThirdPartyFormLinkDAO.normalizeAction("REVOKE"));
        assertEquals("", ThirdPartyFormLinkDAO.normalizeAction("delete"));
        assertEquals("", ThirdPartyFormLinkDAO.normalizeAction(null));
    }
}
