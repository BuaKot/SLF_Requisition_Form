package com.slf.dao;

import com.slf.model.TechnicalApprovalForm;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;

public class TechnicalApprovalDAO {
    public List<TechnicalApprovalForm> getAllForms() throws SQLException {
        List<TechnicalApprovalForm> forms = new ArrayList<>();
        // zennnne แก้
        // แก้ SQL ที่อ้าง column ผิด 3 ชื่อ: REQUESTID/APPROVALSTATUS ไม่มีใน APPROVALINFO
        // เปลี่ยนเป็น CTE ที่ใช้ FORMID, STATE_STEP (column จริง) + กรอง STATE_STEP = 1
        String sql =
            "WITH latest_step AS ( " +
            "    SELECT FORMID, STATE_STEP, " +
            "           ROW_NUMBER() OVER (PARTITION BY FORMID ORDER BY APPROVALID DESC) AS RN " +
            "    FROM APPROVALINFO " +
            ") " +
            "SELECT rf.FORMID, e.EMPNAME, d.DEPTNAME, s.SECNAME, " +
            "       rf.DEADLINE, rf.TITLEFORM, ls.STATE_STEP " +
            "FROM REQUISITIONFORM rf " +
            "JOIN latest_step ls ON ls.FORMID = rf.FORMID AND ls.RN = 1 " +
            "LEFT JOIN EMPLOYEE e ON rf.EMPID = e.EMPID " +
            "LEFT JOIN SECTION s ON rf.ASSIGN_SECID = s.SECID " +
            "LEFT JOIN DEPARTMENT d ON s.DEPTID = d.DEPTID " +
            "WHERE ls.STATE_STEP = 1 " +
            "ORDER BY rf.DEADLINE ASC NULLS LAST, rf.FORMID DESC";
        // zennnne แก้

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                TechnicalApprovalForm form = new TechnicalApprovalForm();
                form.setFormId(rs.getInt("FORMID"));
                form.setRequesterName(defaultText(rs.getString("EMPNAME")));
                form.setDepartmentName(defaultText(rs.getString("DEPTNAME")));
                form.setSectionName(defaultText(rs.getString("SECNAME")));
                form.setDeadline(formatThaiDate(rs.getDate("DEADLINE")));
                form.setTitleForm(defaultText(rs.getString("TITLEFORM")));
                form.setApprovalStatus(defaultStatus(rs.getString("STATE_STEP"))); // zennnne แก้
                forms.add(form);
            }
        }
        return forms;
    }

    private String defaultText(String value) {
        return (value == null || value.trim().isEmpty()) ? "-" : value;
    }

    private String defaultStatus(String value) {
        return (value == null || value.trim().isEmpty()) ? "Pending" : value;
    }

    private String formatThaiDate(java.util.Date date) {
        if (date == null) return "-";
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(date);
        calendar.add(Calendar.YEAR, 543);
        return new SimpleDateFormat("dd/MM/yyyy").format(calendar.getTime());
    }
}