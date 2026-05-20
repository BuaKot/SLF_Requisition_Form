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

            String driverClass = props.getProperty("db.driver", "oracle.jdbc.OracleDriver");
            Class.forName(driverClass);

            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(props.getProperty("db.url"));
            config.setUsername(props.getProperty("db.username"));
            config.setPassword(props.getProperty("db.password"));
            config.setDriverClassName(driverClass);

            config.setPoolName("SLF-Hikari-Pool");
            config.setMaximumPoolSize(10);
            config.setMinimumIdle(2);
            config.setConnectionTimeout(30_000);
            config.setIdleTimeout(600_000);
            config.setMaxLifetime(1_800_000);
            config.setConnectionTestQuery("SELECT 1 FROM DUAL");

            dataSource = new HikariDataSource(config);
        } catch (Exception e) {
            throw new RuntimeException("Failed to initialise HikariCP pool", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }
    // zennnne แก้ end
}
