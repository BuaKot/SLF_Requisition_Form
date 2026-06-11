package com.slf.dao;

import com.slf.model.Employee;
import com.slf.util.BangkokTimeUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class ThirdPartyWorkflowDAO {
    private static final String TECHNICAL_POSITION = "Technical";
    private static final String INFRASTRUCTURE_POSITION = "Infrastructure";

    public List<Employee> findActiveInfrastructureEmployees() throws SQLException {
        String sql =
            "SELECT EMPID, EMPNAME, POSITION, SECID, PHONE " +
            "FROM EMPLOYEE WHERE UPPER(TRIM(POSITION)) = UPPER(?) AND NVL(IS_ACTIVE, 1) = 1 " +
            "ORDER BY EMPNAME, EMPID";
        List<Employee> employees = new ArrayList<Employee>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, INFRASTRUCTURE_POSITION);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Employee employee = new Employee();
                    employee.setEmpId(rs.getInt("EMPID"));
                    employee.setEmpName(rs.getString("EMPNAME"));
                    employee.setPosition(rs.getString("POSITION"));
                    employee.setSecId(rs.getInt("SECID"));
                    employee.setPhone(rs.getString("PHONE"));
                    employees.add(employee);
                }
            }
        }
        return employees;
    }

    public boolean submitSectionHeadReview(long requestId, int actorEmpId, String comment,
                                           int grantOperatorEmpId, int revokeOperatorEmpId,
                                           int revokeReviewerEmpId) throws SQLException {
        if (grantOperatorEmpId == revokeReviewerEmpId || revokeOperatorEmpId == revokeReviewerEmpId) {
            throw new IllegalArgumentException("ผู้ตรวจทานต้องไม่ใช่ผู้ดำเนินการหรือผู้ยกเลิกสิทธิ์");
        }

        Timestamp now = BangkokTimeUtil.nowTimestamp();
        String updateRequestSql =
            "UPDATE THIRD_PARTY_REQUEST SET STATUS = 'PENDING_IT_DIRECTOR', UPDATED_AT = ? " +
            "WHERE REQUEST_ID = ? AND STATUS = 'PENDING_SECTION_HEAD'";
        String insertAssignmentSql =
            "INSERT INTO THIRD_PARTY_WORKFLOW_ASSIGNMENT " +
            "(REQUEST_ID, ASSIGNMENT_ROLE, ASSIGNED_EMPID, ASSIGNED_BY_EMPID, ASSIGNED_AT) " +
            "VALUES (?, ?, ?, ?, ?)";
        String insertActionSql =
            "INSERT INTO THIRD_PARTY_WORKFLOW_ACTION " +
            "(REQUEST_ID, ACTION_TYPE, FROM_STATUS, TO_STATUS, ACTOR_TYPE, ACTOR_EMPID, COMMENT_TEXT, ACTED_AT) " +
            "VALUES (?, 'SECTION_HEAD_SUBMITTED', 'PENDING_SECTION_HEAD', 'PENDING_IT_DIRECTOR', " +
            "'INTERNAL', ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection()) {
            boolean oldAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);
            try {
                requireEmployeePosition(conn, actorEmpId, TECHNICAL_POSITION);
                requireEmployeePosition(conn, grantOperatorEmpId, INFRASTRUCTURE_POSITION);
                requireEmployeePosition(conn, revokeOperatorEmpId, INFRASTRUCTURE_POSITION);
                requireEmployeePosition(conn, revokeReviewerEmpId, INFRASTRUCTURE_POSITION);

                try (PreparedStatement update = conn.prepareStatement(updateRequestSql)) {
                    setTimestamp(update, 1, now);
                    update.setLong(2, requestId);
                    if (update.executeUpdate() != 1) {
                        conn.rollback();
                        return false;
                    }
                }

                try (PreparedStatement assignment = conn.prepareStatement(insertAssignmentSql)) {
                    addAssignment(assignment, requestId, "GRANT_OPERATOR", grantOperatorEmpId, actorEmpId, now);
                    addAssignment(assignment, requestId, "REVOKE_OPERATOR", revokeOperatorEmpId, actorEmpId, now);
                    addAssignment(assignment, requestId, "REVOKE_REVIEWER", revokeReviewerEmpId, actorEmpId, now);
                    assignment.executeBatch();
                }

                try (PreparedStatement action = conn.prepareStatement(insertActionSql)) {
                    action.setLong(1, requestId);
                    action.setInt(2, actorEmpId);
                    action.setString(3, comment);
                    setTimestamp(action, 4, now);
                    action.executeUpdate();
                }

                conn.commit();
                return true;
            } catch (SQLException | RuntimeException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(oldAutoCommit);
            }
        }
    }

    private static void requireEmployeePosition(Connection conn, int empId, String position) throws SQLException {
        String sql =
            "SELECT 1 FROM EMPLOYEE " +
            "WHERE EMPID = ? AND UPPER(TRIM(POSITION)) = UPPER(?) AND NVL(IS_ACTIVE, 1) = 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, empId);
            ps.setString(2, position);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new IllegalArgumentException("พนักงานที่เลือกไม่มีสิทธิ์รับบทบาทนี้");
                }
            }
        }
    }

    private static void addAssignment(PreparedStatement ps, long requestId, String role,
                                      int assignedEmpId, int assignedByEmpId, Timestamp assignedAt)
            throws SQLException {
        ps.setLong(1, requestId);
        ps.setString(2, role);
        ps.setInt(3, assignedEmpId);
        ps.setInt(4, assignedByEmpId);
        setTimestamp(ps, 5, assignedAt);
        ps.addBatch();
    }

    private static void setTimestamp(PreparedStatement ps, int index, Timestamp value) throws SQLException {
        ps.setTimestamp(index, value, BangkokTimeUtil.newCalendar());
    }
}
