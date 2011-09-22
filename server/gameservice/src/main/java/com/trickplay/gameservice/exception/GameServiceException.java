package com.trickplay.gameservice.exception;

import java.util.Arrays;

@SuppressWarnings("serial")
public class GameServiceException extends RuntimeException {

	public enum Reason {
		ENTITY_NOT_FOUND,
		ALREADY_BUDDY,
		INVITATION_PREVIOUSLY_SENT,
		INVITATION_INVALID_STATUS,
		GAME_ALREADY_STARTED,
		GAME_ALREADY_ENDED,
		GAME_NOT_STARTED,
		SEND_INVITATION_FAILED,
		FORBIDDEN,
		FAILED_TO_CREATE_SESSION,
		SESSION_EXPIRED,
		ILLEGAL_ARGUMENT,
		GP_RECIPIENT_SAME_AS_REQUESTOR,
		GP_EXCEEDS_MAX_PLAYERS_ALLOWED,
		GP_BELOW_MIN_PLAYERS_REQUIRED,
		UNSUPPORTED_OPERATION_EXCEPTION,
		UNKNOWN,
	};

	public static class ExceptionContext {
		private String name;
		private Object value;
		
		public ExceptionContext() {
			
		}

		public ExceptionContext(String name, Object value) {
			this.name = name;
			this.value = value;
		}
		public String getName() {
			return name;
		}

		public void setName(String name) {
			this.name = name;
		}

		public Object getValue() {
			return value;
		}

		public void setValue(Object value) {
			this.value = value;
		}
		
		public static ExceptionContext make(String name, Object value) {
			return new ExceptionContext(name, value);
		}
		
		public String toString() {
			return "ExceptionContext [name="+name+", value="+value+" ]";
		}
	}
	
	private Reason reason;
	private ExceptionContext args[];

	public GameServiceException() {
		super();
		setReason(Reason.UNKNOWN);
	}

	public GameServiceException(Reason r) {
		super(r.toString());
		setReason(r);
	}
	
	public GameServiceException(Reason r, Exception ex) {
		super(r.toString()+". "+ex.getMessage(), ex);
	}
	
	public GameServiceException(Reason r, Exception ex, ExceptionContext...args) {
		super(r.toString() + ". " + ex.getMessage());
		setReason(r);
		this.args = args; 
	}

	public GameServiceException(String string, Throwable throwable) {
		super(Reason.UNKNOWN.name() + "." + string, throwable);
		setReason(Reason.UNKNOWN);
	}

	public GameServiceException(Throwable throwable) {
		this("", throwable);
	}

	public void setReason(Reason reason) {
		this.reason = reason;
	}

	public Reason getReason() {
		return reason;
	}
	
	public Object[] getArgs() {
		return args;
	}

	@Override
	public String toString() {
		return "GameServiceException [reason=" + reason + ", args="
				+ Arrays.toString(args) 
				+ ", cause="
				+ (getCause()!=null ? getCause().getMessage() : "null") + "]";
	}
	
	
}
