# SLF Requisition Form - Project Context

Updated: 2026-06-17

This is the handoff document for the current repository state. It intentionally reflects the cleanup that moved secured JSPs under `WEB-INF/views`, consolidated local JSP CSS into `styles.css`, removed unused Rust/native captcha artifacts, and archived the removed SQL file list.

## Project Overview

`SLF_Requisition_Form` is a Maven WAR application deployed locally as:

`http://localhost:8080/SLF_Requisition_Form`

It is a classic Servlet/JSP enterprise workflow app for:

- internal IT requisition creation, approval, processing, and confirmation;
- third-party external user registration through secure token links;
- third-party internal review, grant, acceptance, revoke, report, and final certification workflow;
- email notification logging/dispatch;
- admin/member/mail-log/support screens.

The application is route-sensitive and test-sensitive. Many tests assert exact servlet paths, JSP includes, status strings, CSS classes, and workflow state values.

## Current Cleanup State

Important structural changes already done:

- Internal JSP views now live in `src/main/webapp/WEB-INF/views`.
- Public root keeps `index.jsp` only as the main landing page.
- Legacy public JSP URLs are preserved through servlet mappings and `ViewForwardServlet`.
- `Admin.css`, `form.css`, and `submit.css` are no longer the intended CSS entry points; views use `src/main/webapp/css/styles.css`.
- Remaining JSP-local `<style>` blocks were migrated into `styles.css` under scoped `body.view-*` sections.
- PDF print page CSS was moved into `styles.css`; PDF pages use named `@page` rules.
- SQL migration files under `sql/` were removed after writing `docs/sql-removal-log.md`.
- Rust/native captcha files and `CryptoBridge.java` were removed because current login uses `JavaCaptchaService`.
- `src/main/resources/db.properties` is intentionally left in place for now.

## Technology Stack

- Java Servlet/JSP on Tomcat 9.
- Maven WAR project, final name `SLF_Requisition_Form`.
- JSP/JSTL, HTML/CSS/JavaScript.
- Oracle JDBC through HikariCP.
- JavaMail SMTP notification dispatch.
- JUnit 3 style tests under `src/test/java`.
- Self-hosted Anuphan font in `src/main/webapp/css/fonts`.

Useful commands:

```powershell
mvn test
mvn package
rg --files
rg -n "@WebServlet|RequestDispatcher|WEB-INF/views" src/main/java
rg -n "<style|Admin.css|form.css|submit.css" src/main/webapp
```

## Runtime Routes And Views

Views should be forwarded to, not linked to directly under `WEB-INF/views`.

Main route preservation:

- `/login` and `/login.jsp` -> `LoadLoginServlet` -> `WEB-INF/views/Login.jsp`
- `/index.jsp` remains public root landing page.
- `/it-requisition-form-detail.jsp` -> `ViewForwardServlet` -> `WEB-INF/views/ItRequisitionFormDetail.jsp`
- `/third-party-form-detail.jsp` -> `ViewForwardServlet` -> `WEB-INF/views/ThirdPartyFormDetail.jsp`
- `/detail.jsp` -> `ViewForwardServlet` -> `WEB-INF/views/Detail.jsp`
- `/pdf.jsp` -> `ViewForwardServlet` -> `WEB-INF/views/Pdf.jsp`
- `/submit-success` and `/submit-success.jsp` -> `ViewForwardServlet` -> `WEB-INF/views/SubmitSuccess.jsp`

IT requisition routes:

- `/itRequisition/new`, `/newForm/requisition`, `/form.jsp` -> `LoadFormServlet` -> `Form.jsp`
- `/submit` and `/submit.jsp` -> `LoadSubmitServlet` -> `Submit.jsp`
- `/submitRequest` -> `SubmitRequestServlet`
- `/SubmitApprovalServlet` -> approval transition endpoint
- `/directorApprove` and `/DirectorApprove.jsp` -> `DirectorApprove.jsp`
- `/technicalApprove` and `/TechnicalApprove.jsp` -> `TechnicalApprove.jsp`
- `/itDirectorApprove` and `/ITDirectorApprove.jsp` -> `ITDirectorApprove.jsp`
- `/process` and `/Process.jsp` -> `Process.jsp`
- `/RequisitionDetail.jsp` -> `RequisitionDetail.jsp`
- `/RequisitionDetail_Comment.jsp` -> `RequisitionDetailComment.jsp`
- `/RequisitionDetail_ITDirector.jsp` -> `RequisitionDetailITDirector.jsp`
- `/RequisitionDetail_Process.jsp` -> `RequisitionDetailProcess.jsp`

