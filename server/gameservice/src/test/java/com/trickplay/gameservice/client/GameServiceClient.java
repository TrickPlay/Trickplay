package com.trickplay.gameservice.client;

import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.context.ApplicationContext;
import org.springframework.context.support.FileSystemXmlApplicationContext;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.codec.Base64;
import org.springframework.web.client.RestTemplate;

import com.trickplay.gameservice.domain.GameStepId;
import com.trickplay.gameservice.domain.InvitationStatus;
import com.trickplay.gameservice.transferObj.BooleanResponse;
import com.trickplay.gameservice.transferObj.BuddyInvitationListTO;
import com.trickplay.gameservice.transferObj.BuddyInvitationRequestTO;
import com.trickplay.gameservice.transferObj.BuddyInvitationTO;
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
import com.trickplay.gameservice.transferObj.GameRequestTO;
import com.trickplay.gameservice.transferObj.GameSessionMessageListTO;
import com.trickplay.gameservice.transferObj.GameSessionMessageRequestTO;
import com.trickplay.gameservice.transferObj.GameSessionMessageTO;
import com.trickplay.gameservice.transferObj.GameTO;
import com.trickplay.gameservice.transferObj.ScoreFilterTO.ScoreType;
import com.trickplay.gameservice.transferObj.ScoreListTO;
import com.trickplay.gameservice.transferObj.ScoreRequestTO;
import com.trickplay.gameservice.transferObj.ScoreTO;
import com.trickplay.gameservice.transferObj.UpdateInvitationStatusRequestTO;
import com.trickplay.gameservice.transferObj.UserBuddiesTO;
import com.trickplay.gameservice.transferObj.UserRequestTO;
import com.trickplay.gameservice.transferObj.UserTO;
import com.trickplay.gameservice.transferObj.VendorRequestTO;
import com.trickplay.gameservice.transferObj.VendorTO;

public class GameServiceClient {

    /* local instance thru proxy. instance at localhost:9080 */
	private static final String GS_ENDPOINT = "http://localhost:9081/gameservice/rest"; 
	
	/* game service on amazon aws thru proxy. instance at tp-gameservice-dev.elasticbeanstalk.com:80 */
	//private static final String GS_ENDPOINT = "http://localhost:8091/rest"; 
	
