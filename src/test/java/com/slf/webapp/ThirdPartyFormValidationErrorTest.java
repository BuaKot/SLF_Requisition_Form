package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartyFormValidationErrorTest extends TestCase {

    public void testValidationErrorReturnsToPopulatedFormWithPopup() throws Exception {
        String servlet = read("src/main/java/com/slf/controller/ThirdPartySubmitServlet.java");
        String page = read("src/main/webapp/WEB-INF/views/ThirdPartyForm.jsp");

        assertTrue(servlet.contains("forwardFormError(request, response, link, rawToken, e.getMessage())"));
        assertTrue(servlet.contains("request.setAttribute(\"formError\", message)"));
        assertTrue(servlet.contains("request.getRequestDispatcher(\"/WEB-INF/views/ThirdPartyForm.jsp\")"));
        assertTrue(page.contains("id=\"formErrorPopup\""));
        assertTrue(page.contains("กลับไปแก้ไขข้อมูล"));
        assertTrue(page.contains("value=\"<%= h(request.getParameter(\"fullNameTh\")) %>\""));
        assertTrue(page.contains("submittedRows.forEach(addRow)"));
        assertTrue(page.contains("paramAt(request, \"accessFullNameTh\", i)"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
