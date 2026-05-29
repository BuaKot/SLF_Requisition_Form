package com.slf.dao;

import com.slf.model.*;
import com.slf.util.PasswordUtil;

import java.sql.*;
import java.util.*;

public class LookupDAO {
    
    public List<Employee> getAllEmployees() throws SQLException {
        List<Employee> list = new ArrayList<>();
        String sql = "SELECT EMPID, EMPNAME, POSITION, SECID, PHONE FROM EMPLOYEE ORDER BY EMPID";
        try (Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Employee emp = new Employee();
                emp.setEmpId(rs.getInt("EMPID"));
                emp.setEmpName(rs.getString("EMPNAME"));
                emp.setPosition(rs.getString("POSITION"));
                emp.setSecId(rs.getInt("SECID"));
                emp.setPhone(rs.getString("PHONE"));
                list.add(emp);
            }
        }
        return list;
    }

    /**
     * Returns all request types with the destination IT section (SECID) and its name.
     * Requires RequestType to have a constructor (int typeId, String typeName, int secId, String secName)
     * or the corresponding setters, plus getters getSecId() and getSecName().
     */
    public List<RequestType> getAllRequestTypes() throws SQLException {
        List<RequestType> list = new ArrayList<>();
        String sql =
            "SELECT rt.TYPEID, rt.TYPENAME, rt.SECID, s.SECNAME " +
            "FROM REQUESTTYPE rt " +
            "LEFT JOIN SECTION s ON rt.SECID = s.SECID " +
            "ORDER BY rt.TYPEID";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new RequestType(
                    rs.getInt("TYPEID"),
                    rs.getString("TYPENAME"),
                    rs.getInt("SECID"),
                    rs.getString("SECNAME")
                ));
            }
        }
        return list;
    }

    public List<Department> getAllDepartments() throws SQLException {
        List<Department> list = new ArrayList<>();
        String sql = "SELECT DEPTID, DEPTHEAD_EMPID, DEPTNAME FROM DEPARTMENT ORDER BY DEPTID";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Department(
                    rs.getInt("DEPTID"),
                    rs.getString("DEPTHEAD_EMPID"),
                    rs.getString("DEPTNAME")
                ));
            }
        }
        return list;
    }

    public Department getDepartmentById(int deptId) throws SQLException {
        String sql = "SELECT DEPTID, DEPTHEAD_EMPID, DEPTNAME FROM DEPARTMENT WHERE DEPTID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, deptId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Department(
                        rs.getInt("DEPTID"),
                        rs.getString("DEPTHEAD_EMPID"),
                        rs.getString("DEPTNAME")
                    );
                }
            }
        }
        return null;
    }

    public List<Section> getAllSections() throws SQLException {
        List<Section> list = new ArrayList<>();
        String sql = "SELECT SECID, DEPTID, SECNAME, SECTIONHEAD_EMPID FROM SECTION ORDER BY DEPTID, SECID";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Section(
                    rs.getInt("SECID"),
                    rs.getString("SECNAME"),
                    rs.getInt("DEPTID"),
                    rs.getString("SECTIONHEAD_EMPID")
                ));
            }
        }
        return list;
    }

    public Employee findEmployeeById(int empId) throws SQLException {
        String sql = "SELECT EMPID, EMPNAME, POSITION, SECID, PHONE FROM EMPLOYEE WHERE EMPID = ?";
        try (Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, empId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Employee emp = new Employee();
                    emp.setEmpId(rs.getInt("EMPID"));
                    emp.setEmpName(rs.getString("EMPNAME"));
                    emp.setPosition(rs.getString("POSITION"));
                    emp.setSecId(rs.getInt("SECID"));
                    emp.setPhone(rs.getString("PHONE"));
                    return emp;
                }
            }
        }
        return null;
    }

    public Section getSectionById(int secId) throws SQLException {
        String sql = "SELECT SECID, DEPTID, SECNAME, SECTIONHEAD_EMPID FROM SECTION WHERE SECID = ?";
        try (Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, secId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Section(
                        rs.getInt("SECID"),
                        rs.getString("SECNAME"),
                        rs.getInt("DEPTID"),
                        rs.getString("SECTIONHEAD_EMPID")
                    );
                }
            }
        }
        return null;
    }

    // Correctly named password check (fixed typo)
    public Employee findEmployeeByEmpIdAndPassword(int empId, String password) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            boolean hasActiveColumn = hasColumn(conn, "EMPLOYEE", "IS_ACTIVE");
            String sql = hasActiveColumn
                ? "SELECT EMPID, EMPNAME, POSITION, SECID, PHONE, PASSWORD FROM EMPLOYEE WHERE EMPID = ? AND NVL(IS_ACTIVE, 1) = 1"
                : "SELECT EMPID, EMPNAME, POSITION, SECID, PHONE, PASSWORD FROM EMPLOYEE WHERE EMPID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, empId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        String storedPassword = rs.getString("PASSWORD");
                        // Use the utility to check
                        if (PasswordUtil.check(password, storedPassword)) {
                            Employee emp = new Employee();
                            emp.setEmpId(rs.getInt("EMPID"));
                            emp.setEmpName(rs.getString("EMPNAME"));
                            emp.setPosition(rs.getString("POSITION"));
                            emp.setSecId(rs.getInt("SECID"));
                            emp.setPhone(rs.getString("PHONE"));
                            return emp;
                        }
                    }
                }
            }
        }
        return null;
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
