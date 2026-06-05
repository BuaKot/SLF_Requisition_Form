package com.slf.notification;

import junit.framework.TestCase;

public class EmailNotificationLogDAOTest extends TestCase {

    public void testTruncatesErrorMessageToColumnLimit() {
        StringBuilder longMessage = new StringBuilder();
        for (int i = 0; i < 1100; i++) {
            longMessage.append('x');
        }

        assertEquals(1000, EmailNotificationLogDAO.truncate(longMessage.toString(), 1000).length());
    }
}
