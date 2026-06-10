package com.slf.dao;

import com.slf.model.ThirdPartyFormSubmission;
import com.slf.model.ThirdPartyAccessRequest;
import com.slf.util.BangkokTimeUtil;
import java.util.ArrayList;
import java.util.List;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;

public class ThirdPartyFormSubmissionDAO {

    public ThirdPartyFormSubmission findById(long submissionId) throws SQLException {
        String sql =
            "SELECT s.SUBMISSION_ID, s.LINK_ID, s.DOCUMENT_RECEIVE_NO, s.FILLED_AT, " +
            "s.FULL_NAME_TH, s.FULL_NAME_EN, s.ORGANIZATION, s.PHONE, s.EMAIL, " +
            "s.REASON_OBJECTIVE, s.PROJECT_NAME, s.ACCESS_START_DATE, s.ACCESS_END_DATE, " +
            "s.STATUS, s.CREATED_AT, s.REVIEWED_BY, s.REVIEWED_AT, s.IMPORTED_FORMID, s.INTERNAL_NOTE, " +
            "s.CONSENT_ACCEPTED, s.CONSENT_VERSION, s.CONSENT_ACCEPTED_AT, s.CONSENT_IP_ADDRESS, s.CONSENT_USER_AGENT, " +
            "CASE WHEN l.STATUS = 'ACTIVE' AND l.EXPIRES_AT < ? THEN 'EXPIRED' ELSE l.STATUS END AS LINK_STATUS, " +
            "l.REQUEST_ID, r.INTERNAL_OWNER_EMPID, l.CREATED_AT AS LINK_CREATED_AT, l.EXPIRES_AT AS LINK_EXPIRES_AT, l.NOTE AS LINK_NOTE " +
            "FROM THIRD_PARTY_FORM_SUBMISSION s " +
            "JOIN THIRD_PARTY_FORM_LINK l ON l.LINK_ID = s.LINK_ID " +
            "LEFT JOIN THIRD_PARTY_REQUEST r ON r.REQUEST_ID = l.REQUEST_ID " +
            "WHERE s.SUBMISSION_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setBangkokTimestamp(ps, 1, BangkokTimeUtil.nowTimestamp());
            ps.setLong(2, submissionId);
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
        Timestamp eventTimestamp = BangkokTimeUtil.nowTimestamp();
        String insertSql =
            "INSERT INTO THIRD_PARTY_FORM_SUBMISSION " +
            "(LINK_ID, DOCUMENT_RECEIVE_NO, FILLED_AT, FULL_NAME_TH, FULL_NAME_EN, ORGANIZATION, PHONE, EMAIL, " +
            "REASON_OBJECTIVE, PROJECT_NAME, ACCESS_START_DATE, ACCESS_END_DATE, STATUS, CREATED_AT, " +
            "CONSENT_ACCEPTED, CONSENT_VERSION, CONSENT_ACCEPTED_AT, CONSENT_IP_ADDRESS, CONSENT_USER_AGENT) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING_REVIEW', ?, 1, ?, ?, ?, ?)";
        String documentNoSql =
            "UPDATE THIRD_PARTY_FORM_SUBMISSION SET DOCUMENT_RECEIVE_NO = ? WHERE SUBMISSION_ID = ?";
        String updateSql =
            "UPDATE THIRD_PARTY_FORM_LINK SET STATUS = 'USED', RAW_TOKEN = NULL, SUBMIT_COUNT = SUBMIT_COUNT + 1, USED_AT = ? " +
            "WHERE LINK_ID = ? AND STATUS = 'ACTIVE' AND SUBMIT_COUNT = 0 AND EXPIRES_AT >= ?";
        String accessRequestSql =
            "INSERT INTO THIRD_PARTY_ACCESS_REQUEST " +
            "(SUBMISSION_ID, DISPLAY_ORDER, EMPLOYEE_CODE, USERNAME, NATIONAL_ID, FULL_NAME_TH, " +
            "FULL_NAME_EN, POSITION_NAME, MOBILE_PHONE, DEPARTMENT_NAME, EMAIL, SYSTEM_NAME, REQUESTED_ROLE, CREATED_AT) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String updateRequestSql =
            "UPDATE THIRD_PARTY_REQUEST r SET STATUS = 'SUBMITTED', EXTERNAL_COMPANY_NAME = ?, " +
            "EXTERNAL_CONTACT_NAME = ?, EXTERNAL_EMAIL = ?, EXTERNAL_PHONE = ?, PURPOSE = ?, TARGET_SYSTEM = ?, " +
            "ACCESS_START_DATE = ?, ACCESS_END_DATE = ?, SUBMITTED_AT = ?, UPDATED_AT = ? " +
            "WHERE EXISTS (SELECT 1 FROM THIRD_PARTY_FORM_LINK l WHERE l.LINK_ID = ? AND l.REQUEST_ID = r.REQUEST_ID)";

        try (Connection conn = DBConnection.getConnection()) {
            boolean oldAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);
            try (PreparedStatement update = conn.prepareStatement(updateSql)) {
                setBangkokTimestamp(update, 1, eventTimestamp);
                update.setLong(2, submission.getLinkId());
                setBangkokTimestamp(update, 3, eventTimestamp);
                if (update.executeUpdate() != 1) {
                    conn.rollback();
                    throw new SQLException("This third-party form link is no longer available.");
                }

                long submissionId;
                try (PreparedStatement insert = conn.prepareStatement(insertSql, new String[] { "SUBMISSION_ID" })) {
                    insert.setLong(1, submission.getLinkId());
                    insert.setNull(2, java.sql.Types.VARCHAR);
                    setBangkokTimestamp(insert, 3, eventTimestamp);
                    insert.setString(4, submission.getFullNameTh());
                    insert.setString(5, trimToNull(submission.getFullNameEn()));
                    insert.setString(6, submission.getOrganization());
                    insert.setString(7, submission.getPhone());
                    insert.setString(8, submission.getEmail());
                    insert.setString(9, submission.getReasonObjective());
                    insert.setString(10, trimToNull(submission.getProjectName()));
                    setBangkokDate(insert, 11, submission.getAccessStartDate());
                    setBangkokDate(insert, 12, submission.getAccessEndDate());
                    setBangkokTimestamp(insert, 13, eventTimestamp);
                    insert.setString(14, submission.getConsentVersion());
                    setBangkokTimestamp(insert, 15, eventTimestamp);
                    insert.setString(16, submission.getConsentIpAddress());
                    insert.setString(17, submission.getConsentUserAgent());
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
                        setBangkokTimestamp(accessRequest, 14, eventTimestamp);
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
                    setBangkokDate(updateRequest, 7, submission.getAccessStartDate());
                    setBangkokDate(updateRequest, 8, submission.getAccessEndDate());
                    setBangkokTimestamp(updateRequest, 9, eventTimestamp);
                    setBangkokTimestamp(updateRequest, 10, eventTimestamp);
                    updateRequest.setLong(11, submission.getLinkId());
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
        java.sql.Timestamp filledAt = getBangkokTimestamp(rs, "FILLED_AT");
        submission.setFilledDate(filledAt == null ? null : new java.sql.Date(filledAt.getTime()));
        submission.setFullNameTh(rs.getString("FULL_NAME_TH"));
        submission.setFullNameEn(rs.getString("FULL_NAME_EN"));
        submission.setOrganization(rs.getString("ORGANIZATION"));
        submission.setPhone(rs.getString("PHONE"));
        submission.setEmail(rs.getString("EMAIL"));
        submission.setReasonObjective(rs.getString("REASON_OBJECTIVE"));
        submission.setProjectName(rs.getString("PROJECT_NAME"));
        submission.setAccessStartDate(getBangkokDate(rs, "ACCESS_START_DATE"));
        submission.setAccessEndDate(getBangkokDate(rs, "ACCESS_END_DATE"));
        submission.setStatus(rs.getString("STATUS"));
        submission.setCreatedAt(getBangkokTimestamp(rs, "CREATED_AT"));
        int reviewedBy = rs.getInt("REVIEWED_BY");
        submission.setReviewedBy(rs.wasNull() ? null : Integer.valueOf(reviewedBy));
        submission.setReviewedAt(getBangkokTimestamp(rs, "REVIEWED_AT"));
        int importedFormId = rs.getInt("IMPORTED_FORMID");
        submission.setImportedFormId(rs.wasNull() ? null : Integer.valueOf(importedFormId));
        submission.setInternalNote(rs.getString("INTERNAL_NOTE"));
        submission.setConsentAccepted(rs.getInt("CONSENT_ACCEPTED") == 1);
        submission.setConsentVersion(rs.getString("CONSENT_VERSION"));
        submission.setConsentAcceptedAt(getBangkokTimestamp(rs, "CONSENT_ACCEPTED_AT"));
        submission.setConsentIpAddress(rs.getString("CONSENT_IP_ADDRESS"));
        submission.setConsentUserAgent(rs.getString("CONSENT_USER_AGENT"));
        submission.setLinkStatus(rs.getString("LINK_STATUS"));
        submission.setLinkCreatedAt(getBangkokTimestamp(rs, "LINK_CREATED_AT"));
        submission.setLinkExpiresAt(getBangkokTimestamp(rs, "LINK_EXPIRES_AT"));
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

    private static void setBangkokTimestamp(PreparedStatement ps, int parameterIndex, Timestamp value)
            throws SQLException {
        ps.setTimestamp(parameterIndex, value, BangkokTimeUtil.newCalendar());
    }

    private static void setBangkokDate(PreparedStatement ps, int parameterIndex, Date value)
            throws SQLException {
        ps.setDate(parameterIndex, value, BangkokTimeUtil.newCalendar());
    }

    private static Timestamp getBangkokTimestamp(ResultSet rs, String columnLabel) throws SQLException {
        return rs.getTimestamp(columnLabel, BangkokTimeUtil.newCalendar());
    }

    private static Date getBangkokDate(ResultSet rs, String columnLabel) throws SQLException {
        return rs.getDate(columnLabel, BangkokTimeUtil.newCalendar());
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
