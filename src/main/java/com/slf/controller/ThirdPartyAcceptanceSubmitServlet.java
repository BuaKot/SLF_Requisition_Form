package com.slf.controller;

import com.slf.dao.ThirdPartyAcceptanceDAO;
import com.slf.model.ThirdPartyAcceptanceToken;
import com.slf.notification.ThirdPartyNotificationService;
import com.slf.util.ThirdPartyLinkToken;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/thirdparty/accept/submit")
public class ThirdPartyAcceptanceSubmitServlet extends HttpServlet {
    private final ThirdPartyAcceptanceDAO acceptanceDAO = new ThirdPartyAcceptanceDAO();
    private final ThirdPartyNotificationService notificationService = new ThirdPartyNotificationService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ThirdPartyAcceptanceServlet.preventCaching(response);
        request.setCharacterEncoding("UTF-8");
        try {
            String rawToken = request.getParameter("token");
            ThirdPartyAcceptanceToken token =
                acceptanceDAO.findUsableByTokenHash(ThirdPartyLinkToken.sha256Hex(rawToken));
            if (token == null) throw new IllegalArgumentException("ลิงก์ตรวจรับไม่สามารถใช้งานได้");
            String comment = requireComment(request.getParameter("comment"));
            int satisfactionLevel = parseSatisfaction(request.getParameter("satisfactionLevel"));
            acceptanceDAO.submitAcceptance(
                token.getRequestId(), token.getAcceptanceTokenId(), comment, satisfactionLevel);
            notificationService.notifyExternalAccepted(token.getRequestId());
            request.setAttribute("submitSuccess", Boolean.TRUE);
            request.setAttribute("submitMessage", "ส่งผลตรวจรับและประเมินเรียบร้อยแล้ว");
        } catch (SQLException e) {
            throw new ServletException("Unable to submit third-party acceptance", e);
        } catch (Exception e) {
            request.setAttribute("submitSuccess", Boolean.FALSE);
            request.setAttribute("submitMessage", e.getMessage());
        }
        request.getRequestDispatcher("/WEB-INF/views/ThirdPartySubmitResult.jsp").forward(request, response);
    }

    static String requireComment(String value) {
        String comment = value == null ? "" : value.trim();
        if (comment.isEmpty()) throw new IllegalArgumentException("กรุณากรอกความคิดเห็น");
        if (comment.length() > 4000) throw new IllegalArgumentException("ความคิดเห็นต้องไม่เกิน 4,000 ตัวอักษร");
        return comment;
    }

    static int parseSatisfaction(String value) {
        int level;
        try {
            level = Integer.parseInt(value == null ? "" : value.trim());
        } catch (NumberFormatException e) {
            level = 0;
        }
        if (level < 1 || level > 5) throw new IllegalArgumentException("กรุณาเลือกคะแนนความพึงพอใจ");
        return level;
    }
}
