package com.trickplay.gameservice.service.impl;

import java.nio.charset.Charset;
import java.security.SecureRandom;
import java.util.Date;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.codec.Base64;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.dao.impl.GenericDAOWithJPA;
import com.trickplay.gameservice.dao.impl.SpringUtils;
import com.trickplay.gameservice.domain.SessionToken;
import com.trickplay.gameservice.domain.StatelessHttpSession;
import com.trickplay.gameservice.exception.GameServiceException;
import com.trickplay.gameservice.exception.GameServiceException.ExceptionContext;
import com.trickplay.gameservice.exception.GameServiceException.Reason;
import com.trickplay.gameservice.security.SecurityUtil;
import com.trickplay.gameservice.service.DeviceService;
import com.trickplay.gameservice.service.SessionService;

@Service("sessionService")
@Repository
public class SessionServiceImpl extends
		GenericDAOWithJPA<SessionToken, Long> implements SessionService {
	private static final long MAX_SESSION_DURATION = 12 * 60 * 60 * 1000;

	@Autowired
	DeviceService deviceService;

	public SessionToken findByToken(String token) {
	    SessionToken session = findSessionByToken(token);
		return session;
		//return session != null ? new SessionTO(session) : null;
	}

	@SuppressWarnings("unchecked")
	private SessionToken findSessionByToken(String token) {
		List<SessionToken> list = super.entityManager
				.createQuery(
						"Select session from SessionToken session where session.token = :token")
				.setParameter("token", token).getResultList();
		return SpringUtils.getFirst(list);
	}

	public void create(SessionToken token) {
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
		persist(token);
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
			throw new GameServiceException(Reason.FAILED_TO_CREATE_SESSION, e);
		}
	}
	

	@Transactional
	public SessionToken touchSession(String tokenId) {
		SessionToken httpSession = findByToken(tokenId);
		if (httpSession == null)
			throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null,
					ExceptionContext.make("Session.token", tokenId));
		if (httpSession.isExpired())
			throw new GameServiceException(Reason.SESSION_EXPIRED, null,
					ExceptionContext.make("Session.token", tokenId));
		else 
			httpSession.setLastUsed(new Date());
		return httpSession;
	}
	
	@Transactional
    public SessionToken expireToken(Long tokenId) {
        SessionToken httpSession = find(tokenId);
        if (httpSession == null)
            throw new GameServiceException(Reason.ENTITY_NOT_FOUND, null,
                    ExceptionContext.make("Session.token", tokenId));
        if (!httpSession.isExpired())
            httpSession.setExpired(true);
        return httpSession;
    }

	public void remove(String token) {

	}

	public List<Long> pickPlayersRandom(int count) {
	    // get distinct users from session table whose sessions have not expired
	    String pickPlayersQuery = "select distinct t.userId from SessionToken t where t.expired=false AND t.userId!=:currentUserId order by t.lastUsed DESC"; 
		return entityManager.createQuery(pickPlayersQuery)
		.setParameter("currentUserId", SecurityUtil.getPrincipal().getId())
		.setMaxResults(count)
		.getResultList();
	}

}
