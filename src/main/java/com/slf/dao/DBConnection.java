package com.slf.dao;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

// zennnne แก้ : PERF-1 เปลี่ยนจาก DriverManager มาใช้ HikariCP connection pool
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
// zennnne แก้ end

public class DBConnection {

    // zennnne แก้ : PERF-1 ใช้ HikariDataSource singleton แทนเปิด TCP connection ใหม่ทุก query
    private static final HikariDataSource dataSource;

    static {
        try (InputStream input = DBConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (input == null) {
                throw new RuntimeException("db.properties not found in classpath (src/main/resources/)");
            }
            Properties props = new Properties();
            props.load(input);

            String driverClass = setting("db.driver", "SLF_DB_DRIVER", props, "oracle.jdbc.OracleDriver");
            String jdbcUrl = requiredSetting("db.url", "SLF_DB_URL", props);
            String username = requiredSetting("db.username", "SLF_DB_USERNAME", props);
            String password = requiredSetting("db.password", "SLF_DB_PASSWORD", props);
            Class.forName(driverClass);

            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(jdbcUrl);
            config.setUsername(username);
            config.setPassword(password);
            config.setDriverClassName(driverClass);

            config.setPoolName("SLF-Hikari-Pool");
            config.setMaximumPoolSize(10);
            config.setMinimumIdle(0);
            config.setConnectionTimeout(30_000);
            config.setIdleTimeout(600_000);
            config.setMaxLifetime(1_800_000);
            config.setConnectionTestQuery("SELECT 1 FROM DUAL");
            config.setInitializationFailTimeout(-1);

            dataSource = new HikariDataSource(config);
        } catch (Exception e) {
            throw new RuntimeException("Failed to initialise HikariCP pool", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }

    private static String setting(String propertyName, String envName, Properties props, String defaultValue) {
        String systemValue = trimToNull(System.getProperty(propertyName));
        if (systemValue != null) {
            return systemValue;
        }

        String envValue = trimToNull(System.getenv(envName));
        if (envValue != null) {
            return envValue;
        }

        String propertyValue = trimToNull(props.getProperty(propertyName));
        return propertyValue == null ? defaultValue : propertyValue;
    }

    private static String requiredSetting(String propertyName, String envName, Properties props) {
        String value = setting(propertyName, envName, props, null);
        if (value == null) {
            throw new IllegalStateException("Missing database setting: " + propertyName + " or " + envName);
        }
        return value;
    }

    private static String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
    // zennnne แก้ end
}
