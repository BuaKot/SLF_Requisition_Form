package com.slf.controller;

import com.slf.model.ThirdPartyAccessRequest;
import java.util.Arrays;
import junit.framework.TestCase;

public class ThirdPartySubmitServletTest extends TestCase {

    public void testAcceptsCompleteAccessRequest() {
        ThirdPartyAccessRequest item = validItem();
        ThirdPartySubmitServlet.validateAccessRequests(Arrays.asList(item));
    }

    public void testRequiresNationalIdForDsl() {
        ThirdPartyAccessRequest item = validItem();
        item.setSystemName("DSL");
        assertInvalid(item);
    }

    public void testRequiresEnglishFullNameForAccessRequest() {
        ThirdPartyAccessRequest item = validItem();
        item.setFullNameEn(null);
        assertInvalid(item);
    }

    public void testValidatesThaiNationalIdChecksum() {
        assertTrue(ThirdPartySubmitServlet.isValidThaiNationalId("1101700203450"));
        assertFalse(ThirdPartySubmitServlet.isValidThaiNationalId("1101700203451"));
    }

    private static ThirdPartyAccessRequest validItem() {
        ThirdPartyAccessRequest item = new ThirdPartyAccessRequest();
        item.setDisplayOrder(1);
        item.setFullNameTh("Test User");
        item.setFullNameEn("Test User");
        item.setPositionName("Consultant");
        item.setMobilePhone("0812345678");
        item.setDepartmentName("Vendor");
        item.setEmail("test@example.com");
        item.setSystemName("Reporting");
        item.setRequestedRole("Viewer");
        return item;
    }

    private static void assertInvalid(ThirdPartyAccessRequest item) {
        try {
            ThirdPartySubmitServlet.validateAccessRequests(Arrays.asList(item));
            fail("Expected invalid access request");
        } catch (IllegalArgumentException expected) {
            assertTrue(expected.getMessage().length() > 0);
        }
    }
}
