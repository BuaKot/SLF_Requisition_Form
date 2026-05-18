package com.slf.dao;

import com.slf.model.TechnicalApprovalForm;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;

public class TechnicalApprovalDAO {
    public List<TechnicalApprovalForm> getAllForms() throws SQLException {
        List<TechnicalApprovalForm> forms = new ArrayList<>();
        String sql =
            "SELECT rf.FORMID, e.EMPNAME, d.DEPTNAME, s.SECNAME, " +
            "       rf.DEADLINE, rf.TITLEFORM, " +
            "       COALESCE(latest_approval.APPROVALSTATUS, rf.STATUS) AS APPROVALSTATUS " +
            "FROM REQUISITIONFORM rf " +
            "LEFT JOIN EMPLOYEE e ON rf.EMPID = e.EMPID " +
            "LEFT JOIN SECTION s ON rf.ASSIGN_SECID = s.SECID " +
            "LEFT JOIN DEPARTMENT d ON s.DEPTID = d.DEPTID " +
            "LEFT JOIN ( " +
            "    SELECT FORMID, APPROVALSTATUS " +
            "    FROM ( " +
            "        SELECT r.FORMID, ai.APPROVALSTATUS, " +
            "               ROW_NUMBER() OVER (PARTITION BY r.FORMID " +
            "               ORDER BY COALESCE(ai.APPROVED_DATE, CAST(ai.APPROVALDATE AS TIMESTAMP)) DESC NULLS LAST, ai.APPROVALID DESC) AS RN " +
            "        FROM REQUEST r " +
            "        JOIN APPROVALINFO ai ON ai.REQUESTID = r.REQUESTID " +
            "    ) WHERE RN = 1 " +
            ") latest_approval ON latest_approval.FORMID = rf.FORMID " +
            "ORDER BY rf.DEADLINE ASC NULLS LAST, rf.FORMID DESC";

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
                form.setApprovalStatus(defaultStatus(rs.getString("APPROVALSTATUS")));
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