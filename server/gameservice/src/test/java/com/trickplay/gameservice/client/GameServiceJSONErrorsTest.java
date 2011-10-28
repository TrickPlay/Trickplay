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

import com.trickplay.gameservice.transferObj.BooleanResponse;
import com.trickplay.gameservice.transferObj.UserRequestTO;
import com.trickplay.gameservice.transferObj.UserTO;

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
