package com.trickplay.gameservice.controllers;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.validation.ConstraintViolation;
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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.trickplay.gameservice.domain.Game;
import com.trickplay.gameservice.domain.RecordedScore;
import com.trickplay.gameservice.domain.Vendor;
import com.trickplay.gameservice.service.GameService;
import com.trickplay.gameservice.service.LeaderboardService;
import com.trickplay.gameservice.service.VendorService;
import com.trickplay.gameservice.transferObj.GameRequestTO;
import com.trickplay.gameservice.transferObj.GameTO;
import com.trickplay.gameservice.transferObj.ScoreFilterTO;
import com.trickplay.gameservice.transferObj.ScoreFilterTO.ScoreType;
import com.trickplay.gameservice.transferObj.BooleanResponse;
import com.trickplay.gameservice.transferObj.ScoreListTO;
import com.trickplay.gameservice.transferObj.ScoreRequestTO;
import com.trickplay.gameservice.transferObj.ScoreTO;
import com.trickplay.gameservice.transferObj.VendorTO;

@Controller
public class GameController extends BaseController {
	private static final Logger logger = LoggerFactory
			.getLogger(GameController.class);
	@Autowired
	private VendorService vendorService;
	@Autowired
	private GameService gameService;
	@Autowired
	private LeaderboardService leaderboardService;

	@Autowired
	Validator validator;

	private List<GameTO> toGameTO(List<Game> listGames) {
		List<GameTO> listTO = new ArrayList<GameTO>();
		if (listGames != null) {
			for (Game g : listGames) {
				listTO.add(new GameTO(g));
			}
		}
		return listTO;
	}
	
	private List<VendorTO> toVendorTO(List<Vendor> listVendors) {
		List<VendorTO> listTO = new ArrayList<VendorTO>();
		if (listVendors != null) {
			for (Vendor g : listVendors) {
				listTO.add(new VendorTO(g));
			}
		}
		return listTO;
	}

	@RequestMapping(value = "/game/form", method = RequestMethod.GET)
	public String newGame(Model model, HttpServletRequest request) {
		model.addAttribute("game", new GameTO());
		if (request.getUserPrincipal() != null) {

			model.addAttribute("vendors", toVendorTO(vendorService
					.findByContactName(request.getUserPrincipal().getName())));
		} else {
			return "redirect:/login.jsp";
		}

		return "game/create";
	}

	@RequestMapping(value = { "/game", "/rest/game" }, method = RequestMethod.GET)
	public String getAllGames(Model model) {
		model.addAttribute("games", toGameTO(gameService.findAll()));
		return "game/list";
	}

	@RequestMapping(value = {"/rest/game/exists"}, method = RequestMethod.GET)
    public @ResponseBody BooleanResponse checkGameExists(@RequestParam(value="name", required=true) String name) {
        if (null != gameService.findByName(name))
            return BooleanResponse.TRUE;
        else
            return BooleanResponse.FALSE;
    }
	
	@RequestMapping(value = {"/vendor/{vid}/game", "/rest/vendor/{vid}/game"}, method = RequestMethod.GET)
	public String getVendorGames(@PathVariable("vid") Long vid, Model model) {
		Vendor v = vendorService.find(vid);
		model.addAttribute("games", toGameTO(v.getGames()));
		return "game/list";
	}

	@RequestMapping(value = {"/game/{gid}", "/rest/game/{gid}"}, method = RequestMethod.GET)
	public String getGame(@PathVariable("gid") Long gid, Model model) {
		Assert.notNull(gid, "Identifier must be provided.");
		model.addAttribute("game", new GameTO(gameService.find(gid)));
		return "game/show";
	}

	@RequestMapping(value = "/rest/game", method = RequestMethod.POST)
	public @ResponseBody GameTO saveGameGeneric(@RequestBody GameRequestTO gameTO) {
		StringBuilder err = new StringBuilder();
		boolean hasErrors = false;
		for (ConstraintViolation<GameRequestTO> constraint : validator.validate(gameTO)) {
			if (hasErrors)
				err.append(",");
			err.append("[").append(constraint.getMessage()).append("]");
			hasErrors = true;
		}
		if (hasErrors)
			throw new BaseControllerException(400, null, "Invalid parameters. "+err.toString());

		try {
			return new GameTO(gameService.create(gameTO.getVendorId(), gameTO.toGame()));
		} catch(Exception e) {
			throw new BaseControllerException(e);
		}
	}
	
