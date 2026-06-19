package com.slf.controller;

import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {
    "/Admin.jsp",
    "/Dashboard.jsp",
    "/history.jsp",
    "/pdf.jsp",
    "/it-requisition-form-detail.jsp",
    "/third-party-form-detail.jsp",
    "/submit-success",
    "/submit-success.jsp",
    "/RequisitionDetail.jsp",
    "/RequisitionDetail_Comment.jsp",
    "/RequisitionDetail_ITDirector.jsp",
    "/RequisitionDetail_Process.jsp"
})
public class ViewForwardServlet extends HttpServlet {
    private static final Map<String, String> VIEWS;

    static {
        Map<String, String> views = new HashMap<String, String>();
        views.put("/Admin.jsp", "/WEB-INF/views/Admin.jsp");
        views.put("/Dashboard.jsp", "/WEB-INF/views/Dashboard.jsp");
        views.put("/history.jsp", "/WEB-INF/views/History.jsp");
        views.put("/pdf.jsp", "/WEB-INF/views/Pdf.jsp");
        views.put("/it-requisition-form-detail.jsp", "/WEB-INF/views/ItRequisitionFormDetail.jsp");
        views.put("/third-party-form-detail.jsp", "/WEB-INF/views/ThirdPartyFormDetail.jsp");
        views.put("/submit-success", "/WEB-INF/views/SubmitSuccess.jsp");
        views.put("/submit-success.jsp", "/WEB-INF/views/SubmitSuccess.jsp");
        views.put("/RequisitionDetail.jsp", "/WEB-INF/views/RequisitionDetail.jsp");
        views.put("/RequisitionDetail_Comment.jsp", "/WEB-INF/views/RequisitionDetailComment.jsp");
        views.put("/RequisitionDetail_ITDirector.jsp", "/WEB-INF/views/RequisitionDetailITDirector.jsp");
        views.put("/RequisitionDetail_Process.jsp", "/WEB-INF/views/RequisitionDetailProcess.jsp");
        VIEWS = Collections.unmodifiableMap(views);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        String view = VIEWS.get(path);
        if (view == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        request.getRequestDispatcher(view).forward(request, response);
    }
}
