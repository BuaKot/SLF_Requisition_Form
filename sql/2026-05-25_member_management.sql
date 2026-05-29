-- Adds soft-disable support for MemberManage.jsp.
-- Run once as the application schema owner before using disable/enable member.

ALTER TABLE EMPLOYEE ADD (
    IS_ACTIVE NUMBER(1) DEFAULT 1 NOT NULL
);

UPDATE EMPLOYEE
SET IS_ACTIVE = 1
WHERE IS_ACTIVE IS NULL;

COMMIT;
