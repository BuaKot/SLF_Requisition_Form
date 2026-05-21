package com.slf.filter;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.FilterChain;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletResponse;

import junit.framework.TestCase;

public class SecurityHeadersFilterTest extends TestCase {

    public void testAddsSecurityHeadersBeforeContinuingFilterChain() throws Exception {
        Map<String, String> headers = new HashMap<String, String>();
        final boolean[] chainCalled = new boolean[] { false };

        ServletRequest request = (ServletRequest) Proxy.newProxyInstance(
            ServletRequest.class.getClassLoader(),
            new Class<?>[] { ServletRequest.class },
            new DefaultReturnHandler()
        );

        HttpServletResponse response = (HttpServletResponse) Proxy.newProxyInstance(
            HttpServletResponse.class.getClassLoader(),
            new Class<?>[] { HttpServletResponse.class },
            new HeaderCaptureHandler(headers)
        );

        FilterChain chain = new FilterChain() {
            public void doFilter(ServletRequest req, ServletResponse res) {
                chainCalled[0] = true;
            }
        };

        new SecurityHeadersFilter().doFilter(request, response, chain);

        assertTrue(chainCalled[0]);
        assertEquals("max-age=31536000; includeSubDomains", headers.get("Strict-Transport-Security"));
        assertEquals("DENY", headers.get("X-Frame-Options"));
        assertEquals("nosniff", headers.get("X-Content-Type-Options"));
        assertEquals(
            "default-src 'self'; script-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com; style-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com; font-src 'self' https://cdnjs.cloudflare.com data:; img-src 'self' data:",
            headers.get("Content-Security-Policy")
        );
    }

    private static class HeaderCaptureHandler implements InvocationHandler {
        private final Map<String, String> headers;

        HeaderCaptureHandler(Map<String, String> headers) {
            this.headers = headers;
        }

        public Object invoke(Object proxy, Method method, Object[] args) {
            if ("setHeader".equals(method.getName()) && args != null && args.length == 2) {
                headers.put((String) args[0], (String) args[1]);
                return null;
            }
            return defaultValue(method.getReturnType());
        }
    }

    private static class DefaultReturnHandler implements InvocationHandler {
        public Object invoke(Object proxy, Method method, Object[] args) {
            return defaultValue(method.getReturnType());
        }
    }

    private static Object defaultValue(Class<?> type) {
        if (!type.isPrimitive()) {
            return null;
        }
        if (Boolean.TYPE.equals(type)) {
            return Boolean.FALSE;
        }
        if (Character.TYPE.equals(type)) {
            return Character.valueOf('\0');
        }
        if (Byte.TYPE.equals(type)) {
            return Byte.valueOf((byte) 0);
        }
        if (Short.TYPE.equals(type)) {
            return Short.valueOf((short) 0);
        }
        if (Integer.TYPE.equals(type)) {
            return Integer.valueOf(0);
        }
        if (Long.TYPE.equals(type)) {
            return Long.valueOf(0L);
        }
        if (Float.TYPE.equals(type)) {
            return Float.valueOf(0f);
        }
        if (Double.TYPE.equals(type)) {
            return Double.valueOf(0d);
        }
        return null;
    }
}
