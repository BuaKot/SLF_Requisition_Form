package com.slf.security;

public class CaptchaChallenge {
    private final boolean available;
    private final String token;
    private final String imageDataUrl;
    private final String message;

    private CaptchaChallenge(boolean available, String token, String imageDataUrl, String message) {
        this.available = available;
        this.token = token;
        this.imageDataUrl = imageDataUrl;
        this.message = message;
    }

    public static CaptchaChallenge available(String token, String imageDataUrl) {
        return new CaptchaChallenge(true, token, imageDataUrl, "");
    }

    public static CaptchaChallenge unavailable(String message) {
        return new CaptchaChallenge(false, "", "", message);
    }

    public boolean isAvailable() {
        return available;
    }

    public String getToken() {
        return token;
    }

    public String getImageDataUrl() {
        return imageDataUrl;
    }

    public String getMessage() {
        return message;
    }
}
