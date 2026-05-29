package com.slf.security;

import junit.framework.TestCase;

public class RustCaptchaConfigTest extends TestCase {

    public void testSystemPropertyOverridesServiceUrlAndTrimsSlash() {
        System.setProperty("captcha.serviceUrl", "http://127.0.0.1:9999/");
        try {
            assertEquals("http://127.0.0.1:9999", RustCaptchaConfig.getServiceUrl());
        } finally {
            System.clearProperty("captcha.serviceUrl");
        }
    }
}