	public static void main(String[] args) {
			
			RestTemplate restTemplate = getTemplate();
			
			// reset database
			try { 
			
			    resetDB(restTemplate, "admin", "admin");
			} catch (Exception ex) {
			    System.out.println("Got exception will reseting GameService database. Ignoring exception and continuing. exception message: " + ex.getMessage());
			    ex.printStackTrace();
			}
			
			checkUserExists(restTemplate, "u1");
			checkUserExists(restTemplate, "u2");
			checkUserExists(restTemplate, "u3");
			/* create users [u1, u2, u3]*/
			Map<String, UserTO> umap = new HashMap<String, UserTO>();
			umap.put("u1", postUser(restTemplate, new UserRequestTO("u1", "u1@u1.com", "u1")));
			umap.put("u2", postUser(restTemplate, new UserRequestTO("u2", "u2@u2.com", "u2")));
			umap.put("u3", postUser(restTemplate, new UserRequestTO("u3", "u3@u3.com", "u3")));

			/* send a buddy list invitation */
			BuddyInvitationRequestTO bliRequestTO = new BuddyInvitationRequestTO("u2");
			postBuddyListInvitation(restTemplate, umap.get("u1").getId(), bliRequestTO, "u1", "u1");
			Long userId = umap.get("u2").getId();
			BuddyInvitationListTO bilList = getBuddyListReceivedInvitations(restTemplate, userId, "u2", "u2");
			for(BuddyInvitationTO invitation: bilList.getInvitations()) {
				if (invitation.getStatus()==InvitationStatus.PENDING) {
					updateBuddyListInvitationStatus(restTemplate, userId, invitation.getId(), InvitationStatus.ACCEPTED, "u2", "u2");
				}
			}
			
			/* get users buddy list */
			UserBuddiesTO buddies = getBuddyList(restTemplate, umap.get("u1").getId(), "u1", "u1");
			System.out.println("buddies for user:u1 are follows:");
			for(UserTO buddy:buddies.getBuddies()){
				System.out.println("buddy:"+buddy.getUsername());
			}
			
			checkVendorExists(restTemplate, "v1", "u1", "u1");
			/* create vendors [(v1,u1), (v2,u1), (v3,u3)]*/
			Map<String, VendorTO> vmap = new HashMap<String, VendorTO>();
			vmap.put("v1-u1", postVendor(restTemplate, new VendorRequestTO("v1-u1"), "u1", "u1"));			
			vmap.put("v2-u1", postVendor(restTemplate, new VendorRequestTO("v2-u1"), "u1", "u1"));			
			vmap.put("v3-u3", postVendor(restTemplate,new VendorRequestTO("v3-u3"), "u3", "u3"));

			/* create games [(g10-g12,v1,u1)(g20-g22,v2,u1)(g30-g32,v3,u3)] */
			Map<String, GameTO> gmap = new HashMap<String, GameTO>();
			for(int i=0; i<3; i++) {
			    String name = "g1"+i+"-v1-u1";
			    checkGameExists(restTemplate, name, "u1", "u1");
				gmap.put(name, postGame(restTemplate, 
					new GameRequestTO( 
							name, 
							name+".us.world",
							vmap.get("v1-u1").getId(),
							1,
							3,
							true,
							true,
							true,
							true), "u1", "u1"));
			}
			

			for(int i=0; i<3; i++) {
				gmap.put("g2"+i+"-v2-u1", postGame(restTemplate, 
					new GameRequestTO(
							"g2"+i+"-v2-u1", 
							"g2"+i+"-v2-u1.us.world",
							vmap.get("v2-u1").getId(),
							1,
							3,
							true,
							true,
							true,
							true), "u1", "u1"));
			}
			

			for(int i=0; i<3; i++) {
				gmap.put("g3"+i+"-v3-u3", postGame(restTemplate, 
					new GameRequestTO( 
							"g3"+i+"-v3-u3", 
							"g3"+i+"-v3-u3.us.world",
							vmap.get("v3-u3").getId(),
							1,
							3,
							true,
							true,
							true,
							true), "u3", "u3"));
			}
			
			/*
			 * create a game session
			 */
			Long gameId = gmap.get("g10-v1-u1").getId();
			GamePlaySessionRequestTO gpTO = new GamePlaySessionRequestTO(gameId);
			GamePlaySessionTO gsTO = postCreateGameSession(restTemplate, gpTO, "u1", "u1");
			
			GamePlaySessionListTO sessionListTO = getGameSessionList(restTemplate, "u1", "u1");
			/*
			 * send a wild card game invitation
			 */
			GamePlayInvitationRequestTO gpiTO = new GamePlayInvitationRequestTO(/*umap.get("u2").getId()*/);
			
			GamePlayInvitationTO gpInvitationTO = postGamePlayInvitation(restTemplate, gsTO, gpiTO, "u1", "u1");
			
			getGameServiceEvents(restTemplate, "u1", "u1");
			
			EventListTO elist = getGameServiceEvents(restTemplate, "u2", "u2");
		//	ProcessGamePlayInvitationRequestTO gpi = new ProcessGamePlayInvitationRequestTO(InvitationStatus.ACCEPTED);
			GamePlayInvitationListTO invitationList = getGamePlayInvitations(restTemplate, gameId, 10, "u2", "u2");
			gpInvitationTO = invitationList.getInvitations().get(0);
			updateGamePlayInvitation(restTemplate, gpInvitationTO.getId(), InvitationStatus.ACCEPTED, "u2", "u2");
			
			elist = getGameServiceEvents(restTemplate, "u2", "u2");
		
			/* pass state to json */
			GamePlayRequestTO gsRequestTO = new GamePlayRequestTO(gsTO.getId(), encodeState("1"), umap.get("u2").getId());
			
			startGamePlay(restTemplate, gsRequestTO, "u1", "u1");
			long u1points = 0;
			long u2points = 0;
			String winner = null;
			
			boolean gameOver = false;
			while(!gameOver) {
				/******* u1 playing *********/
				GamePlayStateTO gpsTO = getGamePlayState(restTemplate, gsTO.getId(), "u1", "u1");
				
				if (gpsTO.isGameEnded()) {
					gameOver = true;
					break;
				}
				if (gpsTO.getTurnId().equals(umap.get("u1").getId())) {
					/******** u1's turn ********/
				    postGameSessionMessage(restTemplate, gsTO.getId(), "my (u1's) turn", "u1", "u1");
					String state = decodeState(gpsTO.getState());
					int counter = Integer.parseInt(state);
					if (counter<10) {
						counter++;
						System.out.println("u1 setting counter to "+counter);
						if (counter==10) {
							gameOver = true;
							gsRequestTO = new GamePlayRequestTO(gsTO.getId(), encodeState(Integer.toString(counter)), null);
							endGamePlay(restTemplate, gsRequestTO, "u1", "u1");
							u1points += 100;
							winner = "u1";
							postGameSessionMessage(restTemplate, gsTO.getId(), "I (u1) am the winner. You (u2) suck", "u1", "u1");
							break;
						} else {
							gsRequestTO = new GamePlayRequestTO(gsTO.getId(), encodeState(Integer.toString(counter)), umap.get("u2").getId());
							updateGamePlay(restTemplate, gsRequestTO, "u1", "u1");
							u1points += 10;
                            postGameSessionMessage(restTemplate, gsTO.getId(), "I ( u1 ) incremented the counter. Your ( u2's ) turn", "u1", "u1");
						}
					}
					else {
						throw new RuntimeException("Game Logic error");
					}
					
				}
				
				
				gpsTO = getGamePlayState(restTemplate, gsTO.getId(), "u2", "u2");
				
				if (gpsTO.isGameEnded()) {
					gameOver = true;
					break;
				}
				
				if (gpsTO.getTurnId().equals(umap.get("u2").getId())) {
					/*** u2's turn ********/
                    postGameSessionMessage(restTemplate, gsTO.getId(), "my (u2's) turn", "u2", "u2");
					String state = decodeState(gpsTO.getState());
					int counter = Integer.parseInt(state);
					if (counter<10) {
						counter++;
						
						System.out.println("u2 setting counter to "+counter);
						if (counter==10) {
							gameOver = true;
							gsRequestTO = new GamePlayRequestTO(gsTO.getId(), encodeState(Integer.toString(counter)), null);
							endGamePlay(restTemplate, gsRequestTO, "u2", "u2");
							u2points = 100;
							winner = "u2";
                            postGameSessionMessage(restTemplate, gsTO.getId(), "I (u2) am the winner. You (u1) suck", "u2", "u2");
						} else {
							gsRequestTO = new GamePlayRequestTO(gsTO.getId(), encodeState(Integer.toString(counter)), umap.get("u1").getId());
							updateGamePlay(restTemplate, gsRequestTO, "u2", "u2");
							u2points += 10;
                            postGameSessionMessage(restTemplate, gsTO.getId(), "I ( u2 ) incremented the counter. Your ( u1's ) turn", "u2", "u2");
						}
					}
					else {
						throw new RuntimeException("Game Logic error");
					}
					
				}
			}
			/* record scores */
			ScoreRequestTO scoreTO = new ScoreRequestTO(u1points);
			postScore(restTemplate, gameId, scoreTO, "u1", "u1");
			
			scoreTO.setPoints(u2points);
			postScore(restTemplate, gameId, scoreTO, "u2", "u2");
			
			/* get my scores */
			ScoreListTO slist = getScore(restTemplate, gameId, ScoreType.USER_TOP_SCORES, "u1", "u1");
			System.out.println("USER_TOP_SCORES for u1 follows:");
			for(ScoreTO score: slist.getScoreList()) {
				System.out.println("user:"+score.getUserName()+", game="+score.getGameName()+", points="+score.getPoints());
			}
			
			slist = getScore(restTemplate, gameId, ScoreType.BUDDY_TOP_SCORES, "u1", "u1");
			System.out.println("BUDDY_TOP_SCORES for u1 follows:");
			for(ScoreTO score: slist.getScoreList()) {
				System.out.println("user:"+score.getUserName()+", game="+score.getGameName()+", points="+score.getPoints());
			}
			
			slist = getScore(restTemplate, gameId, ScoreType.TOP_SCORES, "u1", "u1");
			System.out.println("TOP_SCORES for u1 follows:");
			for(ScoreTO score: slist.getScoreList()) {
				System.out.println("user:"+score.getUserName()+", game="+score.getGameName()+", points="+score.getPoints());
			}
			
			Long u1Id = umap.get("u1").getId();
			GamePlaySummaryTO summaryTO = getGamePlaySummary(restTemplate, gameId, "u1", "u1");
			
			GamePlaySummaryRequestTO initSummaryTO = new GamePlaySummaryRequestTO("{\"record\":\"0:0\"}");
            postGamePlaySummary(restTemplate, gameId, initSummaryTO, "u1", "u1");
            postGamePlaySummary(restTemplate, gameId, initSummaryTO, "u2", "u2");
            
			GamePlaySummaryRequestTO winnerSummaryTO = new GamePlaySummaryRequestTO("{\"record\":\"1:0\"}");
			GamePlaySummaryRequestTO loserSummaryTO = new GamePlaySummaryRequestTO("{\"record\":\"0:1\"}");
			if ("u1".equals(winner)) {
			    postGamePlaySummary(restTemplate, gameId, winnerSummaryTO, "u1", "u1");
			    postGamePlaySummary(restTemplate, gameId, loserSummaryTO, "u2", "u2");
			} else {
			    postGamePlaySummary(restTemplate, gameId, winnerSummaryTO, "u2", "u2");
                postGamePlaySummary(restTemplate, gameId, loserSummaryTO, "u1", "u1");
			}
			
			GamePlaySummaryTO u1Summary = getGamePlaySummary(restTemplate, gameId, "u1", "u1");
			GamePlaySummaryTO u2Summary = getGamePlaySummary(restTemplate, gameId, "u2", "u2");
			
			getGameSessionMessages(restTemplate, gsTO.getId(), "u1", "u1");
			
			
		}
		
