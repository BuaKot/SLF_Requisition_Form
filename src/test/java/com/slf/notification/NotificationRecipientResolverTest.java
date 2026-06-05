package com.slf.notification;

import junit.framework.TestCase;

public class NotificationRecipientResolverTest extends TestCase {

    public void testAcceptsEmailShape() {
        assertTrue(NotificationRecipientResolver.hasEmailShape(" user@gmail.com "));
    }

    public void testRejectsPhoneNumberShape() {
        assertFalse(NotificationRecipientResolver.hasEmailShape("0812345678"));
    }

    public void testRejectsBlankEmail() {
        assertFalse(NotificationRecipientResolver.hasEmailShape(" "));
    }
}
