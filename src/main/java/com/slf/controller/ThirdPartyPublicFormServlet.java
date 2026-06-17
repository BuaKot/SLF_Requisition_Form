package com.slf.controller;

import com.slf.dao.ThirdPartyFormLinkDAO;
import com.slf.model.ThirdPartyFormLink;
import com.slf.util.ThirdPartyConsentContent;
import com.slf.util.ThirdPartyLinkToken;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/thirdparty/form")
public class ThirdPartyPublicFormServlet extends HttpServlet {
    private final ThirdPartyFormLinkDAO linkDAO = new ThirdPartyFormLinkDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        preventCaching(response);
        String rawToken = request.getParameter("token");
        if (rawToken == null || rawToken.trim().isEmpty()) {
            forwardInvalid(request, response, "ลิงก์ไม่ถูกต้องหรือไม่มี token");
            return;
        }

        try {
            ThirdPartyFormLink link = linkDAO.findUsableByTokenHash(ThirdPartyLinkToken.sha256Hex(rawToken));
            if (link == null) {
                forwardInvalid(request, response, "ลิงก์นี้หมดอายุ ถูกใช้แล้ว ถูกยกเลิก หรือไม่ถูกต้อง");
                return;
            }

            request.setAttribute("thirdPartyLink", link);
            request.setAttribute("token", rawToken.trim());
            request.setAttribute("consentVersion", ThirdPartyConsentContent.VERSION);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/views/ThirdPartyForm.jsp");
            dispatcher.forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to load third-party form link", e);
        } catch (IllegalArgumentException e) {
            forwardInvalid(request, response, "ลิงก์ไม่ถูกต้อง");
        }
    }

    private void forwardInvalid(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
        request.setAttribute("invalidLinkMessage", message);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/views/ThirdPartyForm.jsp");
        dispatcher.forward(request, response);
    }

    private static void preventCaching(HttpServletResponse response) {
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0L);
    }
}
