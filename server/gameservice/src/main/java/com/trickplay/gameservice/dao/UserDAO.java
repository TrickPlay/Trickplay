package com.trickplay.gameservice.dao;


import java.util.List;

import com.trickplay.gameservice.domain.User;

public interface UserDAO extends GenericDAO<User, Long> {

  public User findByName(String username);
  
  public List<String> getRoles(String username);

}
