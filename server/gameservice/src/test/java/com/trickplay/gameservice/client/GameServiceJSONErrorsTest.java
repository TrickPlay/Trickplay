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
import com.trickplay.gameservice.transferObj.GamePlaySessionRequestTO;
import com.trickplay.gameservice.transferObj.GamePlaySessionTO;
import com.trickplay.gameservice.transferObj.GamePlayStateTO;
import com.trickplay.gameservice.transferObj.GameRequestTO;
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

public class GameServiceJSONErrorsTest {

    private static final String GS_ENDPOINT = "http://localhost:9081/gameservice/rest";

    public static void main(String[] args) {

        RestTemplate restTemplate = getTemplate();

        checkUserExists(restTemplate, "u1");

        /* create users [u1, u2, u3] */
        Map<String, UserTO> umap = new HashMap<String, UserTO>();
        umap.put(
                "u1",
                postUser(restTemplate, new UserRequestTO("u1", "u1@u1.com",
                        "u1")));
        
        //Attempt to create the same user twice. should throw an exception
        postUser(restTemplate, new UserRequestTO("u1", "u1@u1.com",
                "u1"));

    }

    public static BooleanResponse checkUserExists(RestTemplate rest,
            String username) {
        HttpEntity<String> entity = prepareJsonGet();
        ResponseEntity<BooleanResponse> response = rest.exchange(GS_ENDPOINT
                + "/user/exists?username={username}", HttpMethod.GET, entity,
                BooleanResponse.class, username);

        BooleanResponse output = response.getBody();
        System.out
                .println("user: " + username + ", exists:" + output.isValue());
        return output;
    }

    public static UserTO postUser(RestTemplate rest, UserRequestTO input) {
        HttpEntity<UserRequestTO> entity = prepareJsonRequest(input);// new
                                                                     // HttpEntity<UserTO>(input);
        ResponseEntity<UserTO> response = rest.postForEntity(GS_ENDPOINT
                + "/user", entity, UserTO.class);

        UserTO output = response.getBody();
        System.out.println("New user: " + output.getId() + ", "
                + output.getUsername());
        return output;
    }

    public static BuddyInvitationTO postBuddyListInvitation(RestTemplate rest,
            Long userId, BuddyInvitationRequestTO input, String username,
            String password) {
        HttpEntity<BuddyInvitationRequestTO> entity = prepareJsonRequest(input,
                true, username, password);
        // entity.
        ResponseEntity<BuddyInvitationTO> response = rest.postForEntity(
                GS_ENDPOINT + "/user/invitation", entity,
                BuddyInvitationTO.class);

        BuddyInvitationTO output = response.getBody();
        System.out.println("Sent buddy list invitation. id: " + output.getId()
                + ", to:" + output.getRecipient());
        return output;
    }

    public static BuddyInvitationListTO getBuddyListReceivedInvitations(
            RestTemplate rest, Long userId, String username, String password) {
        HttpEntity<String> entity = prepareJsonGet(username, password);
        ResponseEntity<BuddyInvitationListTO> response = rest.exchange(
                GS_ENDPOINT + "/user/invitation?type=RECEIVED", HttpMethod.GET,
                entity, BuddyInvitationListTO.class);

        BuddyInvitationListTO output = response.getBody();
        System.out.println("Number of Buddy List invitations received: "
                + output.getInvitations().size());
        return output;

    }

    public static BuddyInvitationTO updateBuddyListInvitationStatus(
            RestTemplate rest, Long userId, Long invitationId,
            InvitationStatus status, String username, String password) {
        UpdateInvitationStatusRequestTO input = new UpdateInvitationStatusRequestTO(
                status);
        HttpEntity<UpdateInvitationStatusRequestTO> entity = prepareJsonRequest(
                input, true, username, password);
        // entity.
        ResponseEntity<BuddyInvitationTO> response = rest.exchange(GS_ENDPOINT
                + "/user/invitation/" + invitationId, HttpMethod.PUT, entity,
                BuddyInvitationTO.class);

        BuddyInvitationTO output = response.getBody();
        System.out.println("updated buddy invitation. id: " + output.getId()
                + ", status:" + output.getStatus().name());
        return output;
    }

    //
    public static UserBuddiesTO getBuddyList(RestTemplate rest, Long userId,
            String username, String password) {
        HttpEntity<String> entity = prepareJsonGet(username, password);
        ResponseEntity<UserBuddiesTO> response = rest.exchange(GS_ENDPOINT
                + "/user/buddy-list", HttpMethod.GET, entity,
                UserBuddiesTO.class);

        UserBuddiesTO output = response.getBody();
        System.out.println("Got Buddy List for user:"
                + output.getUser().getUsername() + ". size:"
                + output.getBuddies().size());
        return output;

    }

    public static VendorTO checkVendorExists(RestTemplate rest, String name,
            String username, String password) {
        HttpEntity<String> entity = prepareJsonGet(username, password);
        ResponseEntity<VendorTO> response = rest.exchange(GS_ENDPOINT
                + "/vendor/exists?name={name}", HttpMethod.GET, entity,
                VendorTO.class, name);

        VendorTO output = response.getBody();
        System.out
                .println("vendor: " + name + ", exists:" + output.getId() == null);
        return output;
    }

