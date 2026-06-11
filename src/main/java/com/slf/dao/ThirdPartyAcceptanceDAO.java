package com.slf.dao;

import com.slf.model.ThirdPartyAcceptanceToken;
import com.slf.model.ThirdPartyAcceptanceResult;
import com.slf.util.BangkokTimeUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class ThirdPartyAcceptanceDAO {

    public ThirdPartyAcceptanceResult findByRequestId(long requestId) throws SQLException {
        String sql =
            "SELECT REQUEST_ID, COMMENT_TEXT, SATISFACTION_LEVEL, SUBMITTED_AT " +
            "FROM THIRD_PARTY_ACCEPTANCE_RESULT WHERE REQUEST_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                ThirdPartyAcceptanceResult result = new ThirdPartyAcceptanceResult();
                result.setRequestId(rs.getLong("REQUEST_ID"));
                result.setCommentText(rs.getString("COMMENT_TEXT"));
                result.setSatisfactionLevel(rs.getInt("SATISFACTION_LEVEL"));
                result.setSubmittedAt(rs.getTimestamp("SUBMITTED_AT", BangkokTimeUtil.newCalendar()));
                return result;
            }
        }
    }

    public List<ThirdPartyAcceptanceToken> findRecentForOwner(int ownerEmpId, int limit) throws SQLException {
        String sql =
            "SELECT t.ACCEPTANCE_TOKEN_ID, t.REQUEST_ID, t.RAW_TOKEN, " +
            "CASE WHEN t.STATUS = 'ACTIVE' AND t.EXPIRES_AT < ? THEN 'EXPIRED' ELSE t.STATUS END EFFECTIVE_STATUS, " +
            "t.CREATED_AT, t.EXPIRES_AT, t.USED_AT, r.EXTERNAL_CONTACT_NAME, r.EXTERNAL_COMPANY_NAME " +
            "FROM THIRD_PARTY_ACCEPTANCE_TOKEN t JOIN THIRD_PARTY_REQUEST r ON r.REQUEST_ID = t.REQUEST_ID " +
            "WHERE r.INTERNAL_OWNER_EMPID = ? ORDER BY t.CREATED_AT DESC FETCH FIRST ? ROWS ONLY";
        List<ThirdPartyAcceptanceToken> tokens = new ArrayList<ThirdPartyAcceptanceToken>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, BangkokTimeUtil.nowTimestamp(), BangkokTimeUtil.newCalendar());
            ps.setInt(2, ownerEmpId);
            ps.setInt(3, Math.max(1, limit));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) tokens.add(mapToken(rs));
            }
        }
        return tokens;
    }

    public ThirdPartyAcceptanceToken findUsableByTokenHash(String tokenHash) throws SQLException {
        String sql =
            "SELECT t.ACCEPTANCE_TOKEN_ID, t.REQUEST_ID, t.RAW_TOKEN, t.STATUS EFFECTIVE_STATUS, " +
            "t.CREATED_AT, t.EXPIRES_AT, t.USED_AT, r.EXTERNAL_CONTACT_NAME, r.EXTERNAL_COMPANY_NAME " +
            "FROM THIRD_PARTY_ACCEPTANCE_TOKEN t JOIN THIRD_PARTY_REQUEST r ON r.REQUEST_ID = t.REQUEST_ID " +
            "WHERE t.TOKEN_HASH = ? AND t.STATUS = 'ACTIVE' AND t.EXPIRES_AT >= ? " +
            "AND r.STATUS = 'PENDING_EXTERNAL_ACCEPTANCE'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tokenHash);
            ps.setTimestamp(2, BangkokTimeUtil.nowTimestamp(), BangkokTimeUtil.newCalendar());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapToken(rs) : null;
            }
        }
    }

    public void submitAcceptance(long requestId, long tokenId, String comment, int satisfactionLevel)
            throws SQLException {
        Timestamp now = BangkokTimeUtil.nowTimestamp();
        String updateToken =
            "UPDATE THIRD_PARTY_ACCEPTANCE_TOKEN SET STATUS='USED', RAW_TOKEN=NULL, USED_AT=? " +
            "WHERE ACCEPTANCE_TOKEN_ID=? AND REQUEST_ID=? AND STATUS='ACTIVE' AND EXPIRES_AT>=?";
        String insertResult =
            "INSERT INTO THIRD_PARTY_ACCEPTANCE_RESULT " +
            "(REQUEST_ID, COMMENT_TEXT, SATISFACTION_LEVEL, SUBMITTED_AT) VALUES (?, ?, ?, ?)";
        String updateRequest =
            "UPDATE THIRD_PARTY_REQUEST SET STATUS='PENDING_REVOKER', UPDATED_AT=? " +
            "WHERE REQUEST_ID=? AND STATUS='PENDING_EXTERNAL_ACCEPTANCE'";
        String insertAction =
            "INSERT INTO THIRD_PARTY_WORKFLOW_ACTION " +
            "(REQUEST_ID,ACTION_TYPE,FROM_STATUS,TO_STATUS,ACTOR_TYPE,ACTOR_EMPID,COMMENT_TEXT,ACTED_AT) " +
            "VALUES (?,'EXTERNAL_ACCEPTED','PENDING_EXTERNAL_ACCEPTANCE','PENDING_REVOKER','EXTERNAL',NULL,?,?)";
        try (Connection conn = DBConnection.getConnection()) {
            boolean oldAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(updateToken)) {
                    setTimestamp(ps, 1, now); ps.setLong(2, tokenId); ps.setLong(3, requestId); setTimestamp(ps, 4, now);
                    if (ps.executeUpdate() != 1) throw new SQLException("Acceptance link is no longer available.");
                }
                try (PreparedStatement ps = conn.prepareStatement(updateRequest)) {
                    setTimestamp(ps, 1, now); ps.setLong(2, requestId);
                    if (ps.executeUpdate() != 1) throw new SQLException("Request is no longer awaiting acceptance.");
                }
                try (PreparedStatement ps = conn.prepareStatement(insertResult)) {
                    ps.setLong(1, requestId); ps.setString(2, comment); ps.setInt(3, satisfactionLevel); setTimestamp(ps, 4, now); ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(insertAction)) {
                    ps.setLong(1, requestId); ps.setString(2, comment); setTimestamp(ps, 3, now); ps.executeUpdate();
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(oldAutoCommit);
            }
        }
    }

    private static ThirdPartyAcceptanceToken mapToken(ResultSet rs) throws SQLException {
        ThirdPartyAcceptanceToken token = new ThirdPartyAcceptanceToken();
        token.setAcceptanceTokenId(rs.getLong("ACCEPTANCE_TOKEN_ID"));
        token.setRequestId(rs.getLong("REQUEST_ID"));
        token.setRawToken(rs.getString("RAW_TOKEN"));
        token.setStatus(rs.getString("EFFECTIVE_STATUS"));
        token.setCreatedAt(rs.getTimestamp("CREATED_AT", BangkokTimeUtil.newCalendar()));
        token.setExpiresAt(rs.getTimestamp("EXPIRES_AT", BangkokTimeUtil.newCalendar()));
        token.setUsedAt(rs.getTimestamp("USED_AT", BangkokTimeUtil.newCalendar()));
        token.setExternalContactName(rs.getString("EXTERNAL_CONTACT_NAME"));
        token.setExternalCompanyName(rs.getString("EXTERNAL_COMPANY_NAME"));
        return token;
    }

    private static void setTimestamp(PreparedStatement ps, int index, Timestamp value) throws SQLException {
        ps.setTimestamp(index, value, BangkokTimeUtil.newCalendar());
    }
}
