package com.slf.form;

import com.slf.model.FormType;
import junit.framework.TestCase;
import java.util.List;

public class FormRegistryTest extends TestCase {

    public void testFindsRegisteredFormTypes() {
        FormType requisition = FormRegistry.findByCode(FormRegistry.IT_REQUISITION_REQUEST);
        assertNotNull(requisition);
        assertTrue(requisition.isEnabled());
        assertEquals("/itRequisition/new", requisition.getTargetUrl());

        FormType thirdParty = FormRegistry.findByCode(FormRegistry.THIRD_PARTY_USER_REGISTRATION);
        assertNotNull(thirdParty);
        assertTrue(thirdParty.isEnabled());
        assertEquals("/thirdParty/request/new", thirdParty.getTargetUrl());
    }

    public void testVisibleFormsAreReturnedForLoggedInUsers() {
        List<FormType> formTypes = FormRegistry.findVisibleFor("User");
        assertEquals(2, formTypes.size());
    }
}