    public static VendorTO postVendor(RestTemplate rest, VendorRequestTO input,
            String username, String password) {
        HttpEntity<VendorRequestTO> entity = prepareJsonRequest(input, true,
                username, password);
        // entity.
        ResponseEntity<VendorTO> response = rest.postForEntity(GS_ENDPOINT
                + "/vendor", entity, VendorTO.class);

        VendorTO output = response.getBody();
        System.out.println("New vendor: " + output.getId() + ", "
                + output.getName());
        return output;

    }

    public static GameTO checkGameExists(RestTemplate rest, String name,
            String username, String password) {
        HttpEntity<String> entity = prepareJsonGet(username, password);
        ResponseEntity<GameTO> response = rest.exchange(GS_ENDPOINT
                + "/game/exists?name={name}", HttpMethod.GET, entity,
                GameTO.class, name);

        GameTO output = response.getBody();
        System.out
                .println("game: " + name + ", exists:" + output.getId() == null);
        return output;
    }

    public static GameTO postGame(RestTemplate rest, GameRequestTO input,
            String username, String password) {
        HttpEntity<GameRequestTO> entity = prepareJsonRequest(input, true,
                username, password);
        // entity.
        ResponseEntity<GameTO> response = rest.postForEntity(GS_ENDPOINT
                + "/game", entity, GameTO.class);

        GameTO output = response.getBody();
        System.out.println("New game: " + output.getId() + ", "
                + output.getName());
        return output;

    }

    public static GamePlaySessionTO postCreateGameSession(RestTemplate rest,
            GamePlaySessionRequestTO input, String username, String password) {
        HttpEntity<GamePlaySessionRequestTO> entity = prepareJsonRequest(input,
                true, username, password);
        // entity.
        ResponseEntity<GamePlaySessionTO> response = rest.postForEntity(
                GS_ENDPOINT + "/gameplay", entity, GamePlaySessionTO.class);

        GamePlaySessionTO output = response.getBody();
        System.out.println("New game play session: " + output.getId() + ", "
                + output.getGameName());
        return output;
    }

    public static GamePlayInvitationTO postGamePlayInvitation(
            RestTemplate rest, GamePlaySessionTO gsTO,
            GamePlayInvitationRequestTO input, String username, String password) {
        HttpEntity<GamePlayInvitationRequestTO> entity = prepareJsonRequest(
                input, true, username, password);
        // entity.
        ResponseEntity<GamePlayInvitationTO> response = rest.postForEntity(
                GS_ENDPOINT + "/gameplay/" + gsTO.getId() + "/invitation",
                entity, GamePlayInvitationTO.class);

        GamePlayInvitationTO output = response.getBody();
        System.out.println("New game play invitation: " + output.getId() + ", "
                + output.getGameSessionId());
        return output;
    }

    public static GamePlayInvitationTO updateGamePlayInvitation(
            RestTemplate rest, Long invitationId, InvitationStatus status,
            String username, String password) {
        UpdateInvitationStatusRequestTO input = new UpdateInvitationStatusRequestTO(
                status);
        HttpEntity<UpdateInvitationStatusRequestTO> entity = prepareJsonRequest(
                input, true, username, password);
        // entity.
        ResponseEntity<GamePlayInvitationTO> response = rest.postForEntity(
                GS_ENDPOINT + "/gameplay/invitation/" + invitationId
                        + "/update", entity, GamePlayInvitationTO.class);

        GamePlayInvitationTO output = response.getBody();
        System.out.println("Updated game play invitation: " + output.getId()
                + ", " + output.getGameSessionId() + ", " + output.getStatus());
        return output;

    }

    public static GamePlayInvitationListTO getGamePlayInvitations(
            RestTemplate rest, Long gameId, int max, String username,
            String password) {
        HttpEntity<String> entity = prepareJsonGet(username, password);
        ResponseEntity<GamePlayInvitationListTO> response = rest.exchange(
                GS_ENDPOINT + "/game/" + gameId + "/invitations?max=" + max,
                HttpMethod.GET, entity, GamePlayInvitationListTO.class);

        GamePlayInvitationListTO output = response.getBody();
        System.out.println("Number of Game Play invitations received: "
                + output.getInvitations().size());
        return output;

    }

    public static GameStepId startGamePlay(RestTemplate rest,
            GamePlayRequestTO gamePlayTO, String username, String password) {
        HttpEntity<GamePlayRequestTO> entity = prepareJsonRequest(gamePlayTO,
                true, username, password);
        // entity.
        ResponseEntity<GameStepId> response = rest.postForEntity(GS_ENDPOINT
                + "/gameplay/" + gamePlayTO.getGameSessionId() + "/start",
                entity, GameStepId.class);

        GameStepId output = response.getBody();
        System.out.println("Game play started. stepId: " + output.getKey());
        return output;

    }

