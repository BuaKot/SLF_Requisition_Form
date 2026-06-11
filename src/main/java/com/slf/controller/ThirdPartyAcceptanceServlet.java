package com.slf.controller;

import com.slf.dao.ThirdPartyAcceptanceDAO;
import com.slf.dao.ThirdPartyFormSubmissionDAO;
import com.slf.dao.ThirdPartyRequestDAO;
import com.slf.dao.ThirdPartyWorkflowDAO;
import com.slf.model.ThirdPartyAcceptanceToken;
import com.slf.model.ThirdPartyRequest;
import com.slf.util.ThirdPartyLinkToken;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/thirdparty/accept")
public class ThirdPartyAcceptanceServlet extends HttpServlet {
    private final ThirdPartyAcceptanceDAO acceptanceDAO = new ThirdPartyAcceptanceDAO();
    private final ThirdPartyRequestDAO requestDAO = new ThirdPartyRequestDAO();
    private final ThirdPartyFormSubmissionDAO submissionDAO = new ThirdPartyFormSubmissionDAO();
    private final ThirdPartyWorkflowDAO workflowDAO = new ThirdPartyWorkflowDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        preventCaching(response);
        String rawToken = request.getParameter("token");
        try {
            ThirdPartyAcceptanceToken token =
                acceptanceDAO.findUsableByTokenHash(ThirdPartyLinkToken.sha256Hex(rawToken));
            if (token == null) {
                forwardInvalid(request, response);
                return;
            }
            ThirdPartyRequest thirdPartyRequest = requestDAO.findById(token.getRequestId());
            request.setAttribute("acceptanceToken", token);
            request.setAttribute("token", rawToken.trim());
            request.setAttribute("submission",
                submissionDAO.findById(thirdPartyRequest.getSubmissionId().longValue()));
            request.setAttribute("operationDetail",
                workflowDAO.findLatestActionComment(token.getRequestId(), "OPERATOR_COMPLETED"));
            request.getRequestDispatcher("/thirdpartyAcceptance.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to load third-party acceptance form", e);
        } catch (Exception e) {
            forwardInvalid(request, response);
        }
    }

    private static void forwardInvalid(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
        request.setAttribute("invalidLinkMessage", "ลิงก์ตรวจรับหมดอายุ ถูกใช้แล้ว หรือไม่ถูกต้อง");
        request.getRequestDispatcher("/thirdpartyAcceptance.jsp").forward(request, response);
    }

    static void preventCaching(HttpServletResponse response) {
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0L);
    }
}
