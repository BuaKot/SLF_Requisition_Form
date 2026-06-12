package com.slf.controller;

import com.slf.dao.ThirdPartyRequestDAO;
import com.slf.dao.ThirdPartyWorkflowDAO;
import com.slf.model.ThirdPartyRequest;
import com.slf.model.ThirdPartyWorkflowActionEntry;
import com.slf.util.AuthUtil;
import com.slf.util.ThirdPartyAccessPolicy;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/thirdParty/history")
public class ThirdPartyHistoryServlet extends HttpServlet {
    private static final int PAGE_SIZE = 25;
    private static final int MAX_PAGE = 100000;
    private static final int MAX_SEARCH_LENGTH = 100;
    private final ThirdPartyRequestDAO requestDAO = new ThirdPartyRequestDAO();
    private final ThirdPartyWorkflowDAO workflowDAO = new ThirdPartyWorkflowDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String position = session == null ? null : (String) session.getAttribute("position");
        Integer empId = ThirdPartyAccessPolicy.sessionEmpId(session);
        if (!ThirdPartyAccessPolicy.canViewHistory(position, empId)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        boolean adminView = AuthUtil.isAllowedForPage(position, "thirdPartyHistory");
        int page = parsePage(request.getParameter("page"));
        String filter = normalizeFilter(request.getParameter("filter"));
        String search = normalizeSearch(request.getParameter("q"));
        try {
            List<ThirdPartyRequest> requests =
                requestDAO.findHistory(adminView ? null : empId, filter, search,
                    (page - 1) * PAGE_SIZE, PAGE_SIZE + 1);
            boolean hasNextPage = requests.size() > PAGE_SIZE;
            if (hasNextPage) {
                requests.remove(requests.size() - 1);
            }
            Map<Long, List<ThirdPartyWorkflowActionEntry>> actionHistory =
                workflowDAO.findActionHistoryForRequests(requests);
            request.setAttribute("thirdPartyRequests", requests);
            request.setAttribute("thirdPartyHistoryActions", actionHistory);
            request.setAttribute("thirdPartyHistoryAdminView", Boolean.valueOf(adminView));
            request.setAttribute("thirdPartyHistoryFilter", filter);
            request.setAttribute("thirdPartyHistorySearch", search);
            request.setAttribute("thirdPartyHistoryPage", Integer.valueOf(page));
            request.setAttribute("thirdPartyHistoryHasNextPage", Boolean.valueOf(hasNextPage));
            request.getRequestDispatcher("/third-party-history.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to load third-party history", e);
        }
    }

    static int parsePage(String value) {
        if (value == null || value.trim().isEmpty()) return 1;
        try {
            return Math.min(MAX_PAGE, Math.max(1, Integer.parseInt(value.trim())));
        } catch (NumberFormatException e) {
            return 1;
        }
    }

    static String normalizeFilter(String value) {
        if ("waiting".equals(value) || "completed".equals(value) || "rejected".equals(value)) {
            return value;
        }
        return "all";
    }

    static String normalizeSearch(String value) {
        if (value == null) return "";
        String normalized = value.trim();
        return normalized.length() <= MAX_SEARCH_LENGTH
            ? normalized
            : normalized.substring(0, MAX_SEARCH_LENGTH);
    }
}
