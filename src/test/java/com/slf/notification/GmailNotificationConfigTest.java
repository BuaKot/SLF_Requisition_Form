package com.slf.notification;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import junit.framework.TestCase;

public class GmailNotificationConfigTest extends TestCase {

    public void testDefaultSmtpSettingsUseGmail() {
        assertEquals(
            "C:\\slf-secrets\\gmail.properties",
            GmailNotificationConfig.DEFAULT_CONFIG_PATH
        );
        assertEquals("smtp.gmail.com", GmailNotificationConfig.DEFAULT_SMTP_HOST);
        assertEquals(587, GmailNotificationConfig.DEFAULT_SMTP_PORT);
    }

    public void testConfigRequiresSmtpAccountAndRecipient() {
        GmailNotificationConfig missingRecipient = new GmailNotificationConfig(
            true,
            "smtp.gmail.com",
            587,
            false,
            "sender@example.com",
            "app-password",
            "sender@example.com",
            null
        );

        assertFalse(missingRecipient.isConfigured());

        GmailNotificationConfig complete = new GmailNotificationConfig(
            true,
            "smtp.gmail.com",
            587,
            false,
            "sender@example.com",
            "app-password",
            "sender@example.com",
            "to@example.com"
        );

        assertTrue(complete.isConfigured());
    }

    public void testReadsSmtpSettingsFromConfigFile() throws Exception {
        Path configFile = Files.createTempFile("slf-gmail", ".properties");
        String oldConfig = System.getProperty("slf.mail.config");
        String oldUsername = System.getProperty("slf.mail.username");
        try {
            Files.write(
                configFile,
                (
                    "slf.mail.host=smtp.gmail.com\n"
                        + "slf.mail.port=465\n"
                        + "slf.mail.ssl=true\n"
                        + "slf.mail.username=config-file-sender@example.com\n"
                        + "slf.mail.password=app-password\n"
                        + "slf.mail.from=config-file-sender@example.com\n"
                        + "slf.mail.to=to@example.com\n"
                ).getBytes(StandardCharsets.ISO_8859_1)
            );
            System.setProperty("slf.mail.config", configFile.toString());
            System.clearProperty("slf.mail.username");

            GmailNotificationConfig config = GmailNotificationConfig.fromEnvironment();
            assertEquals("smtp.gmail.com", config.getHost());
            assertEquals(465, config.getPort());
            assertTrue(config.isSslEnabled());
            assertEquals("config-file-sender@example.com", config.getUsername());
            assertEquals("app-password", config.getPassword());
            assertEquals("config-file-sender@example.com", config.getFrom());
            assertEquals("to@example.com", config.getRecipient());
        } finally {
            if (oldConfig == null) {
                System.clearProperty("slf.mail.config");
            } else {
                System.setProperty("slf.mail.config", oldConfig);
            }
            if (oldUsername == null) {
                System.clearProperty("slf.mail.username");
            } else {
                System.setProperty("slf.mail.username", oldUsername);
            }
            Files.deleteIfExists(configFile);
        }
    }

    public void testPort465EnablesSslByDefault() {
        GmailNotificationConfig config = new GmailNotificationConfig(
            true,
            "smtp.gmail.com",
            465,
            false,
            "sender@example.com",
            "app-password",
            "sender@example.com",
            "to@example.com"
        );

        assertTrue(config.isSslEnabled());
    }
}
