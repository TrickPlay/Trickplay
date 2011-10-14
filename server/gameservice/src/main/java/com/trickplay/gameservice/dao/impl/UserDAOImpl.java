package com.trickplay.gameservice.dao.impl;

import java.util.List;

import org.springframework.stereotype.Repository;

import com.trickplay.gameservice.dao.UserDAO;
import com.trickplay.gameservice.domain.User;

@Repository
@SuppressWarnings("unchecked")
public class UserDAOImpl extends GenericDAOWithJPA<User, Long> implements UserDAO {

    public User findByName(String username) {
        
        List<User> list = 
                super.entityManager
                .createQuery("Select u from User as u where u.username = :username")
                .setParameter("username", username).getResultList();
        User u = SpringUtils.getFirst(list);
     /*   if (detached) 
            entityManager.detach(u);
            */
        return u;
    }
    

}
