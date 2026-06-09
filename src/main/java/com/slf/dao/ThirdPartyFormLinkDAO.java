package com.slf.dao;

import com.slf.model.ThirdPartyFormLink;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class ThirdPartyFormLinkDAO {
    private static final long LINK_TTL_MILLIS = 24L * 60L * 60L * 1000L;

    public long createLink(String tokenHash, String rawToken, int createdBy, String note) throws SQLException {
        return createLink(tokenHash, rawToken, createdBy, note, null, null, null);
    }

    public long createLink(String tokenHash, String rawToken, int createdBy, String note,
                           String formCode, Long requestId, Integer createdByEmpId) throws SQLException {
        String sql =
            "INSERT INTO THIRD_PARTY_FORM_LINK " +
            "(TOKEN_HASH, RAW_TOKEN, STATUS, MAX_SUBMIT_COUNT, SUBMIT_COUNT, CREATED_BY, EXPIRES_AT, NOTE, " +
            "FORM_CODE, REQUEST_ID, CREATED_BY_EMPID) " +
            "VALUES (?, ?, 'ACTIVE', 1, 0, ?, ?, ?, ?, ?, ?)";
        Timestamp expiresAt = new Timestamp(System.currentTimeMillis() + LINK_TTL_MILLIS);
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, new String[] { "LINK_ID" })) {
            ps.setString(1, tokenHash);
            ps.setString(2, rawToken);
            ps.setInt(3, createdBy);
            ps.setTimestamp(4, expiresAt);
            ps.setString(5, trimToNull(note));
            ps.setString(6, trimToNull(formCode));
            if (requestId == null) {
                ps.setNull(7, java.sql.Types.NUMERIC);
            } else {
                ps.setLong(7, requestId.longValue());
            }
            if (createdByEmpId == null) {
                ps.setNull(8, java.sql.Types.NUMERIC);
            } else {
                ps.setInt(8, createdByEmpId.intValue());
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

    public List<ThirdPartyFormLink> findRecentLinks(int limit) throws SQLException {
        String sql =
            "SELECT l.LINK_ID, l.TOKEN_HASH, l.RAW_TOKEN, " +
            "CASE WHEN l.STATUS = 'ACTIVE' AND l.EXPIRES_AT < SYSTIMESTAMP THEN 'EXPIRED' ELSE l.STATUS END AS EFFECTIVE_STATUS, " +
            "l.MAX_SUBMIT_COUNT, l.SUBMIT_COUNT, l.CREATED_BY, l.FORM_CODE, l.REQUEST_ID, l.CREATED_BY_EMPID, l.CREATED_AT, l.EXPIRES_AT, " +
            "l.USED_AT, l.REVOKED_AT, l.REVOKED_BY, l.NOTE, " +
            "s.SUBMISSION_ID, s.STATUS AS SUBMISSION_STATUS, s.CREATED_AT AS SUBMITTED_AT " +
            "FROM THIRD_PARTY_FORM_LINK l " +
            "LEFT JOIN THIRD_PARTY_FORM_SUBMISSION s ON s.LINK_ID = l.LINK_ID " +
            "ORDER BY l.CREATED_AT DESC FETCH FIRST ? ROWS ONLY";
        List<ThirdPartyFormLink> links = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Math.max(1, limit));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    links.add(mapLink(rs));
                }
            }
        }
        return links;
    }

    public boolean revokeLink(long linkId, int revokedBy) throws SQLException {
        String sql =
            "UPDATE THIRD_PARTY_FORM_LINK " +
            "SET STATUS = 'REVOKED', RAW_TOKEN = NULL, REVOKED_AT = SYSTIMESTAMP, REVOKED_BY = ? " +
            "WHERE LINK_ID = ? AND STATUS = 'ACTIVE' AND SUBMIT_COUNT = 0";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, revokedBy);
            ps.setLong(2, linkId);
            return ps.executeUpdate() == 1;
        }
    }

    public ThirdPartyFormLink findUsableByTokenHash(String tokenHash) throws SQLException {
        String sql =
            "SELECT l.LINK_ID, l.TOKEN_HASH, l.RAW_TOKEN, " +
            "CASE WHEN l.STATUS = 'ACTIVE' AND l.EXPIRES_AT < SYSTIMESTAMP THEN 'EXPIRED' ELSE l.STATUS END AS EFFECTIVE_STATUS, " +
            "l.MAX_SUBMIT_COUNT, l.SUBMIT_COUNT, l.CREATED_BY, l.FORM_CODE, l.REQUEST_ID, l.CREATED_BY_EMPID, l.CREATED_AT, l.EXPIRES_AT, " +
            "l.USED_AT, l.REVOKED_AT, l.REVOKED_BY, l.NOTE, " +
            "s.SUBMISSION_ID, s.STATUS AS SUBMISSION_STATUS, s.CREATED_AT AS SUBMITTED_AT " +
            "FROM THIRD_PARTY_FORM_LINK l " +
            "LEFT JOIN THIRD_PARTY_FORM_SUBMISSION s ON s.LINK_ID = l.LINK_ID " +
            "WHERE l.TOKEN_HASH = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tokenHash);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                ThirdPartyFormLink link = mapLink(rs);
                if (!"ACTIVE".equals(link.getStatus()) || link.getSubmitCount() >= link.getMaxSubmitCount()
                        || link.getSubmissionId() != null) {
                    return null;
                }
                return link;
            }
        }
    }

    public static String normalizeAction(String value) {
        if (value == null) {
            return "";
        }
        String action = value.trim().toLowerCase();
        if ("generate".equals(action) || "revoke".equals(action)) {
            return action;
        }
        return "";
    }

    private static ThirdPartyFormLink mapLink(ResultSet rs) throws SQLException {
        ThirdPartyFormLink link = new ThirdPartyFormLink();
        link.setLinkId(rs.getLong("LINK_ID"));
        link.setTokenHash(rs.getString("TOKEN_HASH"));
        link.setRawToken(rs.getString("RAW_TOKEN"));
        link.setStatus(rs.getString("EFFECTIVE_STATUS"));
        link.setMaxSubmitCount(rs.getInt("MAX_SUBMIT_COUNT"));
        link.setSubmitCount(rs.getInt("SUBMIT_COUNT"));
        int createdBy = rs.getInt("CREATED_BY");
        link.setCreatedBy(rs.wasNull() ? null : Integer.valueOf(createdBy));
        link.setFormCode(rs.getString("FORM_CODE"));
        long requestId = rs.getLong("REQUEST_ID");
        link.setRequestId(rs.wasNull() ? null : Long.valueOf(requestId));
        int createdByEmpId = rs.getInt("CREATED_BY_EMPID");
        link.setCreatedByEmpId(rs.wasNull() ? null : Integer.valueOf(createdByEmpId));
        link.setCreatedAt(rs.getTimestamp("CREATED_AT"));
        link.setExpiresAt(rs.getTimestamp("EXPIRES_AT"));
        link.setUsedAt(rs.getTimestamp("USED_AT"));
        link.setRevokedAt(rs.getTimestamp("REVOKED_AT"));
        int revokedBy = rs.getInt("REVOKED_BY");
        link.setRevokedBy(rs.wasNull() ? null : Integer.valueOf(revokedBy));
        link.setNote(rs.getString("NOTE"));
        long submissionId = rs.getLong("SUBMISSION_ID");
        link.setSubmissionId(rs.wasNull() ? null : Long.valueOf(submissionId));
        link.setSubmissionStatus(rs.getString("SUBMISSION_STATUS"));
        link.setSubmittedAt(rs.getTimestamp("SUBMITTED_AT"));
        return link;
    }

    private static String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
