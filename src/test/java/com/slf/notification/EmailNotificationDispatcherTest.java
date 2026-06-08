package com.slf.notification;

import junit.framework.TestCase;

public class EmailNotificationDispatcherTest extends TestCase {

    public void testRetryDelayUsesExponentialBackoffWithOneHourCap() {
        assertEquals(60_000L, EmailNotificationDispatcher.retryDelayMillis(1));
        assertEquals(120_000L, EmailNotificationDispatcher.retryDelayMillis(2));
        assertEquals(240_000L, EmailNotificationDispatcher.retryDelayMillis(3));
        assertEquals(3_600_000L, EmailNotificationDispatcher.retryDelayMillis(20));
    }
}
