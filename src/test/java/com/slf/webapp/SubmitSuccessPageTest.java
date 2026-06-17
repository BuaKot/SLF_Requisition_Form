package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class SubmitSuccessPageTest extends TestCase {

    public void testCreateNewRequestLinkUsesFormSelectionRoute() throws Exception {
        String page = new String(
            Files.readAllBytes(Paths.get("src/main/webapp/WEB-INF/views/SubmitSuccess.jsp")),
            StandardCharsets.UTF_8
        );

        assertTrue(page.contains("${pageContext.request.contextPath}/forms/select?code=IT_REQUISITION_REQUEST"));
        assertTrue(page.contains("${pageContext.request.contextPath}/it-requisition-form-detail.jsp"));
        assertFalse(page.contains("${pageContext.request.contextPath}/form.jsp"));
    }
}
