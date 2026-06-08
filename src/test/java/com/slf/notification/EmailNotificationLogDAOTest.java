package com.slf.notification;

import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;

import junit.framework.TestCase;

public class EmailNotificationLogDAOTest extends TestCase {

    public void testTruncatesErrorMessageToColumnLimit() {
        StringBuilder longMessage = new StringBuilder();
        for (int i = 0; i < 1100; i++) {
            longMessage.append('x');
        }

        assertEquals(1000, EmailNotificationLogDAO.truncate(longMessage.toString(), 1000).length());
    }

    public void testRecognizesOracleDuplicateKeyOnly() {
        assertTrue(EmailNotificationLogDAO.isDuplicateKey(new SQLException("ORA-00001 unique constraint", null, 1)));
        assertTrue(EmailNotificationLogDAO.isDuplicateKey(
            new SQLException("constraint UQ_EMAIL_NOTIFICATION_DEDUPE violated")
        ));
        assertFalse(EmailNotificationLogDAO.isDuplicateKey(
            new SQLIntegrityConstraintViolationException("not-null constraint", "23000", 1400)
        ));
    }
}