		public static BooleanResponse resetDB(RestTemplate rest, String username, String password) {
            HttpEntity<String> entity = prepareJsonGet(username, password);
            ResponseEntity<BooleanResponse> response = rest.exchange(
                    GS_ENDPOINT+"/user/resetDB", HttpMethod.GET, 
                    entity, BooleanResponse.class);
            
            BooleanResponse output = response.getBody();
            System.out.println("user/resetDB returned " + output.isValue());
            return output;
        }
		
		public static GamePlaySummaryTO getGamePlaySummary(RestTemplate rest, Long gameId, String username, String password) {
            HttpEntity<String> entity = prepareJsonGet(username, password);
            ResponseEntity<GamePlaySummaryTO> response = rest.exchange(
                    GS_ENDPOINT+"/game/{id}/summary", HttpMethod.GET, 
                    entity, GamePlaySummaryTO.class, gameId);
            
            GamePlaySummaryTO output = response.getBody();
            System.out.println("GamePlaySummary for gameId: " + gameId + ", username:" + username + " is: " + output.getDetail());
            return output;
        }
		
		public static GamePlaySummaryTO postGamePlaySummary(RestTemplate rest, Long gameId, GamePlaySummaryRequestTO summaryRequestTO, String username, String password) {
            HttpEntity<GamePlaySummaryRequestTO> entity = prepareJsonRequest(summaryRequestTO, true, username, password);
            ResponseEntity<GamePlaySummaryTO> response = rest.postForEntity(
                    GS_ENDPOINT+"/game/{id}/summary", 
                    entity, GamePlaySummaryTO.class, gameId);
            
            GamePlaySummaryTO output = response.getBody();
            System.out.println("GamePlaySummary for gameId: " + gameId + ", username:" + username + " is: " + output.getDetail());
            return output;
        }
		