    public static GameStepId updateGamePlay(RestTemplate rest,
            GamePlayRequestTO gamePlayTO, String username, String password) {
        HttpEntity<GamePlayRequestTO> entity = prepareJsonRequest(gamePlayTO,
                true, username, password);
        // entity.
        ResponseEntity<GameStepId> response = rest.postForEntity(GS_ENDPOINT
                + "/gameplay/" + gamePlayTO.getGameSessionId() + "/update",
                entity, GameStepId.class);

        GameStepId output = response.getBody();
        System.out.println("Game play updated. stepId: " + output.getKey());
        return output;

    }

    public static GameStepId endGamePlay(RestTemplate rest,
            GamePlayRequestTO gamePlayTO, String username, String password) {
        HttpEntity<GamePlayRequestTO> entity = prepareJsonRequest(gamePlayTO,
                true, username, password);
        // entity.
        ResponseEntity<GameStepId> response = rest.postForEntity(GS_ENDPOINT
                + "/gameplay/" + gamePlayTO.getGameSessionId() + "/end",
                entity, GameStepId.class);

        GameStepId output = response.getBody();
        System.out.println("Game play ended. stepId: " + output.getKey());
        return output;

    }

    public static EventListTO getGameServiceEvents(RestTemplate rest,
            String username, String password) {
        HttpEntity<String> entity = prepareJsonGet(username, password);
        ResponseEntity<EventListTO> response = rest
                .exchange(GS_ENDPOINT + "/gameplay/events", HttpMethod.GET,
                        entity, EventListTO.class);

        EventListTO output = response.getBody();
        System.out.println("Total Events recvd: " + output.getEvents().size());
        return output;

    }

    public static GamePlayStateTO getGamePlayState(RestTemplate rest,
            Long sessionId, String username, String password) {
        HttpEntity<String> entity = prepareJsonGet(username, password);
        ResponseEntity<GamePlayStateTO> response = rest.exchange(GS_ENDPOINT
                + "/gameplay/" + sessionId + "/state", HttpMethod.GET, entity,
                GamePlayStateTO.class);

        GamePlayStateTO output = response.getBody();
        System.out.println("Got GamePlayState. id:" + output.getId() + ", key:"
                + output.getKey() + ",turn:" + output.getTurnUsername());
        return output;
    }

    public static ScoreTO postScore(RestTemplate rest, Long gameId,
            ScoreRequestTO scoreTO, String username, String password) {
        HttpEntity<ScoreRequestTO> entity = prepareJsonRequest(scoreTO, true,
                username, password);
        ResponseEntity<ScoreTO> response = rest.postForEntity(GS_ENDPOINT
                + "/game/" + gameId + "/score", entity, ScoreTO.class);

        ScoreTO output = response.getBody();
        System.out.println("recorded score. response id:" + output.getId()
                + ", username:" + output.getUserName() + ", gamename:"
                + output.getGameName() + ", points:" + output.getPoints());
        return output;
    }

    public static ScoreListTO getScore(RestTemplate rest, Long gameId,
            ScoreType st, String username, String password) {
        HttpEntity<String> entity = prepareJsonGet(username, password);
        ResponseEntity<ScoreListTO> response = rest.exchange(GS_ENDPOINT
                + "/game/" + gameId + "/score?type={type}", HttpMethod.GET,
                entity, ScoreListTO.class, st.name());

        ScoreListTO output = response.getBody();
        System.out.println("Got score list. size:"
                + output.getScoreList().size());
        return output;
    }

    private static RestTemplate getTemplate() {
        ApplicationContext ctx = new FileSystemXmlApplicationContext(
                "classpath:gameservice-client.xml");
        RestTemplate template = (RestTemplate) ctx.getBean("restTemplate");
        return template;
    }

    private static <T> HttpEntity<T> prepareJsonRequest(T object) {
        return prepareJsonRequest(object, false, null, null);
    }

    private static <T> HttpEntity<T> prepareJsonRequest(T object,
            boolean useBasicAuth, String username, String password) {
        HttpEntity<T> entity = new HttpEntity<T>(object, prepareJsonHeaders(
                useBasicAuth, username, password));
        return entity;
    }

    private static HttpEntity<String> prepareJsonGet() {
        return new HttpEntity<String>(prepareJsonHeaders());
    }

    private static HttpEntity<String> prepareJsonGet(String username,
            String password) {
        return new HttpEntity<String>(prepareJsonHeaders(true, username,
                password));
    }

    private static HttpHeaders prepareJsonHeaders() {
        return prepareJsonHeaders(false, null, null);
    }

    private static HttpHeaders prepareJsonHeaders(boolean useBasicAuth,
            String username, String password) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        List<MediaType> acceptList = new ArrayList<MediaType>();
        acceptList.add(MediaType.APPLICATION_JSON);
        headers.setAccept(acceptList);

        if (useBasicAuth) {
            String credentials = (new StringBuilder(username)).append(":")
                    .append(password).toString();
            String base64Credentials = new String(Base64.encode(credentials
                    .getBytes()), Charset.forName("US-ASCII"));
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
