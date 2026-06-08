package com.slf.filter;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.FilterChain;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import junit.framework.TestCase;

public class AuthenticationFilterTest extends TestCase {

    public void testAllowsAuthenticatedSessionUsingLoggedInEmpId() throws Exception {
        final boolean[] chainCalled = new boolean[] { false };
        final boolean[] redirected = new boolean[] { false };
        final Map<String, Object> sessionValues = new HashMap<String, Object>();
        sessionValues.put("loggedInEmpId", Integer.valueOf(1001));

        HttpSession session = (HttpSession) Proxy.newProxyInstance(
            HttpSession.class.getClassLoader(),
            new Class<?>[] { HttpSession.class },
            new SessionHandler(sessionValues)
        );

        HttpServletRequest request = (HttpServletRequest) Proxy.newProxyInstance(
            HttpServletRequest.class.getClassLoader(),
            new Class<?>[] { HttpServletRequest.class },
            new RequestHandler("/MyFirstJSP", "/MyFirstJSP/Admin.jsp", session)
        );

        HttpServletResponse response = (HttpServletResponse) Proxy.newProxyInstance(
            HttpServletResponse.class.getClassLoader(),
            new Class<?>[] { HttpServletResponse.class },
            new ResponseHandler(redirected)
        );

        FilterChain chain = new FilterChain() {
            public void doFilter(ServletRequest req, ServletResponse res) {
                chainCalled[0] = true;
            }
        };

        new AuthenticationFilter().doFilter(request, response, chain);

        assertTrue(chainCalled[0]);
        assertFalse(redirected[0]);
    }

    public void testAllowsThirdPartyPublicFormWithoutSession() throws Exception {
        final boolean[] chainCalled = new boolean[] { false };
        final boolean[] redirected = new boolean[] { false };

        HttpServletRequest request = (HttpServletRequest) Proxy.newProxyInstance(
            HttpServletRequest.class.getClassLoader(),
            new Class<?>[] { HttpServletRequest.class },
            new RequestHandler("/SLF_Requisition_Form", "/SLF_Requisition_Form/thirdparty/form", null)
        );

        HttpServletResponse response = (HttpServletResponse) Proxy.newProxyInstance(
            HttpServletResponse.class.getClassLoader(),
            new Class<?>[] { HttpServletResponse.class },
            new ResponseHandler(redirected)
        );

        FilterChain chain = new FilterChain() {
            public void doFilter(ServletRequest req, ServletResponse res) {
                chainCalled[0] = true;
            }
        };

        new AuthenticationFilter().doFilter(request, response, chain);

        assertTrue(chainCalled[0]);
        assertFalse(redirected[0]);
    }

    private static class RequestHandler implements InvocationHandler {
        private final String contextPath;
        private final String requestUri;
        private final HttpSession session;

        RequestHandler(String contextPath, String requestUri, HttpSession session) {
            this.contextPath = contextPath;
            this.requestUri = requestUri;
            this.session = session;
        }

        public Object invoke(Object proxy, Method method, Object[] args) {
            if ("getContextPath".equals(method.getName())) {
                return contextPath;
            }
            if ("getRequestURI".equals(method.getName())) {
                return requestUri;
            }
            if ("getSession".equals(method.getName())) {
                return session;
            }
            return defaultValue(method.getReturnType());
        }
    }

    private static class SessionHandler implements InvocationHandler {
        private final Map<String, Object> values;

        SessionHandler(Map<String, Object> values) {
            this.values = values;
        }

        public Object invoke(Object proxy, Method method, Object[] args) {
            if ("getAttribute".equals(method.getName()) && args != null && args.length == 1) {
                return values.get(args[0]);
            }
            return defaultValue(method.getReturnType());
        }
    }

    private static class ResponseHandler implements InvocationHandler {
        private final boolean[] redirected;

        ResponseHandler(boolean[] redirected) {
            this.redirected = redirected;
        }

        public Object invoke(Object proxy, Method method, Object[] args) {
            if ("sendRedirect".equals(method.getName())) {
                redirected[0] = true;
                return null;
            }
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
