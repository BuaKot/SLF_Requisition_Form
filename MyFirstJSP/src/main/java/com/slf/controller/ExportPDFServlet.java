package com.slf.controller;

import com.slf.dao.DBConnection;
import org.xhtmlrenderer.pdf.ITextRenderer;

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
        
        // ---- 1. Session and Security Check ----
        HttpSession session = request.getSession();
        Integer loggedInEmpId = (Integer) session.getAttribute("loggedInEmpId");
        if (loggedInEmpId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String formIdStr = request.getParameter("formId");
        if (formIdStr == null || formIdStr.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing formId");
            return;
        }
        int formId = Integer.parseInt(formIdStr.trim());

        // ---- 2. Data Structures (Mirroring your JSP layout) ----
        String fullName = "", sectionName = "", departmentName = "", phone = "";
        String requestDate = "", deadline = "", requestTitle = "";
        boolean found = false;

        java.util.List<java.util.Map<String, String>> items = new java.util.ArrayList<>();
        java.util.List<java.util.Map<String, Object>> permissions = new java.util.ArrayList<>();
        java.util.Map<String, java.util.Map<String, String>> approvalSections = new java.util.LinkedHashMap<>();

        // Match standby configurations from your detail.jsp
        approvalSections.put("director", createStandbyApproval("ผู้อำนวยการฝ่าย"));
        approvalSections.put("technical", createStandbyApproval("Technical"));
        approvalSections.put("itDirector", createStandbyApproval("ผู้อำนวยการฝ่ายเทคโนโลยีสารสนเทศ"));
        approvalSections.put("process", createStandbyApproval("ผู้ดำเนินการแก้ไข"));

        // ---- 3. Database Retrieval Pipeline ----
        try (Connection conn = DBConnection.getConnection()) {
            
            // Query A: Header Blocks
            String headerSQL =
                "SELECT E.EMPNAME, E.PHONE, S.SECNAME, D.DEPTNAME, " +
                "RF.TITLEFORM, TO_CHAR(RF.REQUESTDATE, 'DD/MM/YYYY') AS REQDATE, " +
                "TO_CHAR(RF.DEADLINE, 'DD/MM/YYYY') AS DDL " +
                "FROM REQUISITIONFORM RF " +
                "JOIN EMPLOYEE E ON RF.EMPID = E.EMPID " +
                "LEFT JOIN SECTION S ON E.SECID = S.SECID " +
                "LEFT JOIN DEPARTMENT D ON S.DEPTID = D.DEPTID " +
                "WHERE RF.FORMID = ?";
            try (PreparedStatement ps = conn.prepareStatement(headerSQL)) {
                ps.setInt(1, formId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        found = true;
                        fullName = nvl(rs.getString("EMPNAME"));
                        phone = nvl(rs.getString("PHONE"));
                        sectionName = nvl(rs.getString("SECNAME"));
                        departmentName = nvl(rs.getString("DEPTNAME"));
                        requestTitle = nvl(rs.getString("TITLEFORM"));
                        requestDate = nvl(rs.getString("REQDATE"));
                        deadline = nvl(rs.getString("DDL"));
                    } else {
                        response.sendError(HttpServletResponse.SC_NOT_FOUND, "Form reference profile missing");
                        return;
                    }
                }
            }

            if (found) {
                // Query B: Request Items Matrix Array
                String itemsSQL =
                    "SELECT RT.TYPENAME, R.TYPEID, R.OTHERDETAILS_OR_PROGRAM, " +
                    "R.DETAILOBJECTIVE, R.CURRENTMETHOD " +
                    "FROM REQUEST R " +
                    "JOIN REQUESTTYPE RT ON R.TYPEID = RT.TYPEID " +
                    "WHERE R.FORMID = ? ORDER BY R.REQUESTID";
                try (PreparedStatement ps = conn.prepareStatement(itemsSQL)) {
                    ps.setInt(1, formId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            java.util.Map<String, String> item = new java.util.HashMap<>();
                            item.put("typeName", rs.getString("TYPENAME"));
                            item.put("typeId", String.valueOf(rs.getInt("TYPEID")));
                            item.put("programOrOther", nvl(rs.getString("OTHERDETAILS_OR_PROGRAM")));
                            item.put("objective", nvl(rs.getString("DETAILOBJECTIVE")));
                            item.put("currentMethod", nvl(rs.getString("CURRENTMETHOD")));
                            items.add(item);
                        }
                    }
                }

                // Query C: Storage Path Access Rules List
                String permSQL = "SELECT ISROOT, PATH, HASFULLCONTROL, HASMODIFY, " +
                                 "HASREADEXECUTE, HASREAD, HASWRITE " +
                                 "FROM PERMISSIONDETAILS WHERE FORMID = ? ORDER BY ISROOT DESC, PATH";
                try (PreparedStatement ps = conn.prepareStatement(permSQL)) {
                    ps.setInt(1, formId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            java.util.Map<String, Object> perm = new java.util.HashMap<>();
                            perm.put("isRoot", rs.getInt("ISROOT"));
                            perm.put("path", rs.getString("PATH"));
                            perm.put("full", rs.getInt("HASFULLCONTROL"));
                            perm.put("modify", rs.getInt("HASMODIFY"));
                            perm.put("readExec", rs.getInt("HASREADEXECUTE"));
                            perm.put("read", rs.getInt("HASREAD"));
                            perm.put("write", rs.getInt("HASWRITE"));
                            permissions.add(perm);
                        }
                    }
                }

                // Query D: Dynamic Form Workflow History Logs
                String approvalSQL =
                    "SELECT AI.STATE_STEP, AI.IT_COMMENT, " +
                    "TO_CHAR(AI.APPROVED_DATE, 'DD/MM/YYYY') AS APPROVED_DAY, " +
                    "TO_CHAR(AI.APPROVED_DATE, 'HH24:MI') AS APPROVED_TIME, " +
                    "EMP.EMPNAME, EMP.POSITION " +
                    "FROM APPROVALINFO AI " +
                    "LEFT JOIN EMPLOYEE EMP ON AI.REVIEWER_EMPID = EMP.EMPID " +
                    "WHERE AI.FORMID = ? " +
                    "AND ABS(AI.STATE_STEP) BETWEEN 1 AND 4 " +
                    "ORDER BY AI.APPROVALID";
                try (PreparedStatement ps = conn.prepareStatement(approvalSQL)) {
                    ps.setInt(1, formId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            int stateStep = rs.getInt("STATE_STEP");
                            String key = approvalKey(stateStep);
                            if (key != null && approvalSections.containsKey(key)) {
                                java.util.Map<String, String> approval = approvalSections.get(key);
                                approval.put("hasApproval", "true");
                                approval.put("position", nvl(rs.getString("POSITION")));
                                approval.put("empName", nvl(rs.getString("EMPNAME")));
                                approval.put("action", stateStep < 0 ? "ไม่อนุมัติ" : "อนุมัติ");
                                approval.put("approvedDay", nvl(rs.getString("APPROVED_DAY")));
                                approval.put("approvedTime", nvl(rs.getString("APPROVED_TIME")));
                                approval.put("comment", nvl(rs.getString("IT_COMMENT")));
                            }
                        }
                    }
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Database process exception handled", e);
        }

        // ---- 4. HTML Layout Rendering Engine Design ----
        String fontPath = getServletContext().getRealPath("/WEB-INF/classes/fonts/THSarabunNew.ttf");
        
        StringBuilder html = new StringBuilder();
        html.append("<!DOCTYPE html><html><head><meta charset='UTF-8'/>");
        html.append("<style>");
        
        // Print-specific page properties (A4 setup)
        html.append("@page { size: a4; margin: 15mm 15mm 20mm 15mm; @bottom-right { content: 'หน้า ' counter(page) ' จาก ' counter(pages); font-family: 'THSarabunNew'; font-size: 11pt; color: #666; } }");
        
        // Typography Registration
        html.append("@font-face { font-family: 'THSarabunNew'; src: url('file:///").append(fontPath.replace("\\", "/")).append("'); -fs-pdf-font-embed: embed; -fs-pdf-font-encoding: Identity-H; }");
        
        // Styles matching document standard
        html.append("body { font-family: 'THSarabunNew', sans-serif; font-size: 14pt; line-height: 1.3; color: #111; }")
            .append(".meta-header { width: 100%; font-size: 10.5pt; color: #555; margin-bottom: 5px; }")
            .append(".title-header { text-align: center; font-size: 18pt; font-weight: bold; margin: 10px 0 0 0; color: #002244; }")
            .append(".title-sub { text-align: center; font-size: 14pt; font-weight: bold; margin: 0 0 15px 0; color: #334466; }")
            .append(".section-title { font-size: 14pt; font-weight: bold; color: #003366; border-bottom: 1.5px solid #003366; padding-bottom: 2px; margin-top: 15px; margin-bottom: 8px; page-break-inside: avoid; }")
            .append(".grid-table { width: 100%; border-collapse: collapse; margin-bottom: 10px; }")
            .append(".grid-table td { padding: 4px; vertical-align: top; border: none; }")
            .append(".checkbox-matrix { width: 100%; margin-bottom: 10px; }")
            .append(".checkbox-cell { width: 50%; float: left; padding: 3px 0; }")
            .append(".clear { clear: both; }")
            .append(".content-block { border: 1px solid #aaa; padding: 8px; background: #fafafa; min-height: 40px; margin-bottom: 10px; font-size: 13pt; white-space: pre-wrap; }")
            .append(".matrix-table { width: 100%; border-collapse: collapse; margin-bottom: 10px; font-size: 12pt; }")
            .append(".matrix-table th, .matrix-table td { border: 1px solid #777; padding: 5px; text-align: left; }")
            .append(".matrix-table th { background-color: #eaeaea; font-weight: bold; }")
            .append(".workflow-box { border: 1px solid #999; margin-top: 20px; page-break-inside: avoid; }")
            .append(".workflow-header { background: #f0f0f0; padding: 6px; font-weight: bold; border-bottom: 1px solid #999; font-size: 13pt; text-align: center; }")
            .append(".workflow-grid { display: table; width: 100%; }")
            .append(".workflow-cell { display: table-cell; width: 25%; border-right: 1px solid #999; padding: 8px; text-align: center; vertical-align: top; font-size: 11.5pt; }")
            .append(".workflow-cell:last-child { border-right: none; }")
            .append(".txt-bold { font-weight: bold; }")
            .append(".txt-center { text-align: center; }");
        
        html.append("</style></head><body>");

        // Top Document Meta Strip
        html.append("<table class='meta-header'><tr>")
            .append("<td>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินให้กู้ยืมเพื่อการศึกษา</td>")
            .append("<td style='text-align:right;'>SLF-RF-007 V1.0 / เลขที่รับเอกสาร #").append(formId).append("</td>")
            .append("</tr></table>");

        html.append("<div class='title-header'>ใบขอให้ดำเนินการ</div>");
        html.append("<div class='title-sub'>(Requisition Form)</div>");

        // Section 1: Personal Profile Info
        html.append("<table class='grid-table'>")
            .append("<tr><td class='txt-bold' style='width:15%;'>ชื่อ-นามสกุล:</td><td style='width:35%;'>").append(fullName).append("</td>")
            .append("    <td class='txt-bold' style='width:15%;'>ส่วน / ฝ่าย:</td><td style='width:35%;'>").append(sectionName).append(" / ").append(departmentName).append("</td></tr>")
            .append("<tr><td class='txt-bold'>เบอร์ต่อ:</td><td>").append(phone).append("</td>")
            .append("    <td class='txt-bold'>วันที่ขอเอกสาร:</td><td>").append(requestDate).append("</td></tr>")
            .append("<tr><td class='txt-bold'>กำหนดเสร็จสิ้น (DDL):</td><td>").append(deadline).append("</td>")
            .append("    <td class='txt-bold'>หัวข้อความต้องการ:</td><td>").append(requestTitle).append("</td></tr>")
            .append("</table>");

        // Section 2: Request Action Category Matrix Checkboxes
        html.append("<div class='section-title'>วัตถุประสงค์ / ประเภทความต้องการความช่วยเหลือทางเทคนิค</div>");
        html.append("<div class='checkbox-matrix'>");
        
        Set<String> categoryMapSet = new HashSet<>();
        for (java.util.Map<String, String> it : items) {
            categoryMapSet.add(it.get("typeName").trim());
        }

        String[] targetCategories = {
            "ขอติดตั้งโปรแกรม", "ขอสิทธิ์ใช้อินเตอร์เน็ต", "ขอใช้สิทธิ์เก็บข้อมูล",
            "ขอเปลี่ยน Password", "แจ้งปัญหาการใช้งาน", "ขอให้พัฒนาโปรแกรม",
            "ขอให้จัดหลักสูตรอบรม", "ขอยืมอุปกรณ์ IT"
        };

        for (String cat : targetCategories) {
            String checkMarker = categoryMapSet.contains(cat) ? "&#9745;" : "&#9744;";
            html.append("<div class='checkbox-cell'>").append(checkMarker).append(" ").append(cat).append("</div>");
        }
        html.append("<div class='clear'></div></div>");

        // Section 3: Loop items and format program details/objectives
        html.append("<div class='section-title'>รายละเอียดคำขอความต้องการจากระบบงาน</div>");
        int count = 1;
        for (java.util.Map<String, String> it : items) {
            String typeName = it.get("typeName");
            html.append("<div style='margin-bottom: 10px; page-break-inside: avoid;'>");
            html.append("<strong>รายการที่ ").append(count).append(": ").append(typeName).append("</strong>");
            
            if ("ขอติดตั้งโปรแกรม".equals(typeName) || "ขอให้พัฒนาโปรแกรม".equals(typeName)) {
                html.append(" | <strong>ชื่อโปรแกรม:</strong> ").append(it.get("programOrOther"));
            } else if ("อื่นๆ".equals(typeName) || "อื่น ๆ".equals(typeName)) {
                html.append(" | <strong>ระบุรายละเอียดเพิ่มเติม:</strong> ").append(it.get("programOrOther"));
            }
            
            html.append("<div style='margin-top: 4px;'><strong>วัตถุประสงค์ / ความจำเป็นที่ต้องการใช้งาน:</strong></div>");
            html.append("<div class='content-block'>").append(it.get("objective")).append("</div>");
            
            if (!"-".equals(it.get("currentMethod")) && !it.get("currentMethod").isEmpty()) {
                html.append("<div><strong>วิธีการดำเนินงานปัจจุบัน:</strong></div>");
                html.append("<div class='content-block'>").append(it.get("currentMethod")).append("</div>");
            }
            html.append("</div>");
            count++;
        }

        // Section 4: Data Permissions Structural Mapping Grid Matrix
        if (!permissions.isEmpty()) {
            html.append("<div class='section-title'>รายละเอียดการขอใช้สิทธิ์เพื่อเข้าถึงข้อมูลในเซิร์ฟเวอร์ (Server Resource Permissions)</div>");
            html.append("<table class='matrix-table'>")
                .append("<thead><tr><th>ที่ตั้งทรัพยากรระบบ (Server)</th><th>พาร์ทไดเรกทอรีปลายทาง (Folder Path)</th><th>สิทธิ์การเข้าถึงระบบที่กำหนด</th></tr></thead><tbody>");
            
            for (java.util.Map<String, Object> perm : permissions) {
                String path = (String) perm.get("path");
                String serverName = "-";
                String shareName = "-";
                
                if (path != null && path.startsWith("\\\\")) {
                    String noPrefix = path.substring(2);
                    int slashIdx = noPrefix.indexOf("\\");
                    if (slashIdx > 0) {
                        serverName = noPrefix.substring(0, slashIdx);
                        shareName = noPrefix.substring(slashIdx + 1);
                    } else {
                        serverName = noPrefix;
                    }
                } else if (path != null) {
                    shareName = path;
                }

                StringBuilder permString = new StringBuilder();
                if (((Integer) perm.get("full")) == 1) permString.append("Full Control, ");
                if (((Integer) perm.get("modify")) == 1) permString.append("Modify, ");
                if (((Integer) perm.get("readExec")) == 1) permString.append("Read & Execute, ");
                if (((Integer) perm.get("read")) == 1) permString.append("Read, ");
                if (((Integer) perm.get("write")) == 1) permString.append("Write, ");
                String finalPerm = permString.toString().replaceAll(", $", "");
                if(finalPerm.isEmpty()) finalPerm = "-";

                html.append("<tr>")
                    .append("<td>").append(serverName).append("</td>")
                    .append("<td>").append(shareName).append("</td>")
                    .append("<td>").append(finalPerm).append("</td>")
                    .append("</tr>");
            }
            html.append("</tbody></table>");
        }

        // Section 5: Signature Blocks mixed with Dynamic Review Workflow History Log
        html.append("<div class='workflow-box'>")
            .append("  <div class='workflow-header'>ความเห็นและผลการดำเนินการอนุมัติ (Workflow Signatures)</div>")
            .append("  <div class='workflow-grid'>");

        // Column 1: Base Creator Sign-off Panel Block
        html.append("<div class='workflow-cell'>")
            .append("  <span class='txt-bold'>ผู้ขอ / Requestor</span><br/><br/><br/>")
            .append("  ลงชื่อ.........................................<br/>")
            .append("  (").append(fullName).append(")<br/>")
            .append("  วันที่: ").append(requestDate)
            .append("</div>");

        // Process workflow column loops dynamically
        for (java.util.Map<String, String> approval : approvalSections.values()) {
            boolean hasApproval = "true".equals(approval.get("hasApproval"));
            String label = approval.get("label").replace("ผู้อำนวยการฝ่ายเทคโนโลยีสารสนเทศ", "ผอ.ฝ่ายเทคโนโลยีสารสนเทศ");

            html.append("<div class='workflow-cell'>");
            html.append("  <span class='txt-bold'>").append(label).append("</span><br/><br/>");
            
            if (hasApproval) {
                html.append("  <span style='color:green; font-weight:bold;'>[ ").append(approval.get("action")).append(" ]</span><br/>")
                    .append("  ลงชื่อ.........................................<br/>")
                    .append("  (").append(approval.get("empName")).append(")<br/>")
                    .append("  วันที่: ").append(approval.get("approvedDay")).append("<br/>")
                    .append("  <span style='font-size:9.5pt; color:#444;'>ผอ.สังกัด: ").append(approval.get("comment")).append("</span>");
            } else {
                html.append("  <span style='color:#999;'><br/>( รอดำเนินการ )</span><br/><br/>")
                    .append("  ลงชื่อ.........................................<br/>")
                    .append("  (.........................................)<br/>")
                    .append("  วันที่: ...../...../.....");
            }
            html.append("</div>");
        }

        html.append("  </div>")
            .append("</div>");

        html.append("</body></html>");

        // ---- 5. Transmit Stream Directly over Response Engine ----
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "inline; filename=\"Requisition_" + formId + ".pdf\"");

        try (OutputStream os = response.getOutputStream()) {
            ITextRenderer renderer = new ITextRenderer();
            renderer.setDocumentFromString(html.toString());
            renderer.layout();
            renderer.createPDF(os);
        } catch (Exception e) {
            throw new ServletException("HTML-to-PDF Conversion Interruption Error caught", e);
        }
    }

    private java.util.Map<String, String> createStandbyApproval(String label) {
        java.util.Map<String, String> row = new java.util.HashMap<>();
        row.put("label", label);
        row.put("hasApproval", "false");
        return row;
    }

    private String approvalKey(int stateStep) {
        int step = Math.abs(stateStep);
        if (step == 1) return "director";
        if (step == 2) return "technical";
        if (step == 3) return "itDirector";
        if (step == 4) return "process";
        return null;
    }

    private String nvl(String s) {
        return (s == null || s.trim().isEmpty()) ? "-" : s.trim();
    }
}