package com.slf.security;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URLEncoder;
import java.net.URL;

public class RustCaptchaClient {
    private static final ObjectMapper JSON = new ObjectMapper();

    private final String serviceUrl;

    public RustCaptchaClient() {
        this(RustCaptchaConfig.getServiceUrl());
    }

    public RustCaptchaClient(String serviceUrl) {
        this.serviceUrl = serviceUrl;
    }

    public CaptchaChallenge createChallenge() {
        try {
            HttpURLConnection connection = open("/captcha/new");
            connection.setRequestMethod("POST");
            connection.setDoOutput(true);
            connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");
            connection.getOutputStream().close();

            JsonNode response = JSON.readTree(readResponse(connection));
            if (response.path("ok").asBoolean(false)) {
                return CaptchaChallenge.available(
                    response.path("token").asText(""),
                    response.path("imageDataUrl").asText("")
                );
            }
            return CaptchaChallenge.unavailable("ระบบ CAPTCHA ไม่พร้อมใช้งาน");
        } catch (Exception e) {
            return CaptchaChallenge.unavailable("ระบบ CAPTCHA ไม่พร้อมใช้งาน");
        }
    }

    public boolean verify(String token, String answer) {
        if (!hasText(token) || !hasText(answer)) {
            return false;
        }

        try {
            HttpURLConnection connection = open("/captcha/verify");
            connection.setRequestMethod("POST");
            connection.setDoOutput(true);
            connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");

            String body = "token=" + encode(token) + "&answer=" + encode(answer);
            try (OutputStream output = connection.getOutputStream()) {
                output.write(body.getBytes("UTF-8"));
            }

            JsonNode response = JSON.readTree(readResponse(connection));
            return response.path("ok").asBoolean(false);
        } catch (Exception e) {
            return false;
        }
    }

    private HttpURLConnection open(String path) throws IOException {
        HttpURLConnection connection = (HttpURLConnection) new URL(serviceUrl + path).openConnection();
        connection.setConnectTimeout(2000);
        connection.setReadTimeout(3000);
        return connection;
    }

    private static String readResponse(HttpURLConnection connection) throws IOException {
        InputStream stream = connection.getResponseCode() >= 400
            ? connection.getErrorStream()
            : connection.getInputStream();
        if (stream == null) {
            return "{}";
        }

        try (BufferedReader reader = new BufferedReader(new InputStreamReader(stream, "UTF-8"))) {
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                response.append(line);
            }
            return response.toString();
        }
    }

    private static String encode(String value) throws IOException {
        return URLEncoder.encode(value, "UTF-8");
    }

    private static boolean hasText(String value) {
        return value != null && value.trim().length() > 0;
    }
}
