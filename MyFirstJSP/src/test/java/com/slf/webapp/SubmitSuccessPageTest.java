package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

import junit.framework.TestCase;

public class SubmitSuccessPageTest extends TestCase {

    public void testCreateNewRequestLinkUsesLoadFormServlet() throws Exception {
        String page = new String(
            Files.readAllBytes(Paths.get("src/main/webapp/submit-success.jsp")),
            StandardCharsets.UTF_8
        );

        assertTrue(page.contains("${pageContext.request.contextPath}/newForm"));
        assertFalse(page.contains("${pageContext.request.contextPath}/form.jsp"));
    }
}
