package com.trickplay.gameservice.controllers;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.validation.ConstraintViolation;
import javax.validation.Valid;
import javax.validation.Validator;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.dao.DataAccessException;
import org.springframework.security.authentication.ProviderManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.Assert;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.trickplay.gameservice.domain.BuddyListInvitation;
import com.trickplay.gameservice.domain.User;
import com.trickplay.gameservice.exception.GameServiceException;
import com.trickplay.gameservice.exception.GameServiceException.Reason;
import com.trickplay.gameservice.security.SecurityUtil;
import com.trickplay.gameservice.service.BuddyService;
import com.trickplay.gameservice.service.DBPurgeService;
import com.trickplay.gameservice.service.UserService;
import com.trickplay.gameservice.transferObj.BooleanResponse;
import com.trickplay.gameservice.transferObj.BuddyInvitationListTO;
import com.trickplay.gameservice.transferObj.BuddyInvitationRequestTO;
import com.trickplay.gameservice.transferObj.BuddyInvitationTO;
import com.trickplay.gameservice.transferObj.DeviceRequestTO;
import com.trickplay.gameservice.transferObj.DeviceTO;
import com.trickplay.gameservice.transferObj.UpdateInvitationStatusRequestTO;
import com.trickplay.gameservice.transferObj.UserBuddiesTO;
import com.trickplay.gameservice.transferObj.UserRequestTO;
import com.trickplay.gameservice.transferObj.UserTO;

@Controller
// @RequestMapping(value={"/rest/user", "/user"})
public class UserController extends BaseController {
	private static final Logger logger = LoggerFactory
			.getLogger(UserController.class);
	@Autowired
	private UserService userService;
	
	@Autowired
    private DBPurgeService dbPurgeService;

	@Autowired
	Validator validator;

	@Resource
	@Qualifier("am")
	private ProviderManager authenticationManager;

	@Autowired
	private BuddyService buddyService;
	
	
	/*
	 * @ModelAttribute("user") public User userInstance() { return new User(); }
	 */
	public static final String BUDDY_VIEW = "user/buddies";
	public static final String SHOW_USER_VIEW = "user/show";
	public static final String CREATE_USER_VIEW = "user/create";
	public static final String LIST_USER_VIEW = "user/list";

	@RequestMapping(value = "/user/form", method = RequestMethod.GET)
	public String newUser(Model m) {
		m.addAttribute("user", new User());
		return CREATE_USER_VIEW;
	}

	@RequestMapping(value = { "/user" }, method = RequestMethod.POST, headers = "content-type=application/x-www-form-urlencoded")
	public String processFormUser(
			@ModelAttribute("user") @Valid User user, BindingResult result,
			Model model, HttpServletRequest request,
			HttpServletResponse response) {
		if (result.hasErrors()) {
			return CREATE_USER_VIEW;
		}
		String password = user.getPassword();
		try {
			userService.create(user);
		} catch (DataAccessException dae) {
			result.reject("user.exists", "Duplicate User");
			return CREATE_USER_VIEW;
		}
		if (request.getUserPrincipal() == null) {
			autoLogin(request, response, user.getUsername(), password);
		}
		return "redirect:/user/" + user.getId();
	}

	@RequestMapping(value = { "/rest/user" }, method = RequestMethod.POST)
	public @ResponseBody
	UserTO processCreateUserGeneric(@RequestBody UserRequestTO userRequest) {
		StringBuilder err = new StringBuilder();
		boolean hasErrors = false;
		for (ConstraintViolation<UserRequestTO> constraint : validator.validate(userRequest)) {
			// result.rejectValue(constraint.getPropertyPath().toString(), "",
			// constraint.getMessage());
			// logger.error("\n\n " + constraint.getMessage() + "\n\n");
			if (hasErrors)
				err.append(",");
			err.append("[").append(constraint.getMessage()).append("]");
			hasErrors = true;
		}
		if (hasErrors) {
			throw new BaseControllerException(400, null, "Invalid parameters. "
					+ err.toString());
		}
		User u = userRequest.toUser();
		try {
			userService.create(u);
		} catch (DataAccessException dae) {
			throw new BaseControllerException(400, null, "Duplicate user");
		}
		return new UserTO(u);
	}

