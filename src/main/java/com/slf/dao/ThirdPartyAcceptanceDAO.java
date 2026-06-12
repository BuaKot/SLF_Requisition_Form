package com.slf.dao;

import com.slf.model.ThirdPartyAcceptanceToken;
import com.slf.model.ThirdPartyAcceptanceResult;
import com.slf.util.BangkokTimeUtil;
import com.slf.util.ThirdPartyLinkToken;
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
                result.setSubmittedAt(rs.getTimestamp("SUBMITTED_AT"));
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
            ps.setTimestamp(1, BangkokTimeUtil.nowTimestamp());
            ps.setInt(2, ownerEmpId);
            ps.setInt(3, Math.max(1, limit));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) tokens.add(mapToken(rs));
            }
        }
        return tokens;
    }

    public int repairMissingTokensForOwner(int ownerEmpId, int limit) throws SQLException {
        String findSql =
            "SELECT r.REQUEST_ID FROM THIRD_PARTY_REQUEST r " +
            "WHERE r.INTERNAL_OWNER_EMPID = ? AND r.STATUS = 'PENDING_EXTERNAL_ACCEPTANCE' " +
            "AND NOT EXISTS (SELECT 1 FROM THIRD_PARTY_ACCEPTANCE_TOKEN t WHERE t.REQUEST_ID = r.REQUEST_ID) " +
            "ORDER BY r.UPDATED_AT ASC FETCH FIRST ? ROWS ONLY";
        String insertSql =
            "INSERT INTO THIRD_PARTY_ACCEPTANCE_TOKEN " +
            "(REQUEST_ID, TOKEN_HASH, RAW_TOKEN, STATUS, CREATED_AT, EXPIRES_AT) " +
            "SELECT ?, ?, ?, 'ACTIVE', ?, ? FROM DUAL " +
            "WHERE NOT EXISTS (SELECT 1 FROM THIRD_PARTY_ACCEPTANCE_TOKEN WHERE REQUEST_ID = ?)";
        Timestamp now = BangkokTimeUtil.nowTimestamp();
        Timestamp expiresAt = new Timestamp(now.getTime() + (7L * 24L * 60L * 60L * 1000L));
        List<Long> requestIds = new ArrayList<Long>();
        try (Connection conn = DBConnection.getConnection()) {
            boolean oldAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement find = conn.prepareStatement(findSql)) {
                    find.setInt(1, ownerEmpId);
                    find.setInt(2, Math.max(1, limit));
                    try (ResultSet rs = find.executeQuery()) {
                        while (rs.next()) requestIds.add(Long.valueOf(rs.getLong("REQUEST_ID")));
                    }
                }
                int repaired = 0;
                try (PreparedStatement insert = conn.prepareStatement(insertSql)) {
                    for (Long requestId : requestIds) {
                        String rawToken = ThirdPartyLinkToken.generateRawToken();
                        insert.setLong(1, requestId.longValue());
                        insert.setString(2, ThirdPartyLinkToken.sha256Hex(rawToken));
                        insert.setString(3, rawToken);
                        setTimestamp(insert, 4, now);
                        setTimestamp(insert, 5, expiresAt);
                        insert.setLong(6, requestId.longValue());
                        repaired += insert.executeUpdate();
                    }
                }
                conn.commit();
                return repaired;
            } catch (SQLException | RuntimeException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(oldAutoCommit);
            }
        }
    }

    public int advanceExpiredAcceptances() throws SQLException {
        Timestamp now = BangkokTimeUtil.nowTimestamp();
        String findSql =
            "SELECT r.REQUEST_ID, t.ACCEPTANCE_TOKEN_ID " +
            "FROM THIRD_PARTY_REQUEST r JOIN THIRD_PARTY_ACCEPTANCE_TOKEN t ON t.REQUEST_ID = r.REQUEST_ID " +
            "WHERE r.STATUS = 'PENDING_EXTERNAL_ACCEPTANCE' AND t.STATUS = 'ACTIVE' AND t.EXPIRES_AT < ? " +
            "FOR UPDATE OF r.STATUS, t.STATUS SKIP LOCKED";
        String expireTokenSql =
            "UPDATE THIRD_PARTY_ACCEPTANCE_TOKEN SET STATUS = 'EXPIRED', RAW_TOKEN = NULL " +
            "WHERE ACCEPTANCE_TOKEN_ID = ? AND STATUS = 'ACTIVE' AND EXPIRES_AT < ?";
        String updateRequestSql =
            "UPDATE THIRD_PARTY_REQUEST SET STATUS = 'PENDING_REVOKER', UPDATED_AT = ? " +
            "WHERE REQUEST_ID = ? AND STATUS = 'PENDING_EXTERNAL_ACCEPTANCE'";
        String insertActionSql =
            "INSERT INTO THIRD_PARTY_WORKFLOW_ACTION " +
            "(REQUEST_ID, ACTION_TYPE, FROM_STATUS, TO_STATUS, ACTOR_TYPE, ACTOR_EMPID, COMMENT_TEXT, ACTED_AT) " +
            "VALUES (?, 'EXTERNAL_ACCEPTANCE_EXPIRED', 'PENDING_EXTERNAL_ACCEPTANCE', " +
            "'PENDING_REVOKER', 'SYSTEM', NULL, " +
            "'External acceptance period expired; request forwarded for access revocation.', ?)";
        List<Long> requestIds = new ArrayList<Long>();
        List<Long> tokenIds = new ArrayList<Long>();
        try (Connection conn = DBConnection.getConnection()) {
            boolean oldAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement find = conn.prepareStatement(findSql)) {
                    setTimestamp(find, 1, now);
                    try (ResultSet rs = find.executeQuery()) {
                        while (rs.next()) {
                            requestIds.add(Long.valueOf(rs.getLong("REQUEST_ID")));
                            tokenIds.add(Long.valueOf(rs.getLong("ACCEPTANCE_TOKEN_ID")));
                        }
                    }
                }
                int advanced = 0;
                try (PreparedStatement expireToken = conn.prepareStatement(expireTokenSql);
                     PreparedStatement updateRequest = conn.prepareStatement(updateRequestSql);
                     PreparedStatement insertAction = conn.prepareStatement(insertActionSql)) {
                    for (int i = 0; i < requestIds.size(); i++) {
                        expireToken.setLong(1, tokenIds.get(i).longValue());
                        setTimestamp(expireToken, 2, now);
                        if (expireToken.executeUpdate() != 1) continue;

                        setTimestamp(updateRequest, 1, now);
                        updateRequest.setLong(2, requestIds.get(i).longValue());
                        if (updateRequest.executeUpdate() != 1) {
                            throw new SQLException("Unable to advance expired third-party acceptance request.");
                        }

                        insertAction.setLong(1, requestIds.get(i).longValue());
                        setTimestamp(insertAction, 2, now);
                        insertAction.executeUpdate();
                        advanced++;
                    }
                }
                conn.commit();
                return advanced;
            } catch (SQLException | RuntimeException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(oldAutoCommit);
            }
        }
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
            ps.setTimestamp(2, BangkokTimeUtil.nowTimestamp());
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
        token.setCreatedAt(rs.getTimestamp("CREATED_AT"));
        token.setExpiresAt(rs.getTimestamp("EXPIRES_AT"));
        token.setUsedAt(rs.getTimestamp("USED_AT"));
        token.setExternalContactName(rs.getString("EXTERNAL_CONTACT_NAME"));
        token.setExternalCompanyName(rs.getString("EXTERNAL_COMPANY_NAME"));
        return token;
    }

    private static void setTimestamp(PreparedStatement ps, int index, Timestamp value) throws SQLException {
        ps.setTimestamp(index, value);
    }
}
