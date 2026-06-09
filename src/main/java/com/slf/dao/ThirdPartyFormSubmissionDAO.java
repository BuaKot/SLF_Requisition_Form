package com.slf.dao;

import com.slf.model.ThirdPartyFormSubmission;
import com.slf.model.ThirdPartyAccessRequest;
import java.util.ArrayList;
import java.util.List;
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
            "s.CONSENT_ACCEPTED, s.CONSENT_VERSION, s.CONSENT_ACCEPTED_AT, s.CONSENT_IP_ADDRESS, s.CONSENT_USER_AGENT, " +
            "CASE WHEN l.STATUS = 'ACTIVE' AND l.EXPIRES_AT < SYSTIMESTAMP THEN 'EXPIRED' ELSE l.STATUS END AS LINK_STATUS, " +
            "l.REQUEST_ID, r.INTERNAL_OWNER_EMPID, l.CREATED_AT AS LINK_CREATED_AT, l.EXPIRES_AT AS LINK_EXPIRES_AT, l.NOTE AS LINK_NOTE " +
            "FROM THIRD_PARTY_FORM_SUBMISSION s " +
            "JOIN THIRD_PARTY_FORM_LINK l ON l.LINK_ID = s.LINK_ID " +
            "LEFT JOIN THIRD_PARTY_REQUEST r ON r.REQUEST_ID = l.REQUEST_ID " +
            "WHERE s.SUBMISSION_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, submissionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                ThirdPartyFormSubmission submission = mapSubmission(rs);
                submission.setAccessRequests(findAccessRequests(conn, submissionId));
                return submission;
            }
        }
    }

    public void submitOnce(ThirdPartyFormSubmission submission) throws SQLException {
        String insertSql =
            "INSERT INTO THIRD_PARTY_FORM_SUBMISSION " +
            "(LINK_ID, DOCUMENT_RECEIVE_NO, FULL_NAME_TH, FULL_NAME_EN, ORGANIZATION, PHONE, EMAIL, " +
            "REASON_OBJECTIVE, PROJECT_NAME, ACCESS_START_DATE, ACCESS_END_DATE, STATUS, " +
            "CONSENT_ACCEPTED, CONSENT_VERSION, CONSENT_ACCEPTED_AT, CONSENT_IP_ADDRESS, CONSENT_USER_AGENT) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING_REVIEW', 1, ?, SYSTIMESTAMP, ?, ?)";
        String documentNoSql =
            "UPDATE THIRD_PARTY_FORM_SUBMISSION SET DOCUMENT_RECEIVE_NO = ? WHERE SUBMISSION_ID = ?";
        String updateSql =
            "UPDATE THIRD_PARTY_FORM_LINK SET STATUS = 'USED', RAW_TOKEN = NULL, SUBMIT_COUNT = SUBMIT_COUNT + 1, USED_AT = SYSTIMESTAMP " +
            "WHERE LINK_ID = ? AND STATUS = 'ACTIVE' AND SUBMIT_COUNT = 0 AND EXPIRES_AT >= SYSTIMESTAMP";
        String accessRequestSql =
            "INSERT INTO THIRD_PARTY_ACCESS_REQUEST " +
            "(SUBMISSION_ID, DISPLAY_ORDER, EMPLOYEE_CODE, USERNAME, NATIONAL_ID, FULL_NAME_TH, " +
            "FULL_NAME_EN, POSITION_NAME, MOBILE_PHONE, DEPARTMENT_NAME, EMAIL, SYSTEM_NAME, REQUESTED_ROLE) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String updateRequestSql =
            "UPDATE THIRD_PARTY_REQUEST r SET STATUS = 'SUBMITTED', EXTERNAL_COMPANY_NAME = ?, " +
            "EXTERNAL_CONTACT_NAME = ?, EXTERNAL_EMAIL = ?, EXTERNAL_PHONE = ?, PURPOSE = ?, TARGET_SYSTEM = ?, " +
            "ACCESS_START_DATE = ?, ACCESS_END_DATE = ?, SUBMITTED_AT = SYSTIMESTAMP, UPDATED_AT = SYSTIMESTAMP " +
            "WHERE EXISTS (SELECT 1 FROM THIRD_PARTY_FORM_LINK l WHERE l.LINK_ID = ? AND l.REQUEST_ID = r.REQUEST_ID)";

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
                    insert.setString(12, submission.getConsentVersion());
                    insert.setString(13, submission.getConsentIpAddress());
                    insert.setString(14, submission.getConsentUserAgent());
                    insert.executeUpdate();
                    submissionId = generatedSubmissionId(insert);
                }

                try (PreparedStatement documentNo = conn.prepareStatement(documentNoSql)) {
                    documentNo.setString(1, formatDocumentReceiveNo(submissionId));
                    documentNo.setLong(2, submissionId);
                    documentNo.executeUpdate();
                }
                try (PreparedStatement accessRequest = conn.prepareStatement(accessRequestSql)) {
                    for (ThirdPartyAccessRequest item : submission.getAccessRequests()) {
                        accessRequest.setLong(1, submissionId);
                        accessRequest.setInt(2, item.getDisplayOrder());
                        accessRequest.setString(3, trimToNull(item.getEmployeeCode()));
                        accessRequest.setString(4, trimToNull(item.getUsername()));
                        accessRequest.setString(5, trimToNull(item.getNationalId()));
                        accessRequest.setString(6, item.getFullNameTh());
                        accessRequest.setString(7, trimToNull(item.getFullNameEn()));
                        accessRequest.setString(8, item.getPositionName());
                        accessRequest.setString(9, item.getMobilePhone());
                        accessRequest.setString(10, item.getDepartmentName());
                        accessRequest.setString(11, item.getEmail());
                        accessRequest.setString(12, item.getSystemName());
                        accessRequest.setString(13, item.getRequestedRole());
                        accessRequest.addBatch();
                    }
                    accessRequest.executeBatch();
                }
                try (PreparedStatement updateRequest = conn.prepareStatement(updateRequestSql)) {
                    updateRequest.setString(1, submission.getOrganization());
                    updateRequest.setString(2, submission.getFullNameTh());
                    updateRequest.setString(3, submission.getEmail());
                    updateRequest.setString(4, submission.getPhone());
                    updateRequest.setString(5, submission.getReasonObjective());
                    updateRequest.setString(6, trimToNull(submission.getProjectName()));
                    updateRequest.setDate(7, submission.getAccessStartDate());
                    updateRequest.setDate(8, submission.getAccessEndDate());
                    updateRequest.setLong(9, submission.getLinkId());
                    updateRequest.executeUpdate();
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
        long requestId = rs.getLong("REQUEST_ID");
        submission.setRequestId(rs.wasNull() ? null : Long.valueOf(requestId));
        int internalOwnerEmpId = rs.getInt("INTERNAL_OWNER_EMPID");
        submission.setInternalOwnerEmpId(rs.wasNull() ? null : Integer.valueOf(internalOwnerEmpId));
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
        submission.setConsentAccepted(rs.getInt("CONSENT_ACCEPTED") == 1);
        submission.setConsentVersion(rs.getString("CONSENT_VERSION"));
        submission.setConsentAcceptedAt(rs.getTimestamp("CONSENT_ACCEPTED_AT"));
        submission.setConsentIpAddress(rs.getString("CONSENT_IP_ADDRESS"));
        submission.setConsentUserAgent(rs.getString("CONSENT_USER_AGENT"));
        submission.setLinkStatus(rs.getString("LINK_STATUS"));
        submission.setLinkCreatedAt(rs.getTimestamp("LINK_CREATED_AT"));
        submission.setLinkExpiresAt(rs.getTimestamp("LINK_EXPIRES_AT"));
        submission.setLinkNote(rs.getString("LINK_NOTE"));
        return submission;
    }

    private static List<ThirdPartyAccessRequest> findAccessRequests(Connection conn, long submissionId)
            throws SQLException {
        String sql =
            "SELECT ACCESS_REQUEST_ID, DISPLAY_ORDER, EMPLOYEE_CODE, USERNAME, NATIONAL_ID, " +
            "FULL_NAME_TH, FULL_NAME_EN, POSITION_NAME, MOBILE_PHONE, DEPARTMENT_NAME, EMAIL, SYSTEM_NAME, REQUESTED_ROLE " +
            "FROM THIRD_PARTY_ACCESS_REQUEST WHERE SUBMISSION_ID = ? ORDER BY DISPLAY_ORDER";
        List<ThirdPartyAccessRequest> items = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, submissionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ThirdPartyAccessRequest item = new ThirdPartyAccessRequest();
                    item.setAccessRequestId(rs.getLong("ACCESS_REQUEST_ID"));
                    item.setDisplayOrder(rs.getInt("DISPLAY_ORDER"));
                    item.setEmployeeCode(rs.getString("EMPLOYEE_CODE"));
                    item.setUsername(rs.getString("USERNAME"));
                    item.setNationalId(rs.getString("NATIONAL_ID"));
                    item.setFullNameTh(rs.getString("FULL_NAME_TH"));
                    item.setFullNameEn(rs.getString("FULL_NAME_EN"));
                    item.setPositionName(rs.getString("POSITION_NAME"));
                    item.setMobilePhone(rs.getString("MOBILE_PHONE"));
                    item.setDepartmentName(rs.getString("DEPARTMENT_NAME"));
                    item.setEmail(rs.getString("EMAIL"));
                    item.setSystemName(rs.getString("SYSTEM_NAME"));
                    item.setRequestedRole(rs.getString("REQUESTED_ROLE"));
                    items.add(item);
                }
            }
        }
        return items;
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
