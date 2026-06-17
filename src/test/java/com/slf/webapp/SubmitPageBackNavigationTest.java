package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class SubmitPageBackNavigationTest extends TestCase {

    public void testSubmitPageBackButtonReturnsToItRequisitionDetail() throws Exception {
        String source = new String(
            Files.readAllBytes(Paths.get("src/main/webapp/WEB-INF/views/Submit.jsp")),
            StandardCharsets.UTF_8
        );

        assertTrue(source.contains("submit-home-button"));
        assertTrue(source.contains("${pageContext.request.contextPath}/it-requisition-form-detail.jsp"));
        assertFalse(source.contains("${pageContext.request.contextPath}/\""));
    }
}
