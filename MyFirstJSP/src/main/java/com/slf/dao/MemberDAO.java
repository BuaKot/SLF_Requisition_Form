package com.slf.dao;

import com.slf.model.MemberProfile;
import com.slf.model.Section;
import com.slf.util.PasswordUtil;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

public class MemberDAO {

    public List<MemberProfile> findMembers(String sectionId, String position, String status) throws SQLException {
        List<MemberProfile> members = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection()) {
            boolean hasActiveColumn = hasColumn(conn, "EMPLOYEE", "IS_ACTIVE");
            if (!hasActiveColumn && "inactive".equalsIgnoreCase(status)) {
                return members;
            }
            boolean filterSection = hasText(sectionId);
            boolean filterPosition = hasText(position);
            boolean filterStatus = hasText(status) && !"all".equalsIgnoreCase(status);

            String sql = buildMemberListSql(hasActiveColumn, filterSection, filterPosition, filterStatus);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                int index = 1;
                if (filterSection) {
                    ps.setInt(index++, Integer.parseInt(sectionId));
                }
                if (filterPosition) {
                    ps.setString(index++, position);
                }
                if (hasActiveColumn && filterStatus) {
                    ps.setInt(index++, "inactive".equalsIgnoreCase(status) ? 0 : 1);
                }

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        MemberProfile member = new MemberProfile();
                        member.setEmpId(rs.getInt("EMPID"));
                        member.setEmpName(rs.getString("EMPNAME"));
                        member.setPosition(rs.getString("POSITION"));
                        member.setSecId(rs.getInt("SECID"));
                        member.setPhone(rs.getString("PHONE"));
                        member.setSecName(rs.getString("SECNAME"));
                        member.setDeptId(rs.getInt("DEPTID"));
                        member.setDeptName(rs.getString("DEPTNAME"));
                        member.setActive(rs.getInt("IS_ACTIVE") == 1);
                        members.add(member);
                    }
                }
            }
        }
        return members;
    }

    public MemberProfile findMemberById(int empId) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            boolean hasActiveColumn = hasColumn(conn, "EMPLOYEE", "IS_ACTIVE");
            String activeSelect = hasActiveColumn ? "NVL(e.IS_ACTIVE, 1) AS IS_ACTIVE" : "1 AS IS_ACTIVE";
            String sql =
                "SELECT e.EMPID, e.EMPNAME, e.POSITION, e.SECID, e.PHONE, " +
                "s.SECNAME, d.DEPTID, d.DEPTNAME, " + activeSelect + " " +
                "FROM EMPLOYEE e " +
                "LEFT JOIN SECTION s ON e.SECID = s.SECID " +
                "LEFT JOIN DEPARTMENT d ON s.DEPTID = d.DEPTID " +
                "WHERE e.EMPID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, empId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        MemberProfile member = new MemberProfile();
                        member.setEmpId(rs.getInt("EMPID"));
                        member.setEmpName(rs.getString("EMPNAME"));
                        member.setPosition(rs.getString("POSITION"));
                        member.setSecId(rs.getInt("SECID"));
                        member.setPhone(rs.getString("PHONE"));
                        member.setSecName(rs.getString("SECNAME"));
                        member.setDeptId(rs.getInt("DEPTID"));
                        member.setDeptName(rs.getString("DEPTNAME"));
                        member.setActive(rs.getInt("IS_ACTIVE") == 1);
                        return member;
                    }
                }
            }
        }
        return null;
    }

    public List<Section> getSections() throws SQLException {
        return new LookupDAO().getAllSections();
    }

    public List<String> getPositions() throws SQLException {
        Set<String> positions = new LinkedHashSet<>(defaultPositions());
        String sql = "SELECT DISTINCT POSITION FROM EMPLOYEE WHERE POSITION IS NOT NULL ORDER BY POSITION";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                positions.add(rs.getString("POSITION"));
            }
        }
        return new ArrayList<>(positions);
    }

    static List<String> defaultPositions() {
        return Arrays.asList(
            "Admin",
            "Director",
            "IT Director",
            "Technical",
            "Development",
            "Infrastructure",
            "Data",
            "Cyber Security",
            "Research",
            "IT Planning"
        );
    }

    public void addMember(int empId, String empName, String position, int secId, String phone, String password, boolean active)
            throws SQLException {
        if (!hasText(password)) {
            throw new SQLException("Password is required for a new member.");
        }

        try (Connection conn = DBConnection.getConnection()) {
            boolean hasActiveColumn = hasColumn(conn, "EMPLOYEE", "IS_ACTIVE");
            String sql = hasActiveColumn
                ? "INSERT INTO EMPLOYEE (EMPID, EMPNAME, POSITION, SECID, PHONE, PASSWORD, IS_ACTIVE) VALUES (?, ?, ?, ?, ?, ?, ?)"
                : "INSERT INTO EMPLOYEE (EMPID, EMPNAME, POSITION, SECID, PHONE, PASSWORD) VALUES (?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, empId);
                ps.setString(2, empName);
                ps.setString(3, position);
                ps.setInt(4, secId);
                ps.setString(5, phone);
                ps.setString(6, PasswordUtil.hash(password));
                if (hasActiveColumn) {
                    ps.setInt(7, active ? 1 : 0);
                }
                ps.executeUpdate();
            }
        }
    }

    public void updateMember(int empId, String empName, String position, int secId, String phone, String password, boolean active)
            throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            boolean hasActiveColumn = hasColumn(conn, "EMPLOYEE", "IS_ACTIVE");
            boolean updatePassword = hasText(password);
            StringBuilder sql = new StringBuilder(
                "UPDATE EMPLOYEE SET EMPNAME = ?, POSITION = ?, SECID = ?, PHONE = ?"
            );
            if (updatePassword) {
                sql.append(", PASSWORD = ?");
            }
            if (hasActiveColumn) {
                sql.append(", IS_ACTIVE = ?");
            }
            sql.append(" WHERE EMPID = ?");

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                int index = 1;
                ps.setString(index++, empName);
                ps.setString(index++, position);
                ps.setInt(index++, secId);
                ps.setString(index++, phone);
                if (updatePassword) {
                    ps.setString(index++, PasswordUtil.hash(password));
                }
                if (hasActiveColumn) {
                    ps.setInt(index++, active ? 1 : 0);
                }
                ps.setInt(index, empId);
                ps.executeUpdate();
            }
        }
    }

    public void setActive(int empId, boolean active) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            if (!hasColumn(conn, "EMPLOYEE", "IS_ACTIVE")) {
                throw new SQLException("EMPLOYEE.IS_ACTIVE column is required to disable or enable members.");
            }
            try (PreparedStatement ps = conn.prepareStatement("UPDATE EMPLOYEE SET IS_ACTIVE = ? WHERE EMPID = ?")) {
                ps.setInt(1, active ? 1 : 0);
                ps.setInt(2, empId);
                ps.executeUpdate();
            }
        }
    }

    static String buildMemberListSql(boolean hasActiveColumn, boolean filterSection, boolean filterPosition, boolean filterStatus) {
        String activeSelect = hasActiveColumn ? "NVL(e.IS_ACTIVE, 1) AS IS_ACTIVE" : "1 AS IS_ACTIVE";
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT e.EMPID, e.EMPNAME, e.POSITION, e.SECID, e.PHONE, ");
        sql.append("s.SECNAME, d.DEPTID, d.DEPTNAME, ").append(activeSelect).append(" ");
        sql.append("FROM EMPLOYEE e ");
        sql.append("LEFT JOIN SECTION s ON e.SECID = s.SECID ");
        sql.append("LEFT JOIN DEPARTMENT d ON s.DEPTID = d.DEPTID ");
        sql.append("WHERE 1=1 ");
        if (filterSection) {
            sql.append("AND s.SECID = ? ");
        }
        if (filterPosition) {
            sql.append("AND e.POSITION = ? ");
        }
        if (hasActiveColumn && filterStatus) {
            sql.append("AND NVL(e.IS_ACTIVE, 1) = ? ");
        }
        sql.append("ORDER BY e.EMPID");
        return sql.toString();
    }

    private static boolean hasText(String value) {
        return value != null && value.trim().length() > 0;
    }

    private static boolean hasColumn(Connection conn, String tableName, String columnName) throws SQLException {
        DatabaseMetaData metaData = conn.getMetaData();
        try (ResultSet columns = metaData.getColumns(null, null, tableName, columnName)) {
            if (columns.next()) {
                return true;
            }
        }
        try (ResultSet columns = metaData.getColumns(null, conn.getSchema(), tableName, columnName)) {
            return columns.next();
        }
    }
}
