package com.trickplay.gameservice.exception;

import java.util.Arrays;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.context.i18n.LocaleContextHolder;

@SuppressWarnings("serial")
public class GameServiceException extends RuntimeException {

 	public enum Reason {
		ENTITY_NOT_FOUND("entityNotFound"),
		ENTITY_EXISTS_EXCEPTION("entityExists"),
		ALREADY_BUDDY("alreadyBuddy"),
        BL_INVITATION_CANCEL_FAILED("cancelBuddyListInvitationFailed"),
        BL_INVITATION_ACCEPT_FAILED("acceptBuddyListInvitationFailed"),
        BL_INVITATION_DECLINE_FAILED("declineBuddyListInvitationFailed"),
        BL_INVITATION_STATUS_UPDATE_FAILED("updateBuddyListInvitationFailed"),
		INVITATION_PREVIOUSLY_SENT("invitationPreviouslySent"),
		GAME_ALREADY_STARTED("gameAlreadyStarted"),
		GAME_ALREADY_ENDED("gameAlreadyEnded"),
		GAME_NOT_STARTED("gameNotStarted"),
		SEND_INVITATION_FAILED("sendInvitationFailed"),
		FORBIDDEN("forbidden"),
		FAILED_TO_CREATE_SESSION("failedToCreateSession"),
		SESSION_EXPIRED("sessionExpired"),
		ILLEGAL_ARGUMENT("illegalArgument"),
        GP_INVITATION_INVALID_STATUS("gamePlayInvitationInvalidStatus"),
		GP_RECIPIENT_SAME_AS_REQUESTOR("recipientSameAsRequestor"),
		GP_VIOLATES_MAX_PLAYERS_LIMIT("exceedsMaxPlayersAllowed"),
		UNSUPPORTED_OPERATION_EXCEPTION("unsupportedOperationException"),
		WILDCARD_INVITATION_NOT_ALLOWED("wildcardInvitationNotAllowed"),
		INVITATION_RESERVED("invitationReserved"),
		NOT_INVITATION_RECIPIENT("notInvitationRecipient"),
		UNKNOWN("unknown");
		
        private String messageKey;
		private Reason(String messageKey) {
		    this.messageKey = messageKey;
		}
		
		public String getMessageKey() {
		    return messageKey;
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
	
}
