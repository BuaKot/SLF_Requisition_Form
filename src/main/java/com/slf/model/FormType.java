package com.slf.model;

import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

public class FormType {
    private final String formCode;
    private final String formName;
    private final String description;
    private final String icon;
    private final String targetUrl;
    private final boolean enabled;
    private final Set<String> allowedRoles;

    public FormType(String formCode, String formName, String description, String icon,
                    String targetUrl, boolean enabled, Set<String> allowedRoles) {
        this.formCode = formCode;
        this.formName = formName;
        this.description = description;
        this.icon = icon;
        this.targetUrl = targetUrl;
        this.enabled = enabled;
        this.allowedRoles = allowedRoles == null
                ? Collections.<String>emptySet()
                : Collections.unmodifiableSet(new HashSet<>(allowedRoles));
    }

    public String getFormCode() {
        return formCode;
    }

    public String getFormName() {
        return formName;
    }

    public String getDescription() {
        return description;
    }

    public String getIcon() {
        return icon;
    }

    public String getTargetUrl() {
        return targetUrl;
    }

    public boolean isEnabled() {
        return enabled;
    }

    public boolean isVisibleFor(String position) {
        if (allowedRoles.isEmpty()) {
            return true;
        }
        if (position == null) {
            return false;
        }
        String normalizedPosition = position.trim();
        for (String role : allowedRoles) {
            if (role.equalsIgnoreCase(normalizedPosition)) {
                return true;
            }
        }
        return false;
    }
}
