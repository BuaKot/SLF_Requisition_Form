package com.slf.notification;

import com.slf.dao.DBConnection;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ApprovalNotificationRecipientResolver {

    public ApprovalNotificationRecipient resolveInitialDirector(int formId) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            String sql =
                "SELECT recipient.EMPID, recipient.EMPNAME, recipient.EMAIL " +
                "FROM REQUISITIONFORM r " +
                "JOIN EMPLOYEE requester ON requester.EMPID = r.EMPID " +
                "JOIN SECTION requester_section ON requester_section.SECID = requester.SECID " +
                "JOIN DEPARTMENT requester_dept ON requester_dept.DEPTID = requester_section.DEPTID " +
                "JOIN EMPLOYEE recipient ON recipient.EMPID = requester_dept.DEPTHEAD_EMPID " +
                "WHERE r.FORMID = ?";
            return findRecipient(conn, sql, formId);
        }
    }

    public ApprovalNotificationRecipient resolveNextApprover(int formId, int newStep, Integer assignedDeveloperId)
            throws SQLException {
        if (newStep == 1) {
            return resolveAssignedSectionHead(formId);
        }
        if (newStep == 2) {
            return resolveAssignedDepartmentHead(formId);
        }
        if (newStep == 3 && assignedDeveloperId != null) {
            return resolveEmployee(assignedDeveloperId.intValue());
        }
        if (newStep == 4 || newStep == 5 || newStep < 0) {
            return resolveRequester(formId);
        }
        return null;
    }

    public ApprovalNotificationRecipient resolveRequester(int formId) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            String sql =
                "SELECT recipient.EMPID, recipient.EMPNAME, recipient.EMAIL " +
                "FROM REQUISITIONFORM r " +
                "JOIN EMPLOYEE recipient ON recipient.EMPID = r.EMPID " +
                "WHERE r.FORMID = ?";
            return findRecipient(conn, sql, formId);
        }
    }

    private ApprovalNotificationRecipient resolveAssignedSectionHead(int formId) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            String sql =
                "SELECT recipient.EMPID, recipient.EMPNAME, recipient.EMAIL " +
                "FROM REQUISITIONFORM r " +
                "JOIN SECTION assigned_section ON assigned_section.SECID = r.ASSIGN_SECID " +
                "JOIN EMPLOYEE recipient ON recipient.EMPID = assigned_section.SECTIONHEAD_EMPID " +
                "WHERE r.FORMID = ?";
            return findRecipient(conn, sql, formId);
        }
    }

    private ApprovalNotificationRecipient resolveAssignedDepartmentHead(int formId) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            String sql =
                "SELECT recipient.EMPID, recipient.EMPNAME, recipient.EMAIL " +
                "FROM REQUISITIONFORM r " +
                "JOIN SECTION assigned_section ON assigned_section.SECID = r.ASSIGN_SECID " +
                "JOIN DEPARTMENT assigned_dept ON assigned_dept.DEPTID = assigned_section.DEPTID " +
                "JOIN EMPLOYEE recipient ON recipient.EMPID = assigned_dept.DEPTHEAD_EMPID " +
                "WHERE r.FORMID = ?";
            return findRecipient(conn, sql, formId);
        }
    }

    private ApprovalNotificationRecipient resolveEmployee(int empId) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT recipient.EMPID, recipient.EMPNAME, recipient.EMAIL FROM EMPLOYEE recipient WHERE recipient.EMPID = ?";
            return findRecipient(conn, sql, empId);
        }
    }

    private ApprovalNotificationRecipient findRecipient(Connection conn, String sql, int id) throws SQLException {
        String filteredSql = addNotificationFilter(conn, sql);
        try (PreparedStatement ps = conn.prepareStatement(filteredSql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                String email = rs.getString("EMAIL");
                if (!NotificationRecipientResolver.hasEmailShape(email)) {
                    return null;
                }
                return new ApprovalNotificationRecipient(
                    Integer.valueOf(rs.getInt("EMPID")),
                    email.trim(),
                    rs.getString("EMPNAME")
                );
            }
        }
    }

    private String addNotificationFilter(Connection conn, String sql) throws SQLException {
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
            if (columns.next()) {
                return true;
            }
        }
        try (ResultSet columns = metaData.getColumns(null, conn.getSchema(), tableName, columnName)) {
            return columns.next();
        }
    }
}
