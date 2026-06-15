package com.slf.dao;

import com.slf.model.Employee;
import com.slf.model.ThirdPartyRequest;
import com.slf.model.ThirdPartyWorkflowActionEntry;
import com.slf.model.ThirdPartyWorkflowAssignment;
import com.slf.util.BangkokTimeUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

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

    public List<ThirdPartyWorkflowAssignment> findAssignments(long requestId) throws SQLException {
        String sql =
            "SELECT a.ASSIGNMENT_ROLE, a.ASSIGNED_EMPID, assigned.EMPNAME AS ASSIGNED_EMPNAME, " +
            "a.ASSIGNED_BY_EMPID, assigned_by.EMPNAME AS ASSIGNED_BY_EMPNAME, a.ASSIGNED_AT " +
            "FROM THIRD_PARTY_WORKFLOW_ASSIGNMENT a " +
            "JOIN EMPLOYEE assigned ON assigned.EMPID = a.ASSIGNED_EMPID " +
            "JOIN EMPLOYEE assigned_by ON assigned_by.EMPID = a.ASSIGNED_BY_EMPID " +
            "WHERE a.REQUEST_ID = ? " +
            "ORDER BY CASE a.ASSIGNMENT_ROLE WHEN 'GRANT_OPERATOR' THEN 1 " +
            "WHEN 'REVOKE_OPERATOR' THEN 2 WHEN 'REVOKE_REVIEWER' THEN 3 ELSE 4 END";
        List<ThirdPartyWorkflowAssignment> assignments = new ArrayList<ThirdPartyWorkflowAssignment>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ThirdPartyWorkflowAssignment assignment = new ThirdPartyWorkflowAssignment();
                    assignment.setAssignmentRole(rs.getString("ASSIGNMENT_ROLE"));
                    assignment.setAssignedEmpId(rs.getInt("ASSIGNED_EMPID"));
                    assignment.setAssignedEmpName(rs.getString("ASSIGNED_EMPNAME"));
                    assignment.setAssignedByEmpId(rs.getInt("ASSIGNED_BY_EMPID"));
                    assignment.setAssignedByEmpName(rs.getString("ASSIGNED_BY_EMPNAME"));
                    assignment.setAssignedAt(rs.getTimestamp("ASSIGNED_AT"));
                    assignments.add(assignment);
                }
            }
        }
        return assignments;
    }

    public String findLatestActionComment(long requestId, String actionType) throws SQLException {
        String sql =
            "SELECT COMMENT_TEXT FROM THIRD_PARTY_WORKFLOW_ACTION " +
            "WHERE REQUEST_ID = ? AND ACTION_TYPE = ? " +
            "ORDER BY ACTION_ID DESC FETCH FIRST 1 ROW ONLY";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, requestId);
            ps.setString(2, actionType);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString("COMMENT_TEXT") : null;
            }
        }
    }

    public List<ThirdPartyWorkflowActionEntry> findActionHistory(long requestId) throws SQLException {
        String sql =
            "SELECT a.ACTION_TYPE, a.ACTOR_TYPE, a.ACTOR_EMPID, " +
            "CASE WHEN a.ACTOR_TYPE = 'EXTERNAL' THEN r.EXTERNAL_CONTACT_NAME ELSE e.EMPNAME END AS ACTOR_EMPNAME, " +
            "a.COMMENT_TEXT, a.ACTED_AT " +
            "FROM THIRD_PARTY_WORKFLOW_ACTION a " +
            "JOIN THIRD_PARTY_REQUEST r ON r.REQUEST_ID = a.REQUEST_ID " +
            "LEFT JOIN EMPLOYEE e ON e.EMPID = a.ACTOR_EMPID " +
            "WHERE a.REQUEST_ID = ? AND a.ACTION_TYPE NOT IN ('WORKFLOW_MIGRATED', 'EXTERNAL_SUBMITTED') " +
            "ORDER BY a.ACTED_AT ASC, a.ACTION_ID ASC";
        List<ThirdPartyWorkflowActionEntry> history = new ArrayList<ThirdPartyWorkflowActionEntry>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ThirdPartyWorkflowActionEntry entry = new ThirdPartyWorkflowActionEntry();
                    entry.setActionType(rs.getString("ACTION_TYPE"));
                    entry.setActorType(rs.getString("ACTOR_TYPE"));
                    int actorEmpId = rs.getInt("ACTOR_EMPID");
                    entry.setActorEmpId(rs.wasNull() ? null : Integer.valueOf(actorEmpId));
                    entry.setActorEmpName(rs.getString("ACTOR_EMPNAME"));
                    entry.setCommentText(rs.getString("COMMENT_TEXT"));
                    entry.setActedAt(rs.getTimestamp("ACTED_AT"));
                    history.add(entry);
                }
            }
        }
        return history;
    }

    public Map<Long, List<ThirdPartyWorkflowActionEntry>> findActionHistoryForRequests(
            List<ThirdPartyRequest> requests) throws SQLException {
        Map<Long, List<ThirdPartyWorkflowActionEntry>> historyByRequest =
            new LinkedHashMap<Long, List<ThirdPartyWorkflowActionEntry>>();
        if (requests == null || requests.isEmpty()) {
            return historyByRequest;
        }

        StringBuilder placeholders = new StringBuilder();
        for (ThirdPartyRequest request : requests) {
            if (placeholders.length() > 0) placeholders.append(", ");
            placeholders.append("?");
            historyByRequest.put(Long.valueOf(request.getRequestId()),
                new ArrayList<ThirdPartyWorkflowActionEntry>());
        }
        String sql =
            "SELECT a.REQUEST_ID, a.ACTION_TYPE, a.ACTOR_TYPE, a.ACTOR_EMPID, " +
            "CASE WHEN a.ACTOR_TYPE = 'EXTERNAL' THEN r.EXTERNAL_CONTACT_NAME ELSE e.EMPNAME END AS ACTOR_EMPNAME, " +
            "CASE WHEN a.ACTOR_TYPE = 'EXTERNAL' THEN 'ผู้ขอใช้บริการ' ELSE e.POSITION END AS ACTOR_POSITION, " +
            "a.ACTED_AT " +
            "FROM THIRD_PARTY_WORKFLOW_ACTION a " +
            "JOIN THIRD_PARTY_REQUEST r ON r.REQUEST_ID = a.REQUEST_ID " +
            "LEFT JOIN EMPLOYEE e ON e.EMPID = a.ACTOR_EMPID " +
            "WHERE a.REQUEST_ID IN (" + placeholders + ") AND a.ACTION_TYPE <> 'WORKFLOW_MIGRATED' " +
            "ORDER BY a.REQUEST_ID, a.ACTED_AT ASC, a.ACTION_ID ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int index = 1;
            for (ThirdPartyRequest request : requests) {
                ps.setLong(index++, request.getRequestId());
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ThirdPartyWorkflowActionEntry entry = new ThirdPartyWorkflowActionEntry();
                    entry.setRequestId(rs.getLong("REQUEST_ID"));
                    entry.setActionType(rs.getString("ACTION_TYPE"));
                    entry.setActorType(rs.getString("ACTOR_TYPE"));
                    int actorEmpId = rs.getInt("ACTOR_EMPID");
                    entry.setActorEmpId(rs.wasNull() ? null : Integer.valueOf(actorEmpId));
                    entry.setActorEmpName(rs.getString("ACTOR_EMPNAME"));
                    entry.setActorPosition(rs.getString("ACTOR_POSITION"));
                    entry.setActedAt(rs.getTimestamp("ACTED_AT"));
                    List<ThirdPartyWorkflowActionEntry> history =
                        historyByRequest.get(Long.valueOf(entry.getRequestId()));
                    if (history != null) history.add(entry);
                }
            }
        }
        return historyByRequest;
    }

    public boolean submitItDirectorDecision(long requestId, int actorEmpId, String comment,
                                             boolean approved) throws SQLException {
        Timestamp now = BangkokTimeUtil.nowTimestamp();
        String toStatus = approved ? "PENDING_OPERATOR" : "REJECTED";
        String actionType = approved ? "IT_DIRECTOR_APPROVED" : "IT_DIRECTOR_REJECTED";
        String updateRequestSql =
            "UPDATE THIRD_PARTY_REQUEST SET STATUS = ?, UPDATED_AT = ? " +
            "WHERE REQUEST_ID = ? AND STATUS = 'PENDING_IT_DIRECTOR'";
        String insertActionSql =
            "INSERT INTO THIRD_PARTY_WORKFLOW_ACTION " +
            "(REQUEST_ID, ACTION_TYPE, FROM_STATUS, TO_STATUS, ACTOR_TYPE, ACTOR_EMPID, COMMENT_TEXT, ACTED_AT) " +
            "VALUES (?, ?, 'PENDING_IT_DIRECTOR', ?, 'INTERNAL', ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection()) {
            boolean oldAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);
            try {
                requireItDirector(conn, actorEmpId);
                try (PreparedStatement update = conn.prepareStatement(updateRequestSql)) {
                    update.setString(1, toStatus);
                    setTimestamp(update, 2, now);
                    update.setLong(3, requestId);
                    if (update.executeUpdate() != 1) {
                        conn.rollback();
                        return false;
                    }
                }
                try (PreparedStatement action = conn.prepareStatement(insertActionSql)) {
                    action.setLong(1, requestId);
                    action.setString(2, actionType);
                    action.setString(3, toStatus);
                    action.setInt(4, actorEmpId);
                    action.setString(5, comment);
                    setTimestamp(action, 6, now);
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

    public boolean isAssigned(long requestId, String assignmentRole, int empId) throws SQLException {
        String sql =
            "SELECT 1 FROM THIRD_PARTY_WORKFLOW_ASSIGNMENT " +
            "WHERE REQUEST_ID = ? AND ASSIGNMENT_ROLE = ? AND ASSIGNED_EMPID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, requestId);
            ps.setString(2, assignmentRole);
            ps.setInt(3, empId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean submitOperatorCompletion(long requestId, int actorEmpId, String detail,
                                             String acceptanceTokenHash, String acceptanceRawToken)
            throws SQLException {
        Timestamp now = BangkokTimeUtil.nowTimestamp();
        Timestamp expiresAt = new Timestamp(now.getTime() + (7L * 24L * 60L * 60L * 1000L));
        String updateRequestSql =
            "UPDATE THIRD_PARTY_REQUEST SET STATUS = 'PENDING_EXTERNAL_ACCEPTANCE', UPDATED_AT = ? " +
            "WHERE REQUEST_ID = ? AND STATUS = 'PENDING_OPERATOR' " +
            "AND EXISTS (SELECT 1 FROM THIRD_PARTY_WORKFLOW_ASSIGNMENT a " +
            "WHERE a.REQUEST_ID = THIRD_PARTY_REQUEST.REQUEST_ID " +
            "AND a.ASSIGNMENT_ROLE = 'GRANT_OPERATOR' AND a.ASSIGNED_EMPID = ?)";
        String insertActionSql =
            "INSERT INTO THIRD_PARTY_WORKFLOW_ACTION " +
            "(REQUEST_ID, ACTION_TYPE, FROM_STATUS, TO_STATUS, ACTOR_TYPE, ACTOR_EMPID, COMMENT_TEXT, ACTED_AT) " +
            "VALUES (?, 'OPERATOR_COMPLETED', 'PENDING_OPERATOR', 'PENDING_EXTERNAL_ACCEPTANCE', " +
            "'INTERNAL', ?, ?, ?)";
        String insertAcceptanceTokenSql =
            "INSERT INTO THIRD_PARTY_ACCEPTANCE_TOKEN " +
            "(REQUEST_ID, TOKEN_HASH, RAW_TOKEN, STATUS, CREATED_AT, EXPIRES_AT) " +
            "VALUES (?, ?, ?, 'ACTIVE', ?, ?)";
        try (Connection conn = DBConnection.getConnection()) {
            boolean oldAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);
            try {
                requireEmployeePosition(conn, actorEmpId, INFRASTRUCTURE_POSITION);
                try (PreparedStatement update = conn.prepareStatement(updateRequestSql)) {
                    setTimestamp(update, 1, now);
                    update.setLong(2, requestId);
                    update.setInt(3, actorEmpId);
                    if (update.executeUpdate() != 1) {
                        conn.rollback();
                        return false;
                    }
                }
                try (PreparedStatement action = conn.prepareStatement(insertActionSql)) {
                    action.setLong(1, requestId);
                    action.setInt(2, actorEmpId);
                    action.setString(3, detail);
                    setTimestamp(action, 4, now);
                    action.executeUpdate();
                }
                try (PreparedStatement token = conn.prepareStatement(insertAcceptanceTokenSql)) {
                    token.setLong(1, requestId);
                    token.setString(2, acceptanceTokenHash);
                    token.setString(3, acceptanceRawToken);
                    setTimestamp(token, 4, now);
                    setTimestamp(token, 5, expiresAt);
                    token.executeUpdate();
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

    public boolean submitRevokerCompletion(long requestId, int actorEmpId, String detail)
            throws SQLException {
        return submitAssignedCompletion(requestId, actorEmpId, detail, "REVOKE_OPERATOR",
            "PENDING_REVOKER", "PENDING_REVOKE_REVIEWER", "REVOKER_COMPLETED");
    }

    public boolean submitRevokeReviewerCompletion(long requestId, int actorEmpId, String detail)
            throws SQLException {
        return submitAssignedCompletion(requestId, actorEmpId, detail, "REVOKE_REVIEWER",
            "PENDING_REVOKE_REVIEWER", "PENDING_SECTION_HEAD_REPORT", "REVOKE_REVIEWER_APPROVED");
    }

    public boolean submitSectionHeadReport(long requestId, int actorEmpId, String report)
            throws SQLException {
        return submitPositionCompletion(requestId, actorEmpId, report, TECHNICAL_POSITION,
            "PENDING_SECTION_HEAD_REPORT", "PENDING_FINAL_CERTIFICATION", "SECTION_HEAD_REPORTED");
    }

    public boolean submitFinalCertification(long requestId, int actorEmpId) throws SQLException {
        Timestamp now = BangkokTimeUtil.nowTimestamp();
        String updateRequestSql =
            "UPDATE THIRD_PARTY_REQUEST SET STATUS = 'COMPLETED', UPDATED_AT = ? " +
            "WHERE REQUEST_ID = ? AND STATUS = 'PENDING_FINAL_CERTIFICATION'";
        String insertActionSql =
            "INSERT INTO THIRD_PARTY_WORKFLOW_ACTION " +
            "(REQUEST_ID, ACTION_TYPE, FROM_STATUS, TO_STATUS, ACTOR_TYPE, ACTOR_EMPID, COMMENT_TEXT, ACTED_AT) " +
            "VALUES (?, 'FINAL_CERTIFIED', 'PENDING_FINAL_CERTIFICATION', 'COMPLETED', 'INTERNAL', ?, NULL, ?)";
        try (Connection conn = DBConnection.getConnection()) {
            boolean oldAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);
            try {
                requireItDirector(conn, actorEmpId);
                try (PreparedStatement update = conn.prepareStatement(updateRequestSql)) {
                    setTimestamp(update, 1, now);
                    update.setLong(2, requestId);
                    if (update.executeUpdate() != 1) {
                        conn.rollback();
                        return false;
                    }
                }
                try (PreparedStatement action = conn.prepareStatement(insertActionSql)) {
                    action.setLong(1, requestId);
                    action.setInt(2, actorEmpId);
                    setTimestamp(action, 3, now);
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

    private boolean submitAssignedCompletion(long requestId, int actorEmpId, String detail,
                                             String assignmentRole, String fromStatus,
                                             String toStatus, String actionType) throws SQLException {
        Timestamp now = BangkokTimeUtil.nowTimestamp();
        String updateRequestSql =
            "UPDATE THIRD_PARTY_REQUEST SET STATUS = ?, UPDATED_AT = ? " +
            "WHERE REQUEST_ID = ? AND STATUS = ? " +
            "AND EXISTS (SELECT 1 FROM THIRD_PARTY_WORKFLOW_ASSIGNMENT a " +
            "WHERE a.REQUEST_ID = THIRD_PARTY_REQUEST.REQUEST_ID " +
            "AND a.ASSIGNMENT_ROLE = ? AND a.ASSIGNED_EMPID = ?)";
        String insertActionSql =
            "INSERT INTO THIRD_PARTY_WORKFLOW_ACTION " +
            "(REQUEST_ID, ACTION_TYPE, FROM_STATUS, TO_STATUS, ACTOR_TYPE, ACTOR_EMPID, COMMENT_TEXT, ACTED_AT) " +
            "VALUES (?, ?, ?, ?, 'INTERNAL', ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection()) {
            boolean oldAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);
            try {
                requireEmployeePosition(conn, actorEmpId, INFRASTRUCTURE_POSITION);
                try (PreparedStatement update = conn.prepareStatement(updateRequestSql)) {
                    update.setString(1, toStatus);
                    setTimestamp(update, 2, now);
                    update.setLong(3, requestId);
                    update.setString(4, fromStatus);
                    update.setString(5, assignmentRole);
                    update.setInt(6, actorEmpId);
                    if (update.executeUpdate() != 1) {
                        conn.rollback();
                        return false;
                    }
                }
                try (PreparedStatement action = conn.prepareStatement(insertActionSql)) {
                    action.setLong(1, requestId);
                    action.setString(2, actionType);
                    action.setString(3, fromStatus);
                    action.setString(4, toStatus);
                    action.setInt(5, actorEmpId);
                    action.setString(6, detail);
                    setTimestamp(action, 7, now);
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

    private boolean submitPositionCompletion(long requestId, int actorEmpId, String detail,
                                             String position, String fromStatus,
                                             String toStatus, String actionType) throws SQLException {
        Timestamp now = BangkokTimeUtil.nowTimestamp();
        String updateRequestSql =
            "UPDATE THIRD_PARTY_REQUEST SET STATUS = ?, UPDATED_AT = ? " +
            "WHERE REQUEST_ID = ? AND STATUS = ?";
        String insertActionSql =
            "INSERT INTO THIRD_PARTY_WORKFLOW_ACTION " +
            "(REQUEST_ID, ACTION_TYPE, FROM_STATUS, TO_STATUS, ACTOR_TYPE, ACTOR_EMPID, COMMENT_TEXT, ACTED_AT) " +
            "VALUES (?, ?, ?, ?, 'INTERNAL', ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection()) {
            boolean oldAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);
            try {
                requireEmployeePosition(conn, actorEmpId, position);
                try (PreparedStatement update = conn.prepareStatement(updateRequestSql)) {
                    update.setString(1, toStatus);
                    setTimestamp(update, 2, now);
                    update.setLong(3, requestId);
                    update.setString(4, fromStatus);
                    if (update.executeUpdate() != 1) {
                        conn.rollback();
                        return false;
                    }
                }
                try (PreparedStatement action = conn.prepareStatement(insertActionSql)) {
                    action.setLong(1, requestId);
                    action.setString(2, actionType);
                    action.setString(3, fromStatus);
                    action.setString(4, toStatus);
                    action.setInt(5, actorEmpId);
                    action.setString(6, detail);
                    setTimestamp(action, 7, now);
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

    private static void requireItDirector(Connection conn, int empId) throws SQLException {
        String sql =
            "SELECT 1 FROM EMPLOYEE WHERE EMPID = ? AND NVL(IS_ACTIVE, 1) = 1 " +
            "AND UPPER(REPLACE(TRIM(POSITION), ' ', '')) = 'ITDIRECTOR'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, empId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new IllegalArgumentException("พนักงานไม่มีสิทธิ์อนุมัติในขั้นตอน IT Director");
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
        ps.setTimestamp(index, value);
    }
}
