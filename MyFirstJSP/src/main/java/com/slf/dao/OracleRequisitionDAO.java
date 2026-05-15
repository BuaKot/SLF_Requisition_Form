package com.slf.dao;

import com.slf.model.RequisitionForm;
import com.slf.model.RequestItem;

import java.sql.*;

public class OracleRequisitionDAO implements RequisitionDAO {

    @Override
    public void save(RequisitionForm form) throws Exception {

        Connection conn = null;
        PreparedStatement requestorStmt = null;
        PreparedStatement formStmt = null;
        PreparedStatement itemStmt = null;

        ResultSet requestorRs = null;
        ResultSet formRs = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // =====================================================
            // STEP 1: หา REQUESTORID จาก REQUESTOR
            // FK_FORM_REQUESTOR บังคับให้ REQUISITIONFORM.EMPID
            // ต้องมีค่าอยู่ใน REQUESTOR.REQUESTORID
            // =====================================================
            String requestorSQL =
                    "SELECT REQUESTORID " +
                    "FROM REQUESTOR " +
                    "WHERE NAME = ? AND PHONE = ?";

            requestorStmt = conn.prepareStatement(requestorSQL);
            requestorStmt.setString(1, form.getName());
            requestorStmt.setString(2, form.getPhone());

            requestorRs = requestorStmt.executeQuery();

            int requestorId;

            if (requestorRs.next()) {
                requestorId = requestorRs.getInt("REQUESTORID");
            } else {
                throw new Exception(
                        "ไม่พบข้อมูลผู้ยื่นคำร้องใน REQUESTOR กรุณาตรวจสอบ NAME / PHONE หรือเพิ่มข้อมูลใน REQUESTOR ก่อน"
                );
            }

            // =====================================================
            // STEP 2: INSERT REQUISITIONFORM
            // FORMID เป็น identity auto-generate
            // ห้าม insert FORMID เอง
            // =====================================================
            String formSQL =
                    "INSERT INTO REQUISITIONFORM " +
                    "(EMPID, TITLEFORM, DEADLINE, ASSIGN_SECID) " +
                    "VALUES (?, ?, TO_DATE(?, 'YYYY-MM-DD'), ?)";

            formStmt = conn.prepareStatement(
                    formSQL,
                    new String[]{"FORMID"}
            );

            // EMPID column ใช้ REQUESTORID ตาม FK schema ปัจจุบัน
            formStmt.setInt(1, requestorId);

            formStmt.setString(2, form.getRequestTopic());

            formStmt.setString(3, form.getDeadline());

            if (form.getSection() == null || form.getSection().trim().isEmpty()) {
                formStmt.setNull(4, Types.INTEGER);
            } else {
                formStmt.setInt(4, Integer.parseInt(form.getSection()));
            }

            int formInsertResult = formStmt.executeUpdate();

            if (formInsertResult == 0) {
                throw new Exception("ไม่สามารถบันทึกข้อมูลลง REQUISITIONFORM ได้");
            }

            // =====================================================
            // STEP 3: ดึง FORMID ที่ Oracle generate ให้
            // =====================================================
            formRs = formStmt.getGeneratedKeys();

            int formId;

            if (formRs.next()) {
                formId = formRs.getInt(1);
            } else {
                throw new Exception("ไม่สามารถดึง FORMID ที่สร้างใหม่ได้");
            }

            
            conn.commit();

        } catch (Exception e) {

            if (conn != null) {
                conn.rollback();
            }

            throw e;

        } finally {

            try {
                if (requestorRs != null) requestorRs.close();
            } catch (Exception ignored) {
            }

            try {
                if (formRs != null) formRs.close();
            } catch (Exception ignored) {
            }

            try {
                if (requestorStmt != null) requestorStmt.close();
            } catch (Exception ignored) {
            }

            try {
                if (formStmt != null) formStmt.close();
            } catch (Exception ignored) {
            }

            try {
                if (itemStmt != null) itemStmt.close();
            } catch (Exception ignored) {
            }

            try {
                if (conn != null) conn.close();
            } catch (Exception ignored) {
            }
        }
    }
}