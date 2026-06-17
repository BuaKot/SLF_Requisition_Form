package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ApprovalOnlyHomePageTest extends TestCase {

    public void testHomeUsesFormFirstNavigationWithoutWeakeningApprovalOnlyGuards() throws Exception {
        String index = read("src/main/webapp/index.jsp");
        String itDetail = read("src/main/webapp/WEB-INF/views/ItRequisitionFormDetail.jsp");
        String thirdPartyDetail = read("src/main/webapp/WEB-INF/views/ThirdPartyFormDetail.jsp");
        String sidebar = read("src/main/webapp/WEB-INF/jspf/sidebar.jspf");

        assertTrue(index.contains("approvalOnlyRole"));
        assertTrue(index.contains("canCreateInternalForms"));
        assertTrue(index.contains("canCreateThirdPartyLinks"));
        assertTrue(index.contains("/it-requisition-form-detail.jsp"));
        assertTrue(index.contains("/thirdParty/request/new"));
        assertTrue(index.contains("/third-party-form-detail.jsp"));

        assertTrue(itDetail.contains("approvalOnlyRole"));
        assertTrue(itDetail.contains("IT_REQUISITION_REQUEST"));
        assertTrue(itDetail.contains("/forms/select?code=IT_REQUISITION_REQUEST"));
        assertTrue(thirdPartyDetail.contains("ThirdPartyAccessPolicy.canCreateOwnLinks"));
        assertTrue(thirdPartyDetail.contains("THIRD_PARTY_USER_REGISTRATION"));
        assertTrue(thirdPartyDetail.contains("/forms/select?code=THIRD_PARTY_USER_REGISTRATION"));
        assertTrue(thirdPartyDetail.contains("form-type-action disabled"));

        assertFalse(index.contains("index-history-fab"));
        assertTrue(sidebar.contains("_sidebarApprovalOnlyRole && _sidebarApprovalPage != null"));
        assertTrue(sidebar.contains("!_sidebarApprovalOnlyRole && (_sidebarShowAdmin || _sidebarShowDashboard)"));
        assertFalse(sidebar.contains("boolean approvalOnlyRole"));
        assertFalse(sidebar.contains("String approvalPage"));
        assertFalse(sidebar.contains("String approvalLabel"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
