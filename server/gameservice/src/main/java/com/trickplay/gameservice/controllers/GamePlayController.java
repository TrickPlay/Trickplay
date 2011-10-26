package com.trickplay.gameservice.controllers;

import java.util.List;

import javax.validation.ConstraintViolation;
import javax.validation.Validator;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.trickplay.gameservice.domain.Event;
import com.trickplay.gameservice.domain.EventSelectionCriteria;
import com.trickplay.gameservice.domain.GameSessionMessage;
import com.trickplay.gameservice.domain.GameStepId;
import com.trickplay.gameservice.service.EventService;
import com.trickplay.gameservice.service.GamePlayService;
import com.trickplay.gameservice.transferObj.EventListTO;
import com.trickplay.gameservice.transferObj.GamePlayInvitationListTO;
import com.trickplay.gameservice.transferObj.GamePlayInvitationRequestTO;
import com.trickplay.gameservice.transferObj.GamePlayInvitationTO;
import com.trickplay.gameservice.transferObj.GamePlayRequestTO;
import com.trickplay.gameservice.transferObj.GamePlaySessionListTO;
import com.trickplay.gameservice.transferObj.GamePlaySessionRequestTO;
import com.trickplay.gameservice.transferObj.GamePlaySessionTO;
import com.trickplay.gameservice.transferObj.GamePlayStateTO;
import com.trickplay.gameservice.transferObj.GamePlaySummaryRequestTO;
import com.trickplay.gameservice.transferObj.GamePlaySummaryTO;
import com.trickplay.gameservice.transferObj.GameSessionMessageListTO;
import com.trickplay.gameservice.transferObj.GameSessionMessageRequestTO;
import com.trickplay.gameservice.transferObj.GameSessionMessageTO;
import com.trickplay.gameservice.transferObj.UpdateInvitationStatusRequestTO;

@Controller
public class GamePlayController extends BaseController {
	@Autowired
	GamePlayService gamePlayService;
	@Autowired
	Validator validator;
	@Autowired
	EventService eventService;
	
	@RequestMapping(value={"/rest/gameplay"},  method = RequestMethod.POST )
	public @ResponseBody GamePlaySessionTO createGameSession(@RequestBody GamePlaySessionRequestTO input) {
		StringBuilder err = new StringBuilder();
		if (input == null) {
			throw new BaseControllerException(400, null, "Received GamePlayInvitation is null");
		}
		
		boolean hasErrors = false;
		for (ConstraintViolation<GamePlaySessionRequestTO> constraint : validator.validate(input)) {
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
			return new GamePlaySessionTO(gamePlayService.createGameSession(input.getGameId()));
		} catch (Exception e) {
			throw new BaseControllerException(e);
		}
	}
	
	   
	@RequestMapping(value={"/rest/gameplay/{id}/invitation"},  method = RequestMethod.POST )
	public @ResponseBody GamePlayInvitationTO sendGamePlayInvitation(@PathVariable("id") Long gameSessionId, @RequestBody GamePlayInvitationRequestTO input) {
		StringBuilder err = new StringBuilder();
		if (input == null) {
			throw new BaseControllerException(400, null, "Received GamePlayInvitation is null");
		}
		
		boolean hasErrors = false;
		for (ConstraintViolation<GamePlayInvitationRequestTO> constraint : validator.validate(input)) {
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
			
			return new GamePlayInvitationTO(gamePlayService.sendGamePlayInvitation(gameSessionId, input.getRecipientId()));
		} catch (Exception e) {
			throw new BaseControllerException(e);
		}
	}
	
	@RequestMapping(value={"/rest/gameplay/invitation/{invitationId}/update"},  method = RequestMethod.POST )
	public @ResponseBody GamePlayInvitationTO processGamePlayInvitation(@PathVariable("invitationId") Long invitationId, @RequestBody UpdateInvitationStatusRequestTO input) {
		StringBuilder err = new StringBuilder();
		if (input == null) {
			throw new BaseControllerException(400, null, "Received GamePlayInvitation is null");
		}
		
		boolean hasErrors = false;
		for (ConstraintViolation<UpdateInvitationStatusRequestTO> constraint : validator.validate(input)) {
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
			return new GamePlayInvitationTO(gamePlayService.updateGamePlayInvitation(invitationId,input.getStatus()));
		} catch (Exception e) {
			throw new BaseControllerException(e);
		}
	}
	
	@RequestMapping(value={"/rest/gameplay/events"},  method = RequestMethod.GET )
	public @ResponseBody EventListTO getEvents() {
		try {
			List<Event> events =  eventService.getEvents();
			
			return new EventListTO(events);
		} catch (Exception e) {
			throw new BaseControllerException(e);
		}
	}
	

	@RequestMapping(value={"/rest/gameplay/{id}/events"},  method = RequestMethod.GET )
	public @ResponseBody EventListTO getGameSessionEvents(@PathVariable("id") Long gameSessionId) {
		try {
			List<Event> events =  eventService.getGameSessionEvents(gameSessionId, EventSelectionCriteria.ALL);			
			return new EventListTO(events);
		} catch (Exception e) {
			throw new BaseControllerException(e);
		}
	}

    @RequestMapping(value = {"/rest/game/{id}/invitations"}, method = RequestMethod.GET)
    public @ResponseBody GamePlayInvitationListTO getInvitations(@PathVariable("id") Long gameId, @RequestParam(value="max", required=true) int max) {
        return new GamePlayInvitationListTO(gamePlayService.getInvitations(gameId, max));
    }
    
