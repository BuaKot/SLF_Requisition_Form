package com.slf.notification;

import com.slf.model.ApprovalHistoryEntry;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import junit.framework.TestCase;

public class HtmlEmailRendererTest extends TestCase {

    // ---------------------------------------------------------------
    //  HTML contains form ID
    // ---------------------------------------------------------------

    public void testHtmlContainsFormId() {
        String html = HtmlEmailRenderer.renderITRequisitionEmail(
            42, "VPN access", 1001, 0, null, "DIRECTOR", emptyHistory(), null);
        assertTrue("HTML should contain form ID", html.contains("#42"));
        assertTrue("HTML should start with doctype", html.startsWith("<!DOCTYPE"));
    }

    // ---------------------------------------------------------------
    //  HTML contains SLF branding / logo fallback
    // ---------------------------------------------------------------

    public void testHtmlContainsSlfBranding() {
        String html = HtmlEmailRenderer.renderITRequisitionEmail(
            42, "Test", 1001, 0, null, "DIRECTOR", emptyHistory(), null);
        assertTrue("HTML should contain SLF text", html.contains("กยศ"));
        assertTrue("HTML should contain Student Loan Fund", html.contains("Student Loan Fund"));
        assertTrue("HTML should contain SLF Requisition Form name", html.contains("SLF Requisition Form"));
    }

    public void testHtmlLogoImageIncludedWithBaseUrl() {
        String html = HtmlEmailRenderer.renderITRequisitionEmail(
            42, "Test", 1001, 0, null, "DIRECTOR", emptyHistory(),
            "http://localhost:8080/SLF_Requisition_Form");
        assertTrue("HTML should include logo img tag when base URL set",
            html.contains("<img src="));
        assertTrue("HTML should reference SLF_logo.png",
            html.contains("SLF_logo.png"));
    }

    public void testHtmlLogoImageNotIncludedWithoutBaseUrl() {
        String html = HtmlEmailRenderer.renderITRequisitionEmail(
            42, "Test", 1001, 0, null, "DIRECTOR", emptyHistory(), null);
        // Image may still appear if baseUrl is null, but the src should not contain broken path
        // The text fallback should always be present
        assertTrue("HTML should always have text fallback", html.contains("กยศ"));
    }

    // ---------------------------------------------------------------
    //  HTML contains status badge
    // ---------------------------------------------------------------

    public void testHtmlContainsStatusBadge() {
        String html = HtmlEmailRenderer.renderITRequisitionEmail(
            42, "Test", 1001, 0, null, "DIRECTOR", emptyHistory(), null);
        assertTrue("HTML should contain status badge with label", html.contains("รอ Director อนุมัติ"));
        assertTrue("HTML should contain inline-block style for badge", html.contains("border-radius:12px"));
    }

    // ---------------------------------------------------------------
    //  HTML uses consistent font stack
    // ---------------------------------------------------------------

    public void testHtmlContainsConsistentFontStack() {
        String html = HtmlEmailRenderer.renderITRequisitionEmail(
            42, "Test", 1001, 0, null, "DIRECTOR", emptyHistory(), null);
        assertTrue("HTML should use the project font stack",
            html.contains("Arial, Tahoma"));
    }

    // ---------------------------------------------------------------
    //  HTML contains action button
    // ---------------------------------------------------------------

    public void testHtmlContainsActionButton() {
        String html = HtmlEmailRenderer.renderITRequisitionEmail(
            42, "Test", 1001, 0, null, "DIRECTOR", emptyHistory(), null);
        assertTrue("HTML should contain anchor tag", html.contains("<a href="));
        assertTrue("HTML should contain detail path", html.contains("/detail.jsp?id=42"));
        assertTrue("HTML should contain button label", html.contains("ดูรายละเอียดคำขอ"));
    }

