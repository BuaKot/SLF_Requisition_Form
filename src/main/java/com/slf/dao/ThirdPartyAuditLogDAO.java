package com.slf.dao;

import com.slf.util.BangkokTimeUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class ThirdPartyAuditLogDAO {

    public void log(String eventType, Long requestId, Long linkId, Integer actorEmpId,
                    String actorType, String message) {
        String sql =
            "INSERT INTO THIRD_PARTY_AUDIT_LOG " +
            "(EVENT_TYPE, REQUEST_ID, LINK_ID, ACTOR_EMPID, ACTOR_TYPE, MESSAGE, CREATED_AT) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, truncate(eventType, 80));
            if (requestId == null) {
                ps.setNull(2, java.sql.Types.NUMERIC);
            } else {
                ps.setLong(2, requestId.longValue());
            }
            if (linkId == null) {
                ps.setNull(3, java.sql.Types.NUMERIC);
            } else {
                ps.setLong(3, linkId.longValue());
            }
            if (actorEmpId == null) {
                ps.setNull(4, java.sql.Types.NUMERIC);
            } else {
                ps.setInt(4, actorEmpId.intValue());
            }
            ps.setString(5, truncate(actorType, 30));
            ps.setString(6, truncate(message, 1000));
            ps.setTimestamp(7, BangkokTimeUtil.nowTimestamp(), BangkokTimeUtil.newCalendar());
            ps.executeUpdate();
        } catch (Exception e) {
            System.err.println("Third-party audit log skipped: " + e.getMessage());
        }
    }

    private static String truncate(String value, int maxLength) {
        if (value == null) {
            return null;
        }
        return value.length() <= maxLength ? value : value.substring(0, maxLength);
    }
}