        public static BooleanResponse checkUserExists(RestTemplate rest, String username) {
            HttpEntity<String> entity = prepareJsonGet();
            ResponseEntity<BooleanResponse> response = rest.exchange(
                    GS_ENDPOINT+"/user/exists?username={username}", HttpMethod.GET, 
                    entity, BooleanResponse.class, username);
            
            BooleanResponse output = response.getBody();
            System.out.println("user: " + username + ", exists:" + output.isValue());
            return output;
        }
        
		public static UserTO postUser(RestTemplate rest, UserRequestTO input) {
			HttpEntity<UserRequestTO> entity = prepareJsonRequest(input);//new HttpEntity<UserTO>(input);
			ResponseEntity<UserTO> response = rest.postForEntity(
					GS_ENDPOINT+"/user", 
					entity, UserTO.class);
			
			UserTO output = response.getBody();
			System.out.println("New user: " + output.getId() + ", " + output.getUsername());
			return output;
		}
		
		public static BuddyInvitationTO postBuddyListInvitation(RestTemplate rest, Long userId, BuddyInvitationRequestTO input, String username, String password) {
			HttpEntity<BuddyInvitationRequestTO> entity = prepareJsonRequest(input, true, username, password);
			//	entity.
				ResponseEntity<BuddyInvitationTO> response = rest.postForEntity(
						GS_ENDPOINT+"/user/invitation", 
						entity, BuddyInvitationTO.class);
				
				BuddyInvitationTO output = response.getBody();
				System.out.println("Sent buddy list invitation. id: " + output.getId() + ", to:" + output.getRecipient());
				return output;
		}
		
