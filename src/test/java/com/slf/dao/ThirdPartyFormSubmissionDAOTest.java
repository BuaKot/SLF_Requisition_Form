package com.slf.dao;

import junit.framework.TestCase;

public class ThirdPartyFormSubmissionDAOTest extends TestCase {

    public void testFormatsDocumentReceiveNoFromSequence() {
        assertEquals("TP-000001", ThirdPartyFormSubmissionDAO.formatDocumentReceiveNo(1L));
        assertEquals("TP-000123", ThirdPartyFormSubmissionDAO.formatDocumentReceiveNo(123L));
    }
}
