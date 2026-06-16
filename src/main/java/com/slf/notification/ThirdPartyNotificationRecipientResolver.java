package com.slf.notification;

import com.slf.dao.DBConnection;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ThirdPartyNotificationRecipientResolver {

    public List<ApprovalNotificationRecipient> resolveTechnicalRecipients() throws SQLException {
        return resolveEmployeesByPosition("Technical");
    }

    public List<ApprovalNotificationRecipient> resolveItDirectorRecipients() throws SQLException {
        String sql =
            "SELECT recipient.EMPID, recipient.EMPNAME, recipient.EMAIL " +
            "FROM EMPLOYEE recipient " +
            "WHERE UPPER(REPLACE(TRIM(recipient.POSITION), ' ', '')) = 'ITDIRECTOR'";
        try (Connection conn = DBConnection.getConnection()) {
            return findRecipients(conn, sql);
        }
    }

    public List<ApprovalNotificationRecipient> resolveAssignmentRecipients(long requestId, String... roles)
            throws SQLException {
        if (roles == null || roles.length == 0) {
            return new ArrayList<ApprovalNotificationRecipient>();
        }
        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < roles.length; i++) {
            if (i > 0) placeholders.append(", ");
            placeholders.append("?");
        }
        String sql =
            "SELECT DISTINCT recipient.EMPID, recipient.EMPNAME, recipient.EMAIL " +
            "FROM THIRD_PARTY_WORKFLOW_ASSIGNMENT a " +
            "JOIN EMPLOYEE recipient ON recipient.EMPID = a.ASSIGNED_EMPID " +
            "WHERE a.REQUEST_ID = ? AND a.ASSIGNMENT_ROLE IN (" + placeholders + ")";
        try (Connection conn = DBConnection.getConnection()) {
            String filteredSql = addEmployeeNotificationFilter(conn, sql);
            try (PreparedStatement ps = conn.prepareStatement(filteredSql)) {
                ps.setLong(1, requestId);
                for (int i = 0; i < roles.length; i++) {
                    ps.setString(i + 2, roles[i]);
                }
                return readRecipients(ps);
            }
        }
    }

    public ApprovalNotificationRecipient resolveInternalOwner(long requestId) throws SQLException {
        String sql =
            "SELECT recipient.EMPID, recipient.EMPNAME, recipient.EMAIL " +
            "FROM THIRD_PARTY_REQUEST r " +
            "JOIN EMPLOYEE recipient ON recipient.EMPID = r.INTERNAL_OWNER_EMPID " +
            "WHERE r.REQUEST_ID = ?";
        try (Connection conn = DBConnection.getConnection()) {
            return findOneRecipient(conn, sql, requestId);
        }
    }

    public ApprovalNotificationRecipient resolveExternalRequester(long requestId) throws SQLException {
        String sql =
            "SELECT EXTERNAL_CONTACT_NAME, EXTERNAL_EMAIL " +
            "FROM THIRD_PARTY_REQUEST WHERE REQUEST_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                String email = rs.getString("EXTERNAL_EMAIL");
                if (!NotificationRecipientResolver.hasEmailShape(email)) return null;
                return new ApprovalNotificationRecipient(null, email.trim(), rs.getString("EXTERNAL_CONTACT_NAME"));
            }
        }
    }

    private List<ApprovalNotificationRecipient> resolveEmployeesByPosition(String position) throws SQLException {
        String sql =
            "SELECT recipient.EMPID, recipient.EMPNAME, recipient.EMAIL " +
            "FROM EMPLOYEE recipient " +
            "WHERE UPPER(TRIM(recipient.POSITION)) = UPPER(?)";
        try (Connection conn = DBConnection.getConnection()) {
            String filteredSql = addEmployeeNotificationFilter(conn, sql);
            try (PreparedStatement ps = conn.prepareStatement(filteredSql)) {
                ps.setString(1, position);
                return readRecipients(ps);
            }
        }
    }

    private ApprovalNotificationRecipient findOneRecipient(Connection conn, String sql, long id)
            throws SQLException {
        String filteredSql = addEmployeeNotificationFilter(conn, sql);
        try (PreparedStatement ps = conn.prepareStatement(filteredSql)) {
            ps.setLong(1, id);
            List<ApprovalNotificationRecipient> recipients = readRecipients(ps);
            return recipients.isEmpty() ? null : recipients.get(0);
        }
    }

    private List<ApprovalNotificationRecipient> findRecipients(Connection conn, String sql) throws SQLException {
        String filteredSql = addEmployeeNotificationFilter(conn, sql);
        try (PreparedStatement ps = conn.prepareStatement(filteredSql)) {
            return readRecipients(ps);
        }
    }

    private List<ApprovalNotificationRecipient> readRecipients(PreparedStatement ps) throws SQLException {
        List<ApprovalNotificationRecipient> recipients = new ArrayList<ApprovalNotificationRecipient>();
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String email = rs.getString("EMAIL");
                if (!NotificationRecipientResolver.hasEmailShape(email)) {
                    continue;
                }
                recipients.add(new ApprovalNotificationRecipient(
                    Integer.valueOf(rs.getInt("EMPID")),
                    email.trim(),
                    rs.getString("EMPNAME")
                ));
            }
        }
        return recipients;
    }

    private String addEmployeeNotificationFilter(Connection conn, String sql) throws SQLException {
        StringBuilder filteredSql = new StringBuilder(sql);
        if (hasColumn(conn, "EMPLOYEE", "EMAIL_NOTIFICATION_ENABLED")) {
            filteredSql.append(" AND NVL(recipient.EMAIL_NOTIFICATION_ENABLED, 1) = 1");
        }
        if (hasColumn(conn, "EMPLOYEE", "IS_ACTIVE")) {
            filteredSql.append(" AND NVL(recipient.IS_ACTIVE, 1) = 1");
        }
        return filteredSql.toString();
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
}
