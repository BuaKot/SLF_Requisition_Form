package com.slf.util;

import junit.framework.TestCase;

public class PasswordUtilTest extends TestCase {

    public void testAcceptsLegacyPlainTextPasswordDuringMigration() {
        assertTrue(PasswordUtil.check("1234", "1234"));
        assertFalse(PasswordUtil.check("1234", "wrong"));
    }
}
