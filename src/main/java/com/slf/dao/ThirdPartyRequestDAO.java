package com.slf.dao;

import com.slf.model.ThirdPartyRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class ThirdPartyRequestDAO {

    public long createRequest(int ownerEmpId) throws SQLException {
        String sql =
            "INSERT INTO THIRD_PARTY_REQUEST " +
            "(FORM_CODE, INTERNAL_OWNER_EMPID, STATUS) " +
            "VALUES (?, ?, 'LINK_CREATED')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, new String[] { "REQUEST_ID" })) {
            ps.setString(1, "THIRD_PARTY_USER_REGISTRATION");
            ps.setInt(2, ownerEmpId);
            ps.executeUpdate();
            return generatedId(ps);
        }
    }

    public boolean cancelRequest(long requestId, long linkId, int ownerEmpId) throws SQLException {
        String deleteLinkSql =
            "DELETE FROM THIRD_PARTY_FORM_LINK l " +
            "WHERE l.LINK_ID = ? AND l.REQUEST_ID = ? AND l.STATUS = 'ACTIVE' AND l.SUBMIT_COUNT = 0 " +
            "AND EXISTS (SELECT 1 FROM THIRD_PARTY_REQUEST r " +
            "WHERE r.REQUEST_ID = l.REQUEST_ID AND r.INTERNAL_OWNER_EMPID = ? AND r.STATUS = 'LINK_CREATED') " +
            "AND NOT EXISTS (SELECT 1 FROM THIRD_PARTY_FORM_SUBMISSION s WHERE s.LINK_ID = l.LINK_ID)";
        String deleteRequestSql =
            "DELETE FROM THIRD_PARTY_REQUEST r " +
            "WHERE r.REQUEST_ID = ? AND r.INTERNAL_OWNER_EMPID = ? AND r.STATUS = 'LINK_CREATED' " +
            "AND NOT EXISTS (SELECT 1 FROM THIRD_PARTY_FORM_LINK l WHERE l.REQUEST_ID = r.REQUEST_ID)";

        try (Connection conn = DBConnection.getConnection()) {
            boolean oldAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);
            try {
                int linkUpdated;
                try (PreparedStatement ps = conn.prepareStatement(deleteLinkSql)) {
                    ps.setLong(1, linkId);
                    ps.setLong(2, requestId);
                    ps.setInt(3, ownerEmpId);
                    linkUpdated = ps.executeUpdate();
                }
                if (linkUpdated != 1) {
                    conn.rollback();
                    return false;
                }
                try (PreparedStatement ps = conn.prepareStatement(deleteRequestSql)) {
                    ps.setLong(1, requestId);
                    ps.setInt(2, ownerEmpId);
                    if (ps.executeUpdate() != 1) {
                        conn.rollback();
                        return false;
                    }
                }
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(oldAutoCommit);
            }
        }
    }

    public ThirdPartyRequest findByIdForOwner(long requestId, int ownerEmpId) throws SQLException {
        String sql =
            "SELECT r.REQUEST_ID, r.FORM_CODE, r.INTERNAL_OWNER_EMPID, r.EXTERNAL_COMPANY_NAME, " +
            "r.EXTERNAL_CONTACT_NAME, r.EXTERNAL_EMAIL, r.EXTERNAL_PHONE, r.PURPOSE, r.TARGET_SYSTEM, " +
            "r.ACCESS_START_DATE, r.ACCESS_END_DATE, r.STATUS, r.CREATED_AT, r.SUBMITTED_AT, r.UPDATED_AT, " +
            "l.LINK_ID, l.RAW_TOKEN, CASE WHEN l.STATUS = 'ACTIVE' AND l.EXPIRES_AT < SYSTIMESTAMP THEN 'EXPIRED' ELSE l.STATUS END AS LINK_STATUS, " +
            "l.CREATED_AT AS LINK_CREATED_AT, l.EXPIRES_AT AS LINK_EXPIRES_AT, l.USED_AT AS LINK_USED_AT, " +
            "s.SUBMISSION_ID " +
            "FROM THIRD_PARTY_REQUEST r " +
            "LEFT JOIN THIRD_PARTY_FORM_LINK l ON l.REQUEST_ID = r.REQUEST_ID " +
            "LEFT JOIN THIRD_PARTY_FORM_SUBMISSION s ON s.LINK_ID = l.LINK_ID " +
            "WHERE r.REQUEST_ID = ? AND r.INTERNAL_OWNER_EMPID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, requestId);
            ps.setInt(2, ownerEmpId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRequest(rs) : null;
            }
        }
    }

    public List<ThirdPartyRequest> findRecentForOwner(int ownerEmpId, int limit) throws SQLException {
        String sql =
            "SELECT r.REQUEST_ID, r.FORM_CODE, r.INTERNAL_OWNER_EMPID, r.EXTERNAL_COMPANY_NAME, " +
            "r.EXTERNAL_CONTACT_NAME, r.EXTERNAL_EMAIL, r.EXTERNAL_PHONE, r.PURPOSE, r.TARGET_SYSTEM, " +
            "r.ACCESS_START_DATE, r.ACCESS_END_DATE, r.STATUS, r.CREATED_AT, r.SUBMITTED_AT, r.UPDATED_AT, " +
            "l.LINK_ID, l.RAW_TOKEN, CASE WHEN l.STATUS = 'ACTIVE' AND l.EXPIRES_AT < SYSTIMESTAMP THEN 'EXPIRED' ELSE l.STATUS END AS LINK_STATUS, " +
            "l.CREATED_AT AS LINK_CREATED_AT, l.EXPIRES_AT AS LINK_EXPIRES_AT, l.USED_AT AS LINK_USED_AT, " +
            "s.SUBMISSION_ID " +
            "FROM THIRD_PARTY_REQUEST r " +
            "LEFT JOIN THIRD_PARTY_FORM_LINK l ON l.REQUEST_ID = r.REQUEST_ID " +
            "LEFT JOIN THIRD_PARTY_FORM_SUBMISSION s ON s.LINK_ID = l.LINK_ID " +
            "WHERE r.INTERNAL_OWNER_EMPID = ? AND r.STATUS <> 'CANCELLED' " +
            "AND (l.STATUS IS NULL OR l.STATUS <> 'REVOKED') " +
            "ORDER BY r.CREATED_AT DESC FETCH FIRST ? ROWS ONLY";
        List<ThirdPartyRequest> requests = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ownerEmpId);
            ps.setInt(2, Math.max(1, limit));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    requests.add(mapRequest(rs));
                }
            }
        }
        return requests;
    }

    public ThirdPartyRequest findByLinkId(long linkId) throws SQLException {
        String sql =
            "SELECT r.REQUEST_ID, r.FORM_CODE, r.INTERNAL_OWNER_EMPID, r.EXTERNAL_COMPANY_NAME, " +
            "r.EXTERNAL_CONTACT_NAME, r.EXTERNAL_EMAIL, r.EXTERNAL_PHONE, r.PURPOSE, r.TARGET_SYSTEM, " +
            "r.ACCESS_START_DATE, r.ACCESS_END_DATE, r.STATUS, r.CREATED_AT, r.SUBMITTED_AT, r.UPDATED_AT, " +
            "l.LINK_ID, l.RAW_TOKEN, CASE WHEN l.STATUS = 'ACTIVE' AND l.EXPIRES_AT < SYSTIMESTAMP THEN 'EXPIRED' ELSE l.STATUS END AS LINK_STATUS, " +
            "l.CREATED_AT AS LINK_CREATED_AT, l.EXPIRES_AT AS LINK_EXPIRES_AT, l.USED_AT AS LINK_USED_AT, " +
            "s.SUBMISSION_ID " +
            "FROM THIRD_PARTY_FORM_LINK l " +
            "JOIN THIRD_PARTY_REQUEST r ON r.REQUEST_ID = l.REQUEST_ID " +
            "LEFT JOIN THIRD_PARTY_FORM_SUBMISSION s ON s.LINK_ID = l.LINK_ID " +
            "WHERE l.LINK_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, linkId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRequest(rs) : null;
            }
        }
    }

    private static ThirdPartyRequest mapRequest(ResultSet rs) throws SQLException {
        ThirdPartyRequest request = new ThirdPartyRequest();
        request.setRequestId(rs.getLong("REQUEST_ID"));
        request.setFormCode(rs.getString("FORM_CODE"));
        request.setInternalOwnerEmpId(rs.getInt("INTERNAL_OWNER_EMPID"));
        request.setExternalCompanyName(rs.getString("EXTERNAL_COMPANY_NAME"));
        request.setExternalContactName(rs.getString("EXTERNAL_CONTACT_NAME"));
        request.setExternalEmail(rs.getString("EXTERNAL_EMAIL"));
        request.setExternalPhone(rs.getString("EXTERNAL_PHONE"));
        request.setPurpose(rs.getString("PURPOSE"));
        request.setTargetSystem(rs.getString("TARGET_SYSTEM"));
        request.setAccessStartDate(rs.getDate("ACCESS_START_DATE"));
        request.setAccessEndDate(rs.getDate("ACCESS_END_DATE"));
        request.setStatus(rs.getString("STATUS"));
        request.setCreatedAt(rs.getTimestamp("CREATED_AT"));
        request.setSubmittedAt(rs.getTimestamp("SUBMITTED_AT"));
        request.setUpdatedAt(rs.getTimestamp("UPDATED_AT"));
        long linkId = rs.getLong("LINK_ID");
        request.setLinkId(rs.wasNull() ? null : Long.valueOf(linkId));
        request.setRawToken(rs.getString("RAW_TOKEN"));
        request.setLinkStatus(rs.getString("LINK_STATUS"));
        request.setLinkCreatedAt(rs.getTimestamp("LINK_CREATED_AT"));
        request.setLinkExpiresAt(rs.getTimestamp("LINK_EXPIRES_AT"));
        request.setLinkUsedAt(rs.getTimestamp("LINK_USED_AT"));
        long submissionId = rs.getLong("SUBMISSION_ID");
        request.setSubmissionId(rs.wasNull() ? null : Long.valueOf(submissionId));
        return request;
    }

    private static long generatedId(Statement statement) throws SQLException {
        try (ResultSet keys = statement.getGeneratedKeys()) {
            if (keys.next()) {
                return keys.getLong(1);
            }
        }
        throw new SQLException("Unable to read generated third-party request id.");
    }
}
