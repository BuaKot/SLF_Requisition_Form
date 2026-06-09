package com.slf.controller;

import com.slf.dao.ThirdPartyFormLinkDAO;
import com.slf.util.AuthUtil;
import com.slf.util.ThirdPartyLinkToken;
import java.io.IOException;
import java.security.SecureRandom;
import java.sql.SQLException;
import java.util.Base64;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/thirdPartyLinks")
public class ThirdPartyLinksServlet extends HttpServlet {
    private static final int LIST_LIMIT = 100;
    private static final String CSRF_SESSION_KEY = "thirdPartyLinksCsrfToken";
    private static final String GENERATED_LINKS_SESSION_KEY = "thirdPartyGeneratedLinks";
    private static final int GENERATED_LINKS_SESSION_LIMIT = 20;
    private static final SecureRandom RANDOM = new SecureRandom();
    private final ThirdPartyFormLinkDAO linkDAO = new ThirdPartyFormLinkDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request, response)) {
            return;
        }
        loadAndForward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request, response)) {
            return;
        }
        if (!isValidCsrf(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid CSRF token");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = ThirdPartyFormLinkDAO.normalizeAction(request.getParameter("action"));
        int empId = getLoggedInEmpId(request);
        try {
            if ("generate".equals(action)) {
                String rawToken = ThirdPartyLinkToken.generateRawToken();
                String tokenHash = ThirdPartyLinkToken.sha256Hex(rawToken);
                long linkId = linkDAO.createLink(tokenHash, rawToken, empId, request.getParameter("note"));
                String generatedLink = buildPublicLink(request, rawToken);
                rememberGeneratedLink(request, linkId, generatedLink);
                response.sendRedirect(request.getContextPath() + "/thirdPartyLinks?status=generated&linkId=" + linkId);
                return;
            }

            if ("revoke".equals(action)) {
                long linkId = parseLong(request.getParameter("linkId"));
                boolean revoked = linkDAO.revokeLink(linkId, empId);
                response.sendRedirect(request.getContextPath() + "/thirdPartyLinks?status=" + (revoked ? "revoked" : "not_revoked"));
                return;
            }

            response.sendRedirect(request.getContextPath() + "/thirdPartyLinks?status=unknown_action");
        } catch (SQLException e) {
            throw new ServletException("Unable to update third-party links", e);
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
            loadAndForward(request, response);
        }
    }

    private void loadAndForward(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setAttribute("csrfToken", ensureCsrfToken(request));
            request.setAttribute("links", linkDAO.findRecentLinks(LIST_LIMIT));
            request.setAttribute("generatedLinks", generatedLinks(request));
            request.setAttribute("publicBaseUrl", buildPublicLinkPrefix(request));
            request.setAttribute("status", request.getParameter("status"));
            RequestDispatcher dispatcher = request.getRequestDispatcher("/ThirdPartyLinks.jsp");
            dispatcher.forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to load third-party links", e);
        }
    }

    private boolean isAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        String position = session == null ? null : (String) session.getAttribute("position");
        if (!AuthUtil.isAllowedForPage(position, "thirdPartyLinks")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return false;
        }
        return true;
    }

    private static int getLoggedInEmpId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object empObj = session == null ? null : session.getAttribute("loggedInEmpId");
        if (empObj == null && session != null) {
            empObj = session.getAttribute("empid");
        }
        if (empObj == null) {
            return 0;
        }
        return Integer.parseInt(empObj.toString());
    }

    static String buildPublicLink(HttpServletRequest request, String rawToken) {
        return buildPublicLinkPrefix(request) + rawToken;
    }

    static String buildPublicLinkPrefix(HttpServletRequest request) {
        StringBuilder link = new StringBuilder();
        link.append(request.getScheme()).append("://").append(request.getServerName());
        int port = request.getServerPort();
        boolean defaultPort = ("http".equalsIgnoreCase(request.getScheme()) && port == 80)
            || ("https".equalsIgnoreCase(request.getScheme()) && port == 443);
        if (!defaultPort) {
            link.append(":").append(port);
        }
        link.append(request.getContextPath()).append("/thirdparty/form?token=");
        return link.toString();
    }

    static long parseLong(String value) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException("Missing link id.");
        }
        return Long.parseLong(value.trim());
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
        String actual = request.getParameter("csrfToken");
        return expected instanceof String && ((String) expected).equals(actual);
    }

    private static void rememberGeneratedLink(HttpServletRequest request, long linkId, String generatedLink) {
        Map<Long, String> links = generatedLinks(request);
        links.put(Long.valueOf(linkId), generatedLink);
        while (links.size() > GENERATED_LINKS_SESSION_LIMIT) {
            Iterator<Long> iterator = links.keySet().iterator();
            if (iterator.hasNext()) {
                iterator.next();
                iterator.remove();
            }
        }
        request.getSession(true).setAttribute(GENERATED_LINKS_SESSION_KEY, links);
    }

    @SuppressWarnings("unchecked")
    private static Map<Long, String> generatedLinks(HttpServletRequest request) {
        HttpSession session = request.getSession(true);
        Object value = session.getAttribute(GENERATED_LINKS_SESSION_KEY);
        if (value instanceof Map) {
            return (Map<Long, String>) value;
        }
        Map<Long, String> links = new LinkedHashMap<Long, String>();
        session.setAttribute(GENERATED_LINKS_SESSION_KEY, links);
        return links;
    }
}