Admin/support routes:

- `/Admin.jsp` -> `Admin.jsp`
- `/Dashboard.jsp` -> `Dashboard.jsp`
- `/memberManage` and `/MemberManage.jsp` -> `MemberManage.jsp`
- `/mailLog` and `/MailLog.jsp` -> `MailLog.jsp`
- `/emailNotifications` and `/EmailNotificationSettings.jsp` -> `EmailNotificationSettings.jsp`
- `/history.jsp` -> `History.jsp`

Third-party routes:

- `/thirdParty/request/new` -> `ThirdPartyRequestNew.jsp`
- `/thirdParty/request/link` -> `ThirdPartyRequestLink.jsp`
- `/thirdparty/form` -> `ThirdPartyForm.jsp`
- `/thirdparty/submit` -> `ThirdPartySubmitResult.jsp`
- `/thirdparty/accept` -> `ThirdPartyAcceptance.jsp`
- `/thirdparty/accept/submit` -> `ThirdPartySubmitResult.jsp`
- `/thirdParty/history` -> `ThirdPartyHistory.jsp`
- `/thirdPartySubmission` and `/ThirdPartySubmission.jsp` -> `ThirdPartySubmission.jsp`
- `/thirdPartyLinks` and `/ThirdPartyLinks.jsp` -> `ThirdPartyLinks.jsp`
- `/thirdParty/exportPdf` -> `ThirdPartyPdf.jsp`
- `/thirdParty/sectionHead` -> `ThirdPartySectionHeadInbox.jsp`
- `/thirdParty/sectionHead/review` -> `ThirdPartySectionHeadReview.jsp`
- `/thirdParty/itDirector` -> `ThirdPartyItDirectorInbox.jsp`
- `/thirdParty/itDirector/review` -> `ThirdPartyItDirectorReview.jsp`
- `/thirdParty/operator` -> `ThirdPartyOperatorInbox.jsp`
- `/thirdParty/operator/review` -> `ThirdPartyOperatorReview.jsp`
- `/thirdParty/revoker/review` -> revoke operator action servlet
- `/thirdParty/revokeReviewer/review` -> revoke reviewer action servlet
- `/thirdParty/sectionHead/report` -> section-head report action servlet
- `/thirdParty/itDirector/certify` -> final certification action servlet

## Folder Map

Root:

- `pom.xml`: Maven WAR build.
- `.gitignore`: ignores build/native/crash/secrets artifacts.
- `docs/PROJECT_CONTEXT.md`: this file.
- `docs/sql-removal-log.md`: log of removed SQL files.

Java:

- `src/main/java/com/slf/controller`: Servlets and route/view forwarding.
- `src/main/java/com/slf/dao`: JDBC data access.
- `src/main/java/com/slf/model`: DTO/model objects.
- `src/main/java/com/slf/filter`: authentication, role access, security headers.
- `src/main/java/com/slf/security`: login attempt and Java captcha.
- `src/main/java/com/slf/util`: auth, security, token, date, navigation helpers.
- `src/main/java/com/slf/notification`: email outbox and notification services.

Web:

- `src/main/webapp/index.jsp`: public landing page after login.
- `src/main/webapp/WEB-INF/checkAuth.jsp`: JSP auth include.
- `src/main/webapp/WEB-INF/jspf`: shared topbar/sidebar/footer/confirm-dialog fragments.
- `src/main/webapp/WEB-INF/views`: secured JSP views.
- `src/main/webapp/css/styles.css`: single project CSS entry point.
- `src/main/webapp/css/fonts`: web fonts.
- `src/main/webapp/images`: MoF/SLF/favicon assets.

Removed/obsolete:

- `sql/`: removed; see `docs/sql-removal-log.md`.
- `rust/`, `rust_captcha.dll`, `lib/rust_captcha.dll`: removed.
- `src/main/java/com/example/crypto/CryptoBridge.java`: removed.
- `src/main/webapp/WEB-INF/sidebar.jsp` and `sticky-bar.jsp`: removed; use `WEB-INF/jspf`.

