package com.slf.controller;

import com.slf.dao.ThirdPartyFormLinkDAO;
import com.slf.dao.ThirdPartyFormSubmissionDAO;
import com.slf.model.ThirdPartyFormLink;
import com.slf.model.ThirdPartyFormSubmission;
import com.slf.model.ThirdPartyAccessRequest;
import com.slf.notification.ThirdPartyNotificationService;
import com.slf.util.ThirdPartyLinkToken;
import com.slf.util.ThirdPartyConsentContent;
import com.slf.util.RequestMetadataUtil;
import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
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
    private final ThirdPartyNotificationService notificationService = new ThirdPartyNotificationService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        preventCaching(response);
        request.setCharacterEncoding("UTF-8");
        String rawToken = request.getParameter("token");
        ThirdPartyFormLink link = null;
        try {
            link = linkDAO.findUsableByTokenHash(ThirdPartyLinkToken.sha256Hex(rawToken));
            if (link == null) {
                forwardResult(request, response, false, "ลิงก์นี้หมดอายุ ถูกใช้แล้ว ถูกยกเลิก หรือไม่ถูกต้อง");
                return;
            }

            if (!ThirdPartyConsentContent.VERSION.equals(trimToNull(request.getParameter("consentVersion")))) {
                throw new IllegalArgumentException("The consent version changed while the form was open. Please reopen the link and review it again.");
            }
            ThirdPartyFormSubmission submission = buildSubmission(request, link.getLinkId(), ThirdPartyConsentContent.VERSION);
            validateSubmission(submission);
            submissionDAO.submitOnce(submission);
            if (link.getRequestId() != null) {
                notificationService.notifyExternalSubmitted(link.getRequestId().longValue(), link.getCreatedByEmpId());
            }
            forwardResult(request, response, true, "ส่งแบบฟอร์มเรียบร้อยแล้ว เจ้าหน้าที่จะตรวจสอบข้อมูลก่อนนำเข้าสู่ workflow หลัก");
        } catch (SQLException e) {
            throw new ServletException("Unable to submit third-party form", e);
        } catch (IllegalArgumentException e) {
            if (link != null) {
                forwardFormError(request, response, link, rawToken, e.getMessage());
                return;
            }
            forwardResult(request, response, false, e.getMessage());
        }
    }

    private static ThirdPartyFormSubmission buildSubmission(HttpServletRequest request, long linkId, String consentVersion) {
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
        submission.setConsentAccepted("accepted".equals(request.getParameter("consentAccepted")));
        submission.setConsentVersion(consentVersion);
        submission.setConsentIpAddress(limit(trimToNull(RequestMetadataUtil.getClientIp(request)), 45));
        submission.setConsentUserAgent(limit(trimToNull(request.getHeader("User-Agent")), 500));
        submission.setAccessRequests(buildAccessRequests(request));
        return submission;
    }

    private static void validateSubmission(ThirdPartyFormSubmission submission) {
        requireText(submission.getFullNameTh(), "ชื่อ-สกุล ภาษาไทย");
        requireText(submission.getFullNameEn(), "ชื่อ-สกุล ภาษาอังกฤษ");
        requireText(submission.getOrganization(), "หน่วยงาน");
        requireText(submission.getPhone(), "เบอร์โทรศัพท์");
        requireText(submission.getEmail(), "Email");
        requireText(submission.getReasonObjective(), "เหตุผลและวัตถุประสงค์การขอ");
        if (!submission.isConsentAccepted()) {
            throw new IllegalArgumentException("Consent must be accepted before submitting the form.");
        }
        if (!submission.getEmail().matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
            throw new IllegalArgumentException("รูปแบบ Email ไม่ถูกต้อง");
        }
        if (submission.getAccessEndDate().before(submission.getAccessStartDate())) {
            throw new IllegalArgumentException("วันที่สิ้นสุดต้องไม่น้อยกว่าวันที่เริ่มต้น");
        }
        validateAccessRequests(submission.getAccessRequests());
    }

    private static List<ThirdPartyAccessRequest> buildAccessRequests(HttpServletRequest request) {
        String[] employeeCodes = values(request, "accessEmployeeCode");
        String[] usernames = values(request, "accessUsername");
        String[] nationalIds = values(request, "accessNationalId");
        String[] fullNamesTh = values(request, "accessFullNameTh");
        String[] fullNamesEn = values(request, "accessFullNameEn");
        String[] positions = values(request, "accessPosition");
        String[] mobiles = values(request, "accessMobile");
        String[] departments = values(request, "accessDepartment");
        String[] emails = values(request, "accessEmail");
        String[] systems = values(request, "accessSystem");
        String[] roles = values(request, "accessRole");
        int count = fullNamesTh.length;
        if (count == 0 || count > 20 || !sameLength(count, employeeCodes, usernames, nationalIds, fullNamesTh,
                fullNamesEn, positions, mobiles, departments, emails, systems, roles)) {
            throw new IllegalArgumentException("กรุณาระบุรายชื่อผู้ขอรับสิทธิ์ 1 ถึง 20 คนให้ครบถ้วน");
        }

        List<ThirdPartyAccessRequest> items = new ArrayList<>();
        for (int i = 0; i < count; i++) {
            ThirdPartyAccessRequest item = new ThirdPartyAccessRequest();
            item.setDisplayOrder(i + 1);
            item.setEmployeeCode(trimToNull(employeeCodes[i]));
            item.setUsername(trimToNull(usernames[i]));
            item.setNationalId(digitsOnly(nationalIds[i]));
            item.setFullNameTh(trimToNull(fullNamesTh[i]));
            item.setFullNameEn(trimToNull(fullNamesEn[i]));
            item.setPositionName(trimToNull(positions[i]));
            item.setMobilePhone(trimToNull(mobiles[i]));
            item.setDepartmentName(trimToNull(departments[i]));
            item.setEmail(trimToNull(emails[i]));
            item.setSystemName(trimToNull(systems[i]));
            item.setRequestedRole(trimToNull(roles[i]));
            items.add(item);
        }
        return items;
    }

    static void validateAccessRequests(List<ThirdPartyAccessRequest> items) {
        if (items == null || items.isEmpty() || items.size() > 20) {
            throw new IllegalArgumentException("กรุณาระบุรายชื่อผู้ขอรับสิทธิ์ 1 ถึง 20 คน");
        }
        for (ThirdPartyAccessRequest item : items) {
            String prefix = "รายชื่อคนที่ " + item.getDisplayOrder() + ": ";
            requireText(item.getFullNameTh(), prefix + "ชื่อ-สกุลภาษาไทย");
            requireText(item.getFullNameEn(), prefix + "ชื่อ-สกุลภาษาอังกฤษ");
            requireText(item.getPositionName(), prefix + "ตำแหน่ง");
            requireText(item.getMobilePhone(), prefix + "เบอร์โทรศัพท์มือถือ");
            requireText(item.getDepartmentName(), prefix + "ฝ่าย/กลุ่มงาน");
            requireText(item.getEmail(), prefix + "Email");
            requireText(item.getSystemName(), prefix + "ระบบงาน");
            requireText(item.getRequestedRole(), prefix + "สิทธิ์การใช้งาน (Role)");
            requireMax(item.getEmployeeCode(), 100, prefix + "รหัสพนักงาน");
            requireMax(item.getUsername(), 150, prefix + "ชื่อผู้ใช้งาน");
            requireMax(item.getFullNameTh(), 255, prefix + "ชื่อ-สกุลภาษาไทย");
            requireMax(item.getFullNameEn(), 255, prefix + "ชื่อ-สกุลภาษาอังกฤษ");
            requireMax(item.getPositionName(), 255, prefix + "ตำแหน่ง");
            requireMax(item.getMobilePhone(), 50, prefix + "เบอร์โทรศัพท์มือถือ");
            requireMax(item.getDepartmentName(), 255, prefix + "ฝ่าย/กลุ่มงาน");
            requireMax(item.getEmail(), 320, prefix + "Email");
            requireMax(item.getSystemName(), 255, prefix + "ระบบงาน");
            requireMax(item.getRequestedRole(), 1000, prefix + "สิทธิ์การใช้งาน (Role)");
            if (!item.getEmail().matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
                throw new IllegalArgumentException(prefix + "รูปแบบ Email ไม่ถูกต้อง");
            }
            if (item.getSystemName().toUpperCase().contains("DSL") && item.getNationalId() == null) {
                throw new IllegalArgumentException(prefix + "ระบบ DSL ต้องระบุเลขบัตรประชาชน");
            }
            if (item.getNationalId() != null && !isValidThaiNationalId(item.getNationalId())) {
                throw new IllegalArgumentException(prefix + "เลขบัตรประชาชนไม่ถูกต้อง");
            }
        }
    }

    static boolean isValidThaiNationalId(String value) {
        if (value == null || !value.matches("\\d{13}")) {
            return false;
        }
        int sum = 0;
        for (int i = 0; i < 12; i++) {
            sum += (value.charAt(i) - '0') * (13 - i);
        }
        return (11 - (sum % 11)) % 10 == value.charAt(12) - '0';
    }

    private static void requireMax(String value, int maximumLength, String label) {
        if (value != null && value.length() > maximumLength) {
            throw new IllegalArgumentException(label + "ยาวเกิน " + maximumLength + " ตัวอักษร");
        }
    }

    private static String[] values(HttpServletRequest request, String name) {
        String[] values = request.getParameterValues(name);
        return values == null ? new String[0] : values;
    }

    private static boolean sameLength(int expected, String[]... arrays) {
        for (String[] array : arrays) {
            if (array.length != expected) {
                return false;
            }
        }
        return true;
    }

    private static String digitsOnly(String value) {
        String trimmed = trimToNull(value);
        return trimmed == null ? null : trimmed.replaceAll("[^0-9]", "");
    }

    private static void requireText(String value, String label) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException("กรุณากรอก " + label);
        }
    }

    static Date parseDate(String value, String label) {
        try {
            LocalDate parsed = LocalDate.parse(value);
            if (parsed.getYear() >= 2500) {
                parsed = parsed.minusYears(543);
            }
            return Date.valueOf(parsed);
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

    private static String limit(String value, int maximumLength) {
        return value == null || value.length() <= maximumLength ? value : value.substring(0, maximumLength);
    }

    private static void forwardResult(HttpServletRequest request, HttpServletResponse response,
                                      boolean success, String message)
            throws ServletException, IOException {
        request.setAttribute("submitSuccess", Boolean.valueOf(success));
        request.setAttribute("submitMessage", message);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/views/ThirdPartySubmitResult.jsp");
        dispatcher.forward(request, response);
    }

    private static void forwardFormError(HttpServletRequest request, HttpServletResponse response,
                                         ThirdPartyFormLink link, String rawToken, String message)
            throws ServletException, IOException {
        request.setAttribute("thirdPartyLink", link);
        request.setAttribute("token", rawToken);
        request.setAttribute("consentVersion", ThirdPartyConsentContent.VERSION);
        request.setAttribute("formError", message);
        request.getRequestDispatcher("/WEB-INF/views/ThirdPartyForm.jsp").forward(request, response);
    }

    private static void preventCaching(HttpServletResponse response) {
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0L);
    }
}
