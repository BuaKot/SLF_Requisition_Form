package com.slf.controller;

import com.slf.dao.ThirdPartyFormLinkDAO;
import com.slf.dao.ThirdPartyFormSubmissionDAO;
import com.slf.model.ThirdPartyFormLink;
import com.slf.model.ThirdPartyFormSubmission;
import com.slf.util.ThirdPartyLinkToken;
import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/thirdparty/submit")
public class ThirdPartySubmitServlet extends HttpServlet {
    private final ThirdPartyFormLinkDAO linkDAO = new ThirdPartyFormLinkDAO();
    private final ThirdPartyFormSubmissionDAO submissionDAO = new ThirdPartyFormSubmissionDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String rawToken = request.getParameter("token");
        try {
            ThirdPartyFormLink link = linkDAO.findUsableByTokenHash(ThirdPartyLinkToken.sha256Hex(rawToken));
            if (link == null) {
                forwardResult(request, response, false, "ลิงก์นี้หมดอายุ ถูกใช้แล้ว ถูกยกเลิก หรือไม่ถูกต้อง");
                return;
            }

            ThirdPartyFormSubmission submission = buildSubmission(request, link.getLinkId());
            validateSubmission(submission);
            submissionDAO.submitOnce(submission);
            forwardResult(request, response, true, "ส่งแบบฟอร์มเรียบร้อยแล้ว เจ้าหน้าที่จะตรวจสอบข้อมูลก่อนนำเข้าสู่ workflow หลัก");
        } catch (SQLException e) {
            throw new ServletException("Unable to submit third-party form", e);
        } catch (Exception e) {
            forwardResult(request, response, false, e.getMessage());
        }
    }

    private static ThirdPartyFormSubmission buildSubmission(HttpServletRequest request, long linkId) {
        ThirdPartyFormSubmission submission = new ThirdPartyFormSubmission();
        submission.setLinkId(linkId);
        submission.setFullNameTh(trimToNull(request.getParameter("fullNameTh")));
        submission.setFullNameEn(trimToNull(request.getParameter("fullNameEn")));
        submission.setOrganization(trimToNull(request.getParameter("organization")));
        submission.setPhone(trimToNull(request.getParameter("phone")));
        submission.setEmail(trimToNull(request.getParameter("email")));
        submission.setReasonObjective(trimToNull(request.getParameter("reasonObjective")));
        submission.setProjectName(trimToNull(request.getParameter("projectName")));
        submission.setAccessStartDate(parseDate(request.getParameter("accessStartDate"), "วันที่เริ่มต้นใช้ระบบงาน"));
        submission.setAccessEndDate(parseDate(request.getParameter("accessEndDate"), "ถึงวันที่"));
        return submission;
    }

    private static void validateSubmission(ThirdPartyFormSubmission submission) {
        requireText(submission.getFullNameTh(), "ชื่อ-สกุล ภาษาไทย");
        requireText(submission.getOrganization(), "หน่วยงาน");
        requireText(submission.getPhone(), "เบอร์โทรศัพท์");
        requireText(submission.getEmail(), "Email");
        requireText(submission.getReasonObjective(), "เหตุผลและวัตถุประสงค์การขอ");
        if (!submission.getEmail().matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
            throw new IllegalArgumentException("รูปแบบ Email ไม่ถูกต้อง");
        }
        if (submission.getAccessEndDate().before(submission.getAccessStartDate())) {
            throw new IllegalArgumentException("วันที่สิ้นสุดต้องไม่น้อยกว่าวันที่เริ่มต้น");
        }
    }

    private static void requireText(String value, String label) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException("กรุณากรอก " + label);
        }
    }

    private static Date parseDate(String value, String label) {
        try {
            return Date.valueOf(value);
        } catch (Exception e) {
            throw new IllegalArgumentException(label + " ไม่ถูกต้อง");
        }
    }

    private static String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private static void forwardResult(HttpServletRequest request, HttpServletResponse response,
                                      boolean success, String message)
            throws ServletException, IOException {
        request.setAttribute("submitSuccess", Boolean.valueOf(success));
        request.setAttribute("submitMessage", message);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/thirdpartySubmitResult.jsp");
        dispatcher.forward(request, response);
    }
}
