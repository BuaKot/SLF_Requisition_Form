package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

import junit.framework.TestCase;

public class LoginServletMappingTest extends TestCase {

    public void testWebXmlExplicitlyMapsLoginRoutes() throws Exception {
        String source = new String(
            Files.readAllBytes(Paths.get("src/main/webapp/WEB-INF/web.xml")),
            StandardCharsets.UTF_8
        );

        assertTrue(source.contains("<servlet-class>com.slf.controller.LoadLoginServlet</servlet-class>"));
        assertTrue(source.contains("<url-pattern>/login</url-pattern>"));
        assertTrue(source.contains("<servlet-class>com.slf.controller.LoginProcessorServlet</servlet-class>"));
        assertTrue(source.contains("<url-pattern>/processLogin</url-pattern>"));
    }

    public void testExplicitlyMappedLoginServletsDoNotAlsoUseAnnotations() throws Exception {
        assertFalse(read("src/main/java/com/slf/controller/LoadLoginServlet.java").contains("@WebServlet"));
        assertFalse(read("src/main/java/com/slf/controller/LoginProcessorServlet.java").contains("@WebServlet"));
    }

    private String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
