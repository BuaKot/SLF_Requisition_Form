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

        // ดักจับ: ถ้าสิ่งที่ขอมาคือหน้า login.jsp, พาร์ทล็อกอิน, หรือไฟล์ตกแต่ง
        // CSS/Images ให้ปล่อยผ่านฉลุย!
        if (path.equals("/login.jsp")
                || path.equals("/processLogin")
                || path.startsWith("/css/")
                || path.startsWith("/images/")) {

            // ปล่อยผ่านไปได้เลย ไม่ต้องเช็คเซสชัน
            chain.doFilter(request, response);
            return;
        }

        // ---- หลังจากบรรทัดนี้ลงไป ค่อยเป็นโค้ดเช็ค Session ตามปกติของคุณ ----
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            // ถ้าไม่มีสิทธิ์จริง ๆ และไม่ใช่หน้า login ค่อยเตะกลับมาที่นี่
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // 3. Logged in – carry on, you're grand
        chain.doFilter(req, res);
    }
}