	@RequestMapping(value = { "/user", "/rest/user" }, method = RequestMethod.GET)
	public @ResponseBody UserTO getUserInfo(@RequestParam(value="username") String username) {
		return new UserTO(userService.findByName(username));
	}

	private static List<UserTO> toUserTO(List<? extends User> lu) {
		List<UserTO> lt = new ArrayList<UserTO>();
		for (User u : lu) {
			lt.add(new UserTO(u));
		}
		return lt;
	}

	@RequestMapping(value = { "/user/{id}", "/rest/user/{id}" }, method = RequestMethod.GET)
	public String getUser(@PathVariable("id") Long userId, Model model) {
		Assert.notNull(userId, "Identifier must be provided.");
		model.addAttribute("user", new UserTO(userService.find(userId)));
		return SHOW_USER_VIEW;
	}

    @RequestMapping(value = { "/rest/user/exists" }, method = RequestMethod.GET)
    public @ResponseBody BooleanResponse checkUserExists(@RequestParam(value="username", required=true) String username) {
        if (null != userService.findByName(username))
            return BooleanResponse.TRUE;
        else
            return BooleanResponse.FALSE;
    }
    
	@RequestMapping(value = { "/user/buddy-list" }, method = RequestMethod.GET)
	public String getBuddyList(@PathVariable("id") Long userid, Model model) {
		model.addAttribute("invitation", new BuddyInvitationTO());
		
		return retrieveBuddyList(model);
	}
	
	public String retrieveBuddyList(Model m) {
		User u = userService.find(SecurityUtil.getPrincipal().getId());
		m.addAttribute("buddies", new UserBuddiesTO(u));
		return BUDDY_VIEW;
	}

	@RequestMapping(value = { "/rest/user/buddy-list" }, method = RequestMethod.GET)
	public @ResponseBody UserBuddiesTO getBuddyListGeneric() {
		User u = userService.find(SecurityUtil.getPrincipal().getId());

		return new UserBuddiesTO(u);
	}
	
	@RequestMapping(value = { "/rest/user/invitation" }, method = RequestMethod.GET)
	public @ResponseBody BuddyInvitationListTO getBuddyInvitationsGeneric(@RequestParam(value="type", required=false) String type) {
		User u = userService.find(SecurityUtil.getPrincipal().getId());
		if ("RECEIVED".equalsIgnoreCase(type))
			return new BuddyInvitationListTO(u.getInvitationsReceived());
		else {
			List<BuddyListInvitation> all = new ArrayList<BuddyListInvitation>();
			all.addAll(u.getInvitationsReceived());
			all.addAll(u.getInvitationsSent());
			return new BuddyInvitationListTO(all);
		}
	}

	@RequestMapping(value = { "/rest/user/invitation" }, method = RequestMethod.POST)
	public @ResponseBody
	BuddyInvitationTO sendBuddyInvitationGeneric(
			@RequestBody BuddyInvitationRequestTO invitation) {

		StringBuilder err = new StringBuilder();
		boolean hasErrors = false;
		for (ConstraintViolation<BuddyInvitationRequestTO> constraint : validator
				.validate(invitation)) {
			// result.rejectValue(constraint.getPropertyPath().toString(), "",
			// constraint.getMessage());
			// logger.error("\n\n " + constraint.getMessage() + "\n\n");
			if (hasErrors)
				err.append(",");
			err.append("[").append(constraint.getMessage()).append("]");
			hasErrors = true;
		}

		if (hasErrors) {
			throw new BaseControllerException(400, null, "Invalid parameters. "
					+ err.toString());
		}

		try {
			return new BuddyInvitationTO(buddyService.sendInvitation(invitation.getRecipient()));
		} catch (Exception ex) {
			throw new BaseControllerException(ex);
		}

	}

	@RequestMapping(value = { "/user/invitation" }, method = RequestMethod.POST)
	public String sendBuddyInvitation(@ModelAttribute("invitation") @Valid BuddyInvitationRequestTO invitation,
			BindingResult rs, Model model) {

		if (rs.hasErrors()) {
			retrieveBuddyList(model);
			return BUDDY_VIEW;
		}

		try {
			buddyService.sendInvitation(invitation.getRecipient());
		} catch (GameServiceException ex) {
			if (ex.getReason() == Reason.ALREADY_BUDDY) {
				rs.reject("recipientAlreadyBuddy",
						"Recipient already in buddy list");
			} else {
				rs.reject("sendBuddyInvitationFailed",
						"Failed to send invitation. error=" + ex.toString());
			}

		} catch (Exception ex) {
			rs.reject("sendBuddyInvitationFailed",
					"Failed to send invitation. error=" + ex.getMessage());
		}

		if (rs.hasErrors()) {
			retrieveBuddyList(model);
			return BUDDY_VIEW;
		}

		return "redirect:/user/buddy-list";
	}

