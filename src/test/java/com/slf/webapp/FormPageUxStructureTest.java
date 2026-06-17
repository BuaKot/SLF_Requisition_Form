package com.slf.webapp;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

import junit.framework.TestCase;

public class FormPageUxStructureTest extends TestCase {

    private static String read(String path) throws IOException {
        return new String(Files.readAllBytes(Paths.get(path)), "UTF-8");
    }

    private static void assertHasClasses(String html, String tag, String... classes) {
        String token = "<" + tag;
        int searchFrom = 0;
        while (true) {
            int tagStart = html.indexOf(token, searchFrom);
            if (tagStart < 0) {
                fail("Missing <" + tag + "> with classes");
            }
            int tagEnd = html.indexOf(">", tagStart);
            if (tagEnd < 0) {
                fail("Malformed <" + tag + "> tag");
            }
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
                    if (allPresent) {
                        return;
                    }
                }
            }
            searchFrom = tagEnd + 1;
        }
    }

    public void testFormPageUsesEnterpriseSectionsWithoutChangingSubmitContract() throws IOException {
        String jsp = read("src/main/webapp/form.jsp");

        assertHasClasses(jsp, "main", "it-request-form-page", "form-container");
        assertHasClasses(jsp, "section", "form-section", "applicant-information", "panel");
        assertHasClasses(jsp, "section", "form-section", "request-information", "panel");
        assertHasClasses(jsp, "section", "form-section", "requested-items", "panel");
        assertHasClasses(jsp, "div", "request-item", "request-item-card");
        assertHasClasses(jsp, "div", "request-item-subsection", "additional-information");
        assertHasClasses(jsp, "div", "form-action-bar", "action-row");
        assertTrue(jsp.contains("aria-describedby"));

        assertTrue(jsp.contains("action=\"${pageContext.request.contextPath}/submitRequest\""));
        assertTrue(jsp.contains("id=\"name\" name=\"name\""));
        assertTrue(jsp.contains("id=\"departmentDisplay\""));
        assertTrue(jsp.contains("id=\"department\" name=\"department\""));
        assertTrue(jsp.contains("id=\"sectionDisplay\""));
        assertTrue(jsp.contains("id=\"section\" name=\"section\""));
        assertTrue(jsp.contains("id=\"phone\" name=\"phone\""));
        assertTrue(jsp.contains("id=\"date\" name=\"dateDisplay\""));
        assertTrue(jsp.contains("id=\"dateIso\" name=\"date\""));
        assertTrue(jsp.contains("id=\"deadlineText\" name=\"deadlineDisplay\""));
        assertTrue(jsp.contains("id=\"deadlinePicker\""));
        assertTrue(jsp.contains("id=\"deadlineIso\" name=\"deadline\""));
        assertTrue(jsp.contains("id=\"requestTopic\" name=\"requestTopic\""));
        assertTrue(jsp.contains("name=\"requestType[]\""));
        assertTrue(jsp.contains("name=\"programName[]\""));
        assertTrue(jsp.contains("name=\"serverName[]\""));
        assertTrue(jsp.contains("name=\"serverFolder[]\""));
        assertTrue(jsp.contains("name=\"folderPermission[]\""));
        assertTrue(jsp.contains("name=\"subFolder[]\""));
        assertTrue(jsp.contains("name=\"subFolderPermission[]\""));
        assertTrue(jsp.contains("name=\"otherRequest[]\""));
        assertTrue(jsp.contains("name=\"objective[]\""));
        assertTrue(jsp.contains("name=\"currentMethod[]\""));
        assertTrue(jsp.contains("id=\"addRequestBtn\""));
        assertTrue(jsp.contains("id=\"submitBtn\""));
        assertTrue(jsp.contains("id=\"requestsContainer\""));
        assertTrue(jsp.contains("request-delete-btn"));
    }

    public void testFormStylesExposeQuietEnterpriseFormComponents() throws IOException {
        String css = read("src/main/webapp/css/styles.css");

        assertTrue(css.contains(".it-request-form-page"));
        assertTrue(css.contains(".form-section"));
        assertTrue(css.contains(".section-heading"));
        assertTrue(css.contains(".request-item-card"));
        assertTrue(css.contains(".form-action-bar"));
        assertTrue(css.contains("--slf-page-content-width: calc(100% - 60px)"));
        assertTrue(css.contains("--slf-page-content-width-md: calc(100% - 32px)"));
        assertTrue(css.contains("--slf-page-content-width-sm: calc(100% - 24px)"));
        assertTrue(css.contains(".it-request-form-page.form-container"));
        assertTrue(css.contains("width: var(--slf-page-content-width)"));
        assertTrue(css.contains(".it-requisition-detail-page .it-action-section"));
        assertTrue(css.contains(".readonly-field"));
        assertTrue(css.contains(".field-required"));
        assertTrue(css.contains(".request-alert-actions"));
        assertTrue(css.contains(".it-request-form-page .form-group.has-byte-counter > input[type=\"text\"] + .byte-counter"));
        assertTrue(css.contains("top: 33px"));
        assertTrue(css.contains("bottom: auto"));
        assertTrue(css.contains("@media (max-width: 900px)"));
        assertTrue(css.contains("var(--slf-color-primary"));
    }

    public void testDetailPageKeepsLegacySafeFormCssSupport() throws IOException {
        String detail = read("src/main/webapp/detail.jsp");
        String css = read("src/main/webapp/css/styles.css");

        assertTrue(detail.contains("${pageContext.request.contextPath}/css/styles.css"));
        assertFalse(detail.contains("${pageContext.request.contextPath}/css/form.css"));
        assertTrue(detail.contains("class=\"enterprise-index-main it-requisition-detail-page requisition-detail-page\""));
        assertTrue(detail.contains("class=\"enterprise-hero index-banner it-requisition-banner requisition-detail-banner\""));
        assertTrue(detail.indexOf("class=\"detail-action-bar it-detail-back-row\"") > detail.indexOf("class=\"enterprise-hero index-banner it-requisition-banner requisition-detail-banner\""));
        assertFalse(detail.contains("class=\"topbar-back-row\""));
        assertTrue(detail.contains("class=\"banner\""));
        assertTrue(detail.contains("class=\"form-container\""));
        assertTrue(detail.contains("class=\"form-grid\""));
        assertTrue(detail.contains("class=\"form-group\""));
        assertTrue(detail.contains("class=\"btn-group detail-action-footer\""));
        assertTrue(detail.contains("class=\"action-row-btn detail-export-button\""));
        assertFalse(detail.contains("background:#dc2626"));
        assertTrue(detail.contains("class=\"form-group full-width server-permission-box\""));

        assertTrue(css.contains("Detail page legacy compatibility"));
        assertTrue(css.contains("#main > .banner"));
        assertTrue(css.contains("#main > .form-container:not(.it-request-form-page)"));
        assertTrue(css.contains(".requisition-detail-page > .form-container:not(.it-request-form-page)"));
        assertTrue(css.contains("width: var(--slf-page-content-width)"));
        assertTrue(css.contains(".form-container:not(.it-request-form-page)) .form-grid"));
        assertTrue(css.contains(".form-container:not(.it-request-form-page)) .form-group"));
        assertTrue(css.contains(".form-container:not(.it-request-form-page)) .btn-group"));
        assertTrue(css.contains(".form-container:not(.it-request-form-page)) .detail-action-footer"));
        assertTrue(css.contains(".detail-export-button"));
        assertTrue(css.contains(".form-container:not(.it-request-form-page)) .server-permission-box"));
    }
}
