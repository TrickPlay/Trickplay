package org.frogx.service.api.exception;

public class NotFoundException extends RuntimeException {
	
	private static final long serialVersionUID = 1L;
	
	public NotFoundException() {
		super();
	}
	
	public NotFoundException(String msg) {
		super(msg);
	}
	
	public NotFoundException(String message, Throwable cause) {
		super(message, cause);
	}
	
	public NotFoundException(Throwable cause) {
		super(cause);
	}
}
