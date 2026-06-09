package com.slf.dao;

import com.slf.model.ThirdPartyFormSubmission;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class ThirdPartyFormSubmissionDAO {

    public ThirdPartyFormSubmission findById(long submissionId) throws SQLException {
        String sql =
            "SELECT s.SUBMISSION_ID, s.LINK_ID, s.DOCUMENT_RECEIVE_NO, s.FILLED_AT, " +
            "s.FULL_NAME_TH, s.FULL_NAME_EN, s.ORGANIZATION, s.PHONE, s.EMAIL, " +
            "s.REASON_OBJECTIVE, s.PROJECT_NAME, s.ACCESS_START_DATE, s.ACCESS_END_DATE, " +
            "s.STATUS, s.CREATED_AT, s.REVIEWED_BY, s.REVIEWED_AT, s.IMPORTED_FORMID, s.INTERNAL_NOTE, " +
            "CASE WHEN l.STATUS = 'ACTIVE' AND l.EXPIRES_AT < SYSTIMESTAMP THEN 'EXPIRED' ELSE l.STATUS END AS LINK_STATUS, " +
            "l.CREATED_AT AS LINK_CREATED_AT, l.EXPIRES_AT AS LINK_EXPIRES_AT, l.NOTE AS LINK_NOTE " +
            "FROM THIRD_PARTY_FORM_SUBMISSION s " +
            "JOIN THIRD_PARTY_FORM_LINK l ON l.LINK_ID = s.LINK_ID " +
            "WHERE s.SUBMISSION_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, submissionId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapSubmission(rs) : null;
            }
        }
    }

    public void submitOnce(ThirdPartyFormSubmission submission) throws SQLException {
        String insertSql =
            "INSERT INTO THIRD_PARTY_FORM_SUBMISSION " +
            "(LINK_ID, DOCUMENT_RECEIVE_NO, FULL_NAME_TH, FULL_NAME_EN, ORGANIZATION, PHONE, EMAIL, " +
            "REASON_OBJECTIVE, PROJECT_NAME, ACCESS_START_DATE, ACCESS_END_DATE, STATUS) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING_REVIEW')";
        String documentNoSql =
            "UPDATE THIRD_PARTY_FORM_SUBMISSION SET DOCUMENT_RECEIVE_NO = ? WHERE SUBMISSION_ID = ?";
        String updateSql =
            "UPDATE THIRD_PARTY_FORM_LINK SET STATUS = 'USED', RAW_TOKEN = NULL, SUBMIT_COUNT = SUBMIT_COUNT + 1, USED_AT = SYSTIMESTAMP " +
            "WHERE LINK_ID = ? AND STATUS = 'ACTIVE' AND SUBMIT_COUNT = 0 AND EXPIRES_AT >= SYSTIMESTAMP";

        try (Connection conn = DBConnection.getConnection()) {
            boolean oldAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);
            try (PreparedStatement update = conn.prepareStatement(updateSql)) {
                update.setLong(1, submission.getLinkId());
                if (update.executeUpdate() != 1) {
                    conn.rollback();
                    throw new SQLException("This third-party form link is no longer available.");
                }

                long submissionId;
                try (PreparedStatement insert = conn.prepareStatement(insertSql, new String[] { "SUBMISSION_ID" })) {
                    insert.setLong(1, submission.getLinkId());
                    insert.setNull(2, java.sql.Types.VARCHAR);
                    insert.setString(3, submission.getFullNameTh());
                    insert.setString(4, trimToNull(submission.getFullNameEn()));
                    insert.setString(5, submission.getOrganization());
                    insert.setString(6, submission.getPhone());
                    insert.setString(7, submission.getEmail());
                    insert.setString(8, submission.getReasonObjective());
                    insert.setString(9, trimToNull(submission.getProjectName()));
                    insert.setDate(10, submission.getAccessStartDate());
                    insert.setDate(11, submission.getAccessEndDate());
                    insert.executeUpdate();
                    submissionId = generatedSubmissionId(insert);
                }

                try (PreparedStatement documentNo = conn.prepareStatement(documentNoSql)) {
                    documentNo.setString(1, formatDocumentReceiveNo(submissionId));
                    documentNo.setLong(2, submissionId);
                    documentNo.executeUpdate();
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

    static String formatDocumentReceiveNo(long sequenceValue) {
        return "TP-" + String.format("%06d", sequenceValue);
    }

    private static ThirdPartyFormSubmission mapSubmission(ResultSet rs) throws SQLException {
        ThirdPartyFormSubmission submission = new ThirdPartyFormSubmission();
        submission.setSubmissionId(rs.getLong("SUBMISSION_ID"));
        submission.setLinkId(rs.getLong("LINK_ID"));
        submission.setDocumentReceiveNo(rs.getString("DOCUMENT_RECEIVE_NO"));
        java.sql.Timestamp filledAt = rs.getTimestamp("FILLED_AT");
        submission.setFilledDate(filledAt == null ? null : new java.sql.Date(filledAt.getTime()));
        submission.setFullNameTh(rs.getString("FULL_NAME_TH"));
        submission.setFullNameEn(rs.getString("FULL_NAME_EN"));
        submission.setOrganization(rs.getString("ORGANIZATION"));
        submission.setPhone(rs.getString("PHONE"));
        submission.setEmail(rs.getString("EMAIL"));
        submission.setReasonObjective(rs.getString("REASON_OBJECTIVE"));
        submission.setProjectName(rs.getString("PROJECT_NAME"));
        submission.setAccessStartDate(rs.getDate("ACCESS_START_DATE"));
        submission.setAccessEndDate(rs.getDate("ACCESS_END_DATE"));
        submission.setStatus(rs.getString("STATUS"));
        submission.setCreatedAt(rs.getTimestamp("CREATED_AT"));
        int reviewedBy = rs.getInt("REVIEWED_BY");
        submission.setReviewedBy(rs.wasNull() ? null : Integer.valueOf(reviewedBy));
        submission.setReviewedAt(rs.getTimestamp("REVIEWED_AT"));
        int importedFormId = rs.getInt("IMPORTED_FORMID");
        submission.setImportedFormId(rs.wasNull() ? null : Integer.valueOf(importedFormId));
        submission.setInternalNote(rs.getString("INTERNAL_NOTE"));
        submission.setLinkStatus(rs.getString("LINK_STATUS"));
        submission.setLinkCreatedAt(rs.getTimestamp("LINK_CREATED_AT"));
        submission.setLinkExpiresAt(rs.getTimestamp("LINK_EXPIRES_AT"));
        submission.setLinkNote(rs.getString("LINK_NOTE"));
        return submission;
    }

    private static String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private static long generatedSubmissionId(Statement statement) throws SQLException {
        try (ResultSet keys = statement.getGeneratedKeys()) {
            if (keys.next()) {
                return keys.getLong(1);
            }
        }
        throw new SQLException("Unable to read generated third-party submission id.");
    }
}
