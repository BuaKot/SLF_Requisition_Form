package com.slf.util;

import javax.servlet.http.HttpSession;

public final class ThirdPartyAccessPolicy {
    public static final int INTERNAL_LINK_CREATOR_EMPID = 678;

    private ThirdPartyAccessPolicy() {
    }

    public static Integer sessionEmpId(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object value = session.getAttribute("loggedInEmpId");
        if (value == null) {
            value = session.getAttribute("empid");
        }
        if (value == null) {
            return null;
        }
        try {
            return Integer.valueOf(value.toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    public static boolean canCreateOwnLinks(Integer empId) {
        return empId != null && empId.intValue() == INTERNAL_LINK_CREATOR_EMPID;
    }

    public static boolean canViewSubmission(String position, Integer empId, Integer ownerEmpId) {
        return AuthUtil.isAllowedForPage(position, "thirdPartySubmission")
            || (canCreateOwnLinks(empId) && empId.equals(ownerEmpId));
    }
}
