package com.slf.dao;

import junit.framework.TestCase;

public class MemberDAOTest extends TestCase {

    public void testBuildMemberListSqlIncludesFiltersAndActiveStatusColumn() {
        String sql = MemberDAO.buildMemberListSql(true, true, true, true);

        assertTrue(sql.contains("LEFT JOIN SECTION s ON e.SECID = s.SECID"));
        assertTrue(sql.contains("LEFT JOIN DEPARTMENT d ON s.DEPTID = d.DEPTID"));
        assertTrue(sql.contains("WHERE 1=1"));
        assertTrue(sql.contains("AND s.SECID = ?"));
        assertTrue(sql.contains("AND e.POSITION = ?"));
        assertTrue(sql.contains("AND NVL(e.IS_ACTIVE, 1) = ?"));
        assertTrue(sql.contains("e.EMAIL"));
        assertTrue(sql.contains("ORDER BY e.EMPID"));
    }

    public void testBuildMemberListSqlOmitsStatusFilterWhenActiveColumnIsMissing() {
        String sql = MemberDAO.buildMemberListSql(false, false, false, true);

        assertFalse(sql.contains("e.IS_ACTIVE"));
        assertFalse(sql.contains("NVL(e.IS_ACTIVE"));
        assertTrue(sql.contains("ORDER BY e.EMPID"));
    }

    public void testDefaultPositionsIncludeRolesEvenBeforeTheyExistInEmployeeTable() {
        assertTrue(MemberDAO.defaultPositions().contains("Admin"));
        assertTrue(MemberDAO.defaultPositions().contains("IT Director"));
        assertTrue(MemberDAO.defaultPositions().contains("Infrastructure"));
        assertTrue(MemberDAO.defaultPositions().contains("Cyber Security"));
        assertTrue(MemberDAO.defaultPositions().contains("IT Planning"));
    }
}
