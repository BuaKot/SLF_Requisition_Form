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
    String message = (String) request.getAttribute("submitMessage");
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Third-party Form Result</title>
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/images/cropped-logo-192x192.png">
    <style>
        body { margin: 0; min-height: 100vh; display: grid; place-items: center; background: #f4f8fc; font-family: Tahoma, Arial, sans-serif; color: #102a43; }
        .panel { width: min(640px, calc(100% - 32px)); background: #fff; border: 1px solid #d9e6f2; border-radius: 10px; padding: 28px; box-shadow: 0 8px 22px rgba(0, 51, 102, 0.08); }
        h1 { margin: 0 0 10px; color: <%= success ? "#137a42" : "#b42318" %>; }
        p { margin: 0; line-height: 1.6; }
    </style>
</head>
<body>
    <section class="panel">
        <h1><%= success ? "ส่งแบบฟอร์มสำเร็จ" : "ไม่สามารถส่งแบบฟอร์มได้" %></h1>
        <p><%= h(message) %></p>
    </section>
</body>
</html>
