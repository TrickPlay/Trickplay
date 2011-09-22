package com.trickplay.gameservice.dao.impl;

import static java.lang.String.format;

import java.util.List;

import org.hibernate.criterion.Restrictions;
import org.springframework.stereotype.Repository;

import com.trickplay.gameservice.dao.UserDAO;
import com.trickplay.gameservice.domain.User;
import com.trickplay.gameservice.exception.AuthenticationException;

@Repository
@SuppressWarnings("unchecked")
public class UserDAOImpl extends GenericEJB3DAO<User, Long> implements UserDAO {

    public UserDAOImpl() {
        super();
    }
    
    public Class<User> getEntityBeanType() {
        return User.class;
    }
    
    public User findByName(String username) {
        return SpringUtils.getFirst(findByCriteria(Restrictions.eq("username", username)));
    }

    public User authenticateUser(String username, String password)
            throws AuthenticationException {
        List<User> validUsers = findByCriteria(
                Restrictions.conjunction()
            .add(Restrictions.eq("username", username))
            .add(Restrictions.eq("password", password))
            );

        if (validUsers.isEmpty())
            throw new AuthenticationException(format(
                    "Could not authenticate %s", username));
        return SpringUtils.getFirst(validUsers);
    }

}
