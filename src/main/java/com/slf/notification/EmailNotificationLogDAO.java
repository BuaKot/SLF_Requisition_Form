package com.slf.notification;

import com.slf.dao.DBConnection;
import com.slf.model.EmailNotificationLogEntry;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
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
        return enqueueIfAbsent("REQUISITION", Long.valueOf(formId), formId, approvalId, eventType, recipientEmpId,
            recipientEmail, subject, body, createdBy, dedupeKey);
    }

    public boolean enqueueIfAbsent(String formType, Long referenceId, int formId, Integer approvalId,
                                   String eventType, Integer recipientEmpId, String recipientEmail, String subject,
                                   String body, Integer createdBy, String dedupeKey) throws SQLException {
        try {
            createPendingLog(formType, referenceId, formId, approvalId, eventType, recipientEmpId, recipientEmail,
                subject, body, createdBy, dedupeKey);
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
        return createPendingLog("REQUISITION", Long.valueOf(formId), formId, approvalId, eventType, recipientEmpId,
            recipientEmail, subject, body, createdBy, dedupeKey);
    }

    public long createPendingLog(String formType, Long referenceId, int formId, Integer approvalId,
                                 String eventType, Integer recipientEmpId, String recipientEmail,
                                 String subject, String body, Integer createdBy, String dedupeKey)
            throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            boolean hasFormReferenceColumns = hasFormReferenceColumns(conn);
            try (PreparedStatement ps = conn.prepareStatement(
                    createPendingLogSql(hasFormReferenceColumns), new String[] { "EMAIL_LOG_ID" })) {
            if (hasFormReferenceColumns) {
                ps.setString(1, normalizeFormType(formType));
                setNullableLong(ps, 2, referenceId);
                ps.setInt(3, formId);
                setNullableInt(ps, 4, approvalId);
                ps.setString(5, eventType);
                setNullableInt(ps, 6, recipientEmpId);
                ps.setString(7, recipientEmail);
                ps.setString(8, subject);
                ps.setString(9, body);
                ps.setString(10, dedupeKey);
                setNullableInt(ps, 11, createdBy);
            } else {
                ps.setInt(1, formId);
                setNullableInt(ps, 2, approvalId);
                ps.setString(3, eventType);
                setNullableInt(ps, 4, recipientEmpId);
                ps.setString(5, recipientEmail);
                ps.setString(6, subject);
                ps.setString(7, body);
                ps.setString(8, dedupeKey);
                setNullableInt(ps, 9, createdBy);
            }
            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getLong(1);
                }
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
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(findByIdSql(conn))) {
            ps.setLong(1, emailLogId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapQueueEntry(rs) : null;
            }
        }
    }

    public List<EmailNotificationLogEntry> findLogs(String status, int page, int pageSize) throws SQLException {
        return findLogs(status, null, page, pageSize);
    }

    public List<EmailNotificationLogEntry> findLogs(String status, String formType, int page, int pageSize)
            throws SQLException {
        boolean filterStatus = status != null && !status.trim().isEmpty();
        List<EmailNotificationLogEntry> logs = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection()) {
            boolean hasFormType = hasColumn(conn, "EMAIL_NOTIFICATION_LOG", "FORM_TYPE");
            boolean hasReferenceId = hasColumn(conn, "EMAIL_NOTIFICATION_LOG", "REFERENCE_ID");
            if (isUnavailableLegacyFormTypeFilter(formType, hasFormType)) {
                return logs;
            }
            boolean filterFormType = canFilterFormType(formType, hasFormType);
            try (PreparedStatement ps = conn.prepareStatement(findLogsSql(filterStatus, filterFormType, hasFormType, hasReferenceId))) {
                int index = 1;
                if (filterStatus) {
                    ps.setString(index++, status);
                }
                if (filterFormType) {
                    ps.setString(index++, formType);
                }
                ps.setInt(index++, Math.max(0, (page - 1) * pageSize));
                ps.setInt(index, pageSize);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        logs.add(mapDisplayEntry(rs));
                    }
                }
            }
        }
        return logs;
    }

    public int countLogs(String status) throws SQLException {
        return countLogs(status, null);
    }

    public int countLogs(String status, String formType) throws SQLException {
        boolean filterStatus = status != null && !status.trim().isEmpty();
        try (Connection conn = DBConnection.getConnection()) {
            boolean hasFormType = hasColumn(conn, "EMAIL_NOTIFICATION_LOG", "FORM_TYPE");
            if (isUnavailableLegacyFormTypeFilter(formType, hasFormType)) {
                return 0;
            }
            boolean filterFormType = canFilterFormType(formType, hasFormType);
            String sql = "SELECT COUNT(*) FROM EMAIL_NOTIFICATION_LOG" + whereClause(filterStatus, filterFormType);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                int index = 1;
                if (filterStatus) {
                    ps.setString(index++, status);
                }
                if (filterFormType) {
                    ps.setString(index, formType);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next() ? rs.getInt(1) : 0;
                }
            }
        }
    }

    public Map<String, Integer> countByStatus() throws SQLException {
        return countByStatus(null);
    }

    public Map<String, Integer> countByStatus(String formType) throws SQLException {
        Map<String, Integer> counts = new LinkedHashMap<>();
        try (Connection conn = DBConnection.getConnection()) {
            boolean hasFormType = hasColumn(conn, "EMAIL_NOTIFICATION_LOG", "FORM_TYPE");
            if (isUnavailableLegacyFormTypeFilter(formType, hasFormType)) {
                return counts;
            }
            boolean filterFormType = canFilterFormType(formType, hasFormType);
            String sql = countByStatusSql(filterFormType);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                if (filterFormType) {
                    ps.setString(1, formType);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        counts.put(rs.getString("STATUS"), Integer.valueOf(rs.getInt("TOTAL")));
                    }
                }
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

    private static void setNullableLong(PreparedStatement ps, int index, Long value) throws SQLException {
        if (value == null) {
            ps.setNull(index, java.sql.Types.NUMERIC);
        } else {
            ps.setLong(index, value.longValue());
        }
    }

    private static String normalizeFormType(String formType) {
        String normalized = formType == null ? "" : formType.trim();
        return normalized.isEmpty() ? "REQUISITION" : normalized;
    }

    static String formTypeSelectExpression(boolean hasFormTypeColumn) {
        return hasFormTypeColumn ? "l.FORM_TYPE" : "'REQUISITION' AS FORM_TYPE";
    }

    static String referenceIdSelectExpression(boolean hasReferenceIdColumn) {
        return hasReferenceIdColumn ? "l.REFERENCE_ID" : "l.FORMID AS REFERENCE_ID";
    }

    static String countByStatusSql(boolean filterFormType) {
        return ("SELECT STATUS, COUNT(*) AS TOTAL FROM EMAIL_NOTIFICATION_LOG"
            + whereClause(false, filterFormType)).trim()
            + " GROUP BY STATUS";
    }

    private static String createPendingLogSql(boolean hasFormReferenceColumns) {
        if (hasFormReferenceColumns) {
            return "INSERT INTO EMAIL_NOTIFICATION_LOG " +
                "(FORM_TYPE, REFERENCE_ID, FORMID, APPROVALID, EVENT_TYPE, RECIPIENT_EMPID, RECIPIENT_EMAIL, SUBJECT, BODY, STATUS, " +
                "SEND_ATTEMPT, DEDUPE_KEY, CREATED_BY, NEXT_ATTEMPT_AT) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, '" + STATUS_READY + "', 0, ?, ?, SYSTIMESTAMP)";
        }
        return "INSERT INTO EMAIL_NOTIFICATION_LOG " +
            "(FORMID, APPROVALID, EVENT_TYPE, RECIPIENT_EMPID, RECIPIENT_EMAIL, SUBJECT, BODY, STATUS, " +
            "SEND_ATTEMPT, DEDUPE_KEY, CREATED_BY, NEXT_ATTEMPT_AT) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, '" + STATUS_READY + "', 0, ?, ?, SYSTIMESTAMP)";
    }

    private static String findByIdSql(Connection conn) throws SQLException {
        boolean hasFormType = hasColumn(conn, "EMAIL_NOTIFICATION_LOG", "FORM_TYPE");
        boolean hasReferenceId = hasColumn(conn, "EMAIL_NOTIFICATION_LOG", "REFERENCE_ID");
        return "SELECT l.EMAIL_LOG_ID, " + formTypeSelectExpression(hasFormType) + ", "
            + referenceIdSelectExpression(hasReferenceId) + ", l.FORMID, l.EVENT_TYPE, l.RECIPIENT_EMAIL, "
            + "l.SUBJECT, l.BODY, l.STATUS, l.SEND_ATTEMPT, l.CREATED_AT, l.LAST_ATTEMPT_AT, "
            + "l.NEXT_ATTEMPT_AT, l.SENT_AT, l.ERROR_MESSAGE "
            + "FROM EMAIL_NOTIFICATION_LOG l WHERE l.EMAIL_LOG_ID = ?";
    }

    private static String findLogsSql(boolean filterStatus, boolean filterFormType,
                                      boolean hasFormType, boolean hasReferenceId) {
        return "SELECT l.EMAIL_LOG_ID, " + formTypeSelectExpression(hasFormType) + ", "
            + referenceIdSelectExpression(hasReferenceId) + ", l.FORMID, l.EVENT_TYPE, l.RECIPIENT_EMAIL, "
            + "l.SUBJECT, l.STATUS, l.SEND_ATTEMPT, l.CREATED_AT, l.LAST_ATTEMPT_AT, "
            + "l.NEXT_ATTEMPT_AT, l.SENT_AT, l.ERROR_MESSAGE, e.EMPNAME, e.POSITION, e.PHONE, s.SECNAME "
            + "FROM EMAIL_NOTIFICATION_LOG l "
            + "LEFT JOIN EMPLOYEE e ON e.EMPID = l.RECIPIENT_EMPID "
            + "LEFT JOIN SECTION s ON s.SECID = e.SECID "
            + whereClause(filterStatus, filterFormType)
            + "ORDER BY l.CREATED_AT DESC, l.EMAIL_LOG_ID DESC OFFSET ? ROWS FETCH FIRST ? ROWS ONLY";
    }

    private static boolean canFilterFormType(String formType, boolean hasFormTypeColumn) {
        return hasFormTypeColumn && formType != null && !formType.trim().isEmpty();
    }

    private static boolean isUnavailableLegacyFormTypeFilter(String formType, boolean hasFormTypeColumn) {
        return !hasFormTypeColumn && "THIRD_PARTY".equals(formType);
    }

    private static boolean hasFormReferenceColumns(Connection conn) throws SQLException {
        return hasColumn(conn, "EMAIL_NOTIFICATION_LOG", "FORM_TYPE")
            && hasColumn(conn, "EMAIL_NOTIFICATION_LOG", "REFERENCE_ID");
    }

    private static boolean hasColumn(Connection conn, String tableName, String columnName) throws SQLException {
        DatabaseMetaData metaData = conn.getMetaData();
        try (ResultSet columns = metaData.getColumns(null, null, tableName, columnName)) {
            if (columns.next()) return true;
        }
        try (ResultSet columns = metaData.getColumns(null, conn.getSchema(), tableName, columnName)) {
            return columns.next();
        }
    }

    private static String whereClause(boolean filterStatus, boolean filterFormType) {
        StringBuilder where = new StringBuilder();
        if (filterStatus) {
            where.append(" WHERE ");
            where.append("STATUS = ? ");
        }
        if (filterFormType) {
            where.append(where.length() == 0 ? " WHERE " : "AND ");
            where.append("FORM_TYPE = ? ");
        }
        return where.toString();
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
        entry.setFormType(rs.getString("FORM_TYPE"));
        long referenceId = rs.getLong("REFERENCE_ID");
        entry.setReferenceId(rs.wasNull() ? null : Long.valueOf(referenceId));
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
