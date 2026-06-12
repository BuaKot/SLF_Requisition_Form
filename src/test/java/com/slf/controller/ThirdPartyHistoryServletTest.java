package com.slf.controller;

import junit.framework.TestCase;

public class ThirdPartyHistoryServletTest extends TestCase {

    public void testNormalizesPageFilterAndSearch() {
        assertEquals(1, ThirdPartyHistoryServlet.parsePage(null));
        assertEquals(1, ThirdPartyHistoryServlet.parsePage("-2"));
        assertEquals(3, ThirdPartyHistoryServlet.parsePage(" 3 "));
        assertEquals("all", ThirdPartyHistoryServlet.normalizeFilter("unknown"));
        assertEquals("completed", ThirdPartyHistoryServlet.normalizeFilter("completed"));
        assertEquals("abc", ThirdPartyHistoryServlet.normalizeSearch(" abc "));
        assertEquals(100, ThirdPartyHistoryServlet.normalizeSearch(repeat("x", 120)).length());
    }

    private static String repeat(String value, int count) {
        StringBuilder result = new StringBuilder();
        for (int i = 0; i < count; i++) result.append(value);
        return result.toString();
    }
}
