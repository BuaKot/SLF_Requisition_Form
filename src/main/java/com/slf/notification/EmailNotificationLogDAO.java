package com.slf.notification;

import com.slf.dao.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class EmailNotificationLogDAO {

    public long createPendingSubmittedLog(int formId, Integer recipientEmpId, String recipientEmail,
                                          String subject, String body, Integer createdBy) throws SQLException {
        String sql =
            "INSERT INTO EMAIL_NOTIFICATION_LOG " +
            "(FORMID, EVENT_TYPE, RECIPIENT_EMPID, RECIPIENT_EMAIL, SUBJECT, BODY, STATUS, SEND_ATTEMPT, DEDUPE_KEY, CREATED_BY) " +
            "VALUES (?, ?, ?, ?, ?, ?, 'PENDING', 0, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, new String[] { "EMAIL_LOG_ID" })) {
            ps.setInt(1, formId);
            ps.setString(2, "FORM_SUBMITTED");
            if (recipientEmpId != null) {
                ps.setInt(3, recipientEmpId);
            } else {
                ps.setNull(3, java.sql.Types.INTEGER);
            }
            ps.setString(4, recipientEmail);
            ps.setString(5, subject);
            ps.setString(6, body);
            ps.setString(7, "FORM_SUBMITTED:" + formId + ":" + recipientEmail);
            if (createdBy != null) {
                ps.setInt(8, createdBy);
            } else {
                ps.setNull(8, java.sql.Types.INTEGER);
            }
            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getLong(1);
                }
            }
        }

        return -1L;
    }

    public void markSent(long emailLogId) throws SQLException {
        updateStatus(emailLogId, "SENT", null);
    }

    public void markFailed(long emailLogId, String errorMessage) throws SQLException {
        updateStatus(emailLogId, "FAILED", truncate(errorMessage, 1000));
    }

    private void updateStatus(long emailLogId, String status, String errorMessage) throws SQLException {
        if (emailLogId <= 0) {
            return;
        }

        String sql =
            "UPDATE EMAIL_NOTIFICATION_LOG " +
            "SET STATUS = ?, SEND_ATTEMPT = NVL(SEND_ATTEMPT, 0) + 1, SENT_AT = ?, ERROR_MESSAGE = ? " +
            "WHERE EMAIL_LOG_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            if ("SENT".equals(status)) {
                ps.setTimestamp(2, new java.sql.Timestamp(System.currentTimeMillis()));
            } else {
                ps.setNull(2, java.sql.Types.TIMESTAMP);
            }
            ps.setString(3, errorMessage);
            ps.setLong(4, emailLogId);
            ps.executeUpdate();
        }
    }

    static String truncate(String value, int maxLength) {
        if (value == null || value.length() <= maxLength) {
            return value;
        }
        return value.substring(0, maxLength);
    }
}
