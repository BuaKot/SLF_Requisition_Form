-- Correct Third-party dates that were written as Buddhist Era years.
-- Only values with year >= 2500 are adjusted, so Gregorian values are untouched.

DECLARE
    PROCEDURE fix_column(p_table VARCHAR2, p_column VARCHAR2) IS
        v_sql VARCHAR2(1000);
    BEGIN
        v_sql := 'UPDATE ' || p_table ||
                 ' SET ' || p_column || ' = ADD_MONTHS(' || p_column || ', -6516)' ||
                 ' WHERE ' || p_column || ' IS NOT NULL AND EXTRACT(YEAR FROM ' || p_column || ') >= 2500';
        EXECUTE IMMEDIATE v_sql;
    END;
BEGIN
    fix_column('THIRD_PARTY_ACCEPTANCE_RESULT', 'SUBMITTED_AT');
    fix_column('THIRD_PARTY_ACCEPTANCE_TOKEN', 'CREATED_AT');
    fix_column('THIRD_PARTY_ACCEPTANCE_TOKEN', 'EXPIRES_AT');
    fix_column('THIRD_PARTY_ACCEPTANCE_TOKEN', 'USED_AT');
    fix_column('THIRD_PARTY_ACCESS_REQUEST', 'CREATED_AT');
    fix_column('THIRD_PARTY_AUDIT_LOG', 'CREATED_AT');
    fix_column('THIRD_PARTY_FORM_LINK', 'CREATED_AT');
    fix_column('THIRD_PARTY_FORM_LINK', 'EXPIRES_AT');
    fix_column('THIRD_PARTY_FORM_LINK', 'USED_AT');
    fix_column('THIRD_PARTY_FORM_LINK', 'REVOKED_AT');
    fix_column('THIRD_PARTY_FORM_SUBMISSION', 'FILLED_AT');
    fix_column('THIRD_PARTY_FORM_SUBMISSION', 'ACCESS_START_DATE');
    fix_column('THIRD_PARTY_FORM_SUBMISSION', 'ACCESS_END_DATE');
    fix_column('THIRD_PARTY_FORM_SUBMISSION', 'CREATED_AT');
    fix_column('THIRD_PARTY_FORM_SUBMISSION', 'REVIEWED_AT');
    fix_column('THIRD_PARTY_FORM_SUBMISSION', 'CONSENT_ACCEPTED_AT');
    fix_column('THIRD_PARTY_REQUEST', 'ACCESS_START_DATE');
    fix_column('THIRD_PARTY_REQUEST', 'ACCESS_END_DATE');
    fix_column('THIRD_PARTY_REQUEST', 'CREATED_AT');
    fix_column('THIRD_PARTY_REQUEST', 'SUBMITTED_AT');
    fix_column('THIRD_PARTY_REQUEST', 'UPDATED_AT');
    fix_column('THIRD_PARTY_WORKFLOW_ACTION', 'ACTED_AT');
    fix_column('THIRD_PARTY_WORKFLOW_ASSIGNMENT', 'ASSIGNED_AT');
    COMMIT;
END;
/