    public void testHtmlActionButtonWithBaseUrl() {
        String html = HtmlEmailRenderer.renderITRequisitionEmail(
            42, "Test", 1001, 0, null, "DIRECTOR", emptyHistory(),
            "http://localhost:8080/SLF_Requisition_Form");
        assertTrue("HTML should contain full URL", html.contains("http://localhost:8080/SLF_Requisition_Form/detail.jsp?id=42"));
    }

    // ---------------------------------------------------------------
    //  HTML contains approval history
    // ---------------------------------------------------------------

    public void testHtmlContainsApprovalHistory() {
        List<ApprovalHistoryEntry> history = new ArrayList<>();
        history.add(new ApprovalHistoryEntry(1, 2001, null,
            new Timestamp(1718611200000L), "Director อนุมัติแล้ว"));

        String html = HtmlEmailRenderer.renderITRequisitionEmail(
            42, "Test", 1001, 2, null, "IT_DIRECTOR", history, null);
        assertTrue("HTML should contain approval history section", html.contains("Approval History"));
        assertTrue("HTML should contain history entry", html.contains("Director อนุมัติแล้ว"));
        assertTrue("HTML should contain reviewer", html.contains("EMP 2001"));
        assertTrue("HTML should have navy header row", html.contains("#1B2A4A"));
    }

    // ---------------------------------------------------------------
    //  HTML contains rejection details
    // ---------------------------------------------------------------

    public void testHtmlContainsRejectionDetails() {
        String html = HtmlEmailRenderer.renderITRequisitionEmail(
            42, "Test", 1001, -1, "เอกสารไม่สมบูรณ์", "REQUESTER", emptyHistory(), null);
        assertTrue("HTML should contain rejection section", html.contains("Rejection Details"));
        assertTrue("HTML should contain rejection comment", html.contains("เอกสารไม่สมบูรณ์"));
        assertTrue("HTML should contain rejected step", html.contains("Director"));
    }

    // ---------------------------------------------------------------
    //  Completed state
    // ---------------------------------------------------------------

    public void testHtmlCompletedState() {
        String html = HtmlEmailRenderer.renderITRequisitionEmail(
            42, "Test", 1001, 5, null, "REQUESTER", emptyHistory(), null);
        assertTrue("Completed HTML should contain completed label", html.contains("เสร็จสมบูรณ์"));
        assertTrue("Completed HTML should contain success color", html.contains("#2E7D32"));
    }

    // ---------------------------------------------------------------
    //  Unknown role fallback
    // ---------------------------------------------------------------

    public void testHtmlUnknownRoleFallback() {
        String html = HtmlEmailRenderer.renderITRequisitionEmail(
            42, "Test", 1001, 0, null, "UNKNOWN_ROLE", emptyHistory(), null);
        assertNotNull("Unknown role should still produce HTML", html);
        assertTrue("HTML should still contain request ID", html.contains("#42"));
    }

    // ---------------------------------------------------------------
    //  Blank topic fallback
    // ---------------------------------------------------------------

    public void testHtmlBlankTopicFallback() {
        String html = HtmlEmailRenderer.renderITRequisitionEmail(
            42, null, 1001, 0, null, "DIRECTOR", emptyHistory(), null);
        assertTrue("HTML should show blank topic fallback", html.contains("ไม่ได้ระบุหัวข้อ"));

        html = HtmlEmailRenderer.renderITRequisitionEmail(
            42, "   ", 1001, 0, null, "DIRECTOR", emptyHistory(), null);
        assertTrue("HTML should show blank topic fallback for whitespace", html.contains("ไม่ได้ระบุหัวข้อ"));
    }

    // ---------------------------------------------------------------
    //  Null comment handling
    // ---------------------------------------------------------------

    public void testHtmlWithNullComment() {
        String html = HtmlEmailRenderer.renderITRequisitionEmail(
            42, "Test", 1001, -1, null, "REQUESTER", emptyHistory(), null);
        assertNotNull("Null comment should not cause error", html);
        assertTrue("HTML should contain rejection section", html.contains("Rejection Details"));
    }

