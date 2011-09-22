package com.trickplay.gameservice.security;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextImpl;
import org.springframework.security.web.context.HttpRequestResponseHolder;
import org.springframework.security.web.context.SecurityContextRepository;

public class EmptySecurityContextRepository implements
        SecurityContextRepository {

    public EmptySecurityContextRepository() {
        
    }
    public SecurityContext loadContext(
            HttpRequestResponseHolder requestResponseHolder) {
        return new SecurityContextImpl();
    }

    public void saveContext(SecurityContext context,
            HttpServletRequest request, HttpServletResponse response) {

    }

    public boolean containsContext(HttpServletRequest request) {
        return false;
    }

}
