<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
    public String h(Object input) {
        if (input == null) return "";
        return String.valueOf(input)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#x27;");
    }
%>
<%
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0L);
    boolean success = Boolean.TRUE.equals(request.getAttribute("submitSuccess"));
    String resultBodyClass = success ? "result-success" : "result-error";
    String message = (String) request.getAttribute("submitMessage");
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Third-party Form Result</title>
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/images/cropped-logo-192x192.png">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body class="<%= resultBodyClass %> view-third-party-submit-result">
    <section class="panel">
        <h1><%= success ? "ส่งแบบฟอร์มสำเร็จ" : "ไม่สามารถส่งแบบฟอร์มได้" %></h1>
        <p><%= h(message) %></p>
    </section>
</body>
</html>