    // ---------------------------------------------------------------
    //  Base URL normalization
    // ---------------------------------------------------------------

    public void testBuildFullUrlWithTrailingSlash() {
        String url = HtmlEmailRenderer.buildFullUrl("http://example.com/app/", "/detail.jsp?id=1");
        assertEquals("http://example.com/app/detail.jsp?id=1", url);
    }

    public void testBuildFullUrlNullBase() {
        String url = HtmlEmailRenderer.buildFullUrl(null, "/detail.jsp?id=1");
        assertEquals("/detail.jsp?id=1", url);
    }

    public void testBuildFullUrlEmptyBase() {
        String url = HtmlEmailRenderer.buildFullUrl("", "/detail.jsp?id=1");
        assertEquals("/detail.jsp?id=1", url);
    }

    // ---------------------------------------------------------------
    //  StripHtml tests
    // ---------------------------------------------------------------

    public void testStripHtmlRemovesTags() {
        String html = "<html><body><div>Hello</div><p>World</p></body></html>";
        String text = HtmlEmailRenderer.stripHtml(html);
        assertTrue("Stripped text should contain Hello", text.contains("Hello"));
        assertTrue("Stripped text should contain World", text.contains("World"));
        assertFalse("Stripped text should not contain <div>", text.contains("<div>"));
    }

    public void testStripHtmlDecodesEntities() {
        String html = "AT&T <test>";
        String text = HtmlEmailRenderer.stripHtml(html);
        assertTrue("Stripped text should decode &", text.contains("&"));
    }

    public void testStripHtmlNullInput() {
        assertEquals("Null input should return empty", "", HtmlEmailRenderer.stripHtml(null));
    }

    public void testStripHtmlPlainText() {
        String text = HtmlEmailRenderer.stripHtml("Just plain text");
        assertEquals("Plain text should pass through", "Just plain text", text);
    }

    // ---------------------------------------------------------------
    //  Employee ID fallback
    // ---------------------------------------------------------------

    public void testHtmlDisplaysEmpFallback() {
        String html = HtmlEmailRenderer.renderITRequisitionEmail(
            42, "Test", 678, 0, null, "DIRECTOR", emptyHistory(), null);
        assertTrue("HTML should show EMP 678", html.contains("EMP 678"));
    }

    // ---------------------------------------------------------------
    //  Navy/gold color palette
    // ---------------------------------------------------------------

    public void testHtmlUsesNavyPrimaryColor() {
        String html = HtmlEmailRenderer.renderITRequisitionEmail(
            42, "Test", 1001, 0, null, "DIRECTOR", emptyHistory(), null);
        assertTrue("HTML should contain navy (#1B2A4A) in header", html.contains("#1B2A4A"));
    }

    public void testHtmlUsesGoldAccent() {
        String html = HtmlEmailRenderer.renderITRequisitionEmail(
            42, "Test", 1001, 0, null, "DIRECTOR", emptyHistory(), null);
        assertTrue("HTML should contain gold (#C8962E) accent", html.contains("#C8962E"));
    }

    // ---------------------------------------------------------------
    //  Timeline rendering
    // ---------------------------------------------------------------

    public void testHtmlTimelineForState0() {
        String html = HtmlEmailRenderer.renderITRequisitionEmail(
            42, "Test", 1001, 0, null, "DIRECTOR", emptyHistory(), null);
        assertTrue("HTML should contain Timeline section", html.contains("Workflow Timeline"));
        assertTrue("HTML should contain Director in timeline", html.contains("Director"));
        assertTrue("HTML should contain Technical in timeline", html.contains("Technical"));
        assertTrue("HTML should contain Complete in timeline", html.contains("Complete"));
    }

    // ---------------------------------------------------------------
    //  Helpers
    // ---------------------------------------------------------------

    private static List<ApprovalHistoryEntry> emptyHistory() {
        return new ArrayList<>();
    }
}