	@RequestMapping(value = { "/rest/user/invitation/{invitationId}" }, method = RequestMethod.PUT)
	public @ResponseBody
	BuddyInvitationTO processInvitationGeneric(@PathVariable("invitationId") Long invitationId,
			@RequestBody UpdateInvitationStatusRequestTO invitation, Model m) {

		StringBuilder err = new StringBuilder();
		boolean hasErrors = false;
		for (ConstraintViolation<UpdateInvitationStatusRequestTO> constraint : validator
				.validate(invitation)) {
			if (hasErrors)
				err.append(",");
			err.append("[").append(constraint.getMessage()).append("]");
			hasErrors = true;
		}

		if (hasErrors) {
			throw new BaseControllerException(400, null, "Invalid parameters. "
					+ err.toString());
		}

		try {
			return new BuddyInvitationTO(buddyService.updateInvitationStatus(invitationId,
					invitation.getStatus()));
		} catch (Exception ex) {
			throw new BaseControllerException(ex);
		}
	}

	@RequestMapping(value = { "/user/invitation/{invitationId}" }, method = RequestMethod.POST)
	public String processInvitation(@PathVariable("invitationId") Long invitationId,
			@ModelAttribute("invitation") BuddyInvitationTO invitation,
			BindingResult rs, Model model) {

		try {
			buddyService.updateInvitationStatus(invitationId,
					invitation.getStatus());
		} catch (Exception ex) {
			rs.reject("processInvitationFailed",
					"Failed to process invitation. error=" + ex.getMessage());
		}

		if (rs.hasErrors()) {
			retrieveBuddyList(model);
			return BUDDY_VIEW;
		}
		return "redirect:/user/buddy-list";
	}

	private void autoLogin(HttpServletRequest request,
			HttpServletResponse response, String username, String password) {
		try {
			// Must be called from request filtered by Spring Security,
			// otherwise SecurityContextHolder is not updated
			UsernamePasswordAuthenticationToken token = new UsernamePasswordAuthenticationToken(
					username, password);
			token.setDetails(new WebAuthenticationDetails(request));
			Authentication authentication = authenticationManager
					.authenticate(token);
			logger.debug("Logging in with {}", authentication.getPrincipal());
			SecurityContextHolder.getContext()
					.setAuthentication(authentication);
		} catch (Exception e) {
			SecurityContextHolder.getContext().setAuthentication(null);
			logger.error("Failure in autoLogin", e);
		}
	}

	@RequestMapping(value = { "/user/device" }, method = RequestMethod.POST)
	public String registerDevice(@ModelAttribute("device") @Valid DeviceRequestTO deviceRequest, BindingResult rs) {

		if (rs.hasErrors()) {
			return "device/create";
		}
		userService.registerDevice(deviceRequest.toDevice());
		return "redirect:/user/device";
	}

	@RequestMapping(value = { "/rest/user/device" }, method = RequestMethod.POST)
	public @ResponseBody
	DeviceTO registerDeviceGeneric(@RequestBody DeviceRequestTO deviceRequest) {
		boolean hasErrors = false;
		StringBuilder err = new StringBuilder();
		for (ConstraintViolation<DeviceRequestTO> constraint : validator
				.validate(deviceRequest)) {
			if (hasErrors)
				err.append(",");
			err.append("[").append(constraint.getMessage()).append("]");
			hasErrors = true;
		}
		
		if (hasErrors) {
			throw new BaseControllerException(400, null, "Invalid parameters. "
					+ err.toString());
		}
		try {
			return new DeviceTO(userService.registerDevice(deviceRequest.toDevice()));
		} catch (Exception e) {
			throw new BaseControllerException(e);
		}
	}


	@RequestMapping(value = { "/rest/user/resetDB" }, method = RequestMethod.GET)
    public @ResponseBody BooleanResponse resetDB() {
        dbPurgeService.resetDB();
        return BooleanResponse.TRUE;
    }
}
