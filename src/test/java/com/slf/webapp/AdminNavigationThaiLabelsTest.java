package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class AdminNavigationThaiLabelsTest extends TestCase {

    public void testAdminPageContainsThaiManagementLinks() throws Exception {
        String page = read("src/main/webapp/Admin.jsp");
        assertTrue(page.contains("แดชบอร์ด"));
        assertTrue(page.contains("จัดการสมาชิก"));
        assertTrue(page.contains("บันทึกการส่งอีเมล"));
        assertTrue(page.contains("จัดการลิงก์บุคคลภายนอก"));
    }

    public void testSidebarUsesAnimatedThaiAdminMenu() throws Exception {
        String sidebar = read("src/main/webapp/WEB-INF/sidebar.jsp");
        assertTrue(sidebar.contains("เมนูผู้ดูแลระบบ"));
        assertTrue(sidebar.contains("sidebar-submenu"));
        assertTrue(sidebar.contains("classList.toggle(\"open\")"));
        assertFalse(sidebar.contains(">Dashboard</a>"));
        assertFalse(sidebar.contains(">mailLog</a>"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
