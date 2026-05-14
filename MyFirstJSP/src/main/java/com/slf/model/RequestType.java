package com.slf.model;
public class RequestType {
    private int typeId;
    private String typeName;
    public RequestType(int typeId, String typeName) {
        this.typeId = typeId;
        this.typeName = typeName;
    }
    public int getTypeId() { return typeId; }
    public String getTypeName() { return typeName; }
}