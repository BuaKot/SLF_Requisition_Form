package com.slf.controller;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import junit.framework.TestCase;

public class ItRequisitionDataFreshnessTest extends TestCase {

    public void testSubmitListDisablesBrowserCacheAndReloadsFromDatabase() throws Exception {
        String servlet = read("src/main/java/com/slf/controller/LoadSubmitServlet.java");
        assertTrue(servlet.contains("disableCaching(response)"));
        assertTrue(servlet.contains("Cache-Control"));
        assertTrue(servlet.contains("no-store"));
        assertTrue(servlet.contains("ROW_NUMBER() OVER (PARTITION BY FORMID ORDER BY APPROVALID DESC)"));
        assertTrue(servlet.contains("if (!\"asc\".equals(sortParam)) sortParam = \"desc\";"));
        assertTrue(servlet.contains("SELECT RF.FORMID, RF.TITLEFORM, RF.REQUESTDATE"));
        assertTrue(servlet.contains("GROUP BY RF.FORMID, RF.TITLEFORM, RF.REQUESTDATE"));
        assertTrue(servlet.contains("ORDER BY RF.REQUESTDATE \" + orderDir + \", RF.FORMID DESC"));
        assertTrue(servlet.contains("row.put(\"REQUESTDATE\""));
        assertTrue(servlet.contains("request.setAttribute(\"formList\""));
        assertFalse(servlet.contains("session.setAttribute(\"formList\""));
    }

    public void testSubmitAndDetailPagesOptOutOfBackForwardCache() throws Exception {
        String submit = read("src/main/webapp/WEB-INF/views/Submit.jsp");
        String detail = read("src/main/webapp/WEB-INF/views/Detail.jsp");
        assertTrue(submit.contains("Cache-Control"));
        assertTrue(submit.contains("window.location.reload()"));
        assertTrue(detail.contains("Cache-Control"));
        assertTrue(detail.contains("window.location.reload()"));
    }

    private static String read(String path) throws Exception {
        return new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8);
    }
}
