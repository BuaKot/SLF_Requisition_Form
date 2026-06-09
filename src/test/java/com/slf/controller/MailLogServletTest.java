package com.slf.controller;

import junit.framework.TestCase;

public class MailLogServletTest extends TestCase {

    public void testNormalizesSupportedStatuses() {
        assertEquals("SENT", MailLogServlet.normalizeStatus(" sent "));
        assertEquals("FAILED", MailLogServlet.normalizeStatus("failed"));
        assertEquals("READY", MailLogServlet.normalizeStatus("ready"));
        assertNull(MailLogServlet.normalizeStatus("all"));
        assertNull(MailLogServlet.normalizeStatus("unknown"));
    }

    public void testParsesPageWithSafeMinimum() {
        assertEquals(1, MailLogServlet.parsePage(null));
        assertEquals(1, MailLogServlet.parsePage("-3"));
        assertEquals(4, MailLogServlet.parsePage("4"));
    }
}