		public static BuddyInvitationListTO getBuddyListReceivedInvitations(RestTemplate rest, Long userId, String username, String password) {
			HttpEntity<String> entity = prepareJsonGet(username, password);
			ResponseEntity<BuddyInvitationListTO> response = rest.exchange(
					GS_ENDPOINT+"/user/invitation?type=RECEIVED", HttpMethod.GET, entity, BuddyInvitationListTO.class);
			
			BuddyInvitationListTO output = response.getBody();
			System.out.println("Number of Buddy List invitations received: " + output.getInvitations().size());
			return output;
			
		}
		
		public static BuddyInvitationTO updateBuddyListInvitationStatus(RestTemplate rest, Long userId, Long invitationId, InvitationStatus status, String username, String password) {
			UpdateInvitationStatusRequestTO input = new UpdateInvitationStatusRequestTO(status);
			HttpEntity<UpdateInvitationStatusRequestTO> entity = prepareJsonRequest(input, true, username, password);
			//	entity.
				ResponseEntity<BuddyInvitationTO> response = rest.exchange(
						GS_ENDPOINT+"/user/invitation/"+invitationId, HttpMethod.PUT,
						entity, BuddyInvitationTO.class);
				
				BuddyInvitationTO output = response.getBody();
				System.out.println("updated buddy invitation. id: " + output.getId() + ", status:" + output.getStatus().name());
				return output;
		}
		
		//
		public static UserBuddiesTO getBuddyList(RestTemplate rest, Long userId, String username, String password) {
			HttpEntity<String> entity = prepareJsonGet(username, password);
			ResponseEntity<UserBuddiesTO> response = rest.exchange(
					GS_ENDPOINT+"/user/buddy-list", HttpMethod.GET, entity, UserBuddiesTO.class);
			
			UserBuddiesTO output = response.getBody();
			System.out.println("Got Buddy List for user:" + output.getUser().getUsername()+". size:"+output.getBuddies().size());
			return output;
			
		}
		
        public static VendorTO checkVendorExists(RestTemplate rest, String name, String username, String password) {
            HttpEntity<String> entity = prepareJsonGet(username, password);
            ResponseEntity<VendorTO> response = rest.exchange(
                    GS_ENDPOINT+"/vendor/exists?name={name}", HttpMethod.GET,
                    entity, VendorTO.class, name);
            
            VendorTO output = response.getBody();
            System.out.println("vendor: " + name + ", exists:" + output.getId()==null);
            return output;
        }
        
