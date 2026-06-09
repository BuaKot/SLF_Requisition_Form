package com.slf.util;

import java.util.*;

public class AuthUtil {

    // ----- Existing admin‑link logic (unchanged) -----
    private static final Set<String> ADMIN_ROLES = new HashSet<>(Arrays.asList(
        "Admin", "Director", "ITDirector", "IT Director", "Technical",
        "Development", "Data", "Infrastructure",
        "Cyber Security", "Research", "Reseach", "IT Planning"
    ));

    public static boolean isAdmin(String position) {
        return containsRole(ADMIN_ROLES, position);
    }

    // ----- New: page‑level permissions -----

    // Map from pageKey → set of roles that can view the page
    private static final Map<String, Set<String>> PAGE_ROLES = new HashMap<>();

    static {
        // These keys can be whatever you like; use the same ones in the JSP and filter.
        PAGE_ROLES.put("directorApprove",    new HashSet<>(Arrays.asList("Admin", "Director")));
        PAGE_ROLES.put("technicalApprove",   new HashSet<>(Arrays.asList("Admin", "Technical")));
        PAGE_ROLES.put("itDirectorApprove",  new HashSet<>(Arrays.asList("Admin", "ITDirector", "IT Director")));
        PAGE_ROLES.put("process",            new HashSet<>(Arrays.asList("Admin", "Technical",
                                                    "Development", "Data", "Infrastructure",
                                                    "Cyber Security", "Research", "Reseach", "IT Planning")));
        PAGE_ROLES.put("adminPage",          ADMIN_ROLES);
        PAGE_ROLES.put("dashboard",          new HashSet<>(Arrays.asList("Admin")));
        PAGE_ROLES.put("memberManage",       new HashSet<>(Arrays.asList("Admin")));
        PAGE_ROLES.put("mailLog",            new HashSet<>(Arrays.asList("Admin")));
        PAGE_ROLES.put("thirdPartyLinks",    new HashSet<>(Arrays.asList("Admin")));
        PAGE_ROLES.put("thirdPartySubmission", new HashSet<>(Arrays.asList("*")));
        PAGE_ROLES.put("requisitionDetail",  ADMIN_ROLES);
        PAGE_ROLES.put("formSelection",      new HashSet<>(Arrays.asList("*")));
        // Add more keys as you create pages
    }

    /**
     * Returns true if the given position should be allowed to access the page
     * identified by pageKey.
     */
    public static boolean isAllowedForPage(String position, String pageKey) {
        if (pageKey == null) return false;
        Set<String> allowed = PAGE_ROLES.get(pageKey);
        if (allowed != null && allowed.contains("*")) return true;
        if (position == null) return false;
        return allowed != null && containsRole(allowed, position);
    }

    private static boolean containsRole(Set<String> allowedRoles, String position) {
        if (position == null) return false;
        String normalizedPosition = position.trim();
        for (String allowedRole : allowedRoles) {
            if (allowedRole.equalsIgnoreCase(normalizedPosition)) {
                return true;
            }
        }
        return false;
    }
}
