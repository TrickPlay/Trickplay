package com.trickplay.gameservice.controllers;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.ModelAndView;

public class BaseController {


	@ExceptionHandler(BaseControllerException.class)
	public ModelAndView handleException(final BaseControllerException cex,
			final HttpServletRequest request, HttpServletResponse response) {
		response.setStatus(cex.getHttpStatus());
		request.setAttribute("exception", cex);
		Map error = new HashMap();
		
		ModelAndView mv = new ModelAndView("/errors", "error", cex.toMapError());
	//	m.addAttribute("error", cex);
		return mv;
	}



}
