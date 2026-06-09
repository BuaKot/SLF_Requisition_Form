package com.slf.form;

import com.slf.model.FormType;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

public final class FormRegistry {
    public static final String THIRD_PARTY_USER_REGISTRATION = "THIRD_PARTY_USER_REGISTRATION";
    public static final String IT_REQUISITION_REQUEST = "IT_REQUISITION_REQUEST";

    private static final List<FormType> FORM_TYPES = Collections.unmodifiableList(Arrays.asList(
        new FormType(
            THIRD_PARTY_USER_REGISTRATION,
            "แบบฟอร์มการขอลงทะเบียนผู้ใช้ระบบงานสารสนเทศ สำหรับผู้ให้บริการภายนอก",
            "สำหรับลงทะเบียนและจัดเตรียมข้อมูลผู้ให้บริการภายนอก ก่อนเข้าสู่ขั้นตอนตรวจสอบและอนุมัติของระบบ",
            "fa-solid fa-user-shield",
            "/thirdParty/request/new",
            true,
            Collections.<String>emptySet()
        ),
        new FormType(
            IT_REQUISITION_REQUEST,
            "ใบคำขอฝ่ายเทคโนโลยีสารสนเทศ",
            "สำหรับสร้างคำขอด้านเทคโนโลยีสารสนเทศ โดยใช้กระบวนการอนุมัติเดิมของระบบ",
            "fa-solid fa-file-circle-plus",
            "/itRequisition/new",
            true,
            Collections.<String>emptySet()
        )
    ));

    private FormRegistry() {
    }

    public static List<FormType> findVisibleFor(String position) {
        List<FormType> visible = new ArrayList<>();
        for (FormType formType : FORM_TYPES) {
            if (formType.isVisibleFor(position)) {
                visible.add(formType);
            }
        }
        return visible;
    }

    public static FormType findByCode(String formCode) {
        if (formCode == null) {
            return null;
        }
        for (FormType formType : FORM_TYPES) {
            if (formType.getFormCode().equalsIgnoreCase(formCode.trim())) {
                return formType;
            }
        }
        return null;
    }
}
