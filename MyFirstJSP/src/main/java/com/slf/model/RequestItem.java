package com.slf.model;

import java.util.List;

public class RequestItem {
    private String requestType;
    private String programName;
    private String serverName;
    private String serverFolder;
    private List<String> folderPermissions;
    private String subFolder;
    private List<String> subFolderPermissions;
    private String otherRequest;
    private String objective;
    private String currentMethod;

    // Getters and setters
    public String getRequestType() {
        return requestType;
    }

    public void setRequestType(String requestType) {
        this.requestType = requestType;
    }

    public String getProgramName() {
        return programName;
    }

    public void setProgramName(String programName) {
        this.programName = programName;
    }

    public String getServerName() {
        return serverName;
    }

    public void setServerName(String serverName) {
        this.serverName = serverName;
    }

    public String getServerFolder() {
        return serverFolder;
    }

    public void setServerFolder(String serverFolder) {
        this.serverFolder = serverFolder;
    }

    public List<String> getFolderPermissions() {
        return folderPermissions;
    }

    public void setFolderPermissions(List<String> folderPermissions) {
        this.folderPermissions = folderPermissions;
    }

    public String getSubFolder() {
        return subFolder;
    }

    public void setSubFolder(String subFolder) {
        this.subFolder = subFolder;
    }

    public List<String> getSubFolderPermissions() {
        return subFolderPermissions;
    }

    public void setSubFolderPermissions(List<String> subFolderPermissions) {
        this.subFolderPermissions = subFolderPermissions;
    }

    public String getOtherRequest() {
        return otherRequest;
    }

    public void setOtherRequest(String otherRequest) {
        this.otherRequest = otherRequest;
    }

    public String getObjective() {
        return objective;
    }

    public void setObjective(String objective) {
        this.objective = objective;
    }

    public String getCurrentMethod() {
        return currentMethod;
    }

    public void setCurrentMethod(String currentMethod) {
        this.currentMethod = currentMethod;
    }
}