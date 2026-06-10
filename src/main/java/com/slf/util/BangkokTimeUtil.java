package com.slf.util;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.Locale;
import java.util.TimeZone;

public final class BangkokTimeUtil {
    private static final ZoneId BANGKOK_ZONE_ID = ZoneId.of("Asia/Bangkok");
    private static final TimeZone BANGKOK_TIME_ZONE = TimeZone.getTimeZone(BANGKOK_ZONE_ID);
    private static final Locale GREGORIAN_LOCALE = Locale.US;

    private BangkokTimeUtil() {
    }

    public static Timestamp nowTimestamp() {
        return Timestamp.valueOf(LocalDateTime.now(BANGKOK_ZONE_ID));
    }

    public static Calendar newCalendar() {
        return new GregorianCalendar(BANGKOK_TIME_ZONE, GREGORIAN_LOCALE);
    }

    public static TimeZone timeZone() {
        return BANGKOK_TIME_ZONE;
    }
}