		public static VendorTO postVendor(RestTemplate rest, VendorRequestTO input, String username, String password) {
			HttpEntity<VendorRequestTO> entity = prepareJsonRequest(input, true, username, password);
		//	entity.
			ResponseEntity<VendorTO> response = rest.postForEntity(
					GS_ENDPOINT+"/vendor", 
					entity, VendorTO.class);
			
			VendorTO output = response.getBody();
			System.out.println("New vendor: " + output.getId() + ", " + output.getName());
			return output;
			
		}
		
        public static GameTO checkGameExists(RestTemplate rest, String name, String username, String password) {
            HttpEntity<String> entity = prepareJsonGet(username, password);
            ResponseEntity<GameTO> response = rest.exchange(
                    GS_ENDPOINT+"/game/exists?name={name}", HttpMethod.GET,
                    entity, GameTO.class, name);
            
            GameTO output = response.getBody();
            System.out.println("game: " + name + ", exists:" + output.getId()==null);
            return output;
        }
        
		public static GameTO postGame(RestTemplate rest, GameRequestTO input, String username, String password) {
			HttpEntity<GameRequestTO> entity = prepareJsonRequest(input, true, username, password);
		//	entity.
			ResponseEntity<GameTO> response = rest.postForEntity(
					GS_ENDPOINT+"/game", 
					entity, GameTO.class);
			
			GameTO output = response.getBody();
			System.out.println("New game: " + output.getId() + ", " + output.getName());
			return output;
			
		}
		
        public static GamePlaySessionListTO getGameSessionList(RestTemplate rest, String username, String password) {
            HttpEntity<String> entity = prepareJsonGet(username, password);
            ResponseEntity<GamePlaySessionListTO> response = rest.exchange(
                    GS_ENDPOINT+"/gameplay", HttpMethod.GET, entity, GamePlaySessionListTO.class);
            
            GamePlaySessionListTO output = response.getBody();
            System.out.println("Number of Game Play sessions received: " + output.getGameSessionList().size());
            return output;
        }

        public static GamePlaySessionTO postCreateGameSession(RestTemplate rest, GamePlaySessionRequestTO input, String username, String password) {
			HttpEntity<GamePlaySessionRequestTO> entity = prepareJsonRequest(input, true, username, password);
		//	entity.
			ResponseEntity<GamePlaySessionTO> response = rest.postForEntity(
					GS_ENDPOINT+"/gameplay", 
					entity, GamePlaySessionTO.class);
			
			GamePlaySessionTO output = response.getBody();
			System.out.println("New game play session: " + output.getId() + ", " + output.getGameName());
			return output;
		}

		public static GamePlayInvitationTO postGamePlayInvitation(RestTemplate rest, GamePlaySessionTO gsTO, GamePlayInvitationRequestTO input, String username, String password) {
			HttpEntity<GamePlayInvitationRequestTO> entity = prepareJsonRequest(input, true, username, password);
		//	entity.
			ResponseEntity<GamePlayInvitationTO> response = rest.postForEntity(
					GS_ENDPOINT+"/gameplay/"+gsTO.getId()+"/invitation", 
					entity, GamePlayInvitationTO.class);
			
			GamePlayInvitationTO output = response.getBody();
			System.out.println("New game play invitation: " + output.getId() + ", " + output.getGameSessionId());
			return output;			
		}
		
		public static GamePlayInvitationTO updateGamePlayInvitation(RestTemplate rest, Long invitationId, InvitationStatus status, String username, String password) {
			UpdateInvitationStatusRequestTO input = new UpdateInvitationStatusRequestTO(status);
			HttpEntity<UpdateInvitationStatusRequestTO> entity = prepareJsonRequest(input, true, username, password);
		//	entity.
			ResponseEntity<GamePlayInvitationTO> response = rest.postForEntity(
					GS_ENDPOINT+"/gameplay/invitation/"+invitationId+"/update", 
					entity, GamePlayInvitationTO.class);
			
			GamePlayInvitationTO output = response.getBody();
			System.out.println("Updated game play invitation: " + output.getId() + ", " + output.getGameSessionId() + ", " + output.getStatus());
			return output;
			
		}
		
