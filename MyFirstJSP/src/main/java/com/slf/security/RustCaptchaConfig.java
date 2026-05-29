package com.slf.security;

public class RustCaptchaConfig {
    private static final String DEFAULT_SERVICE_URL = "http://127.0.0.1:8787";

    public static String getServiceUrl() {
        String systemValue = System.getProperty("captcha.serviceUrl");
        if (hasText(systemValue)) {
            return trimTrailingSlash(systemValue);
        }

        String envValue = System.getenv("CAPTCHA_SERVICE_URL");
        if (hasText(envValue)) {
            return trimTrailingSlash(envValue);
        }

        return DEFAULT_SERVICE_URL;
    }

    static boolean hasText(String value) {
        return value != null && value.trim().length() > 0;
    }

    private static String trimTrailingSlash(String value) {
        String trimmed = value.trim();
        while (trimmed.endsWith("/")) {
            trimmed = trimmed.substring(0, trimmed.length() - 1);
        }
        return trimmed;
    }
}
