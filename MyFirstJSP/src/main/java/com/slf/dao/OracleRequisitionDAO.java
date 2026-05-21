package com.slf.dao;

import com.slf.model.RequisitionForm;
import com.slf.model.RequestItem;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.List;

public class OracleRequisitionDAO implements RequisitionDAO {
    private int getServerAccessTypeId(Connection conn) throws SQLException {
        String sql = "SELECT TYPEID FROM REQUESTTYPE WHERE TYPENAME = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "ขอใช้สิทธิ์เก็บข้อมูล"); // the exact Thai name
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("TYPEID");
                }
            }
        }
        return -1; // not found
    }
    private void setPermissionValues(PreparedStatement ps, List<String> permissions) throws SQLException {
        boolean fullControl = permissions != null && permissions.contains("Full control");
        boolean modify = permissions != null && permissions.contains("Modify");
        boolean readExecute = permissions != null && permissions.contains("Read & Execute");
        boolean read = permissions != null && permissions.contains("Read");
        boolean write = permissions != null && permissions.contains("Write");

        ps.setInt(4, fullControl ? 1 : 0);
        ps.setInt(5, modify ? 1 : 0);
        ps.setInt(6, readExecute ? 1 : 0);
        ps.setInt(7, read ? 1 : 0);
        ps.setInt(8, write ? 1 : 0);
    }

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
            // ---- Insert server permissions for items that are server access requests ----
            int serverAccessTypeId = getServerAccessTypeId(conn);
            if (serverAccessTypeId != -1 && form.getItems() != null) {
                String permSQL =
                    "INSERT INTO PERMISSIONDETAILS " +
                    "(FORMID, ISROOT, PATH, HASFULLCONTROL, HASMODIFY, HASREADEXECUTE, HASREAD, HASWRITE) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

                try (PreparedStatement permStmt = conn.prepareStatement(permSQL)) {
                    for (RequestItem item : form.getItems()) {
                        if (item.getRequestTypeId() != serverAccessTypeId) continue;
                        if (item.getServerName() == null || item.getServerName().trim().isEmpty()) continue;

                        // Build base path: server name + folder
                        String serverName = item.getServerName().trim();
                        String folder = item.getServerFolder();
                        if (folder == null) folder = "";
                        String basePath = "\\\\" + serverName + "\\" + folder.replace("/", "\\");

                        // 1) Main folder (ISROOT = 1)
                        permStmt.setInt(1, formId);
                        permStmt.setInt(2, 1);  // ISROOT = 1 (main folder)
                        permStmt.setString(3, basePath);
                        setPermissionValues(permStmt, item.getFolderPermissions());
                        permStmt.executeUpdate();

                        // 2) Sub folder (ISROOT = 0) – only if subFolder is not empty
                        String subFolder = item.getSubFolder();
                        if (subFolder != null && !subFolder.trim().isEmpty()) {
                            String subPath = basePath + "\\" + subFolder.trim().replace("/", "\\");
                            permStmt.setInt(1, formId);
                            permStmt.setInt(2, 0);  // ISROOT = 0
                            permStmt.setString(3, subPath);
                            setPermissionValues(permStmt, item.getSubFolderPermissions());
                            permStmt.executeUpdate();
                        }
                    }
                }
            }
            String approvalSQL =
                "INSERT INTO APPROVALINFO (STATE_STEP, FORMID, REVIEWER_EMPID) " +
                "VALUES (0, ?, ?)";

            try (PreparedStatement approvalStmt = conn.prepareStatement(approvalSQL)) {
                approvalStmt.setInt(1, formId);
                // Set reviewer to the employee who submitted the form (the requestor)
                approvalStmt.setInt(2, form.getEmpID());
                approvalStmt.executeUpdate();
                System.out.println("APPROVALINFO row inserted for FORMID=" + formId + ", STATE_STEP=0");
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