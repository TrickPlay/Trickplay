package com.trickplay.gameservice.controllers;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.converter.HttpMessageConversionException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.ModelAndView;

import com.trickplay.gameservice.exception.GameServiceException;

public class BaseController {
    private static final Logger logger = LoggerFactory.getLogger(BaseController.class);
/*
	@ExceptionHandler(BaseControllerException.class)
	public ModelAndView handleException(final BaseControllerException cex,
			final HttpServletRequest request, HttpServletResponse response) {
		response.setStatus(cex.getHttpStatus());
		request.setAttribute("exception", cex);
		
		ModelAndView mv = new ModelAndView("/errors", "error", cex.toMapError());
		return mv;
	}

	@ExceptionHandler(GameServiceException.class)
    public ModelAndView handleException(final GameServiceException ex,
            final HttpServletRequest request, HttpServletResponse response) {
        response.setStatus(ex.getReason().getHttpStatus().value());
        request.setAttribute("exception", ex);
        
        ModelAndView mv = new ModelAndView("/errors", "error", ex.toMapError());
        return mv;
    }
	*/
	
	@ExceptionHandler(RuntimeException.class)
    public ModelAndView handleException(final RuntimeException ex,
            final HttpServletRequest request, HttpServletResponse response) {
	    if (!(ex instanceof GameServiceException) && !(ex instanceof BaseControllerException)) {
	        logger.error("Caught RuntimeException while processing request.", ex);
	    }
	    int httpStatus = exceptionToHttpStatus(ex);
        response.setStatus(httpStatus);
        request.setAttribute("exception", ex);
        
        Map<String, Object> errorMap = new HashMap<String, Object>();
        errorMap.put("httpStatus", httpStatus);
        errorMap.put("errorCode", null);
        errorMap.put("errorMessage", ex.getMessage());
        ModelAndView mv = new ModelAndView("/errors", "error", errorMap);
        return mv;
    }
	
	public int exceptionToHttpStatus(RuntimeException ex) {
	    if (ex instanceof GameServiceException)
	        return ((GameServiceException)ex).getReason().getHttpStatus().value();
	    else if (ex instanceof BaseControllerException)
	        return ((BaseControllerException)ex).getHttpStatus();
	    else if (ex instanceof HttpMessageConversionException)
	        return HttpStatus.BAD_REQUEST.value();
	    else if (ex instanceof IllegalArgumentException)
            return HttpStatus.BAD_REQUEST.value();
	    return HttpStatus.INTERNAL_SERVER_ERROR.value();
	}

}
