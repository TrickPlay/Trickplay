package com.trickplay.gameservice.dao.impl;

import com.trickplay.gameservice.dao.AuthorityDAO;
import com.trickplay.gameservice.domain.Authority;

public class AuthorityDAOImpl extends GenericEJB3DAO<Authority, Long> implements AuthorityDAO {

	@Override
	public Class<Authority> getEntityBeanType() {
		return Authority.class;
	}

}
