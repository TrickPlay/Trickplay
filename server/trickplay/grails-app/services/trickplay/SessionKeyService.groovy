package trickplay;

import java.security.SecureRandom;
import org.codehaus.groovy.grails.plugins.springsecurity.GrailsUserImpl;
import org.springframework.security.*;
import org.springframework.security.providers.*;
import org.springframework.security.userdetails.*;

class SessionKeyService {

    boolean transactional = false;

    def userDetailsService;
    def authenticationManager;

    UserDetails authenticate(String username, String password) {
        UsernamePasswordAuthenticationToken authRequest = new UsernamePasswordAuthenticationToken(username, password);
        Authentication authResult;
        try {
            authResult = authenticationManager.authenticate(authRequest);
        } catch (AuthenticationException failed) {
            log.debug "Authentication request for user: ${username} failed: ${failed}";
            return null;
        }
        return authResult.principal;
    }

    User getUser(UserDetails userDetails) {
        //principal is GrailsUserImpl which extends User which implements UserDetails
        if (userDetails instanceof GrailsUserImpl) {
            return ((GrailsUserImpl)userDetails).domainClass;
        } else {
            return null;
        }
    }

    SessionKey getSessionKey(String token) {
        try {
            SessionKey sessionKey = SessionKey.findByToken(token);
            //Update last access?
            return sessionKey;
        } catch (Exception e) {
            log.error(e);
        }
        return null;
    }

    SessionKey newToken(User user, Device device) {
        def keys = SessionKey.findAllByUserAndDevice(user, device);
        keys.each() { it.delete(flush:true); };
        SessionKey key = new SessionKey(user:user,
                                        device:device,
                                        token:generateToken(),
                                        expires:null);
        key.save(flush:true);
        if (key.hasErrors()){
            println key.errors
        }
        return key;
    }

    String generateToken() {
        //token is a 256-bit base64 encoded random string
        SecureRandom random = SecureRandom.getInstance("SHA1PRNG");
        byte[] bytes = new byte[256/8];
        random.nextBytes(bytes);
        return bytes.encodeBase64().toString();
    }

}


