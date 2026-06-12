package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartyConsentPageTest extends TestCase {

    public void testPublicFormRequiresConsentAndCarriesDisplayedVersion() throws Exception {
        String jsp = new String(Files.readAllBytes(
            Paths.get("src/main/webapp/thirdpartyForm.jsp")), StandardCharsets.UTF_8);

        assertTrue(jsp.contains("name=\"consentVersion\""));
        assertTrue(jsp.contains("name=\"consentAccepted\""));
        assertTrue(jsp.contains("value=\"accepted\" <%= \"accepted\".equals(request.getParameter(\"consentAccepted\")) ? \"checked\" : \"\" %> required"));
        assertTrue(jsp.contains("class=\"consent-note\""));
        assertTrue(jsp.contains("class=\"consent-extra\""));
        assertTrue(jsp.contains("<strong>"));
        assertFalse(jsp.contains("ThirdPartyConsent"));
    }
}