	@RequestMapping(value = "/rest/game", method = RequestMethod.PUT)
	public @ResponseBody GameTO updateGameGeneric(@RequestBody GameTO gameTO) {
		StringBuilder err = new StringBuilder();
		boolean hasErrors = false;
		for (ConstraintViolation<GameTO> constraint : validator.validate(gameTO)) {
			if (hasErrors)
				err.append(",");
			err.append("[").append(constraint.getMessage()).append("]");
			hasErrors = true;
		}
		if (hasErrors)
			throw new BaseControllerException(400, null, "Invalid parameters. "+err.toString());

		try {
			return new GameTO(gameService.update(gameTO.getVendorId(), gameTO.toGame()));
		} catch(Exception e) {
			throw new BaseControllerException(e);
		}
	}
	
	@RequestMapping(value = "/game", method = RequestMethod.POST)
	public String saveGame(@ModelAttribute("game")/* @Valid */GameRequestTO gameTO,
			BindingResult result, Model model, HttpServletRequest request) {
		for (ConstraintViolation<GameRequestTO> constraint : validator.validate(gameTO)) {
			result.rejectValue(constraint.getPropertyPath().toString(), "",
					constraint.getMessage());
			logger.error("\n\n " + constraint.getMessage() + "\n\n");
		}

		if (result.hasErrors()) {
			// model.addAttribute("vendor", v);
			model.addAttribute("errors", result);
			model.addAttribute("game", gameTO);
			return "game/create";
		}
		Game game = gameTO.toGame();
		gameService.create(gameTO.getVendorId(), game);

		return "redirect:/game/" + game.getId();
	}
	
	@RequestMapping(value = "/game", method = RequestMethod.PUT)
	public String updateGame(@ModelAttribute("game")/* @Valid */GameTO gameTO,
			BindingResult result, Model model, HttpServletRequest request) {
		for (ConstraintViolation<GameTO> constraint : validator.validate(gameTO)) {
			result.rejectValue(constraint.getPropertyPath().toString(), "",
					constraint.getMessage());
			logger.error("\n\n " + constraint.getMessage() + "\n\n");
		}

		if (result.hasErrors()) {
			// model.addAttribute("vendor", v);
			model.addAttribute("errors", result);
			model.addAttribute("game", gameTO);
			return "game/create";
		}
		Game game = gameTO.toGame();
		game = gameService.update(gameTO.getVendorId(), game);

		return "redirect:/game/" + game.getId();
	}
	
	@RequestMapping(value = "/rest/game/{id}/score", method = RequestMethod.POST)
	public @ResponseBody ScoreTO recordScore(@PathVariable("id") Long gameId, @RequestBody ScoreRequestTO scoreTO) {
		StringBuilder err = new StringBuilder();
		boolean hasErrors = false;
		for (ConstraintViolation<ScoreRequestTO> constraint : validator.validate(scoreTO)) {
			if (hasErrors)
				err.append(",");
			err.append("[").append(constraint.getMessage()).append("]");
			hasErrors = true;
		}
		if (hasErrors)
			throw new BaseControllerException(400, null, "Invalid parameters. "+err.toString());

		RecordedScore score = leaderboardService.recordScore(gameId, scoreTO.getPoints());
		return new ScoreTO(score);
	}
	
	@RequestMapping(value = "/rest/game/{id}/score", method = RequestMethod.GET)
	public @ResponseBody ScoreListTO getTopScores(@PathVariable("id") Long gameId, @RequestParam(value="type", required=false)String type) {
		ScoreType scoreType = ScoreType.TOP_SCORES;
		if (ScoreType.BUDDY_TOP_SCORES.name().equals(type)) {
			scoreType = ScoreType.BUDDY_TOP_SCORES;
		} else if (ScoreType.TOP_SCORES.name().equals(type)) {
			scoreType = ScoreType.TOP_SCORES;
		} else if (ScoreType.USER_TOP_SCORES.name().equals(type)){
			scoreType = ScoreType.USER_TOP_SCORES;
		}

		switch(scoreType) {
		case TOP_SCORES:
			return new ScoreListTO(leaderboardService.findTopScores(gameId, 100));
		case BUDDY_TOP_SCORES:
			return new ScoreListTO(leaderboardService.findBuddyScores(gameId));
		case USER_TOP_SCORES:
			default:
				return new ScoreListTO(leaderboardService.findScoreByUserId(gameId));
		}
	}
	
}
