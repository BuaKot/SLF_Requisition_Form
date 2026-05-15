package com.slf.filter;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter("/*") // Intercept every bloody request
public class AuthenticationFilter implements Filter {

    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        String path = request.getRequestURI().substring(request.getContextPath().length());

        // 1. Allow access to login-related resources WITHOUT authentication
        if (path.startsWith("/login")           // the login page servlet (GET)
            || path.startsWith("/processLogin") // the login processor (POST)
            || path.startsWith("/css/")         // your stylesheets
            || path.startsWith("/images/")      // your logos
            || path.startsWith("/js/")          // any JavaScript files
            || path.startsWith("/fonts/")) {    // fonts if you have 'em
            chain.doFilter(req, res); // Let 'em through
            return;
        }

        // 2. For everything else, check the session
        HttpSession session = request.getSession(false); // don't create a new one if it doesn't exist
        if (session == null || session.getAttribute("loggedInEmpId") == null) {
            // No valid session – send 'em back to the login page
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 3. Logged in – carry on, you're grand
        chain.doFilter(req, res);
    }
}