package com.slf.util;

import junit.framework.TestCase;

public class ThirdPartyLinkTokenTest extends TestCase {

    public void testGeneratesSixtyFourRandomBytesAsUrlSafeToken() {
        String token = ThirdPartyLinkToken.generateRawToken();

        assertEquals(86, token.length());
        assertTrue(token.matches("^[A-Za-z0-9_-]+$"));
    }

    public void testSha256HexIsStableAndDoesNotExposeRawToken() {
        String hash = ThirdPartyLinkToken.sha256Hex("sample-token");

        assertEquals(64, hash.length());
        assertEquals(hash, ThirdPartyLinkToken.sha256Hex(" sample-token "));
        assertFalse(hash.contains("sample-token"));
    }
}
