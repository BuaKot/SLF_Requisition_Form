package com.slf.dao;

import com.slf.model.RequisitionForm;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;

public class OracleRequisitionDAO implements RequisitionDAO {

    @Override
    public void save(RequisitionForm form) throws Exception {

        Connection conn = null;
        PreparedStatement empStmt = null;
        PreparedStatement formStmt = null;

        ResultSet empRs = null;
        ResultSet formRs = null;

        try {
            // =====================================================
            // STEP 0: CONNECT DATABASE
            // =====================================================
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // =====================================================
            // STEP 1: หา EMPID จาก EMPLOYEE
            // ใช้ EMPNAME + PHONE เพื่อกันชื่อซ้ำ
            // (ต้องแก้ FK ของ REQUISITIONFORM ให้ชี้ EMPLOYEE ก่อน)
            // =====================================================
            String empSQL =
                    "SELECT EMPID " +
                    "FROM EMPLOYEE " +
                    "WHERE EMPNAME = ? AND PHONE = ?";

            empStmt = conn.prepareStatement(empSQL);

            empStmt.setString(1, form.getName());
            empStmt.setString(2, form.getPhone());

            empRs = empStmt.executeQuery();

            int empId;

            if (empRs.next()) {
                empId = empRs.getInt("EMPID");

                // Debug
                System.out.println("EMPID FOUND: " + empId);

            } else {
                throw new Exception(
                        "ไม่พบข้อมูลพนักงานใน EMPLOYEE กรุณาตรวจสอบชื่อและเบอร์โทร"
                );
            }

            // =====================================================
            // STEP 2: INSERT REQUISITIONFORM
            // FORMID เป็น auto-generated identity
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

            // FK ไป EMPLOYEE.EMPID
            formStmt.setInt(1, empId);

            // TITLEFORM
            formStmt.setString(2, form.getRequestTopic());

            // DEADLINE
            formStmt.setString(3, form.getDeadline());

            // ASSIGN_SECID
            if (form.getSection() == null || form.getSection().trim().isEmpty()) {
                formStmt.setNull(4, Types.INTEGER);
            } else {
                formStmt.setInt(4, Integer.parseInt(form.getSection()));
            }

            int insertResult = formStmt.executeUpdate();

            if (insertResult == 0) {
                throw new Exception("ไม่สามารถบันทึกข้อมูลลง REQUISITIONFORM ได้");
            }

            // =====================================================
            // STEP 3: GET GENERATED FORMID
            // =====================================================
            formRs = formStmt.getGeneratedKeys();

            int formId;

            if (formRs.next()) {
                formId = formRs.getInt(1);

                // Debug
                System.out.println("REQUISITIONFORM INSERT SUCCESS");
                System.out.println("FORMID: " + formId);

            } else {
                throw new Exception("ไม่สามารถดึง FORMID ที่สร้างใหม่ได้");
            }

            // =====================================================
            // STEP 4: COMMIT
            // =====================================================
            conn.commit();

        } catch (Exception e) {

            // =====================================================
            // ROLLBACK เมื่อเกิด error
            // =====================================================
            if (conn != null) {
                conn.rollback();
            }

            throw e;

        } finally {

            // =====================================================
            // CLOSE RESULTSETS
            // =====================================================
            try {
                if (empRs != null) {
                    empRs.close();
                }
            } catch (Exception ignored) {
            }

            try {
                if (formRs != null) {
                    formRs.close();
                }
            } catch (Exception ignored) {
            }

            // =====================================================
            // CLOSE STATEMENTS
            // =====================================================
            try {
                if (empStmt != null) {
                    empStmt.close();
                }
            } catch (Exception ignored) {
            }

            try {
                if (formStmt != null) {
                    formStmt.close();
                }
            } catch (Exception ignored) {
            }

            // =====================================================
            // CLOSE CONNECTION
            // =====================================================
            try {
                if (conn != null) {
                    conn.close();
                }
            } catch (Exception ignored) {
            }
        }
    }
}