package org.frogx.service.api.exception;

public class LeasedException extends RuntimeException {
	
	private static final long serialVersionUID = 1L;
	
	public LeasedException() {
		super();
	}
	
	public LeasedException(String msg) {
		super(msg);
	}
	
	public LeasedException(String message, Throwable cause) {
		super(message, cause);
	}
	
	public LeasedException(Throwable cause) {
		super(cause);
	}
}
