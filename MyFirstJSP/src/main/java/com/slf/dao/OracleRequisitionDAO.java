package com.slf.dao;

import com.slf.model.RequisitionForm;
import com.slf.model.RequestItem;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;

public class OracleRequisitionDAO implements RequisitionDAO {

    @Override
    public void save(RequisitionForm form) throws Exception {
        Connection conn = null;
        PreparedStatement formStmt = null;
        PreparedStatement itemStmt = null;
        ResultSet formRs = null;

        try {
            // 1. Get connection and start transaction
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 2. Insert header into REQUISITIONFORM
            String formSQL =
                "INSERT INTO REQUISITIONFORM (EMPID, TITLEFORM, DEADLINE, ASSIGN_SECID) " +
                "VALUES (?, ?, TO_DATE(?, 'YYYY-MM-DD'), ?)";

            formStmt = conn.prepareStatement(formSQL, new String[]{"FORMID"});

            // Use the employee ID that was set by the controller (from session)
            formStmt.setInt(1, form.getEmpID());
            formStmt.setString(2, form.getRequestTopic());
            formStmt.setString(3, form.getDeadline());

            // ASSIGN_SECID – from the section dropdown (now a numeric SECID)
            if (form.getSection() == null || form.getSection().trim().isEmpty()) {
                formStmt.setNull(4, Types.INTEGER);
            } else {
                formStmt.setInt(4, Integer.parseInt(form.getSection().trim()));
            }

            int rows = formStmt.executeUpdate();
            if (rows == 0) {
                throw new Exception("ไม่สามารถบันทึกข้อมูลลง REQUISITIONFORM ได้");
            }

            // Get the generated FORMID
            formRs = formStmt.getGeneratedKeys();
            int formId;
            if (formRs.next()) {
                formId = formRs.getInt(1);
                System.out.println("REQUISITIONFORM INSERTED, FORMID=" + formId);
            } else {
                throw new Exception("ไม่สามารถดึง FORMID ที่สร้างใหม่ได้");
            }

            // 3. Insert each request item into REQUEST table
            if (form.getItems() != null && !form.getItems().isEmpty()) {
                String itemSQL =
                    "INSERT INTO REQUEST (TYPEID, FORMID, OTHERDETAILS_OR_PROGRAM, DETAILOBJECTIVE, CURRENTMETHOD) " +
                    "VALUES (?, ?, ?, ?, ?)";

                itemStmt = conn.prepareStatement(itemSQL);

                for (RequestItem item : form.getItems()) {
                    itemStmt.setInt(1, item.getRequestTypeId()); // numeric TYPEID
                    itemStmt.setInt(2, formId);

                    // Combine programName and otherRequest into the single column
                    String otherOrProgram = item.getProgramName();
                    if (otherOrProgram == null || otherOrProgram.trim().isEmpty()) {
                        otherOrProgram = item.getOtherRequest();
                    }
                    itemStmt.setString(3, otherOrProgram);
                    itemStmt.setString(4, item.getObjective());
                    itemStmt.setString(5, item.getCurrentMethod());
                    itemStmt.executeUpdate();
                }
                System.out.println("Items inserted: " + form.getItems().size());
            }

            // 4. Commit transaction
            conn.commit();

        } catch (Exception e) {
            // Rollback on any error
            if (conn != null) {
                conn.rollback();
            }
            throw e;

        } finally {
            // Close resources
            try { if (formRs != null) formRs.close(); } catch (Exception ignored) {}
            try { if (formStmt != null) formStmt.close(); } catch (Exception ignored) {}
            try { if (itemStmt != null) itemStmt.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }
}