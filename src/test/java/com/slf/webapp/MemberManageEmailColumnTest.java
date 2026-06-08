package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

import junit.framework.TestCase;

public class MemberManageEmailColumnTest extends TestCase {

    public void testMemberTableHidesEmailButEditButtonKeepsIt() throws Exception {
        String page = new String(
            Files.readAllBytes(Paths.get("src/main/webapp/MemberManage.jsp")),
            StandardCharsets.UTF_8
        );

        assertFalse(page.contains("<th>Email แจ้งเตือน</th>"));
        assertTrue(page.contains("data-email=\"<%= h(member.getEmail()) %>\""));
    }
}
