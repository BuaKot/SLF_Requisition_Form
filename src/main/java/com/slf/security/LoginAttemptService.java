package com.slf.security;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class LoginAttemptService {
    public static final int CAPTCHA_THRESHOLD = 4;
    public static final int DELAY_THRESHOLD = 6;
    public static final long DELAY_MILLIS = 30L * 1000L;
    public static final long WINDOW_MILLIS = 10L * 60L * 1000L;

    private static final LoginAttemptService INSTANCE = new LoginAttemptService();

    private final Map<String, AttemptState> attempts = new ConcurrentHashMap<String, AttemptState>();

    public static LoginAttemptService getInstance() {
        return INSTANCE;
    }

    public boolean isCaptchaRequired(String clientIp, String empId) {
        AttemptState state = currentState(buildKey(clientIp, empId));
        return state.failures >= CAPTCHA_THRESHOLD;
    }

    public boolean isDelayRequired(String clientIp, String empId) {
        return getRemainingDelaySeconds(clientIp, empId) > 0;
    }

    public int getRemainingDelaySeconds(String clientIp, String empId) {
        AttemptState state = currentState(buildKey(clientIp, empId));
        long remainingMillis = state.delayedUntil - System.currentTimeMillis();
        if (remainingMillis <= 0) {
            return 0;
        }
        return (int) Math.ceil(remainingMillis / 1000.0d);
    }

    public void recordFailure(String clientIp, String empId) {
        String key = buildKey(clientIp, empId);
        AttemptState state = currentState(key);
        state.failures++;
        state.lastFailureAt = System.currentTimeMillis();
        if (state.failures >= DELAY_THRESHOLD) {
            state.delayedUntil = state.lastFailureAt + DELAY_MILLIS;
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
        if (windowExpired) {
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
        long delayedUntil;
    }
}
