package com.slf.util;

import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtil {
    // Define how expensive the hashing is (10–12 is good)
    private static final int BCRYPT_ROUNDS = 12;

    /**
     * Hash a plain‑text password. Returns a 60‑character BCrypt hash.
     */
    public static String hash(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(BCRYPT_ROUNDS));
    }

    /**
     * Check a plain‑text password against a BCrypt hash.
     */
    public static boolean check(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null) {
            return false;
        }

        if (!hashedPassword.startsWith("$2a$")) {
            return plainPassword.equals(hashedPassword);
        }

        return BCrypt.checkpw(plainPassword, hashedPassword);
    }
}
