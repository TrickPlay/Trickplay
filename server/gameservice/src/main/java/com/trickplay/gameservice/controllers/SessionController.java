package com.trickplay.gameservice.controllers;

import java.util.List;

import javax.validation.ConstraintViolation;
import javax.validation.Valid;
import javax.validation.Validator;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.Assert;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.trickplay.gameservice.domain.StatelessHttpSession;
import com.trickplay.gameservice.security.SecurityUtil;
import com.trickplay.gameservice.service.SessionService;
import com.trickplay.gameservice.transferObj.SessionRequestTO;
import com.trickplay.gameservice.transferObj.SessionTO;

@Controller
public class SessionController extends BaseController {
	private static final Logger logger = LoggerFactory.getLogger(SessionController.class);
	@Autowired
	private SessionService sessionService;
	@Autowired
	Validator validator;

	
    @RequestMapping(value = {"/session", "/rest/session"}, method = RequestMethod.GET)
    public String getSessions(Model model) {
        List<SessionTO> allSessions = sessionService.getActiveSessions();
        model.addAttribute("sessions", allSessions);
        return "session/list";
    }

    @RequestMapping(value = {"/session/{token}", "/rest/session/{token}"}, method = RequestMethod.GET)
    public String getSession(@PathVariable("token") String token, Model model) {
    	Assert.notNull(token, "Session token must be provided.");
		model.addAttribute("session", sessionService.findByToken(token));
		return "session/show";
    }

    @RequestMapping(value = "/session/form", method = RequestMethod.GET)
    public String newSession(Model model) {
        model.addAttribute("user", new StatelessHttpSession());
        return "session/create";
    }
    
    @RequestMapping(value = {"/session"}, method = RequestMethod.POST)
    public String createSession(@ModelAttribute("session") @Valid SessionRequestTO sessionTO, BindingResult result, Model model) {
    	if (result.hasErrors()) {
        	model.addAttribute("session", sessionTO);
            return "session/create";
        }
        
    	SessionTO session = sessionService.create(sessionTO.getDeviceKey());
        
        return "redirect:/user/" + SecurityUtil.getPrincipal().getId();
    }

    @RequestMapping(value = {"/rest/session"}, method = RequestMethod.POST)
    public @ResponseBody SessionTO createSessionGeneric(@RequestBody SessionRequestTO sessionTO) {
  
    	boolean hasErrors = false;
		StringBuilder err = new StringBuilder();
		for (ConstraintViolation<SessionRequestTO> constraint : validator
				.validate(sessionTO)) {
			if (hasErrors)
				err.append(",");
			err.append("[").append(constraint.getMessage()).append("]");
			hasErrors = true;
		}
		
		if (hasErrors) {
			throw new BaseControllerException(400, null, "Invalid parameters. "
					+ err.toString());
		}
		return sessionService.create(sessionTO.getDeviceKey());
    }

}
