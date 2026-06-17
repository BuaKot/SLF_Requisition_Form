package com.slf.notification;

import com.slf.model.ApprovalHistoryEntry;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import junit.framework.TestCase;

public class EmailContentBuilderTest extends TestCase {

    // ---------------------------------------------------------------
    //  Subject tests
    // ---------------------------------------------------------------

    public void testSubjectContainsFormIdAndStatus() {
        String subject = EmailContentBuilder.buildITRequisitionSubject(42, 0);
        assertTrue("Subject should contain form ID", subject.contains("#42"));
        assertTrue("Subject should contain status label", subject.contains("รอ Director อนุมัติ"));
    }

    public void testSubjectForCompletedState() {
        String subject = EmailContentBuilder.buildITRequisitionSubject(99, 5);
        assertTrue("Subject should contain form ID", subject.contains("#99"));
        assertTrue("Subject should contain completed label", subject.contains("เสร็จสมบูรณ์"));
    }

    public void testSubjectForRejectedState() {
        String subject = EmailContentBuilder.buildITRequisitionSubject(55, -2);
        assertTrue("Subject should contain form ID", subject.contains("#55"));
        assertTrue("Subject should contain rejection label", subject.contains("ถูกปฏิเสธ"));
    }

    public void testThirdPartySubjectContainsRequestId() {
        String subject = EmailContentBuilder.buildThirdPartySubject(123, "PENDING");
        assertTrue("Subject should contain request ID", subject.contains("#123"));
        assertTrue("Subject should contain status", subject.contains("PENDING"));
    }

    // ---------------------------------------------------------------
    //  Body content tests
    // ---------------------------------------------------------------

    public void testBodyContainsRequestSummarySection() {
        String body = EmailContentBuilder.buildITRequisitionBody(
            42, "VPN access", 1001, 0, null, "DIRECTOR", emptyHistory());
        assertTrue("Body should contain Form ID", body.contains("#42"));
        assertTrue("Body should contain requester", body.contains("1001"));
        assertTrue("Body should contain topic", body.contains("VPN access"));
        assertTrue("Body should contain 'Request Summary' section", body.contains("สรุปคำขอ"));
    }

    public void testBodyContainsCurrentStep() {
        String body = EmailContentBuilder.buildITRequisitionBody(
            42, "Test", 1001, 0, null, "DIRECTOR", emptyHistory());
        assertTrue("Body should contain current step label", body.contains("รอ Director อนุมัติ"));
        assertTrue("Body should contain 'Current Step' section", body.contains("ขั้นตอนปัจจุบัน"));
    }

    public void testBodyContainsWorkflowTimeline() {
        String body = EmailContentBuilder.buildITRequisitionBody(
            42, "Test", 1001, 0, null, "DIRECTOR", emptyHistory());
        assertTrue("Body should contain timeline markers [⬜]", body.contains("[⬜]"));
        assertTrue("Body should contain timeline markers [🔄]", body.contains("[🔄]"));
        assertTrue("Body should contain 'Workflow Timeline' section", body.contains("Workflow Timeline"));
    }

    public void testBodyContainsRoleSpecificActionMessage() {
        String directorBody = EmailContentBuilder.buildITRequisitionBody(
            42, "Test", 1001, 0, null, "DIRECTOR", emptyHistory());
        assertTrue("Director body should mention director action",
            directorBody.contains("Director") && directorBody.contains("อนุมัติ"));

        String requesterBody = EmailContentBuilder.buildITRequisitionBody(
            42, "Test", 1001, 5, null, "REQUESTER", emptyHistory());
        assertTrue("Requester body (completed) should mention completed",
            requesterBody.contains("ดำเนินการครบถ้วน"));

        String technicalBody = EmailContentBuilder.buildITRequisitionBody(
            42, "Test", 1001, 1, null, "TECHNICAL", emptyHistory());
        assertTrue("Technical body should mention technical action",
            technicalBody.contains("อนุมัติ"));
    }

    public void testBodyContainsNextActionSection() {
        String body = EmailContentBuilder.buildITRequisitionBody(
            42, "Test", 1001, 0, null, "DIRECTOR", emptyHistory());
        assertTrue("Body should contain Next Action section", body.contains("Next Action"));
    }

    public void testBodyContainsRouteLink() {
        String body = EmailContentBuilder.buildITRequisitionBody(
            42, "Test", 1001, 0, null, "DIRECTOR", emptyHistory());
        assertTrue("Body should contain route path with form ID",
            body.contains("/detail.jsp?id=42"));
    }

    // ---------------------------------------------------------------
    //  Completed state
    // ---------------------------------------------------------------

