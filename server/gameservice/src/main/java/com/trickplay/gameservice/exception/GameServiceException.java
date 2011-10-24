package com.trickplay.gameservice.exception;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.http.HttpStatus;

@SuppressWarnings("serial")
public class GameServiceException extends RuntimeException {

 	public enum Reason {
		ENTITY_NOT_FOUND("entityNotFound", HttpStatus.BAD_REQUEST),
		ENTITY_EXISTS_EXCEPTION("entityExists", HttpStatus.BAD_REQUEST),
		ALREADY_BUDDY("alreadyBuddy", HttpStatus.BAD_REQUEST),
		INVITATION_TO_SELF("invitationToSelf", HttpStatus.BAD_REQUEST),
		CONSTRAINT_VIOLATION("constraintViolation", HttpStatus.BAD_REQUEST),
        BL_INVITATION_CANCEL_FAILED("cancelBuddyListInvitationFailed",  HttpStatus.BAD_REQUEST),
        BL_INVITATION_ACCEPT_FAILED("acceptBuddyListInvitationFailed",  HttpStatus.BAD_REQUEST),
        BL_INVITATION_REJECT_FAILED("rejectBuddyListInvitationFailed",  HttpStatus.BAD_REQUEST),
        BL_INVITATION_STATUS_UPDATE_FAILED("updateBuddyListInvitationFailed",  HttpStatus.BAD_REQUEST),
		INVITATION_PREVIOUSLY_SENT("invitationPreviouslySent",  HttpStatus.BAD_REQUEST),
		GAME_ALREADY_STARTED("gameAlreadyStarted", HttpStatus.BAD_REQUEST),
		GAME_ALREADY_ENDED("gameAlreadyEnded", HttpStatus.BAD_REQUEST),
		GAME_NOT_STARTED("gameNotStarted", HttpStatus.BAD_REQUEST),
		PAIR_ALREADY_IN_GAME_PLAY_SESSION("pairAlreadyInGamePlaySession", HttpStatus.BAD_REQUEST),
		SEND_INVITATION_FAILED("sendInvitationFailed", HttpStatus.INTERNAL_SERVER_ERROR),
		UNAUTHORIZED("unauthorized", HttpStatus.UNAUTHORIZED),
		FAILED_TO_CREATE_SESSION("failedToCreateSession", HttpStatus.INTERNAL_SERVER_ERROR),
		SESSION_EXPIRED("sessionExpired", HttpStatus.FORBIDDEN),
		ILLEGAL_ARGUMENT("illegalArgument", HttpStatus.BAD_REQUEST),
        GP_INVITATION_INVALID_STATUS("gamePlayInvitationInvalidStatus", HttpStatus.BAD_REQUEST),
		GP_RECIPIENT_SAME_AS_REQUESTOR("recipientSameAsRequestor", HttpStatus.BAD_REQUEST),
		GP_VIOLATES_MAX_PLAYERS_LIMIT("exceedsMaxPlayersAllowed", HttpStatus.BAD_REQUEST),
		UNSUPPORTED_OPERATION_EXCEPTION("unsupportedOperationException", HttpStatus.NOT_IMPLEMENTED),
		WILDCARD_INVITATION_NOT_ALLOWED("wildcardInvitationNotAllowed", HttpStatus.BAD_REQUEST),
		INVITATION_RESERVED("invitationReserved", HttpStatus.BAD_REQUEST),
		NOT_INVITATION_RECIPIENT("notInvitationRecipient", HttpStatus.BAD_REQUEST),
		UNKNOWN("unknown", HttpStatus.INTERNAL_SERVER_ERROR);
		
        private final String messageKey;
        private final HttpStatus httpStatus;
		private Reason(String messageKey, HttpStatus httpStatus) {
		    this.messageKey = messageKey;
		    this.httpStatus = httpStatus;
		}
		
		public String getMessageKey() {
		    return messageKey;
		}
		
		public HttpStatus getHttpStatus() {
		    return httpStatus;
		}
		
	};
	
	
    @Autowired
    private MessageSource messageSource;
    private String message;
	private final Reason reason;
	private Object args[];

	GameServiceException() {
		this(Reason.UNKNOWN);
	}

	 GameServiceException(Exception cause, Reason r, Object...args) {
		super(cause);
		if (r == null) {
		    throw new IllegalArgumentException("invalid reason code: 'null'");
		}
		reason = r;
		this.args = args;
	}
	
    GameServiceException(Reason r, Object... args) {
        this(null, r, args);
    }

	public final String getMessage() {
	    if (message==null) {
	        synchronized(message) {
	            if (message==null) {
	                message = messageSource.getMessage(reason.getMessageKey(), args, LocaleContextHolder.getLocale());
	            }
	        }
	    }
	    return message;
	}
	
	public Reason getReason() {
		return reason;
	}
	
	public Object[] getArgs() {
		return args != null ? args.clone() : null;
	}
	

	@Override
	public String toString() {
		return "GameServiceException [reason=" + reason + ", args="
				+ Arrays.toString(args) 
				+ ", cause="
				+ (getCause()!=null ? getCause().getMessage() : "null") + "]";
	}
	
	public Map<String, Object> toMapError() {
	    Map<String, Object> retval = new HashMap<String, Object>();
	    retval.put("httpStatus", reason.getHttpStatus().value());
	    retval.put("errorCode", null);
	    retval.put("errorMessage", getMessage());
	    return retval;
	}
}
