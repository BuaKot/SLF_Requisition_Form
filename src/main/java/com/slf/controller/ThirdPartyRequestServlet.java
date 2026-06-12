package com.slf.controller;

import com.slf.dao.ThirdPartyAuditLogDAO;
import com.slf.dao.ThirdPartyFormLinkDAO;
import com.slf.dao.ThirdPartyRequestDAO;
import com.slf.dao.ThirdPartyAcceptanceDAO;
import com.slf.model.ThirdPartyRequest;
import com.slf.util.ThirdPartyLinkToken;
import com.slf.util.ThirdPartyAccessPolicy;
import java.io.IOException;
import java.security.SecureRandom;
import java.sql.SQLException;
import java.util.Base64;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/thirdParty/request/new")
public class ThirdPartyRequestServlet extends HttpServlet {
    private static final String CSRF_SESSION_KEY = "thirdPartyRequestCsrfToken";
    private static final SecureRandom RANDOM = new SecureRandom();
    private final ThirdPartyRequestDAO requestDAO = new ThirdPartyRequestDAO();
    private final ThirdPartyFormLinkDAO linkDAO = new ThirdPartyFormLinkDAO();
    private final ThirdPartyAuditLogDAO auditDAO = new ThirdPartyAuditLogDAO();
    private final ThirdPartyAcceptanceDAO acceptanceDAO = new ThirdPartyAcceptanceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Integer allowedEmpId = allowedEmpId(request);
        if (allowedEmpId == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        try {
            int ownerEmpId = allowedEmpId.intValue();
            List<ThirdPartyRequest> requests = requestDAO.findRecentForOwner(ownerEmpId, 100);
            acceptanceDAO.repairMissingTokensForOwner(ownerEmpId, 100);
            request.setAttribute("thirdPartyRequests", requests);
            request.setAttribute("acceptanceTokens", acceptanceDAO.findRecentForOwner(ownerEmpId, 100));
            request.setAttribute("acceptanceLinkPrefix", buildAcceptanceLinkPrefix(request));
            request.setAttribute("csrfToken", ensureCsrfToken(request));
            request.getRequestDispatcher("/third-party-request-new.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to load third-party links", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Integer ownerEmpId = allowedEmpId(request);
        if (ownerEmpId == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        if (!isValidCsrf(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid CSRF token");
            return;
        }

        try {
            String action = trimToEmpty(request.getParameter("action"));
            if ("cancel".equals(action)) {
                cancelRequest(request, response, ownerEmpId.intValue());
                return;
            }

            long requestId = requestDAO.createRequest(ownerEmpId.intValue());
            String rawToken = ThirdPartyLinkToken.generateRawToken();
            String tokenHash = ThirdPartyLinkToken.sha256Hex(rawToken);
            long linkId = linkDAO.createLink(
                tokenHash,
                rawToken,
                ownerEmpId.intValue(),
                "แบบฟอร์มลงทะเบียนผู้ใช้ระบบงานสารสนเทศสำหรับผู้ให้บริการภายนอก",
                "THIRD_PARTY_USER_REGISTRATION",
                Long.valueOf(requestId),
                ownerEmpId
            );
            auditDAO.log("THIRD_PARTY_REQUEST_CREATED", Long.valueOf(requestId), Long.valueOf(linkId), ownerEmpId,
                "INTERNAL", "Internal user generated a third-party external form link.");
            request.getSession(true).setAttribute("thirdPartyGeneratedLink_" + requestId,
                ThirdPartyLinksServlet.buildPublicLink(request, rawToken));
            response.sendRedirect(request.getContextPath() + "/thirdParty/request/new?createdRequestId=" + requestId);
        } catch (SQLException e) {
            throw new ServletException("Unable to create third-party request", e);
        } catch (IllegalArgumentException e) {
            response.sendRedirect(request.getContextPath() + "/thirdParty/request/new?status=invalid_request");
        }
    }

    private void cancelRequest(HttpServletRequest request, HttpServletResponse response, int ownerEmpId)
            throws IOException, SQLException {
        long requestId = parseLong(request.getParameter("requestId"));
        long linkId = parseLong(request.getParameter("linkId"));
        boolean cancelled = requestDAO.cancelRequest(requestId, linkId, ownerEmpId);
        if (cancelled) {
            request.getSession(true).removeAttribute("thirdPartyGeneratedLink_" + requestId);
            auditDAO.log("THIRD_PARTY_REQUEST_DELETED", Long.valueOf(requestId), Long.valueOf(linkId),
                Integer.valueOf(ownerEmpId), "INTERNAL",
                "Internal owner deleted an unused third-party external form link.");
        }
        response.sendRedirect(request.getContextPath() + "/thirdParty/request/new?status="
            + (cancelled ? "cancelled" : "not_cancelled"));
    }

    private static Integer allowedEmpId(HttpServletRequest request) {
        Integer empId = ThirdPartyAccessPolicy.sessionEmpId(request.getSession(false));
        return ThirdPartyAccessPolicy.canCreateOwnLinks(empId) ? empId : null;
    }

    private static String ensureCsrfToken(HttpServletRequest request) {
        HttpSession session = request.getSession(true);
        Object existing = session.getAttribute(CSRF_SESSION_KEY);
        if (existing instanceof String && ((String) existing).length() > 0) {
            return (String) existing;
        }
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        session.setAttribute(CSRF_SESSION_KEY, token);
        return token;
    }

    private static boolean isValidCsrf(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object expected = session == null ? null : session.getAttribute(CSRF_SESSION_KEY);
        return expected instanceof String && expected.equals(request.getParameter("csrfToken"));
    }

    private static long parseLong(String value) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException("Missing id.");
        }
        long id = Long.parseLong(value.trim());
        if (id <= 0) {
            throw new IllegalArgumentException("Invalid id.");
        }
        return id;
    }

    private static String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    private static String buildAcceptanceLinkPrefix(HttpServletRequest request) {
        return request.getScheme() + "://" + request.getServerName()
            + (request.getServerPort() == 80 || request.getServerPort() == 443 ? "" : ":" + request.getServerPort())
            + request.getContextPath() + "/thirdparty/accept?token=";
    }
}