## CSS Rules

Current convention:

- Use only `${pageContext.request.contextPath}/css/styles.css` as the project stylesheet.
- Do not reintroduce page-specific `.css` files without a deliberate reason.
- Do not add JSP-local `<style>` blocks; add scoped CSS to `styles.css`.
- Migrated page-local rules use body scopes such as `body.view-third-party-submission`.
- If a page needs page-specific styling, add a `view-*` body class and scope selectors under it.
- Keep shared layout widths/padding in common classes instead of reconfiguring each page.

Known CSS caveat:

- Some migrated CSS is intentionally scoped but still reflects older JSP structure. Prefer incremental cleanup over broad visual rewrites.

## Main Business Roles

Role strings are used directly in Java/JSP/tests:

- `Admin`
- `Director`
- `Technical`
- `ITDirector` / `IT Director`
- `Infrastructure`
- `Development`
- `Data`
- `Cyber Security`
- `Research`
- `Reseach`
- `IT Planning`
- regular requester/employee roles

Do not rename role strings without updating `AuthUtil`, filters, JSP conditions, controller checks, tests, and database data.

## IT Requisition Workflow

Primary tables:

- `REQUISITIONFORM`: request header; unique form id is `FORMID`.
- `REQUEST`: request detail rows per form.
- `PERMISSIONDETAILS`: server/folder permission details per form.
- `APPROVALINFO`: workflow state history and reviewer comments.
- `REQUESTTYPE`: request category and assigned section.
- `EMPLOYEE`, `SECTION`, `DEPARTMENT`: organization/role lookup.

`APPROVALINFO.STATE_STEP` meaning:

| State | Meaning |
|---:|---|
| `0` | Waiting for requester department Director/head approval |
| `1` | Waiting for Technical/section-head approval and assignment |
| `2` | Waiting for assigned department IT Director/head approval |
| `3` | Waiting for assigned developer/operator completion |
| `4` | Waiting for requester confirmation |
| `5` | Completed |
| `-1` to `-5` | Rejected at corresponding stage |

Critical servlet:

- `SubmitApprovalServlet` validates CSRF, role, expected state, row lock, reviewer identity, and writes the next `APPROVALINFO` row.

## Third-Party Workflow

Important unique ids:

- Request id: `THIRD_PARTY_REQUEST.REQUEST_ID`
- Generated fill-form link id: `THIRD_PARTY_FORM_LINK.LINK_ID`
- External submission id: `THIRD_PARTY_FORM_SUBMISSION.SUBMISSION_ID`
- Human document receive number: `THIRD_PARTY_FORM_SUBMISSION.DOCUMENT_RECEIVE_NO`, formatted like `TP-000162`
- Individual access-user row id: `THIRD_PARTY_ACCESS_REQUEST.ACCESS_REQUEST_ID`
- Workflow action id: `THIRD_PARTY_WORKFLOW_ACTION.ACTION_ID`
- Workflow assignment id: `THIRD_PARTY_WORKFLOW_ASSIGNMENT.ASSIGNMENT_ID`
- Acceptance token/result ids: `THIRD_PARTY_ACCEPTANCE_TOKEN.TOKEN_ID`, `THIRD_PARTY_ACCEPTANCE_RESULT.RESULT_ID`

Core third-party tables:

- `THIRD_PARTY_REQUEST`: owner-created request and current workflow status.
- `THIRD_PARTY_FORM_LINK`: token link for external form filling; stores token hash/raw token lifecycle, expiry, status, submit count.
- `THIRD_PARTY_FORM_SUBMISSION`: external submitted company/contact/request data; document receive number lives here.
- `THIRD_PARTY_ACCESS_REQUEST`: per-user access details under one submission.
- `THIRD_PARTY_WORKFLOW_ASSIGNMENT`: assigned internal reviewers/operators per role/stage.
- `THIRD_PARTY_WORKFLOW_ACTION`: chronological action/history table.
- `THIRD_PARTY_ACCEPTANCE_TOKEN`: external acceptance/evaluation token.
- `THIRD_PARTY_ACCEPTANCE_RESULT`: external acceptance/evaluation result, including satisfaction/score.
- `THIRD_PARTY_AUDIT_LOG`: audit trail for link/request operations.

