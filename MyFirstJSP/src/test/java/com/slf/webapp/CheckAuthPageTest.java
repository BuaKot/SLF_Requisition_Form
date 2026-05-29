package com.slf.webapp;

import junit.framework.TestCase;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

public class CheckAuthPageTest extends TestCase {

    public void testCheckAuthUsesOptionalRequiredPageKey() throws Exception {
        String source = read("src/main/webapp/WEB-INF/checkAuth.jsp");

        assertTrue(source.contains("requiredPageKey"));
        assertTrue(source.contains("com.slf.util.AuthUtil.isAllowedForPage"));
        assertFalse(source.contains("AuthUtil.isAllowedForPage(currentRole, \"adminPage\")"));
    }

    public void testSensitivePagesSetRequiredPageKeyBeforeIncludingCheckAuth() throws Exception {
        assertTrue(read("src/main/webapp/Dashboard.jsp").contains("requiredPageKey\", \"dashboard\""));
        assertTrue(read("src/main/webapp/MemberManage.jsp").contains("requiredPageKey\", \"memberManage\""));
        assertTrue(read("src/main/webapp/Admin.jsp").contains("requiredPageKey\", \"adminPage\""));
    }

    private String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
