package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ThirdPartyFormNavigationTest extends TestCase {

    public void testNewFormSelectionContainsBothRoutesAndGuardsThirdPartyCard() throws Exception {
        String page = read("src/main/webapp/form-selection.jsp");

        assertTrue(page.contains("IT_REQUISITION_REQUEST"));
        assertTrue(page.contains("THIRD_PARTY_USER_REGISTRATION"));
        assertTrue(page.contains("canCreateThirdPartyLinks.booleanValue()"));
    }

    public void testPublicFormRevalidatesWhenRestoredFromBrowserHistory() throws Exception {
        String page = read("src/main/webapp/thirdpartyForm.jsp");

        assertTrue(page.contains("no-store, no-cache, must-revalidate"));
        assertTrue(page.contains("event.persisted"));
        assertTrue(page.contains("window.location.reload()"));
    }

    public void testIndexSkipsThirdPartyDetailForAuthorizedCreators() throws Exception {
        String page = read("src/main/webapp/index.jsp");

        assertTrue(page.contains("String thirdPartyCreateUrl = canCreateThirdPartyLinks"));
        assertTrue(page.contains("? \"/thirdParty/request/new\" : \"/third-party-form-detail.jsp\""));
        assertTrue(page.contains("<%= thirdPartyCreateUrl %>"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
