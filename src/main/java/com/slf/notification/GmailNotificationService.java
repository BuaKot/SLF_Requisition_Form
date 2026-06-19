package com.slf.notification;

import java.io.InputStream;
import java.util.Properties;
import javax.activation.DataHandler;
import javax.activation.DataSource;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Multipart;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;
import javax.mail.util.ByteArrayDataSource;

public class GmailNotificationService {
    private static final String LOGO_CID = "slf-logo";
    private static final String LOGO_RESOURCE = "/SLF_logo.png";

    private final GmailNotificationConfig config;

    public GmailNotificationService() {
        this(GmailNotificationConfig.fromEnvironment());
    }

    public GmailNotificationService(GmailNotificationConfig config) {
        this.config = config;
    }

    public boolean isConfigured() {
        return config.isConfigured();
    }

    public NotificationSendResult sendFormSubmittedNotification(int formId, int requesterEmpId, String requestTopic) {
        return sendFormSubmittedNotification(formId, requesterEmpId, requestTopic, config.getRecipient());
    }

    public NotificationSendResult sendFormSubmittedNotification(int formId, int requesterEmpId,
                                                                String requestTopic, String recipient) {
        if (!config.canSendFrom()) {
            return NotificationSendResult.failed(
                "Gmail notification failed: set slf.mail.username, slf.mail.password, and slf.mail.from "
                    + "in C:\\slf-secrets\\gmail.properties or SLF_MAIL_* environment variables."
            );
        }

        String resolvedRecipient = firstText(recipient, config.getRecipient());
        if (resolvedRecipient == null) {
            return NotificationSendResult.skipped("Gmail notification skipped: no recipient email was found.");
        }

        try {
            sendEmail(
                buildSubmittedSubject(formId),
                buildSubmittedBody(formId, requesterEmpId, requestTopic),
                resolvedRecipient
            );
            return NotificationSendResult.sent();
        } catch (Exception e) {
            return NotificationSendResult.failed(errorMessage(e));
        }
    }

    public String buildSubmittedSubject(int formId) {
        return "[SLF] New requisition form #" + formId;
    }

    public String buildSubmittedBody(int formId, int requesterEmpId, String requestTopic) {
        StringBuilder body = new StringBuilder();
        body.append("A new requisition form was submitted.").append("\n\n");
        body.append("Form ID: ").append(formId).append("\n");
        body.append("Requester EMPID: ").append(requesterEmpId).append("\n");
        if (requestTopic != null && requestTopic.trim().length() > 0) {
            body.append("Topic: ").append(requestTopic.trim()).append("\n");
        }
        body.append("\nOpen the SLF Requisition Form system to review it.");
        return body.toString();
    }

    public NotificationSendResult sendEmailNotification(String subject, String body, String recipient) {
        if (!config.canSendFrom()) {
            return NotificationSendResult.failed(
                "Gmail notification failed: set slf.mail.username, slf.mail.password, and slf.mail.from "
                    + "in C:\\slf-secrets\\gmail.properties or SLF_MAIL_* environment variables."
            );
        }

        String resolvedRecipient = GmailNotificationConfig.trimToNull(recipient);
        if (resolvedRecipient == null) {
            return NotificationSendResult.skipped("Gmail notification skipped: no recipient email was found.");
        }

        try {
            sendEmail(subject, body, resolvedRecipient);
            return NotificationSendResult.sent();
        } catch (Exception e) {
            return NotificationSendResult.failed(errorMessage(e));
        }
    }

