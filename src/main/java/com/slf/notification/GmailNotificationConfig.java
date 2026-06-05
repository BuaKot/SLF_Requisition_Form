package com.slf.notification;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Properties;

public class GmailNotificationConfig {
    static final String DEFAULT_CONFIG_PATH = "C:\\slf-secrets\\gmail.properties";
    static final String DEFAULT_SMTP_HOST = "smtp.gmail.com";
    static final int DEFAULT_SMTP_PORT = 587;

    private final boolean enabled;
    private final String host;
    private final int port;
    private final boolean sslEnabled;
    private final String username;
    private final String password;
    private final String from;
    private final String recipient;

    public GmailNotificationConfig(boolean enabled, String host, int port, boolean sslEnabled, String username,
                                   String password, String from, String recipient) {
        this.enabled = enabled;
        this.host = firstText(host, DEFAULT_SMTP_HOST);
        this.port = port > 0 ? port : DEFAULT_SMTP_PORT;
        this.sslEnabled = sslEnabled || this.port == 465;
        this.username = trimToNull(username);
        this.password = trimToNull(password);
        this.from = firstText(from, username);
        this.recipient = trimToNull(recipient);
    }

    public static GmailNotificationConfig fromEnvironment() {
        Properties fileSettings = loadFileSettings();
        String username = setting("slf.mail.username", "SLF_MAIL_USERNAME", fileSettings,
            setting("slf.gmail.sender", "SLF_GMAIL_SENDER", fileSettings, null));

        return new GmailNotificationConfig(
            booleanSetting("slf.mail.enabled", "SLF_MAIL_ENABLED", fileSettings,
                booleanSetting("slf.gmail.enabled", "SLF_GMAIL_ENABLED", fileSettings, true)),
            setting("slf.mail.host", "SLF_MAIL_HOST", fileSettings, DEFAULT_SMTP_HOST),
            intSetting("slf.mail.port", "SLF_MAIL_PORT", fileSettings, DEFAULT_SMTP_PORT),
            booleanSetting("slf.mail.ssl", "SLF_MAIL_SSL", fileSettings, false),
            username,
            setting("slf.mail.password", "SLF_MAIL_PASSWORD", fileSettings, null),
            setting("slf.mail.from", "SLF_MAIL_FROM", fileSettings,
                setting("slf.gmail.sender", "SLF_GMAIL_SENDER", fileSettings, username)),
            setting("slf.mail.to", "SLF_MAIL_TO", fileSettings,
                setting("slf.gmail.to", "SLF_GMAIL_TO", fileSettings, null))
        );
    }

    public boolean isEnabled() {
        return enabled;
    }

    public String getHost() {
        return host;
    }

    public int getPort() {
        return port;
    }

    public boolean isSslEnabled() {
        return sslEnabled;
    }

    public String getUsername() {
        return username;
    }

    public String getPassword() {
        return password;
    }

    public String getFrom() {
        return from;
    }

    public String getRecipient() {
        return recipient;
    }

    public boolean isConfigured() {
        return canSendFrom() && recipient != null;
    }

    public boolean canSendFrom() {
        return enabled && host != null && port > 0 && username != null && password != null && from != null;
    }

    static String setting(String propertyName, String envName, Properties fileSettings, String defaultValue) {
        String propertyValue = trimToNull(System.getProperty(propertyName));
        if (propertyValue != null) {
            return propertyValue;
        }

        String envValue = trimToNull(System.getenv(envName));
        if (envValue != null) {
            return envValue;
        }

        String fileValue = trimToNull(fileSettings.getProperty(propertyName));
        if (fileValue != null) {
            return fileValue;
        }

        return defaultValue;
    }

    static boolean booleanSetting(String propertyName, String envName, Properties fileSettings, boolean defaultValue) {
        String value = setting(propertyName, envName, fileSettings, null);
        if (value == null) {
            return defaultValue;
        }
        return !"false".equalsIgnoreCase(value) && !"0".equals(value.trim());
    }

    static int intSetting(String propertyName, String envName, Properties fileSettings, int defaultValue) {
        String value = setting(propertyName, envName, fileSettings, null);
        if (value == null) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    static Properties loadFileSettings() {
        String pathValue = trimToNull(System.getProperty("slf.mail.config"));
        if (pathValue == null) {
            pathValue = trimToNull(System.getenv("SLF_MAIL_CONFIG"));
        }
        if (pathValue == null) {
            pathValue = trimToNull(System.getProperty("slf.gmail.config"));
        }
        if (pathValue == null) {
            pathValue = trimToNull(System.getenv("SLF_GMAIL_CONFIG"));
        }
        if (pathValue == null) {
            pathValue = DEFAULT_CONFIG_PATH;
        }

        Properties properties = new Properties();
        Path path = Paths.get(pathValue);
        if (!Files.isRegularFile(path)) {
            return properties;
        }

        try (InputStream input = Files.newInputStream(path)) {
            properties.load(input);
        } catch (IOException e) {
            System.err.println("Unable to read Gmail SMTP config file: " + e.getMessage());
        }
        return properties;
    }

    static String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private static String firstText(String first, String second) {
        String value = trimToNull(first);
        return value != null ? value : trimToNull(second);
    }
}