Typical status flow:

`DRAFT/PENDING_EXTERNAL_FORM` -> `PENDING_SECTION_HEAD` -> `PENDING_IT_DIRECTOR` -> `PENDING_OPERATOR` -> `PENDING_EXTERNAL_ACCEPTANCE` -> `PENDING_REVOKER` -> `PENDING_REVOKE_REVIEW` -> `PENDING_SECTION_HEAD_REPORT` -> `PENDING_FINAL_CERTIFICATION` -> `COMPLETED`

Important action/history strings are asserted in tests. Check `ThirdPartyWorkflowDAO`, `ThirdPartyAcceptanceDAO`, and related servlet tests before renaming statuses/actions.

## Security Notes

- `AuthenticationFilter` is the global session guard and public route allowlist.
- Public token routes include third-party external form/submit/accept paths.
- `RoleBasedAccessFilter` provides page-level role checks.
- State-changing POSTs should validate CSRF where applicable.
- Use `SecurityUtil.escapeHtml` or local escaping helpers for output.
- Use `PreparedStatement`; do not concatenate user input into SQL.
- Do not expose raw token hashes or sensitive employee data to external users.
- `db.properties` is still in repo by explicit decision; do not change it unless asked.

## Email Notifications

Notification flow:

1. Workflow service resolves recipients.
2. Service inserts rows into `EMAIL_NOTIFICATION_LOG`.
3. `EmailNotificationWorkerListener` starts the dispatcher.
4. `EmailNotificationDispatcher` claims due rows and sends via `GmailNotificationService`.

Important classes:

- `ApprovalNotificationService`
- `ThirdPartyNotificationService`
- `ApprovalNotificationRecipientResolver`
- `ThirdPartyNotificationRecipientResolver`
- `EmailNotificationLogDAO`
- `EmailNotificationDispatcher`
- `GmailNotificationConfig`
- `GmailNotificationService`

Third-party email support is best when `EMAIL_NOTIFICATION_LOG` has `FORM_TYPE` and `REFERENCE_ID`. The DAO contains fallback behavior for legacy schemas, but third-party filtering/enqueue can degrade without those columns.

## Tests

Tests are a living route/UI/workflow contract. Run:

```powershell
mvn test
mvn package
```

High-signal test groups:

- Controller workflow tests under `src/test/java/com/slf/controller`.
- DAO tests for third-party and notification schema behavior under `src/test/java/com/slf/dao`.
- Auth/security/util tests under `src/test/java/com/slf/filter`, `security`, and `util`.
- JSP/UI structure tests under `src/test/java/com/slf/webapp`.
- Notification tests under `src/test/java/com/slf/notification`.

When moving JSPs or routes, update both servlet forwards and JSP structure tests.

## Known Debt

- Several files still contain mojibake Thai text in comments/strings. Do not mass-normalize encoding casually because tests and UI strings may depend on exact content.
- `web.xml` display name still says `MyFirstJSP`.
- `pom.xml` includes both `javax.servlet-api` and `jakarta.servlet-api`; code uses `javax.servlet.*` on Tomcat 9.
- Some JSPs still contain scriptlets and inline `style=""` attributes even though `<style>` blocks were moved.
- Some controllers/JSPs still use raw `printStackTrace`, `System.out`, or direct `sendError` messages.
- `ThirdPartyAccessPolicy.INTERNAL_LINK_CREATOR_EMPID = 678` is still hardcoded.
- `ThirdPartyNotificationService.notifyOperatorCompleted()` should be reviewed for acceptance-link email UX before production use.

## Future Change Checklist

Before changing protected routes:

- Verify servlet/session guard.
- Verify role guard.
- Verify CSRF for POST.
- Verify ownership/IDOR check for `formId`, `requestId`, `linkId`, `submissionId`, and `token`.
- Verify output escaping.
- Verify tests for exact routes/classes/status strings.

Preferred workflow:

1. Inspect existing tests and local patterns.
2. Make the smallest route/view/CSS change that solves the task.
3. Run focused tests if available.
4. Run `mvn package`.
5. If deploying locally, deploy the packaged WAR/exploded app to Tomcat.
