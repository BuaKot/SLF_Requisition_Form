package com.slf.controller;

import com.slf.dao.LookupDAO;
import com.slf.model.Employee;
import com.slf.model.Section;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

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
            // 1. Fetch the logged-in employee
            Employee emp = dao.findEmployeeById(empId);
            request.setAttribute("loggedInEmployee", emp);

            // 2. Fetch the employee's section to get their department
            //    We'll need a new DAO method: getSectionById(secId) that returns Section with deptId.
            Section empSection = dao.getSectionById(emp.getSecId());
            int empDeptId = empSection.getDeptId();   // the department ID
            request.setAttribute("empDeptId", empDeptId);
            request.setAttribute("empSectionId", emp.getSecId());

            // 3. Load all the dropdown lookups as before
            request.setAttribute("requestTypes", dao.getAllRequestTypes());
            request.setAttribute("departments", dao.getAllDepartments());
            request.setAttribute("allSections", dao.getAllSections());

        } catch (SQLException e) {
            throw new ServletException("Failed to load form", e);
        }

        request.getRequestDispatcher("/form.jsp").forward(request, response);
    }
}