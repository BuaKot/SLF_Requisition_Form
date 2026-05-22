package com.slf.util;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

public class AuthUtil {

    // This set is the single source of truth for who sees the Admin link.
    // CHANGE IT HERE when roles evolve. Or replace the whole set with a DB call later.
    private static final Set<String> ADMIN_ROLES = new HashSet<>(Arrays.asList(
        "Admin", "Director", "ITDirector", "Technical",
        "Development", "Data", "Infrastructure",
        "Cyber Security", "Research", "IT Planning"
    ));

    /**
     * Returns true if the given position should have access to admin features.
     */
    public static boolean isAdmin(String position) {
        return position != null && ADMIN_ROLES.contains(position.trim());
    }
}