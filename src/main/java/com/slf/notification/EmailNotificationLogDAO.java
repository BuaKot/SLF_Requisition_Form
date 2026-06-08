package com.slf.notification;

import com.slf.dao.DBConnection;
import com.slf.model.EmailNotificationLogEntry;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class EmailNotificationLogDAO {
    public static final String STATUS_READY = "READY";

    public boolean enqueueIfAbsent(int formId, Integer approvalId, String eventType, Integer recipientEmpId,
                                   String recipientEmail, String subject, String body, Integer createdBy,
                                   String dedupeKey) throws SQLException {
        try {
            createPendingLog(formId, approvalId, eventType, recipientEmpId, recipientEmail, subject, body, createdBy, dedupeKey);
            return true;
        } catch (SQLException e) {
            if (isDuplicateKey(e)) {
                return false;
            }
            throw e;
        }
    }

    public long createPendingSubmittedLog(int formId, Integer recipientEmpId, String recipientEmail,
                                          String subject, String body, Integer createdBy) throws SQLException {
        return createPendingLog(
            formId, null, "FORM_SUBMITTED", recipientEmpId, recipientEmail, subject, body, createdBy,
            "FORM_SUBMITTED:" + formId + ":" + recipientEmail
        );
    }

    public long createPendingLog(int formId, Integer approvalId, String eventType, Integer recipientEmpId,
                                 String recipientEmail, String subject, String body, Integer createdBy,
                                 String dedupeKey) throws SQLException {
        String sql =
            "INSERT INTO EMAIL_NOTIFICATION_LOG " +
            "(FORMID, APPROVALID, EVENT_TYPE, RECIPIENT_EMPID, RECIPIENT_EMAIL, SUBJECT, BODY, STATUS, " +
            "SEND_ATTEMPT, DEDUPE_KEY, CREATED_BY, NEXT_ATTEMPT_AT) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, '" + STATUS_READY + "', 0, ?, ?, SYSTIMESTAMP)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, new String[] { "EMAIL_LOG_ID" })) {
            ps.setInt(1, formId);
            setNullableInt(ps, 2, approvalId);
            ps.setString(3, eventType);
            setNullableInt(ps, 4, recipientEmpId);
            ps.setString(5, recipientEmail);
            ps.setString(6, subject);
            ps.setString(7, body);
            ps.setString(8, dedupeKey);
            setNullableInt(ps, 9, createdBy);
            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getLong(1);
                }
            }
        }
        return -1L;
    }

    public Long findNextDueId(int maxAttempts) throws SQLException {
        String sql =
            "SELECT EMAIL_LOG_ID FROM EMAIL_NOTIFICATION_LOG " +
            "WHERE (STATUS = '" + STATUS_READY + "' AND NVL(NEXT_ATTEMPT_AT, SYSTIMESTAMP) <= SYSTIMESTAMP) " +
            "OR (STATUS = 'SENDING' AND LAST_ATTEMPT_AT < SYSTIMESTAMP - INTERVAL '10' MINUTE) " +
            "ORDER BY CREATED_AT FETCH FIRST 1 ROWS ONLY";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? Long.valueOf(rs.getLong("EMAIL_LOG_ID")) : null;
            }
        }
    }

    public boolean claimForSending(long emailLogId, int maxAttempts) throws SQLException {
        String sql =
            "UPDATE EMAIL_NOTIFICATION_LOG SET STATUS = 'SENDING', " +
            "SEND_ATTEMPT = NVL(SEND_ATTEMPT, 0) + 1, LAST_ATTEMPT_AT = SYSTIMESTAMP, ERROR_MESSAGE = NULL " +
            "WHERE EMAIL_LOG_ID = ? AND (" +
            "(STATUS = '" + STATUS_READY + "' AND NVL(NEXT_ATTEMPT_AT, SYSTIMESTAMP) <= SYSTIMESTAMP) " +
            "OR (STATUS = 'SENDING' AND LAST_ATTEMPT_AT < SYSTIMESTAMP - INTERVAL '10' MINUTE))";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, emailLogId);
            return ps.executeUpdate() == 1;
        }
    }

    public EmailNotificationLogEntry findById(long emailLogId) throws SQLException {
        String sql =
            "SELECT EMAIL_LOG_ID, FORMID, EVENT_TYPE, RECIPIENT_EMAIL, SUBJECT, BODY, STATUS, SEND_ATTEMPT, " +
            "CREATED_AT, LAST_ATTEMPT_AT, NEXT_ATTEMPT_AT, SENT_AT, ERROR_MESSAGE " +
            "FROM EMAIL_NOTIFICATION_LOG WHERE EMAIL_LOG_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, emailLogId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapQueueEntry(rs) : null;
            }
        }
    }

    public List<EmailNotificationLogEntry> findLogs(String status, int page, int pageSize) throws SQLException {
        boolean filterStatus = status != null && !status.trim().isEmpty();
        String sql =
            "SELECT l.EMAIL_LOG_ID, l.FORMID, l.EVENT_TYPE, l.RECIPIENT_EMAIL, l.SUBJECT, l.STATUS, l.SEND_ATTEMPT, " +
            "l.CREATED_AT, l.LAST_ATTEMPT_AT, l.NEXT_ATTEMPT_AT, l.SENT_AT, l.ERROR_MESSAGE, " +
            "e.EMPNAME, e.POSITION, e.PHONE, s.SECNAME " +
            "FROM EMAIL_NOTIFICATION_LOG l " +
            "LEFT JOIN EMPLOYEE e ON e.EMPID = l.RECIPIENT_EMPID " +
            "LEFT JOIN SECTION s ON s.SECID = e.SECID " +
            (filterStatus ? "WHERE l.STATUS = ? " : "") +
            "ORDER BY l.CREATED_AT DESC, l.EMAIL_LOG_ID DESC OFFSET ? ROWS FETCH FIRST ? ROWS ONLY";
        List<EmailNotificationLogEntry> logs = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int index = 1;
            if (filterStatus) {
                ps.setString(index++, status);
            }
            ps.setInt(index++, Math.max(0, (page - 1) * pageSize));
            ps.setInt(index, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    logs.add(mapDisplayEntry(rs));
                }
            }
        }
        return logs;
    }

    public int countLogs(String status) throws SQLException {
        boolean filterStatus = status != null && !status.trim().isEmpty();
        String sql = "SELECT COUNT(*) FROM EMAIL_NOTIFICATION_LOG" + (filterStatus ? " WHERE STATUS = ?" : "");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (filterStatus) {
                ps.setString(1, status);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public Map<String, Integer> countByStatus() throws SQLException {
        Map<String, Integer> counts = new LinkedHashMap<>();
        String sql = "SELECT STATUS, COUNT(*) AS TOTAL FROM EMAIL_NOTIFICATION_LOG GROUP BY STATUS";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                counts.put(rs.getString("STATUS"), Integer.valueOf(rs.getInt("TOTAL")));
            }
        }
        return counts;
    }

    public void markSent(long emailLogId) throws SQLException {
        updateFinalStatus(emailLogId, "SENT", null, null);
    }

    public void markSkipped(long emailLogId, String reason) throws SQLException {
        updateFinalStatus(emailLogId, "SKIPPED", truncate(reason, 1000), null);
    }

    public void markFailed(long emailLogId, String errorMessage) throws SQLException {
        markFailed(emailLogId, errorMessage, new Timestamp(System.currentTimeMillis() + 60_000L));
    }

    public void markFailed(long emailLogId, String errorMessage, Timestamp nextAttemptAt) throws SQLException {
        String status = nextAttemptAt == null ? "FAILED" : STATUS_READY;
        updateFinalStatus(emailLogId, status, truncate(errorMessage, 1000), nextAttemptAt);
    }

    private void updateFinalStatus(long emailLogId, String status, String errorMessage, Timestamp nextAttemptAt)
            throws SQLException {
        if (emailLogId <= 0) {
            return;
        }
        String sql =
            "UPDATE EMAIL_NOTIFICATION_LOG SET STATUS = ?, SENT_AT = ?, ERROR_MESSAGE = ?, NEXT_ATTEMPT_AT = ? " +
            "WHERE EMAIL_LOG_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            if ("SENT".equals(status)) {
                ps.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
            } else {
                ps.setNull(2, java.sql.Types.TIMESTAMP);
            }
            ps.setString(3, errorMessage);
            if (nextAttemptAt == null) {
                ps.setNull(4, java.sql.Types.TIMESTAMP);
            } else {
                ps.setTimestamp(4, nextAttemptAt);
            }
            ps.setLong(5, emailLogId);
            ps.executeUpdate();
        }
    }

    static boolean isDuplicateKey(SQLException exception) {
        SQLException current = exception;
        while (current != null) {
            String message = current.getMessage();
            if (current.getErrorCode() == 1
                    || (message != null && (message.contains("ORA-00001")
                        || message.contains("UQ_EMAIL_NOTIFICATION_DEDUPE")))) {
                return true;
            }
            current = current.getNextException();
        }
        return false;
    }

    static String truncate(String value, int maxLength) {
        if (value == null || value.length() <= maxLength) {
            return value;
        }
        return value.substring(0, maxLength);
    }

    private static void setNullableInt(PreparedStatement ps, int index, Integer value) throws SQLException {
        if (value == null) {
            ps.setNull(index, java.sql.Types.INTEGER);
        } else {
            ps.setInt(index, value.intValue());
        }
    }

    private static EmailNotificationLogEntry mapQueueEntry(ResultSet rs) throws SQLException {
        EmailNotificationLogEntry entry = mapCommon(rs);
        entry.setBody(rs.getString("BODY"));
        return entry;
    }

    private static EmailNotificationLogEntry mapDisplayEntry(ResultSet rs) throws SQLException {
        EmailNotificationLogEntry entry = mapCommon(rs);
        entry.setRecipientName(rs.getString("EMPNAME"));
        entry.setRecipientPosition(rs.getString("POSITION"));
        entry.setRecipientPhone(rs.getString("PHONE"));
        entry.setRecipientSection(rs.getString("SECNAME"));
        return entry;
    }

    private static EmailNotificationLogEntry mapCommon(ResultSet rs) throws SQLException {
        EmailNotificationLogEntry entry = new EmailNotificationLogEntry();
        entry.setEmailLogId(rs.getLong("EMAIL_LOG_ID"));
        entry.setFormId(rs.getInt("FORMID"));
        entry.setEventType(rs.getString("EVENT_TYPE"));
        entry.setRecipientEmail(rs.getString("RECIPIENT_EMAIL"));
        entry.setSubject(rs.getString("SUBJECT"));
        entry.setStatus(rs.getString("STATUS"));
        entry.setSendAttempt(rs.getInt("SEND_ATTEMPT"));
        entry.setCreatedAt(rs.getTimestamp("CREATED_AT"));
        entry.setLastAttemptAt(rs.getTimestamp("LAST_ATTEMPT_AT"));
        entry.setNextAttemptAt(rs.getTimestamp("NEXT_ATTEMPT_AT"));
        entry.setSentAt(rs.getTimestamp("SENT_AT"));
        entry.setErrorMessage(rs.getString("ERROR_MESSAGE"));
        return entry;
    }
}
