package com.slf.util;

import java.util.*;

public class AuthUtil {

    // ----- Existing admin‑link logic (unchanged) -----
    private static final Set<String> ADMIN_ROLES = new HashSet<>(Arrays.asList(
        "Admin", "Director", "ITDirector", "Technical",
        "Development", "Data", "Infrastructure",
        "Cyber Security", "Research", "IT Planning"
    ));

    public static boolean isAdmin(String position) {
        return position != null && ADMIN_ROLES.contains(position.trim());
    }

    // ----- New: page‑level permissions -----

    // Map from pageKey → set of roles that can view the page
    private static final Map<String, Set<String>> PAGE_ROLES = new HashMap<>();

    static {
        // These keys can be whatever you like; use the same ones in the JSP and filter.
        PAGE_ROLES.put("directorApprove",    new HashSet<>(Arrays.asList("Admin", "Director")));
        PAGE_ROLES.put("technicalApprove",   new HashSet<>(Arrays.asList("Admin", "Technical")));
        PAGE_ROLES.put("itDirectorApprove",  new HashSet<>(Arrays.asList("Admin", "ITDirector")));
        PAGE_ROLES.put("process",            new HashSet<>(Arrays.asList("Admin", "Technical",
                                                    "Development", "Data", "Infrastructure",
                                                    "Cyber Security", "Research", "IT Planning")));
        PAGE_ROLES.put("adminPage",          ADMIN_ROLES);
        PAGE_ROLES.put("requisitionDetail",  ADMIN_ROLES);
        // Add more keys as you create pages
    }

    /**
     * Returns true if the given position should be allowed to access the page
     * identified by pageKey.
     */
    public static boolean isAllowedForPage(String position, String pageKey) {
        if (position == null || pageKey == null) return false;
        Set<String> allowed = PAGE_ROLES.get(pageKey);
        return allowed != null && allowed.contains(position.trim());
    }
}