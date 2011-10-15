package com.trickplay.gameservice.service.impl;

import java.nio.charset.Charset;
import java.security.SecureRandom;
import java.util.Date;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.core.codec.Base64;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.dao.DeviceDAO;
import com.trickplay.gameservice.dao.SessionTokenDAO;
import com.trickplay.gameservice.domain.SessionToken;
import com.trickplay.gameservice.exception.ExceptionUtil;
import com.trickplay.gameservice.security.SecurityUtil;
import com.trickplay.gameservice.service.SessionService;

@Service("sessionService")
public class SessionServiceImpl implements SessionService {
    private static final Logger logger = LoggerFactory.getLogger(SessionServiceImpl.class);

	@Autowired
	DeviceDAO deviceDAO;
	
	@Autowired
    SessionTokenDAO sessionTokenDAO;

	public SessionToken findByToken(String token) {
	    return sessionTokenDAO.findByToken(token);
	}


	@Transactional
	public void create(SessionToken sessionToken) {
	    /*
		Device d = deviceService.findByKey(deviceKey);
		if (d == null) {
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null,
					ExceptionContext.make("Device.deviceKey", deviceKey));
		}
		StatelessHttpSession session = new StatelessHttpSession();
		session.setToken(generateToken());
		session.setExpires(computeTokenExpirationTime());
		session.setDevice(d);
		User owner = super.entityManager.find(User.class, SecurityUtil
				.getPrincipal().getId());
		session.setOwner(owner);
		*/
	    if (sessionToken == null) {
	        throw ExceptionUtil.newIllegalArgumentException("SessionToken", null, "!= null");
	    } else if (sessionToken.getToken() == null || sessionToken.getToken().trim().isEmpty()) {
	        throw ExceptionUtil.newIllegalArgumentException("SessionToken.token", "", "length(SessionToken.token) > 0");
	    }
	    try {
	        sessionTokenDAO.persist(sessionToken);
	    } catch (DataIntegrityViolationException ex) {
	        logger.error("Failed to create SessionToken.", ex);
	        throw ExceptionUtil.newEntityExistsException(SessionToken.class,
	                "token", sessionToken.getToken());
	    }
	//	return session;
	//	return new SessionTO(session);
	}

	public static String generateToken() {
		try {
			// token is a 256-bit base64 encoded random string
			SecureRandom random = SecureRandom.getInstance("SHA1PRNG");
			byte[] bytes = new byte[256 / 8];
			random.nextBytes(bytes);
			return new String(Base64.encode(bytes), Charset.forName("US-ASCII"));
		} catch (Exception e) {
			throw ExceptionUtil.newFailedToCreateSessionException(e);
		}
	}
	

	@Transactional
	public SessionToken touchSession(String tokenId) {
		SessionToken httpSession = findByToken(tokenId);
		if (httpSession == null) {
			throw ExceptionUtil.newEntityNotFoundException(SessionToken.class, "token", tokenId);
		}
		if (httpSession.isExpired()) {
			throw ExceptionUtil.newSessionExpiredException(tokenId);
		} 
		else { 
			httpSession.setLastUsed(new Date());
		}
		return httpSession;
	}
	
	@Transactional
    public SessionToken expireToken(Long tokenId) {
        SessionToken httpSession = sessionTokenDAO.find(tokenId);
        if (httpSession == null) {
            throw ExceptionUtil.newEntityNotFoundException(SessionToken.class, "token", tokenId);
        }
        if (!httpSession.isExpired())
            httpSession.setExpired(true);
        return httpSession;
    }

	public void remove(String token) {
	    throw ExceptionUtil.newUnsupportedOperationException("remove(Session)");
	}

	public List<Long> pickPlayersRandom(int count) {
	    return sessionTokenDAO.pickPlayersRandom(SecurityUtil.getCurrentUserId(), count);
	}

}