    private void sendEmail(String subject, String body, String recipient) throws MessagingException {
        MimeMessage message = new MimeMessage(mailSession());
        message.setFrom(new InternetAddress(config.getFrom()));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipient, false));
        message.setSubject(subject, "UTF-8");

        String trimmed = body != null ? body.trim() : "";
        boolean isHtml = trimmed.startsWith("<!DOCTYPE") || trimmed.startsWith("<html")
            || trimmed.contains("<body");

        if (isHtml) {
            // Build multipart/alternative: plain-text + HTML-with-image
            Multipart alternative = new MimeMultipart("alternative");

            // Plain text part (stripped HTML)
            MimeBodyPart textPart = new MimeBodyPart();
            textPart.setText(HtmlEmailRenderer.stripHtml(body), "UTF-8");
            alternative.addBodyPart(textPart);

            // HTML + inline image: wrap in multipart/related
            Multipart related = new MimeMultipart("related");

            // HTML part
            MimeBodyPart htmlPart = new MimeBodyPart();
            htmlPart.setContent(body, "text/html; charset=UTF-8");
            related.addBodyPart(htmlPart);

            // Inline logo image (if available)
            MimeBodyPart imagePart = createLogoImagePart();
            if (imagePart != null) {
                related.addBodyPart(imagePart);
            }

            // Wrap related as a single body part inside alternative
            MimeBodyPart wrappedRelated = new MimeBodyPart();
            wrappedRelated.setContent(related);
            alternative.addBodyPart(wrappedRelated);

            message.setContent(alternative);
        } else {
            message.setContent(body, "text/plain; charset=UTF-8");
        }

        Transport.send(message);
    }

    /**
     * Creates an inline MIME body part for the SLF logo image.
     * Returns null if the logo resource cannot be found.
     */
    private MimeBodyPart createLogoImagePart() {
        try {
            InputStream logoStream = getClass().getResourceAsStream(LOGO_RESOURCE);
            if (logoStream == null) {
                // Fallback: try class loader
                logoStream = Thread.currentThread().getContextClassLoader().getResourceAsStream("SLF_logo.png");
            }
            if (logoStream == null) {
                return null;
            }
            byte[] logoBytes = readAllBytes(logoStream);
            logoStream.close();

            DataSource dataSource = new ByteArrayDataSource(logoBytes, "image/png");
            MimeBodyPart imagePart = new MimeBodyPart();
            imagePart.setDataHandler(new DataHandler(dataSource));
            imagePart.setContentID("<" + LOGO_CID + ">");
            imagePart.setDisposition(MimeBodyPart.INLINE);
            imagePart.setFileName("SLF_logo.png");
            return imagePart;
        } catch (Exception e) {
            System.err.println("Unable to attach SLF logo image: " + e.getMessage());
            return null;
        }
    }

    /**
     * Reads all bytes from an InputStream (Java 8 compatible).
     */
    private static byte[] readAllBytes(InputStream stream) throws java.io.IOException {
        java.io.ByteArrayOutputStream buffer = new java.io.ByteArrayOutputStream();
        byte[] data = new byte[8192];
        int n;
        while ((n = stream.read(data, 0, data.length)) != -1) {
            buffer.write(data, 0, n);
        }
        return buffer.toByteArray();
    }

    private Session mailSession() {
        Properties properties = new Properties();
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.host", config.getHost());
        properties.put("mail.smtp.port", String.valueOf(config.getPort()));
        properties.put("mail.smtp.ssl.trust", config.getHost());
        properties.put("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3");
        properties.put("mail.smtp.connectiontimeout", "10000");
        properties.put("mail.smtp.timeout", "15000");
        properties.put("mail.smtp.writetimeout", "15000");
        if (config.isSslEnabled()) {
            properties.put("mail.smtp.ssl.enable", "true");
            properties.put("mail.smtp.starttls.enable", "false");
        } else {
            properties.put("mail.smtp.ssl.enable", "false");
            properties.put("mail.smtp.starttls.enable", "true");
            properties.put("mail.smtp.starttls.required", "true");
        }

        return Session.getInstance(properties, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(config.getUsername(), config.getPassword());
            }
        });
    }

    private static String firstText(String first, String second) {
        String value = GmailNotificationConfig.trimToNull(first);
        return value != null ? value : GmailNotificationConfig.trimToNull(second);
    }

    private static String errorMessage(Exception exception) {
        StringBuilder message = new StringBuilder(firstText(exception.getMessage(), exception.getClass().getName()));
        Throwable cause = exception.getCause();
        while (cause != null) {
            String causeMessage = firstText(cause.getMessage(), cause.getClass().getName());
            if (message.indexOf(causeMessage) < 0) {
                message.append(" | Cause: ").append(causeMessage);
            }
            cause = cause.getCause();
        }
        return message.toString();
    }
}