package com.slf.controller;

import com.slf.dao.DBConnection;
import com.lowagie.text.*;
import com.lowagie.text.pdf.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.*;
import java.sql.*;
import java.util.*;

@WebServlet("/exportPDF")
public class ExportPDFServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // ---- Session check ----
        HttpSession session = request.getSession();
        Integer empId = (Integer) session.getAttribute("loggedInEmpId");
        if (empId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String formIdStr = request.getParameter("formId");
        if (formIdStr == null || formIdStr.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing formId");
            return;
        }
        int formId = Integer.parseInt(formIdStr.trim());

        // ---- Fetch data ----
        String empName = "", sectionName = "", departmentName = "", phone = "";
        String reqDate = "", deadline = "", titleForm = "";
        java.util.List<String[]> items = new ArrayList<>();       // {typeName, program/other, objective, currentMethod}
        java.util.List<String[]> permissions = new ArrayList<>(); // {server, folder, perms}

        try (Connection conn = DBConnection.getConnection()) {
            // Header
            String headerSql =
                "SELECT e.EMPNAME, e.PHONE, s.SECNAME, d.DEPTNAME, " +
                "TO_CHAR(r.REQUESTDATE,'DD/MM/YYYY') AS REQDATE, " +
                "TO_CHAR(r.DEADLINE,'DD/MM/YYYY') AS DDL, r.TITLEFORM " +
                "FROM REQUISITIONFORM r " +
                "LEFT JOIN EMPLOYEE e ON r.EMPID = e.EMPID " +
                "LEFT JOIN SECTION s ON e.SECID = s.SECID " +
                "LEFT JOIN DEPARTMENT d ON s.DEPTID = d.DEPTID " +
                "WHERE r.FORMID = ?";
            try (PreparedStatement ps = conn.prepareStatement(headerSql)) {
                ps.setInt(1, formId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        empName = nvl(rs.getString("EMPNAME"));
                        phone = nvl(rs.getString("PHONE"));
                        sectionName = nvl(rs.getString("SECNAME"));
                        departmentName = nvl(rs.getString("DEPTNAME"));
                        reqDate = nvl(rs.getString("REQDATE"));
                        deadline = nvl(rs.getString("DDL"));
                        titleForm = nvl(rs.getString("TITLEFORM"));
                    } else {
                        response.sendError(HttpServletResponse.SC_NOT_FOUND, "Form not found");
                        return;
                    }
                }
            }

            // Items
            String itemSql =
                "SELECT rt.TYPENAME, r.OTHERDETAILS_OR_PROGRAM, " +
                "r.DETAILOBJECTIVE, r.CURRENTMETHOD " +
                "FROM REQUEST r " +
                "JOIN REQUESTTYPE rt ON r.TYPEID = rt.TYPEID " +
                "WHERE r.FORMID = ? ORDER BY r.REQUESTID";
            try (PreparedStatement ps = conn.prepareStatement(itemSql)) {
                ps.setInt(1, formId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        items.add(new String[]{
                            nvl(rs.getString("TYPENAME")),
                            nvl(rs.getString("OTHERDETAILS_OR_PROGRAM")),
                            nvl(rs.getString("DETAILOBJECTIVE")),
                            nvl(rs.getString("CURRENTMETHOD"))
                        });
                    }
                }
            }

            // Permissions
            String permSql =
                "SELECT PATH, HASFULLCONTROL, HASMODIFY, HASREADEXECUTE, HASREAD, HASWRITE " +
                "FROM PERMISSIONDETAILS WHERE FORMID = ? ORDER BY ISROOT DESC";
            try (PreparedStatement ps = conn.prepareStatement(permSql)) {
                ps.setInt(1, formId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String path = nvl(rs.getString("PATH"));
                        String server = "", folder = "";
                        if (path.startsWith("\\\\")) {
                            String noPrefix = path.substring(2);
                            int idx = noPrefix.indexOf("\\");
                            if (idx > 0) {
                                server = noPrefix.substring(0, idx);
                                folder = noPrefix.substring(idx + 1);
                            } else {
                                server = noPrefix;
                            }
                        }
                        StringBuilder permStr = new StringBuilder();
                        if (rs.getInt("HASFULLCONTROL") == 1) permStr.append("Full, ");
                        if (rs.getInt("HASMODIFY") == 1) permStr.append("Modify, ");
                        if (rs.getInt("HASREADEXECUTE") == 1) permStr.append("Read&Exec, ");
                        if (rs.getInt("HASREAD") == 1) permStr.append("Read, ");
                        if (rs.getInt("HASWRITE") == 1) permStr.append("Write, ");
                        String perms = permStr.toString().replaceAll(", $", "");
                        permissions.add(new String[]{server, folder, perms});
                    }
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        }

        // ---- Build PDF ----
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition",
                "attachment; filename=\"Requisition_" + formId + ".pdf\"");

        try (OutputStream out = response.getOutputStream()) {
            Document document = new Document(PageSize.A4, 36, 36, 50, 50);
            PdfWriter.getInstance(document, out);
            document.open();

            // Load Thai font
            String fontPath = getServletContext().getRealPath("/WEB-INF/classes/fonts/Sarabun-Regular.ttf");
            BaseFont baseFont = BaseFont.createFont(fontPath, BaseFont.IDENTITY_H, BaseFont.EMBEDDED);
            Font thaiFont = new Font(baseFont, 12);
            Font thaiBold = new Font(baseFont, 12, Font.BOLD);
            Font titleFont = new Font(baseFont, 16, Font.BOLD);

            // Title
            Paragraph title = new Paragraph("ใบขอให้ดำเนินการ (Requisition Form)\n\n", titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            document.add(title);

            // Header fields
            PdfPTable headerTable = new PdfPTable(2);
            headerTable.setWidthPercentage(100);
            headerTable.setSpacingBefore(10);
            headerTable.setSpacingAfter(10);
            addRow(headerTable, "ชื่อ-นามสกุล:", empName, thaiBold, thaiFont);
            addRow(headerTable, "ส่วน:", sectionName, thaiBold, thaiFont);
            addRow(headerTable, "ฝ่าย:", departmentName, thaiBold, thaiFont);
            addRow(headerTable, "เบอร์ต่อ:", phone, thaiBold, thaiFont);
            addRow(headerTable, "วันที่:", reqDate, thaiBold, thaiFont);
            addRow(headerTable, "Deadline:", deadline, thaiBold, thaiFont);
            addRow(headerTable, "หัวข้อ:", titleForm, thaiBold, thaiFont);
            document.add(headerTable);

            // Request items
            for (int i = 0; i < items.size(); i++) {
                String[] item = items.get(i);
                Paragraph itemTitle = new Paragraph("คำขอที่ " + (i + 1), thaiBold);
                itemTitle.setSpacingBefore(10);
                document.add(itemTitle);

                PdfPTable itemTable = new PdfPTable(1);
                itemTable.setWidthPercentage(100);
                addCell(itemTable, "ประเภท: " + item[0], thaiFont);
                if (!item[1].isEmpty()) addCell(itemTable, "รายละเอียด/โปรแกรม: " + item[1], thaiFont);
                addCell(itemTable, "วัตถุประสงค์: " + item[2], thaiFont);
                if (!item[3].isEmpty()) addCell(itemTable, "วิธีการปัจจุบัน: " + item[3], thaiFont);
                document.add(itemTable);
            }

            // Permissions
            if (!permissions.isEmpty()) {
                Paragraph permHead = new Paragraph("รายละเอียดการขอใช้สิทธิ์เก็บข้อมูล", thaiBold);
                permHead.setSpacingBefore(10);
                document.add(permHead);

                PdfPTable permTable = new PdfPTable(3);
                permTable.setWidthPercentage(100);
                permTable.addCell(new PdfPCell(new Phrase("Server", thaiBold)));
                permTable.addCell(new PdfPCell(new Phrase("Folder", thaiBold)));
                permTable.addCell(new PdfPCell(new Phrase("สิทธิ์", thaiBold)));
                for (String[] p : permissions) {
                    permTable.addCell(new PdfPCell(new Phrase(p[0], thaiFont)));
                    permTable.addCell(new PdfPCell(new Phrase(p[1], thaiFont)));
                    permTable.addCell(new PdfPCell(new Phrase(p[2], thaiFont)));
                }
                document.add(permTable);
            }

            document.close();
        } catch (DocumentException e) {
            throw new IOException(e);
        }
    }

    private void addRow(PdfPTable table, String label, String value, Font labelFont, Font valueFont) {
        table.addCell(new PdfPCell(new Phrase(label, labelFont)));
        table.addCell(new PdfPCell(new Phrase(value, valueFont)));
    }

    private void addCell(PdfPTable table, String text, Font font) {
        table.addCell(new PdfPCell(new Phrase(text, font)));
    }

    private String nvl(String s) {
        return (s == null || s.trim().isEmpty()) ? "-" : s.trim();
    }
}