package com.slf.model;
public class RequestType {
    private int typeId;
    private String typeName;
    private int secId;
    private String secName;

    public RequestType(int typeId, String typeName) {
        this(typeId, typeName, 0, "");
    }

    public RequestType(int typeId, String typeName, int secId, String secName) {
        this.typeId = typeId;
        this.typeName = typeName;
        this.secId = secId;
        this.secName = secName;
    }

    public int getTypeId() { return typeId; }
    public String getTypeName() { return typeName; }
    public int getSecId() { return secId; }
    public String getSecName() { return secName; }
}