	@RequestMapping(value={"/rest/gameplay/invitation/{id}"},  method = RequestMethod.GET )
	public @ResponseBody GamePlayInvitationTO getGPInvitation(@PathVariable("id") Long invitationId) {
		
		
		try {
			return new GamePlayInvitationTO(gamePlayService.findGamePlayInvitation(invitationId));
		} catch (Exception e) {
			throw new BaseControllerException(e);
		}
	}
	

	@RequestMapping(value={"/rest/gameplay/{id}"},  method = RequestMethod.GET )
	public @ResponseBody GamePlaySessionTO getGameSession(@PathVariable("id") Long sessionId) {
		try {
			return new GamePlaySessionTO(gamePlayService.find(sessionId));
		} catch (Exception e) {
			throw new BaseControllerException(e);
		}
	}
	
	@RequestMapping(value={"/rest/gameplay/{id}/state"},  method = RequestMethod.GET )
	public @ResponseBody GamePlayStateTO getGameState(@PathVariable("id") Long sessionId) {
		try {
			return new GamePlayStateTO(gamePlayService.find(sessionId));
		} catch (Exception e) {
			throw new BaseControllerException(e);
		}
	}
	
	@RequestMapping(value={"/rest/gameplay/{id}/start"},  method = RequestMethod.POST )
	public @ResponseBody GameStepId startGamePlay(@RequestBody GamePlayRequestTO input) {
		StringBuilder err = new StringBuilder();
		if (input == null) {
			throw new BaseControllerException(400, null, "Received GamePlayRequestTO is null");
		}
		
		boolean hasErrors = false;
		for (ConstraintViolation<GamePlayRequestTO> constraint : validator.validate(input)) {
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
			return gamePlayService.startGamePlay(input.getGameSessionId(), input.getGameState(), input.getTurnId());
		} catch (Exception e) {
			throw new BaseControllerException(e);
		}
	}
	
	@RequestMapping(value={"/rest/gameplay/{id}/update"},  method = RequestMethod.POST )
	public @ResponseBody GameStepId updateGamePlay(@RequestBody GamePlayRequestTO input) {
		StringBuilder err = new StringBuilder();
		if (input == null) {
			throw new BaseControllerException(400, null, "Received GamePlayRequestTO is null");
		}
		
		boolean hasErrors = false;
		for (ConstraintViolation<GamePlayRequestTO> constraint : validator.validate(input)) {
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
			return gamePlayService.updateGamePlay(input.getGameSessionId(), input.getGameState(), input.getTurnId());
		} catch (Exception e) {
			throw new BaseControllerException(e);
		}
	}
	
	@RequestMapping(value={"/rest/gameplay/{id}/end"},  method = RequestMethod.POST )
	public @ResponseBody GameStepId endGamePlay(@RequestBody GamePlayRequestTO input) {
		StringBuilder err = new StringBuilder();
		if (input == null) {
			throw new BaseControllerException(400, null, "Received GamePlayRequestTO is null");
		}
		
		boolean hasErrors = false;
		for (ConstraintViolation<GamePlayRequestTO> constraint : validator.validate(input)) {
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
			return gamePlayService.endGamePlay(input.getGameSessionId(), input.getGameState());
		} catch (Exception e) {
			throw new BaseControllerException(e);
		}
	}
	
	@RequestMapping(value={"/rest/gameplay/{id}/message"},  method = RequestMethod.POST )
	public @ResponseBody GameSessionMessageTO postMessage(@PathVariable("id") Long gameSessionId, @RequestBody GameSessionMessageRequestTO input) {
		StringBuilder err = new StringBuilder();
		if (input == null) {
			throw new BaseControllerException(400, null, "Received GamePlayRequestTO is null");
		}
		
		boolean hasErrors = false;
		for (ConstraintViolation<GameSessionMessageRequestTO> constraint : validator.validate(input)) {
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
			GameSessionMessage msg = gamePlayService.postMessage(gameSessionId, input.getMessage());
			return new GameSessionMessageTO(msg);
		} catch (Exception e) {
			throw new BaseControllerException(e);
		}
	}
	
	@RequestMapping(value={"/rest/gameplay/{id}/message"},  method = RequestMethod.GET )
    public @ResponseBody GameSessionMessageListTO getMessages(@PathVariable("id") Long gameSessionId, @RequestParam(value="lastMessageId", required=false) Long lastMessageId) {        
            return new GameSessionMessageListTO(gamePlayService.getMessages(gameSessionId, lastMessageId));
    }
	
	@RequestMapping(value="/rest/gameplay", method = RequestMethod.GET)
	public @ResponseBody GamePlaySessionListTO getGamePlaySessions() {
		return new GamePlaySessionListTO(gamePlayService.findAllSessions());
	}
	
	@RequestMapping(value="/rest/game/{id}/gameplay", method = RequestMethod.GET)
    public @ResponseBody GamePlaySessionListTO getGamePlaySessions(@PathVariable("id") Long gameId) {
        return new GamePlaySessionListTO(gamePlayService.findAllGameSessions(gameId));
    }
	
	@RequestMapping(value="/rest/game/{id}/summary", method = RequestMethod.GET)
    public @ResponseBody GamePlaySummaryTO getGamePlaySummary(@PathVariable("id") Long gameId) {
        return new GamePlaySummaryTO(gamePlayService.getGamePlaySummary(gameId));
    }

    @RequestMapping(value="/rest/game/{id}/summary", method = RequestMethod.POST)
    public @ResponseBody GamePlaySummaryTO saveGamePlaySummary(@PathVariable("id") Long gameId, @RequestBody GamePlaySummaryRequestTO request) {
        return new GamePlaySummaryTO(gamePlayService.saveGamePlaySummary(gameId, request.getDetail()));
    }
}
