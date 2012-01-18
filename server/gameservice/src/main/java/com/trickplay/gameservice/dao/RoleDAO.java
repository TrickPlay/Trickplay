package com.trickplay.gameservice.dao;


import com.trickplay.gameservice.domain.Role;

public interface RoleDAO extends GenericDAO<Role, Long> {
    public Role findRole(String rolename);

}
