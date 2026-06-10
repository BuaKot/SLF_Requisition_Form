package com.slf.util;

import javax.servlet.http.HttpServletRequest;

public final class RequestMetadataUtil {
    private static final String[] IP_HEADERS = new String[] {
        "X-Forwarded-For",
        "X-Real-IP",
        "Proxy-Client-IP",
        "WL-Proxy-Client-IP",
        "HTTP_X_FORWARDED_FOR"
    };

    private RequestMetadataUtil() {
    }

    public static String getClientIp(HttpServletRequest request) {
        for (String header : IP_HEADERS) {
            String value = firstForwardedValue(request.getHeader(header));
            if (value != null) {
                return value;
            }
        }
        return trimToNull(request.getRemoteAddr());
    }

    private static String firstForwardedValue(String headerValue) {
        String trimmed = trimToNull(headerValue);
        if (trimmed == null) {
            return null;
        }

        String[] values = trimmed.split(",");
        for (String value : values) {
            String candidate = trimToNull(value);
            if (candidate != null && !"unknown".equalsIgnoreCase(candidate)) {
                return candidate;
            }
        }
        return null;
    }

    private static String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
