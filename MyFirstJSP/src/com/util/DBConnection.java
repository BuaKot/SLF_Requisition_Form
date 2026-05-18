package com.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    
    private static final String URL = "jdbc:oracle:thin:@172.25.18.186:1521:xe"; 
    private static final String USER = "C##DEVUSER";
    private static final String PASS = "mypassword"; 

    public static Connection getConnection() {
        Connection conn = null;
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection(URL, USER, PASS);
            if (conn != null) {
                System.out.println("--- [Success] Connected to Oracle! ---");
            }
        } catch (ClassNotFoundException e) {
            System.err.println("--- [Error] ojdbc8.jar not found! ---");
            e.printStackTrace();
        } catch (SQLException e) {
            System.err.println("--- [Error] Connection Failed! ---");
            e.printStackTrace();
        }
        return conn;
    }

    public static void main(String[] args) {
        Connection testConn = DBConnection.getConnection();
        if (testConn != null) {
            try {
                testConn.close();
                System.out.println("--- [Closed] Connection closed. ---");
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}