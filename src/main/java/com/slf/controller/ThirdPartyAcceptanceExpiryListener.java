package com.slf.controller;

import com.slf.dao.ThirdPartyAcceptanceDAO;
import com.slf.notification.ThirdPartyNotificationService;
import java.sql.SQLException;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener
public class ThirdPartyAcceptanceExpiryListener implements ServletContextListener {
    private ScheduledExecutorService executor;

    @Override
    public void contextInitialized(ServletContextEvent event) {
        executor = Executors.newSingleThreadScheduledExecutor(runnable -> {
            Thread thread = new Thread(runnable, "third-party-acceptance-expiry-worker");
            thread.setDaemon(true);
            return thread;
        });
        executor.scheduleWithFixedDelay(this::advanceExpiredAcceptances, 5L, 60L, TimeUnit.SECONDS);
    }

    @Override
    public void contextDestroyed(ServletContextEvent event) {
        if (executor != null) executor.shutdownNow();
    }

    private void advanceExpiredAcceptances() {
        try {
            List<Long> requestIds = new ThirdPartyAcceptanceDAO().advanceExpiredAcceptanceRequestIds();
            ThirdPartyNotificationService notificationService = new ThirdPartyNotificationService();
            for (Long requestId : requestIds) {
                if (requestId != null) {
                    notificationService.notifyExternalAcceptanceExpired(requestId.longValue());
                }
            }
        } catch (SQLException e) {
            System.err.println("Unable to advance expired third-party acceptances: " + e.getMessage());
        }
    }
}