	      public static GamePlayInvitationListTO getGamePlayInvitations(RestTemplate rest, Long gameId, int max, String username, String password) {
	            HttpEntity<String> entity = prepareJsonGet(username, password);
	            ResponseEntity<GamePlayInvitationListTO> response = rest.exchange(
	                    GS_ENDPOINT+"/game/"+gameId+"/invitations?max="+max, HttpMethod.GET, entity, GamePlayInvitationListTO.class);
	            
	            GamePlayInvitationListTO output = response.getBody();
	            System.out.println("Number of Game Play invitations received: " + output.getInvitations().size());
	            return output;
	            
	        }

		public static GameStepId startGamePlay(RestTemplate rest, GamePlayRequestTO gamePlayTO, String username, String password) {
			HttpEntity<GamePlayRequestTO> entity = prepareJsonRequest(gamePlayTO, true, username, password);
		//	entity.
			ResponseEntity<GameStepId> response = rest.postForEntity(
					GS_ENDPOINT+"/gameplay/"+gamePlayTO.getGameSessionId()+"/start", 
					entity, GameStepId.class);
			
			GameStepId output = response.getBody();
			System.out.println("Game play started. stepId: " + output.getKey() );
			return output;
			
		}
		
		public static GameStepId updateGamePlay(RestTemplate rest, GamePlayRequestTO gamePlayTO, String username, String password) {
			HttpEntity<GamePlayRequestTO> entity = prepareJsonRequest(gamePlayTO, true, username, password);
		//	entity.
			ResponseEntity<GameStepId> response = rest.postForEntity(
					GS_ENDPOINT+"/gameplay/"+gamePlayTO.getGameSessionId()+"/update", 
					entity, GameStepId.class);
			
			GameStepId output = response.getBody();
			System.out.println("Game play updated. stepId: " + output.getKey() );
			return output;
			
		}
		
		public static GameStepId endGamePlay(RestTemplate rest, GamePlayRequestTO gamePlayTO, String username, String password) {
			HttpEntity<GamePlayRequestTO> entity = prepareJsonRequest(gamePlayTO, true, username, password);
		//	entity.
			ResponseEntity<GameStepId> response = rest.postForEntity(
					GS_ENDPOINT+"/gameplay/"+gamePlayTO.getGameSessionId()+"/end", 
					entity, GameStepId.class);
			
			GameStepId output = response.getBody();
			System.out.println("Game play ended. stepId: " + output.getKey() );
			return output;
			
		}

        public static GameSessionMessageTO postGameSessionMessage(RestTemplate rest, Long sessionId, String message, String username, String password) {
            HttpEntity<GameSessionMessageRequestTO> entity = prepareJsonRequest(new GameSessionMessageRequestTO(message), true, username, password);
        //  entity.
            ResponseEntity<GameSessionMessageTO> response = rest.postForEntity(
                    GS_ENDPOINT+"/gameplay/"+sessionId+"/message", 
                    entity, GameSessionMessageTO.class);
            
            GameSessionMessageTO output = response.getBody();
            System.out.println("Posted a message. game session id: " + output.getGameSessionId() + ", message: '" + output.getMessage() + "'" );
            return output;
            
        }
        
        public static GameSessionMessageListTO getGameSessionMessages(
                RestTemplate rest, Long sessionId, String username, String password) {
            
            HttpEntity<String> entity = prepareJsonGet(username, password);
            
            ResponseEntity<GameSessionMessageListTO> response = rest.exchange(
                    GS_ENDPOINT + "/gameplay/" + sessionId + "/message",
                    HttpMethod.GET, entity, GameSessionMessageListTO.class);
    
            GameSessionMessageListTO output = response.getBody();
            
            System.out.println("Got game session messages in game session:"
                    + sessionId);
            
            for (GameSessionMessageTO message : output.getMessages()) {
                System.out.println("message info [ id : " + message.getId()
                        + ", from : " + message.getSenderName() + ", message: '"
                        + message.getMessage() + "']");
            }
            return output;
        }

