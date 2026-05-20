package com.slf.controller;

import com.slf.dao.LookupDAO;
import com.slf.model.Department;
import com.slf.model.Employee;
import com.slf.model.RequestType;
import com.slf.model.Section;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/newForm")
public class LoadFormServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer empId = (Integer) session.getAttribute("loggedInEmpId");
        if (empId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        LookupDAO dao = new LookupDAO();
        try {
            // 1. Fetch the logged‑in employee
            Employee emp = dao.findEmployeeById(empId);
            request.setAttribute("loggedInEmployee", emp);

            // 2. Check whether the employee belongs to a section
            int secId = emp.getSecId();   // 0 if the database column is NULL
            Section empSection = null;
            if (secId != 0) {
                empSection = dao.getSectionById(secId);
            }

            if (secId == 0 || empSection == null) {
                // The user has no section – they are a department head or similar.
                // Store a message in the session and redirect to the home page.
                session.setAttribute("formDeniedMessage",
    "ท่านไม่มีส่วนงานที่สังกัด หรือเป็นหัวหน้าฝ่ายที่ไม่มีส่วนงาน กรุณาให้ผู้ใต้บังคับบัญชาเป็นผู้สร้างใบขอให้ดำเนินการแทน");
                response.sendRedirect(request.getContextPath() + "/");
                return;
            }

            // 3. The employee has a section – load the department and lookups
            int empDeptId = empSection.getDeptId();
            request.setAttribute("empDeptId", empDeptId);
            request.setAttribute("empSectionId", secId);

            // zennnne แก้
            // Cache static lookups in ServletContext (lazy init, double-checked locking)
            @SuppressWarnings("unchecked")
            List<RequestType> requestTypes = (List<RequestType>) getServletContext().getAttribute("allRequestTypes");
            if (requestTypes == null) {
                synchronized (getServletContext()) {
                    requestTypes = (List<RequestType>) getServletContext().getAttribute("allRequestTypes");
                    if (requestTypes == null) {
                        requestTypes = dao.getAllRequestTypes();
                        getServletContext().setAttribute("allRequestTypes", requestTypes);
                    }
                }
            }

            @SuppressWarnings("unchecked")
            List<Department> departments = (List<Department>) getServletContext().getAttribute("allDepartments");
            if (departments == null) {
                synchronized (getServletContext()) {
                    departments = (List<Department>) getServletContext().getAttribute("allDepartments");
                    if (departments == null) {
                        departments = dao.getAllDepartments();
                        getServletContext().setAttribute("allDepartments", departments);
                    }
                }
            }

            @SuppressWarnings("unchecked")
            List<Section> allSections = (List<Section>) getServletContext().getAttribute("allSections");
            if (allSections == null) {
                synchronized (getServletContext()) {
                    allSections = (List<Section>) getServletContext().getAttribute("allSections");
                    if (allSections == null) {
                        allSections = dao.getAllSections();
                        getServletContext().setAttribute("allSections", allSections);
                    }
                }
            }

            request.setAttribute("requestTypes", requestTypes);
            request.setAttribute("departments", departments);
            request.setAttribute("allSections", allSections);
            // zennnne แก้

        } catch (SQLException e) {
            throw new ServletException("Failed to load form", e);
        }

        request.getRequestDispatcher("/form.jsp").forward(request, response);
    }
}