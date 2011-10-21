package com.trickplay.gameservice.security;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.jdbc.JdbcDaoImpl;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.dao.UserDAO;
import com.trickplay.gameservice.domain.Role;

//@Repository
public class CustomUserDetailsService extends JdbcDaoImpl {
    @Autowired
    private UserDAO userDAO;

	protected UserDetails createUserDetails(String username, UserDetails userFromUserQuery,
            List<GrantedAuthority> combinedAuthorities) {

        UserAdapter userAdapter = (UserAdapter)userFromUserQuery;
        userAdapter.setAdaptee(new User(userFromUserQuery.getUsername(), userFromUserQuery.getPassword(), userFromUserQuery.isEnabled(),
                true, true, true, combinedAuthorities));
        return userAdapter;
    }
	
	protected List<UserDetails> loadUsersByUsername(String username) {
	    /*
	    com.trickplay.gameservice.domain.User u = userDAO.findByName(username);
	    List<UserDetails> result = new ArrayList<UserDetails>();
	    result.add(
	            new UserAdapter(
	            u.getId(), 
	            new User(
	                    u.getUsername(), 
	                    u.getPassword(),
	                    true,
	                    true, 
	                    true, 
	                    true, 
	                    AuthorityUtils.NO_AUTHORITIES
	                    )
	    ));
	    return result;
	    */
        return getJdbcTemplate().query(getUsersByUsernameQuery(), new String[] {username}, new RowMapper<UserDetails>() {
            public UserDetails mapRow(ResultSet rs, int rowNum) throws SQLException {
            	Long userId = rs.getLong(1);
                String username = rs.getString(2);
                String password = rs.getString(3);
                boolean enabled = rs.getBoolean(4);
                return new UserAdapter(userId, new User(username, password, enabled, true, true, true, AuthorityUtils.NO_AUTHORITIES));
            }

        });
    }

	@Transactional
	protected List<GrantedAuthority> loadUserAuthorities(String username) {
	    List<String> roles = userDAO.getRoles(username);
        return AuthorityUtils.createAuthorityList(roles.toArray(new String[] {}));
	}

}
