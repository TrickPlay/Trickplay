package com.trickplay.gameservice.controllers;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class ErrorController {
	/*
	 * @ExceptionHandler(IllegalArgumentException.class) public String
	 * handleException(final Exception e, final HttpServletRequest request) {
	 * final Map<String, Object> map = new HashMap<String, Object>();
	 * map.put("errorCode", 1234); map.put("errorMessage",
	 * "Some error message"); request.setAttribute("error", map); return
	 * "forward:/book/errors"; //forward to url for generic errors }
	 */
	// set the response status and return the error object to be marshalled
	@SuppressWarnings("unchecked")
	@RequestMapping(value =  "/errors" , method = { RequestMethod.POST,
			RequestMethod.GET })
	public @ResponseBody
	Map<String, Object> showError(HttpServletRequest request,
			HttpServletResponse response) {

		Map<String, Object> map = new HashMap<String, Object>();
		if (request.getAttribute("error") != null)
			map = (Map<String, Object>) request.getAttribute("error");

		response.setStatus((Integer)map.get("httpStatus"));

		return map;
	}
}
