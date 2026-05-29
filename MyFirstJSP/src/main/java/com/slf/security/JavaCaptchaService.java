package com.slf.security;

import java.security.SecureRandom;
import java.util.Base64;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

public class JavaCaptchaService {
    private static final String SESSION_ANSWER = "javaCaptchaAnswer";
    private static final String SESSION_EXPIRES = "javaCaptchaExpiresAt";
    private static final String TOKEN = "java-session-captcha";
    private static final long TTL_MILLIS = 5L * 60L * 1000L;
    private static final char[] ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789".toCharArray();
    private static final SecureRandom RANDOM = new SecureRandom();

    public static CaptchaChallenge createChallenge(HttpServletRequest request) {
        String answer = randomAnswer();
        HttpSession session = request.getSession(true);
        session.setAttribute(SESSION_ANSWER, answer);
        session.setAttribute(SESSION_EXPIRES, Long.valueOf(System.currentTimeMillis() + TTL_MILLIS));
        return CaptchaChallenge.available(TOKEN, imageDataUrl(answer));
    }

    public static boolean verify(HttpServletRequest request, String token, String answer) {
        if (!TOKEN.equals(token) || answer == null || answer.trim().length() == 0) {
            return false;
        }

        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }

        Object expected = session.getAttribute(SESSION_ANSWER);
        Object expiresAt = session.getAttribute(SESSION_EXPIRES);
        session.removeAttribute(SESSION_ANSWER);
        session.removeAttribute(SESSION_EXPIRES);

        if (!(expected instanceof String) || !(expiresAt instanceof Long)) {
            return false;
        }

        if (System.currentTimeMillis() > ((Long) expiresAt).longValue()) {
            return false;
        }

        return ((String) expected).equalsIgnoreCase(answer.trim());
    }

    private static String randomAnswer() {
        StringBuilder answer = new StringBuilder();
        for (int index = 0; index < 5; index++) {
            answer.append(ALPHABET[RANDOM.nextInt(ALPHABET.length)]);
        }
        return answer.toString();
    }

    private static String imageDataUrl(String answer) {
        StringBuilder letters = new StringBuilder();
        for (int index = 0; index < answer.length(); index++) {
            int x = 22 + (index * 30);
            int y = 45 + ((index % 2) * 7);
            int rotate = index % 2 == 0 ? -8 : 7;
            letters.append("<text x=\"").append(x)
                .append("\" y=\"").append(y)
                .append("\" transform=\"rotate(").append(rotate)
                .append(" ").append(x).append(" ").append(y).append(")\">")
                .append(answer.charAt(index))
                .append("</text>");
        }

        String svg = "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"190\" height=\"72\" viewBox=\"0 0 190 72\">"
            + "<rect width=\"190\" height=\"72\" rx=\"8\" fill=\"#f6f9fc\"/>"
            + "<path d=\"M8 18 C40 38,70 2,108 24 S160 42,182 20\" fill=\"none\" stroke=\"#8fbce8\" stroke-width=\"3\"/>"
            + "<path d=\"M9 55 C42 30,82 68,124 43 S162 31,184 49\" fill=\"none\" stroke=\"#d8a63a\" stroke-width=\"2\"/>"
            + "<g font-family=\"Consolas,monospace\" font-size=\"32\" font-weight=\"700\" fill=\"#063d73\">"
            + letters
            + "</g><g stroke=\"#94a3b8\" stroke-width=\"1\">"
            + "<line x1=\"16\" y1=\"12\" x2=\"174\" y2=\"59\"/>"
            + "<line x1=\"10\" y1=\"61\" x2=\"180\" y2=\"10\"/>"
            + "</g></svg>";

        return "data:image/svg+xml;base64," + Base64.getEncoder().encodeToString(svg.getBytes());
    }
}
