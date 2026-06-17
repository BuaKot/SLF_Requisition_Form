package com.slf.webapp;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ListQueueUxStructureTest extends TestCase {

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }

    private static void assertHasClasses(String html, String tag, String... classes) {
        String token = "<" + tag;
        int searchFrom = 0;
        while (true) {
            int tagStart = html.indexOf(token, searchFrom);
            if (tagStart < 0) fail("Missing <" + tag + "> with classes");
            int tagEnd = html.indexOf(">", tagStart);
            if (tagEnd < 0) fail("Malformed <" + tag + "> tag");
            String tagText = html.substring(tagStart, tagEnd);
            int classIndex = tagText.indexOf("class=\"");
            if (classIndex >= 0) {
                int classStart = classIndex + "class=\"".length();
                int classEnd = tagText.indexOf("\"", classStart);
                if (classEnd >= 0) {
                    String classValue = " " + tagText.substring(classStart, classEnd) + " ";
                    boolean allPresent = true;
                    for (String className : classes) {
                        if (!classValue.contains(" " + className + " ")) {
                            allPresent = false;
                            break;
                        }
                    }
                    if (allPresent) return;
                }
            }
            searchFrom = tagEnd + 1;
        }
    }

    public void testSubmitQueueKeepsRoutesAndUsesScopedListUx() throws Exception {
        String jsp = read("src/main/webapp/WEB-INF/views/Submit.jsp");
        String css = read("src/main/webapp/css/styles.css");

        assertTrue(jsp.contains("SecurityUtil.ensureCsrfToken(request)"));
        assertTrue(jsp.contains("${pageContext.request.contextPath}/css/styles.css"));
        assertFalse(jsp.contains("${pageContext.request.contextPath}/css/submit.css"));
        assertTrue(jsp.contains("response.sendRedirect(request.getContextPath() + \"/login\")"));
        assertTrue(jsp.contains("form.action = contextPath + \"/SubmitApprovalServlet\""));
        assertTrue(jsp.contains("form.action = contextPath + \"/ExtendDeadlineServlet\""));
        assertTrue(jsp.contains("redirectPage: \"submit\""));
        assertTrue(jsp.contains("csrfToken: csrfToken"));
        assertTrue(jsp.contains("id=\"searchInput\""));
        assertTrue(jsp.contains("id=\"sortAscBtn\""));
        assertTrue(jsp.contains("id=\"sortDescBtn\""));
        assertTrue(jsp.contains("data-requestdate"));
        assertTrue(jsp.contains("a.dataset.requestdate"));
        assertTrue(jsp.contains("get('sortby') || 'formid'"));
        assertTrue(jsp.contains("get('sort') || 'desc'"));
        assertTrue(jsp.contains("value=\"pending\""));
        assertTrue(jsp.contains("value=\"overdue\""));
        assertTrue(jsp.contains("value=\"rejected\""));
        assertTrue(jsp.contains("value=\"approved\""));
        assertHasClasses(jsp, "main", "work-queue-page", "submitted-queue");
        assertHasClasses(jsp, "section", "queue-page-header");
        assertHasClasses(jsp, "section", "queue-toolbar");
        assertHasClasses(jsp, "section", "request-list");

        assertTrue(css.contains(".work-queue-page"));
        assertTrue(css.contains(".submitted-queue"));
        assertTrue(css.contains(".queue-toolbar"));
        assertTrue(css.contains(".filter-label input[type=\"checkbox\"]"));
        assertFalse(css.contains(".filter-label input[type=\"checkbox\"] { display: none; }"));
        assertTrue(css.contains(".filter-label input[type=\"checkbox\"]:focus-visible"));
    }

    public void testHistoryQueueKeepsQueryContractsAndAccessibleFilters() throws Exception {
        String jsp = read("src/main/webapp/WEB-INF/views/History.jsp");

        assertTrue(jsp.contains("<%@ include file=\"/WEB-INF/checkAuth.jsp\" %>"));
        assertTrue(jsp.contains("allowedBackPaths.contains(backParam)"));
        assertTrue(jsp.contains("MY_AI.REVIEWER_EMPID = ?"));
        assertTrue(jsp.contains("sp.set('show'"));
        assertTrue(jsp.contains("sp.set('sort'"));
        assertTrue(jsp.contains("sp.set('sortby'"));
        assertTrue(jsp.contains("&from=history"));
        assertTrue(jsp.contains("id=\"searchInput\""));
        assertTrue(jsp.contains("id=\"sortAscBtn\""));
        assertTrue(jsp.contains("value=\"rejected\""));
        assertTrue(jsp.contains("value=\"approved\""));
        assertHasClasses(jsp, "main", "work-queue-page", "history-work-queue");
        assertHasClasses(jsp, "section", "queue-page-header");
        assertHasClasses(jsp, "section", "queue-toolbar");
        assertHasClasses(jsp, "section", "history-list");
        assertFalse(jsp.contains(".filter-label input[type=\"checkbox\"] { display: none; }"));
    }

    public void testApprovalQueueUsesSharedTemplateAndScopedStyles() throws Exception {
        String shared = read("src/main/webapp/WEB-INF/views/ApprovalList.jsp");
        String css = read("src/main/webapp/css/styles.css");
        String[] wrappers = {"DirectorApprove.jsp", "ITDirectorApprove.jsp", "TechnicalApprove.jsp", "Process.jsp"};

        for (String wrapper : wrappers) {
            String source = read("src/main/webapp/WEB-INF/views/" + wrapper);
            assertTrue(source.contains("<%@ include file=\"/WEB-INF/checkAuth.jsp\" %>"));
            assertTrue(source.contains("<jsp:include page=\"/WEB-INF/views/ApprovalList.jsp\" />"));
            assertTrue(source.contains("approvalDetailPage"));
            assertTrue(source.contains("approvalHistoryBackPage"));
        }

        assertTrue(shared.contains("approvalDetailPage"));
        assertTrue(shared.contains("approvalHistoryBackPage"));
        assertTrue(shared.contains("${pageContext.request.contextPath}<%= approvalDetailPage %>?id="));
        assertTrue(shared.contains("/history.jsp?back="));
        assertHasClasses(shared, "main", "approval-list");
        assertHasClasses(shared, "header", "queue-page-header", "approval-header");
        assertHasClasses(shared, "div", "queue-summary");
        assertHasClasses(shared, "a", "requisition-card");
        assertTrue(shared.contains("empty-state"));
        assertFalse(shared.contains("<style"));
        assertTrue(css.contains("body.view-approval-list"));
        assertTrue(css.contains("@media (max-width: 900px)"));
    }
}