    public void testCompletedStateShowsAllStepsCompleted() {
        String body = EmailContentBuilder.buildITRequisitionBody(
            42, "Test", 1001, 5, null, "REQUESTER", emptyHistory());
        assertTrue("Completed body should contain [✅] markers", body.contains("[✅]"));
        assertTrue("Completed body should contain completed label", body.contains("เสร็จสมบูรณ์"));
        // All positive steps should show as completed
        assertTrue("Completed body should not contain [🔄]", !body.contains("[🔄]"));
        assertTrue("Completed body should not contain [⬜]", !body.contains("[⬜]"));
    }

    // ---------------------------------------------------------------
    //  Rejected state
    // ---------------------------------------------------------------

    public void testRejectedStateShowsRejectionSection() {
        String body = EmailContentBuilder.buildITRequisitionBody(
            42, "Test", 1001, -1, "เอกสารไม่ครบถ้วน", "REQUESTER", emptyHistory());
        assertTrue("Rejected body should contain rejection section", body.contains("Rejection Details"));
        assertTrue("Rejected body should contain [❌] marker", body.contains("[❌]"));
        assertTrue("Rejected body should contain rejection comment", body.contains("เอกสารไม่ครบถ้วน"));
        assertTrue("Rejected body should mention who rejected", body.contains("Director"));
    }

    public void testRejectedStateStep2() {
        String body = EmailContentBuilder.buildITRequisitionBody(
            42, "Test", 1001, -3, null, "REQUESTER", emptyHistory());
        assertTrue("Rejected at IT Director should mention IT Director", body.contains("IT Director"));
    }

    // ---------------------------------------------------------------
    //  Approval history section
    // ---------------------------------------------------------------

    public void testBodyContainsApprovalHistorySection() {
        List<ApprovalHistoryEntry> history = new ArrayList<>();
        history.add(new ApprovalHistoryEntry(0, 2001, null,
            new Timestamp(1718611200000L), "Director อนุมัติแล้ว"));
        history.add(new ApprovalHistoryEntry(1, 3001, "ดำเนินการต่อได้",
            new Timestamp(1718697600000L), "Technical อนุมัติแล้ว"));

        String body = EmailContentBuilder.buildITRequisitionBody(
            42, "Test", 1001, 2, null, "IT_DIRECTOR", history);
        assertTrue("Body should contain Approval History section", body.contains("Approval History"));
        assertTrue("Body should contain first history entry", body.contains("Director อนุมัติแล้ว"));
        assertTrue("Body should contain second history entry", body.contains("Technical อนุมัติแล้ว"));
        assertTrue("Body should contain reviewer emp ID", body.contains("2001"));
        assertTrue("Body should contain comment from history", body.contains("ดำเนินการต่อได้"));
    }

    public void testApprovalHistoryEmptyWhenListIsNull() {
        String section = EmailContentBuilder.buildApprovalHistorySection(null);
        assertTrue("Empty history should have fallback text", section.contains("ไม่มีประวัติ"));
    }

    public void testApprovalHistoryEmptyWhenListIsEmpty() {
        String section = EmailContentBuilder.buildApprovalHistorySection(new ArrayList<>());
        assertTrue("Empty history should have fallback text", section.contains("ไม่มีประวัติ"));
    }

    // ---------------------------------------------------------------
    //  Unknown state fallback
    // ---------------------------------------------------------------

    public void testUnknownStateFallback() {
        String label = EmailContentBuilder.resolveWorkflowStepLabel(999);
        assertTrue("Unknown state should produce fallback label", label.contains("มีการเปลี่ยนแปลง"));
        assertTrue("Fallback should contain state number", label.contains("999"));
    }

    public void testUnknownRoleFallback() {
        String message = EmailContentBuilder.resolveRoleActionMessage("UNKNOWN_ROLE", 0);
        assertNotNull("Unknown role should produce fallback message", message);
        assertFalse("Fallback message should not be empty", message.trim().isEmpty());
    }

    public void testNullRoleFallback() {
        String message = EmailContentBuilder.resolveRoleActionMessage(null, 0);
        assertNotNull("Null role should produce fallback message", message);
        assertFalse("Fallback message should not be empty", message.trim().isEmpty());
    }

    // ---------------------------------------------------------------
    //  Third-party body
    // ---------------------------------------------------------------

    public void testThirdPartyBodyContainsRequestId() {
        String body = EmailContentBuilder.buildThirdPartyBody(123, "Test body lead", null, "SUBMITTED");
        assertTrue("Third-party body should contain request ID", body.contains("#123"));
        assertTrue("Third-party body should contain status", body.contains("SUBMITTED"));
        assertTrue("Third-party body should contain body lead", body.contains("Test body lead"));
        assertTrue("Third-party body should contain route link", body.contains("/third-party-form-detail.jsp"));
    }

