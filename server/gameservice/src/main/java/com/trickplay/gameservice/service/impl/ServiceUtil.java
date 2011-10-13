package com.trickplay.gameservice.service.impl;

import com.trickplay.gameservice.domain.User;
import com.trickplay.gameservice.exception.ExceptionUtil;
import com.trickplay.gameservice.exception.GameServiceException;
import com.trickplay.gameservice.exception.GameServiceException.Reason;
import com.trickplay.gameservice.security.SecurityUtil;
import com.trickplay.gameservice.security.UserAdapter;

public class ServiceUtil {

	public static void checkAuthority(User requestor) {
		UserAdapter principal = SecurityUtil.getPrincipal();
		if (requestor == null || principal == null || !requestor.getId().equals(principal.getId()))
			throw ExceptionUtil.newForbiddenException();
	}
}
