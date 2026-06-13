package com.slf.util;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

public final class NavigationUtil {
    private static final String INDEX = "/index.jsp";
    private static final String IT_DETAIL = "/it-requisition-form-detail.jsp";
    private static final String SUBMITTED_LIST = "/submit";
    private static final String HISTORY_LIST = "/history.jsp";

    private static final Set<String> HISTORY_BACK_PATHS = new HashSet<>(Arrays.asList(
        "/directorApprove",
        "/technicalApprove",
        "/itDirectorApprove",
        "/process",
        IT_DETAIL
    ));

    private NavigationUtil() {
    }

    public static BackLink listPageBack(String contextPath) {
        return link(contextPath, INDEX, "กลับหน้าหลัก");
    }

    public static BackLink adminListPageBack(String contextPath) {
        return link(contextPath, "/Admin.jsp", "กลับหน้า Admin");
    }

    public static BackLink itRequisitionDetailBack(String contextPath) {
        return link(contextPath, IT_DETAIL, "กลับรายละเอียดฟอร์ม");
    }

    public static BackLink submittedListBack(String contextPath) {
        return link(contextPath, SUBMITTED_LIST, "กลับรายการที่ส่งแล้ว");
    }

    public static BackLink detailBack(String contextPath, String fromPage) {
        if ("history".equalsIgnoreCase(trimToEmpty(fromPage))) {
            return link(contextPath, HISTORY_LIST, "กลับหน้าประวัติ");
        }
        return submittedListBack(contextPath);
    }

    public static BackLink approvalDetailBack(String contextPath, String fromPage, String defaultPath, String defaultLabel) {
        if ("history".equalsIgnoreCase(trimToEmpty(fromPage))) {
            return link(contextPath, HISTORY_LIST, "กลับหน้าประวัติ");
        }
        return link(contextPath, defaultPath, defaultLabel);
    }

    public static String historyBackPath(String backParam) {
        String normalized = normalizePath(backParam);
        return HISTORY_BACK_PATHS.contains(normalized) ? normalized : IT_DETAIL;
    }

    public static BackLink historyBack(String contextPath, String backParam) {
        String path = historyBackPath(backParam);
        String label = IT_DETAIL.equals(path) ? "กลับรายละเอียดฟอร์ม" : "กลับหน้ารายการเดิม";
        return link(contextPath, path, label);
    }

    public static BackLink submitSuccessBack(String contextPath, Object formId) {
        String normalizedId = formId == null ? "" : String.valueOf(formId).trim();
        if (normalizedId.matches("\\d+")) {
            return link(contextPath, "/detail.jsp?id=" + urlEncode(normalizedId) + "&from=submit", "กลับรายละเอียดรายการที่ส่ง");
        }
        return itRequisitionDetailBack(contextPath);
    }

    public static BackLink thirdPartyLinksBack(String contextPath) {
        return link(contextPath, "/thirdParty/request/new", "กลับหน้าจัดการลิงก์");
    }

    public static BackLink thirdPartyFormDetailBack(String contextPath) {
        return link(contextPath, "/third-party-form-detail.jsp", "กลับรายละเอียดฟอร์ม");
    }

    public static BackLink thirdPartyHistoryBack(String contextPath, boolean adminView) {
        return adminView ? adminListPageBack(contextPath) : thirdPartyLinksBack(contextPath);
    }

    public static BackLink thirdPartyDetailBack(String backUrl) {
        return new BackLink(safeHref(backUrl), "กลับหน้ารายการเดิม");
    }

    public static String urlEncode(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }

    private static BackLink link(String contextPath, String path, String label) {
        return new BackLink(join(contextPath, path), label);
    }

    private static String join(String contextPath, String path) {
        String context = contextPath == null ? "" : contextPath.trim();
        String normalizedPath = normalizePath(path);
        return context + normalizedPath;
    }

    private static String normalizePath(String path) {
        String value = trimToEmpty(path);
        if (value.isEmpty()) {
            return INDEX;
        }
        if (!value.startsWith("/")) {
            value = "/" + value;
        }
        return value;
    }

    private static String safeHref(String href) {
        String value = trimToEmpty(href);
        if (value.isEmpty()) {
            return INDEX;
        }
        if (value.startsWith("http://") || value.startsWith("https://") || value.startsWith("//")) {
            return INDEX;
        }
        return value;
    }

    private static String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    public static final class BackLink {
        private final String href;
        private final String label;

        private BackLink(String href, String label) {
            this.href = href;
            this.label = label;
        }

        public String getHref() {
            return href;
        }

        public String getLabel() {
            return label;
        }
    }
}