    // ---------------------------------------------------------------
    //  Role mapping for all states
    // ---------------------------------------------------------------

    public void testRoleMappingForDirector() {
        String message = EmailContentBuilder.resolveRoleActionMessage("DIRECTOR", 0);
        assertTrue("Director message should mention approving", message.contains("อนุมัติ"));
    }

    public void testRoleMappingForTechnical() {
        String message = EmailContentBuilder.resolveRoleActionMessage("TECHNICAL", 1);
        assertTrue("Technical message should mention approval", message.contains("อนุมัติ"));
    }

    public void testRoleMappingForItDirector() {
        String message = EmailContentBuilder.resolveRoleActionMessage("IT_DIRECTOR", 2);
        assertTrue("IT Director message should mention approval", message.contains("อนุมัติ"));
    }

    public void testRoleMappingForTechnician() {
        String message = EmailContentBuilder.resolveRoleActionMessage("TECHNICIAN", 3);
        assertTrue("Technician message should mention action", message.contains("ดำเนินการ"));
    }

    public void testRoleMappingForRequesterCompleted() {
        String message = EmailContentBuilder.resolveRoleActionMessage("REQUESTER", 5);
        assertTrue("Requester completed message should mention completion", message.contains("ครบถ้วน"));
    }

    public void testRoleMappingForRequesterRejected() {
        String message = EmailContentBuilder.resolveRoleActionMessage("REQUESTER", -1);
        assertTrue("Requester rejected message should mention rejection", message.contains("ปฏิเสธ"));
    }

    // ---------------------------------------------------------------
    //  Timeline rendering edge cases
    // ---------------------------------------------------------------

    public void testTimelineForState0() {
        String timeline = EmailContentBuilder.buildWorkflowTimeline(0);
        assertTrue("State 0 timeline should have [🔄] for step 0", timeline.contains("[🔄]"));
        assertTrue("State 0 timeline should have [⬜] for step 1", timeline.contains("[⬜]"));
        assertTrue("State 0 timeline should not have [✅] for any step", !timeline.contains("[✅]"));
    }

    public void testTimelineForState3() {
        String timeline = EmailContentBuilder.buildWorkflowTimeline(3);
        assertTrue("State 3 timeline should have [✅] for steps 0-2", timeline.contains("[✅]"));
        assertTrue("State 3 timeline should have [🔄] for step 3", timeline.contains("[🔄]"));
        assertTrue("State 3 timeline should have [⬜] for remaining steps", timeline.contains("[⬜]"));
    }

    public void testTimelineForState5() {
        String timeline = EmailContentBuilder.buildWorkflowTimeline(5);
        // All steps should be [✅]
        String[] lines = timeline.split("\n");
        for (String line : lines) {
            if (line.trim().isEmpty()) continue;
            assertTrue("Completed state timeline should have only [✅] markers: " + line,
                line.contains("[✅]"));
        }
    }

    // ---------------------------------------------------------------
    //  Next actor label
    // ---------------------------------------------------------------

    public void testNextActorLabelForState0() {
        assertEquals("Director", EmailContentBuilder.resolveNextActorLabel(0));
    }

    public void testNextActorLabelForCompleted() {
        assertEquals("-", EmailContentBuilder.resolveNextActorLabel(5));
    }

    // ---------------------------------------------------------------
    //  Rejection details section
    // ---------------------------------------------------------------

    public void testRejectionDetailsWithComment() {
        String section = EmailContentBuilder.buildRejectionDetailsSection(-1, "เอกสารไม่สมบูรณ์");
        assertTrue("Should mention rejected step", section.contains("Director"));
        assertTrue("Should include comment", section.contains("เอกสารไม่สมบูรณ์"));
    }

    public void testRejectionDetailsWithoutComment() {
        String section = EmailContentBuilder.buildRejectionDetailsSection(-3, null);
        assertTrue("Should mention IT Director", section.contains("IT Director"));
    }

    // ---------------------------------------------------------------
    //  Route path
    // ---------------------------------------------------------------

    public void testRoutePathContainsFormId() {
        String path = EmailContentBuilder.resolveRoutePath(77);
        assertEquals("/detail.jsp?id=77", path);
    }

    // ---------------------------------------------------------------
    //  Helpers
    // ---------------------------------------------------------------

    private static List<ApprovalHistoryEntry> emptyHistory() {
        return new ArrayList<>();
    }
}