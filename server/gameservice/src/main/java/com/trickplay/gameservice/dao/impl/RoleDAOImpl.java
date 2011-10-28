package com.trickplay.gameservice.dao.impl;

import java.util.List;

import org.springframework.stereotype.Repository;

import com.trickplay.gameservice.dao.RoleDAO;
import com.trickplay.gameservice.domain.Role;

@Repository
@SuppressWarnings(value="unchecked")
public class RoleDAOImpl extends GenericDAOWithJPA<Role, Long> implements RoleDAO {
    
    public Role findRole(String rolename) {
        List<Role> list = super.entityManager
                .createQuery("Select r from Role as r where r.name = :name")
                .setParameter("name", rolename).getResultList();
                return SpringUtils.getFirst(list);
    }
}
