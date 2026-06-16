package com.slf.controller;

import junit.framework.TestCase;

public class MailLogServletTest extends TestCase {

    public void testNormalizesSupportedStatuses() {
        assertEquals("SENT", MailLogServlet.normalizeStatus(" sent "));
        assertEquals("FAILED", MailLogServlet.normalizeStatus("failed"));
        assertNull(MailLogServlet.normalizeStatus("all"));
        assertNull(MailLogServlet.normalizeStatus("unknown"));
    }

    public void testParsesPageWithSafeMinimum() {
        assertEquals(1, MailLogServlet.parsePage(null));
        assertEquals(1, MailLogServlet.parsePage("-3"));
        assertEquals(4, MailLogServlet.parsePage("4"));
    }

    public void testNormalizesSupportedFormTypes() {
        assertEquals("REQUISITION", MailLogServlet.normalizeFormType(" requisition "));
        assertEquals("THIRD_PARTY", MailLogServlet.normalizeFormType("third_party"));
        assertNull(MailLogServlet.normalizeFormType("all"));
        assertNull(MailLogServlet.normalizeFormType("unknown"));
    }
}
