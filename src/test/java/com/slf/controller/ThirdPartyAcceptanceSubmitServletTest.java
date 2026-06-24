package com.slf.controller;

import junit.framework.TestCase;

public class ThirdPartyAcceptanceSubmitServletTest extends TestCase {

    public void testAcceptanceRequiresCommentAndValidSatisfaction() {
        assertEquals("เรียบร้อย", ThirdPartyAcceptanceSubmitServlet.requireComment(" เรียบร้อย "));
        assertEquals(5, ThirdPartyAcceptanceSubmitServlet.parseSatisfaction("5"));
        try {
            ThirdPartyAcceptanceSubmitServlet.parseSatisfaction("0");
            fail("Expected invalid satisfaction");
        } catch (IllegalArgumentException expected) {
            assertTrue(expected.getMessage().contains("คะแนน"));
        }
        try {
            ThirdPartyAcceptanceSubmitServlet.parseSatisfaction("abc");
            fail("Expected invalid satisfaction");
        } catch (IllegalArgumentException expected) {
            assertFalse(expected.getMessage().contains("For input string"));
        }
    }
}
