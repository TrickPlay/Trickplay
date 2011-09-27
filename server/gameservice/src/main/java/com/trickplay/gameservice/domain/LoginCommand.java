package com.trickplay.gameservice.domain;

import java.io.Serializable;

import org.hibernate.validator.constraints.NotBlank;

public class LoginCommand implements Serializable {

    /**
     * 
     */
    private static final long serialVersionUID = 1L;
    @NotBlank
    private String user;
    @NotBlank
    private String password;
    
    public LoginCommand() {
        
    }

    public String getUser() {
        return user;
    }

    public void setUser(String user) {
        this.user = user;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
    
    
}
