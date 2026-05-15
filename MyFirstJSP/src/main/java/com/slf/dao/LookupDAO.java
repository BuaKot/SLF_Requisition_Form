package com.slf.dao;

import com.slf.model.*;
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

    public List<RequestType> getAllRequestTypes() throws SQLException {
        List<RequestType> list = new ArrayList<>();
        String sql = "SELECT TYPEID, TYPENAME FROM REQUESTTYPE ORDER BY TYPEID";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new RequestType(rs.getInt("TYPEID"), rs.getString("TYPENAME")));
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
                // Constructor: Department(int deptID, int deptHeadID, String deptName)
                // DEPTHEAD_EMPID may be NULL -> getInt returns 0, which is fine.
                list.add(new Department(
                    rs.getInt("DEPTID"),
                    rs.getString("DEPTHEAD_EMPID"),
                    rs.getString("DEPTNAME")
                ));
            }
        }
        return list;
    }

    public List<Section> getAllSections() throws SQLException {
        List<Section> list = new ArrayList<>();
        String sql = "SELECT SECID, DEPTID, SECNAME, SECTIONHEAD_EMPID FROM SECTION ORDER BY DEPTID, SECID";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                // Constructor: Section(int secID, String secName, int deptID, int sectionHeadEmpID)
                // Order of arguments in your constructor is (secID, secName, deptID, sectionHeadEmpID)!
                list.add(new Section(
                    rs.getInt("SECID"),
                    rs.getString("SECNAME"),
                    rs.getInt("DEPTID"),
                    rs.getString("SECTIONHEAD_EMPID") // 0 if NULL
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
    
}