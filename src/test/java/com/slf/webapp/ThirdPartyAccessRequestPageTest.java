package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartyAccessRequestPageTest extends TestCase {

    public void testPublicFormSupportsMultipleAccessRequestsWithoutSignature() throws Exception {
        String jsp = new String(Files.readAllBytes(
            Paths.get("src/main/webapp/thirdpartyForm.jsp")), StandardCharsets.UTF_8);

        assertTrue(jsp.contains("id=\"addAccessRequest\""));
        assertTrue(jsp.contains("name=\"accessSystem\""));
        assertTrue(jsp.contains("name=\"accessRole\""));
        assertTrue(jsp.contains("name=\"accessNationalId\""));
        assertTrue(jsp.contains("DSL"));
        assertFalse(jsp.contains("accessRequestType"));
        assertFalse(jsp.toLowerCase().contains("signature"));
    }
}
