package com.slf.security;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class LoginAttemptService {
    public static final int CAPTCHA_THRESHOLD = 3;
    public static final int BLOCK_THRESHOLD = 10;
    public static final long WINDOW_MILLIS = 5L * 60L * 1000L;
    public static final long BLOCK_MILLIS = 15L * 60L * 1000L;

    private static final LoginAttemptService INSTANCE = new LoginAttemptService();

    private final Map<String, AttemptState> attempts = new ConcurrentHashMap<>();

    public static LoginAttemptService getInstance() {
        return INSTANCE;
    }

    public boolean isCaptchaRequired(String clientIp, String empId) {
        AttemptState state = currentState(buildKey(clientIp, empId));
        return state.failures >= CAPTCHA_THRESHOLD;
    }

    public boolean isBlocked(String clientIp, String empId) {
        AttemptState state = currentState(buildKey(clientIp, empId));
        long now = System.currentTimeMillis();
        return state.blockedUntil > now;
    }

    public void recordFailure(String clientIp, String empId) {
        String key = buildKey(clientIp, empId);
        AttemptState state = currentState(key);
        long now = System.currentTimeMillis();
        state.failures++;
        state.lastFailureAt = now;
        if (state.failures >= BLOCK_THRESHOLD) {
            state.blockedUntil = now + BLOCK_MILLIS;
        }
        attempts.put(key, state);
    }

    public void recordSuccess(String clientIp, String empId) {
        attempts.remove(buildKey(clientIp, empId));
    }

    public void clear() {
        attempts.clear();
    }

    static String buildKey(String clientIp, String empId) {
        String ipPart = hasText(clientIp) ? clientIp.trim() : "unknown-ip";
        String empPart = hasText(empId) ? empId.trim().toLowerCase() : "unknown-emp";
        return ipPart + ":" + empPart;
    }

    private AttemptState currentState(String key) {
        AttemptState state = attempts.get(key);
        if (state == null) {
            return new AttemptState();
        }

        long now = System.currentTimeMillis();
        boolean windowExpired = state.lastFailureAt > 0 && now - state.lastFailureAt > WINDOW_MILLIS;
        boolean blockActive = state.blockedUntil > now;
        if (windowExpired && !blockActive) {
            attempts.remove(key);
            return new AttemptState();
        }
        return state;
    }

    private static boolean hasText(String value) {
        return value != null && value.trim().length() > 0;
    }

    private static class AttemptState {
        int failures;
        long lastFailureAt;
        long blockedUntil;
    }
}
