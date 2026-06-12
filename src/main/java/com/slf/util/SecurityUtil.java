package com.slf.util;

import java.security.SecureRandom;
import java.util.Base64;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

public final class SecurityUtil {
    private static final SecureRandom RANDOM = new SecureRandom();
    private static final String CSRF_SESSION_KEY = "slfCsrfToken";

    private SecurityUtil() {
    }

    public static String ensureCsrfToken(HttpServletRequest request) {
        HttpSession session = request.getSession();
        Object existing = session.getAttribute(CSRF_SESSION_KEY);
        if (existing instanceof String && !((String) existing).isEmpty()) {
            return (String) existing;
        }
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        session.setAttribute(CSRF_SESSION_KEY, token);
        return token;
    }

    public static boolean isValidCsrfToken(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object expected = session == null ? null : session.getAttribute(CSRF_SESSION_KEY);
        String actual = request.getParameter("csrfToken");
        return expected instanceof String && actual != null && expected.equals(actual);
    }

    public static String escapeHtml(Object value) {
        if (value == null) {
            return "";
        }
        return value.toString()
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }
}
