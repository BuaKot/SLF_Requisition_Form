package com.slf.notification;

import com.slf.dao.DBConnection;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class NotificationRecipientResolver {

    public String resolveForSubmittedForm(int formId) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            if (hasColumn(conn, "EMPLOYEE", "EMAIL")) {
                String email = findEmailColumnRecipient(conn, formId);
                if (hasEmailShape(email)) {
                    return email.trim();
                }
            }

            String phone = findPhoneRecipient(conn, formId);
            if (hasEmailShape(phone)) {
                return phone.trim();
            }
        }
        return null;
    }

    private String findEmailColumnRecipient(Connection conn, int formId) throws SQLException {
        String sql =
            "SELECT e.EMAIL " +
            "FROM REQUISITIONFORM r " +
            "JOIN EMPLOYEE e ON r.EMPID = e.EMPID " +
            "WHERE r.FORMID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, formId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString("EMAIL") : null;
            }
        }
    }

    private String findPhoneRecipient(Connection conn, int formId) throws SQLException {
        String sql =
            "SELECT e.PHONE " +
            "FROM REQUISITIONFORM r " +
            "JOIN EMPLOYEE e ON r.EMPID = e.EMPID " +
            "WHERE r.FORMID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, formId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString("PHONE") : null;
            }
        }
    }

    static boolean hasEmailShape(String value) {
        if (value == null) {
            return false;
        }
        String trimmed = value.trim();
        return trimmed.contains("@") && trimmed.indexOf("@") > 0 && trimmed.indexOf("@") < trimmed.length() - 1;
    }

    private static boolean hasColumn(Connection conn, String tableName, String columnName) throws SQLException {
        DatabaseMetaData metaData = conn.getMetaData();
        try (ResultSet columns = metaData.getColumns(null, null, tableName, columnName)) {
            if (columns.next()) {
                return true;
            }
        }
        try (ResultSet columns = metaData.getColumns(null, conn.getSchema(), tableName, columnName)) {
            return columns.next();
        }
    }
}
