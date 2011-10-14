package com.trickplay.gameservice.dao;


import com.trickplay.gameservice.domain.User;
import com.trickplay.gameservice.exception.AuthenticationException;

public interface UserDAO extends GenericDAO<User, Long> {

  public User findByName(String username);

}
