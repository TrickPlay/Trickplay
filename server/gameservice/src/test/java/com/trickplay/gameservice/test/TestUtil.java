package com.trickplay.gameservice.test;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.authentication.encoding.PasswordEncoder;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.stereotype.Component;

import com.trickplay.gameservice.domain.User;
import com.trickplay.gameservice.security.UserAdapter;
import com.trickplay.gameservice.service.UserService;

@Component
public class TestUtil {
    
    public TestUtil() {
        
    }
    
    @Value("#{adminUser}") private User admin;
    
    @Autowired
    UserDetailsService userDetailsService;
    
    @Autowired
    PasswordEncoder passwordEncoder;
    
    @Autowired
    UserService userService;

    public void setSecurityContext(String username, String password) {
        setSecurityContext(username, password, true);
    }
    
    public void setSecurityContext(String username, String password, boolean encodeFlag) {
        UserDetails details = userDetailsService.loadUserByUsername(username);
        if (details != null && details.getPassword().equals(encodeFlag ? passwordEncoder.encodePassword(password, null) : password)) {
                SecurityContextHolder.getContext().setAuthentication(
                        new UsernamePasswordAuthenticationToken(
                                details, 
                                details.getPassword(), 
                                details.getAuthorities()
                                )
                        );
        }
        else {
            setAnonymousSecurityContext();
        }      
    }
    
   private UserAdapter makeSecurityUser(String username, 
            String password, String authority) {
        return new UserAdapter(null, 
                new org.springframework.security.core.userdetails.User(
                        username, 
                        password, 
                        true, 
                        true, 
                        true, 
                        true, 
                        AuthorityUtils.createAuthorityList(authority)
                        )
        );
    }
   
   public void setAdminSecurityContext() {
       setSecurityContext(admin.getUsername(), admin.getPassword(), false);
   }
    
    public void setAnonymousSecurityContext() {
        UserAdapter ud = makeSecurityUser(
                "anonymousUser", "n/a", "ROLE_ANONYMOUS"
        );
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(
                        ud, 
                        null, 
                        ud.getAuthorities()
                        )
                );
    }
    
    public User createUser(String username, String password, String email) {
        Authentication authRequest = new UsernamePasswordAuthenticationToken("anonymous", "anonymous");
        SecurityContextHolder.getContext().setAuthentication(authRequest);

        final User newUser = new User();
        newUser.setUsername(username);
        newUser.setEmail(email);
        newUser.setPassword(password);
        userService.create(newUser);
        
        return newUser;
    }

}
