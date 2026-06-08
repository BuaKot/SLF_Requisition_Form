package com.slf.notification;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener
public class EmailNotificationWorkerListener implements ServletContextListener {
    private ScheduledExecutorService executor;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        executor = Executors.newSingleThreadScheduledExecutor(runnable -> {
            Thread thread = new Thread(runnable, "slf-email-notification-worker");
            thread.setDaemon(true);
            return thread;
        });
        EmailNotificationDispatcher dispatcher = new EmailNotificationDispatcher();
        executor.scheduleWithFixedDelay(dispatcher::dispatchBatch, 2L, 15L, TimeUnit.SECONDS);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (executor != null) {
            executor.shutdownNow();
        }
    }
}
