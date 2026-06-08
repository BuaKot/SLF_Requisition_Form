package com.slf.util;

import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

public final class ThirdPartyLinkToken {
    private static final SecureRandom RANDOM = new SecureRandom();
    static final int TOKEN_BYTE_LENGTH = 64;

    private ThirdPartyLinkToken() {
    }

    public static String generateRawToken() {
        byte[] bytes = new byte[TOKEN_BYTE_LENGTH];
        RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    public static String sha256Hex(String rawToken) {
        if (rawToken == null || rawToken.trim().isEmpty()) {
            throw new IllegalArgumentException("Token is required.");
        }
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(rawToken.trim().getBytes("UTF-8"));
            StringBuilder hex = new StringBuilder(hash.length * 2);
            for (byte value : hash) {
                hex.append(String.format("%02x", value & 0xff));
            }
            return hex.toString();
        } catch (Exception e) {
            throw new IllegalStateException("Unable to hash third-party link token.", e);
        }
    }
}
