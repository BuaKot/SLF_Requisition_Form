package com.slf.filter;

import com.slf.util.AuthUtil;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(urlPatterns = {
    "/Admin.jsp",
    "/Dashboard.jsp",
    "/MemberManage.jsp",
    "/memberManage",
    "/directorApprove",           // if you've mapped this to a servlet
    "/DirectorApprove.jsp",
    "/technicalApprove",
    "/TechnicalApprove.jsp",
    "/itDirectorApprove",
    "/ITDirectorApprove.jsp",
    "/process",
    "/Process.jsp",
    "/RequisitionDetail.jsp",
    "/RequisitionDetail_Comment.jsp",
    "/RequisitionDetail_ITDirector.jsp",
    "/RequisitionDetail_Process.jsp"
})
public class RoleBasedAccessFilter implements Filter {

    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String position = (String) session.getAttribute("position");
        String path = request.getRequestURI().substring(request.getContextPath().length());

        // Map the request path to a pageKey
        String pageKey = null;
        if (path.equals("/directorApprove") || path.equals("/DirectorApprove.jsp")) {
            pageKey = "directorApprove";
        } else if (path.equals("/technicalApprove") || path.equals("/TechnicalApprove.jsp")) {
            pageKey = "technicalApprove";
        } else if (path.equals("/itDirectorApprove") || path.equals("/ITDirectorApprove.jsp")) {
            pageKey = "itDirectorApprove";
        } else if (path.equals("/process") || path.equals("/Process.jsp")) {
            pageKey = "process";
        } else if (path.startsWith("/RequisitionDetail")) {
            // RequisitionDetail pages are accessible to the same roles that can see the
            // corresponding approve lists. You might want to map them individually or
            // use a generic key that allows any "admin" role. I'll default to the same
            // admin set, but you can refine.
            pageKey = "requisitionDetail";  // you'd need to add this to PAGE_ROLES
            // Or just use isAdmin() if all admin roles can view any detail.
        } else if (path.equals("/Admin.jsp")) {
            pageKey = "adminPage";   // add to PAGE_ROLES if needed
        } else if (path.equals("/Dashboard.jsp")) {
            pageKey = "dashboard";
        } else if (path.equals("/memberManage") || path.equals("/MemberManage.jsp")) {
            pageKey = "memberManage";
        }

        // If we have a pageKey, check permission
        if (pageKey != null) {
            if (!AuthUtil.isAllowedForPage(position, pageKey)) {
                session.setAttribute("accessDeniedMessage", "คุณไม่มีสิทธิ์เข้าถึงหน้านี้");
                response.sendRedirect(request.getContextPath() + "/");
                return;
            }
        }

        // No pageKey means it's not one of our guarded patterns, just let it through.
        chain.doFilter(req, res);
    }
}