        public static EventListTO getGameServiceEvents(RestTemplate rest, String username, String password) {
			HttpEntity<String> entity = prepareJsonGet(username, password);
			ResponseEntity<EventListTO> response = rest.exchange(
					GS_ENDPOINT+"/gameplay/events", HttpMethod.GET, entity, EventListTO.class);
			
			EventListTO output = response.getBody();
			System.out.println("Total Events recvd: " + output.getEvents().size());
			return output;
			
		}
		
		public static GamePlayStateTO getGamePlayState(RestTemplate rest, Long sessionId, String username, String password) {
			HttpEntity<String> entity = prepareJsonGet(username, password);
			ResponseEntity<GamePlayStateTO> response = rest.exchange(
					GS_ENDPOINT+"/gameplay/"+sessionId+"/state", HttpMethod.GET, entity, GamePlayStateTO.class);
			
			GamePlayStateTO output = response.getBody();
			System.out.println("Got GamePlayState. id:"+output.getId()+", key:"+output.getKey()+",turn:"+output.getTurnUsername());
			return output;
		}
		
		public static ScoreTO postScore(RestTemplate rest, Long gameId, ScoreRequestTO scoreTO, String username, String password) {
			HttpEntity<ScoreRequestTO> entity = prepareJsonRequest(scoreTO, true, username, password);
			ResponseEntity<ScoreTO> response = rest.postForEntity(
					GS_ENDPOINT+"/game/"+gameId+"/score", entity, ScoreTO.class);
			
			ScoreTO output = response.getBody();
			System.out.println("recorded score. response id:"+output.getId()
					+", username:"+output.getUserName()
					+", gamename:"+output.getGameName()
					+", points:"+output.getPoints());
			return output;
		}
		
		public static ScoreListTO getScore(RestTemplate rest, Long gameId, ScoreType st, String username, String password) {
			HttpEntity<String> entity = prepareJsonGet(username, password);
			ResponseEntity<ScoreListTO> response = rest.exchange(
					GS_ENDPOINT+"/game/"+gameId+"/score?type={type}", HttpMethod.GET, entity, ScoreListTO.class, st.name());
			
			ScoreListTO output = response.getBody();
			System.out.println("Got score list. size:"+output.getScoreList().size());
			return output;
		}
		
		private static RestTemplate getTemplate() {
			ApplicationContext ctx = new FileSystemXmlApplicationContext(
				"classpath:gameservice-client.xml");
			RestTemplate template = (RestTemplate) ctx.getBean("restTemplate");
			return template;
		}

		
		private static <T>  HttpEntity<T> prepareJsonRequest(T object) {
			return prepareJsonRequest(object, false, null, null);
		}
		
		private static <T>  HttpEntity<T> prepareJsonRequest(T object, boolean useBasicAuth, String username, String password) {
			HttpEntity<T> entity = new HttpEntity<T>(object, prepareJsonHeaders(useBasicAuth, username, password));
			return entity;
		}
		
		private static HttpEntity<String> prepareJsonGet() {
            return new HttpEntity<String>(prepareJsonHeaders());
        }
		private static HttpEntity<String> prepareJsonGet(String username, String password) {
            return new HttpEntity<String>(prepareJsonHeaders(true, username, password));
		}
		
		private static HttpHeaders prepareJsonHeaders() {
            return prepareJsonHeaders(false, null, null);
        }
		private static HttpHeaders prepareJsonHeaders(boolean useBasicAuth, String username, String password) {
			HttpHeaders headers = new HttpHeaders();
			headers.setContentType(MediaType.APPLICATION_JSON);
			List<MediaType> acceptList = new ArrayList<MediaType>();
			acceptList.add(MediaType.APPLICATION_JSON);
			headers.setAccept(acceptList);
			
			if (useBasicAuth) {
				String credentials = (new StringBuilder(username)).append(":").append(password).toString();
				String base64Credentials = new String(Base64.encode(credentials.getBytes()), Charset.forName("US-ASCII"));
				headers.set("Authorization", "Basic " + base64Credentials);
			}
			return headers;
		}
		
		private static String encodeState(String state) {
			return new String(Base64.encode(state.getBytes()));
		}
		
		private static String decodeState(String state) {
			return new String(Base64.decode(state.getBytes()));
		}
	}


