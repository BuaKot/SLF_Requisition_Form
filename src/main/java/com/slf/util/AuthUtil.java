package com.slf.util;

import java.util.*;

public class AuthUtil {

    // ----- Existing admin‑link logic (unchanged) -----
    private static final Set<String> ADMIN_ROLES = new HashSet<>(Arrays.asList(
        "Admin", "Director", "ITDirector", "IT Director", "Technical",
        "Development", "Data", "Infrastructure",
        "Cyber Security", "Research", "Reseach", "IT Planning"
    ));

    private static final Set<String> ADMIN_PAGE_ROLES = new HashSet<>(Collections.singletonList("Admin"));

    public static boolean isAdmin(String position) {
        return containsRole(ADMIN_ROLES, position);
    }

    public static boolean isApprovalOnlyRole(String position) {
        return roleEquals(position, "Director")
            || roleEquals(position, "ITDirector")
            || roleEquals(position, "IT Director");
    }

    public static String approvalPageForRole(String position) {
        if (roleEquals(position, "Director")) {
            return "/directorApprove";
        }
        if (roleEquals(position, "ITDirector") || roleEquals(position, "IT Director")) {
            return "/itDirectorApprove";
        }
        return null;
    }

    public static String approvalLabelForRole(String position) {
        if (roleEquals(position, "Director")) {
            return "รายการรออนุมัติของผู้อำนวยการฝ่าย";
        }
        if (roleEquals(position, "ITDirector") || roleEquals(position, "IT Director")) {
            return "รายการรออนุมัติของผู้อำนวยการฝ่ายเทคโนโลยีสารสนเทศ";
        }
        return "รายการรออนุมัติ";
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
        PAGE_ROLES.put("adminPage",          ADMIN_PAGE_ROLES);
        PAGE_ROLES.put("history",            ADMIN_ROLES);
        PAGE_ROLES.put("dashboard",          new HashSet<>(Arrays.asList("Admin")));
        PAGE_ROLES.put("memberManage",       new HashSet<>(Arrays.asList("Admin")));
        PAGE_ROLES.put("mailLog",            new HashSet<>(Arrays.asList("Admin")));
        PAGE_ROLES.put("thirdPartyLinks",    new HashSet<>(Arrays.asList("Admin")));
        PAGE_ROLES.put("thirdPartySubmission", new HashSet<>(Arrays.asList("Admin")));
        PAGE_ROLES.put("requisitionDetail",  ADMIN_ROLES);
        // Add more keys as you create pages
    }

    /**
     * Returns true if the given position should be allowed to access the page
     * identified by pageKey.
     */
    public static boolean isAllowedForPage(String position, String pageKey) {
        if (position == null || pageKey == null) return false;
        if ("history".equals(pageKey)) return true;
        Set<String> allowed = PAGE_ROLES.get(pageKey);
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

    private static boolean roleEquals(String position, String expected) {
        return position != null && expected.equalsIgnoreCase(position.trim());
    }
}
