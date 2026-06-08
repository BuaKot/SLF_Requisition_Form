-- Allows admins to copy still-active third-party links after refresh/redeploy.
-- RAW_TOKEN is cleared by the application when a link is used or revoked.

BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE THIRD_PARTY_FORM_LINK ADD RAW_TOKEN VARCHAR2(120)';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1430 THEN
            RAISE;
        END IF;
END;
/
