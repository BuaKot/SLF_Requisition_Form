package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class DetailBackNavigationTest extends TestCase {

    public void testDetailKeepsNavigationAndAllowsRelatedReviewerAccess() throws Exception {
        String source = read("src/main/webapp/WEB-INF/views/Detail.jsp");
        String servlet = read("src/main/java/com/slf/controller/RequisitionOwnerDetailServlet.java");
        String forwarder = read("src/main/java/com/slf/controller/ViewForwardServlet.java");

        assertTrue(source.contains("request.getParameter(\"from\")"));
        assertTrue(source.contains("\"history\".equals(fromPage) ? \"history.jsp\" : \"submit\""));
        assertTrue(source.contains("requisitionDetailAuthorized"));
        assertTrue(source.contains("VIEWER_AI.REVIEWER_EMPID = ?"));
        assertTrue(source.contains("RF.EMPID = ? OR EXISTS"));

        assertTrue(servlet.contains("@WebServlet(\"/detail.jsp\")"));
        assertTrue(servlet.contains("ai.REVIEWER_EMPID = ?"));
        assertTrue(servlet.contains("rf.EMPID = ? OR EXISTS"));
        assertTrue(servlet.contains("SC_NOT_FOUND"));
        assertTrue(servlet.contains("/WEB-INF/views/Detail.jsp"));
        assertFalse(forwarder.contains("views.put(\"/detail.jsp\""));
    }

    public void testTechnicalDetailUsesIndexBannerAlignedBackButtonAndInlineCounters() throws Exception {
        String page = read("src/main/webapp/WEB-INF/views/RequisitionDetailComment.jsp");
        String styles = read("src/main/webapp/css/styles.css");

        assertTrue(page.contains("enterprise-hero index-banner it-requisition-banner requisition-detail-banner"));
        assertTrue(page.contains("detail-action-bar it-detail-back-row"));
        assertTrue(page.contains("readonly data-maxbytes=\"255\""));
        assertTrue(page.contains("classList.add(\"has-byte-counter\")"));
        assertTrue(styles.contains("body.view-requisition-detail-comment .form-group.has-byte-counter"));
    }

    public void testApprovalDetailsUseRoleSpecificGuardsBeforeLoadingItems() throws Exception {
        String filter = read("src/main/java/com/slf/filter/RoleBasedAccessFilter.java");
        assertTrue(filter.contains("path.equals(\"/RequisitionDetail.jsp\")"));
        assertTrue(filter.contains("pageKey = \"directorApprove\""));
        assertTrue(filter.contains("path.equals(\"/RequisitionDetail_Comment.jsp\")"));
        assertTrue(filter.contains("pageKey = \"technicalApprove\""));
        assertTrue(filter.contains("path.equals(\"/RequisitionDetail_ITDirector.jsp\")"));
        assertTrue(filter.contains("pageKey = \"itDirectorApprove\""));
        assertTrue(filter.contains("path.equals(\"/RequisitionDetail_Process.jsp\")"));
        assertTrue(filter.contains("pageKey = \"process\""));

        assertGuardBeforeItems("RequisitionDetail.jsp", "!canApproveDirectorStep");
        assertGuardBeforeItems("RequisitionDetailComment.jsp", "!canApproveExpectedStep");
        assertGuardBeforeItems("RequisitionDetailITDirector.jsp", "!canApproveExpectedStep");
        assertGuardBeforeItems("RequisitionDetailProcess.jsp", "!canApproveExpectedStep");
    }

    private static void assertGuardBeforeItems(String fileName, String guard) throws Exception {
        String source = read("src/main/webapp/WEB-INF/views/" + fileName);
        int guardIndex = source.indexOf(guard);
        int itemQueryIndex = source.indexOf("// ----- Request items -----");
        assertTrue(fileName + " should contain authorization guard", guardIndex >= 0);
        assertTrue(fileName + " should reject before loading item details", guardIndex < itemQueryIndex);
        assertTrue(source.substring(guardIndex, itemQueryIndex).contains("SC_FORBIDDEN"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
