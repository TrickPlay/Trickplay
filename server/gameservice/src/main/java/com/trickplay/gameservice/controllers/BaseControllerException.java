package com.trickplay.gameservice.controllers;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.HttpStatus;

import com.trickplay.gameservice.exception.GameServiceException;
import com.trickplay.gameservice.exception.GameServiceException.Reason;

public class BaseControllerException extends RuntimeException {
    /**
	 * 
	 */
    private static final long serialVersionUID = 1L;
    private int httpStatus;
    private Integer errorCode;
    private String errorMessage;

    public BaseControllerException(int httpStatus, Integer errorCode,
            String errorMessage) {
        super(errorMessage);
        this.httpStatus = httpStatus;
        this.errorCode = errorCode;
        this.errorMessage = errorMessage;
    }
    
    public BaseControllerException(String errorMessage) {
        this(HttpStatus.BAD_REQUEST.value(), null, errorMessage);
    }
    
    public BaseControllerException(int httpStatus, Integer errorCode, Throwable ex) {
    	super(ex);
    	this.httpStatus = httpStatus;
    	this.errorCode = errorCode;
    }

    public BaseControllerException(Throwable ex) {
    	super(ex);
    	if (ex instanceof GameServiceException) {
    		GameServiceException gex = (GameServiceException)ex;
    		if (gex.getReason() == Reason.FORBIDDEN) {
    			httpStatus = HttpStatus.FORBIDDEN.value();
    		} else {
    			httpStatus = HttpStatus.BAD_REQUEST.value();
    		}
    	} else {
    		this.httpStatus = HttpStatus.INTERNAL_SERVER_ERROR.value();
    	}
    }
    
    public int getHttpStatus() {
        return httpStatus;
    }

    public Integer getErrorCode() {
        return errorCode;
    }

    public String getErrorMessage() {
        return errorMessage!=null ? errorMessage : getMessage();
    }

    public Map<String, Object> toMapError() {
        Map<String, Object> m = new HashMap<String, Object>();
        m.put("httpStatus", httpStatus);
        m.put("errorCode", errorCode);
        m.put("errorMessage", errorMessage);
        return m;
    }
}
