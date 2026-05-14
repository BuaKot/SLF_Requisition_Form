package com.slf.dao;

import com.slf.model.RequisitionForm;
import com.slf.model.RequestItem;

public class MockRequisitionDAO implements RequisitionDAO {
    @Override
    public void save(RequisitionForm form) {
        System.out.println("===== NEW REQUISITION FORM SUBMITTED =====");
        System.out.println("Name: " + form.getName());
        System.out.println("Department: " + form.getDepartment());
        System.out.println("Topic: " + form.getRequestTopic());
        System.out.println("Deadline: " + form.getDeadline());
        System.out.println("Items (" + form.getItems().size() + "):");
        for (int i = 0; i < form.getItems().size(); i++) {
            RequestItem item = form.getItems().get(i);
            System.out.println("  Item " + (i+1) + ": type=" + item.getRequestType() +
                               ", objective=" + item.getObjective() +
                               ", program=" + item.getProgramName());
        }
        System.out.println("==========================================");
    }
}