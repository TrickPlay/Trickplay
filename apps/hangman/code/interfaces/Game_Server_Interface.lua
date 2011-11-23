
local on_lose_internet, on_regain_internet
local re_connecting = false

local try_again = Timer{
	
	interval = 10*1000,
	
	on_timer = function(self)
		
		self:stop()
		
        print( "Resending " .. self.req.url )
        
		self.req:send()
		
	end
}

try_again:stop()

local response_check = function(request_object,response_object,callback)
	
	if response_object.failed or response_object.body == nil then
		
		re_connecting = true
		
        print(
			
			"URLRequest FAILED, receiving the reponse code: "..
			
			response_object.code.." - "..
			
			response_object.status..".  Trying again in "..try_again.interval/1000 .. " seconds."
			
		)
		
		try_again.req = request_object
		
		try_again:start()
		
		on_lose_internet()
		
	else
		
		if re_connecting then
			
			re_connecting = false
			
			on_regain_internet()
			
		end
		
		local json_response = json:parse(response_object.body)
		
		if json_response == nil then
			
			print("json was nil")
			print(response_object.code.." - "..response_object.status)
			
			if callback then callback(response_object.code) end
			
        else
            
            if callback then callback(json_response) end
            
		end
        
	end
    
end






--private methods

local base_url = "http://10.0.190.158:8080/gameservice/rest"

local base_header = {
    
    ["Accept"]       = "application/json",
    
    ["Content-Type"] = "application/json",
    
}
local make_headers = function(user,pswd)
    
	
	base_header["Authorization"] =
		
		(user ~= nil and pswd ~= nil) and
			
			"Basic " .. base64_encode( user .. ":" .. pswd ) or
			
			nil
	
    
    return base_header
	
end



local Game_Server = {}

function Game_Server:init(t)
	
	if type(t) ~= "table" then error("must pass a table as the parameter",2) end
	
	on_lose_internet = t.on_lose_internet or error("must pass on_lose_internet",2)
	on_regain_internet = t.on_lose_internet or error("must pass on_lose_internet",2)
	
end

--------------------------------------------------------------------------------
-- User Services                                                              --
--------------------------------------------------------------------------------

--[[
1. Create User (User Registration)

Request

POST /gameservice/rest/user HTTP/1.1

Accept: application/json

Content-Type: application/json

{"username":"u1","email":"u1@u1.com","password":"u1"}

Response

{"id":2,"username":"u1","email":"u1@u1.com","allowAchievementMessages":false,"allowHighScoresMessages":false}
--]]
function Game_Server:create_user(user,email,pwd,callback)
    
    URLRequest{
        
        url    = base_url.."/user",
        
        method = "POST",
        
        headers = make_headers(),
        
        body = '{"username":"'..user..'","email":"'..email..'","password":"'..pwd..'"}',
        
        on_complete = function(self,response_object)
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end

--[[
1. Check User Exists (User Registration)

Request

GET /gameservice/rest/user/exists?username=u1 HTTP/1.1

Accept: application/json

Content-Type: application/json

{"username":"u1","email":"u1@u1.com","password":"u1"}

Response

{"id":2,"username":"u1","email":"u1@u1.com","allowAchievementMessages":false,"allowHighScoresMessages":false}
--]]
function Game_Server:check_user_exists(user,callback)
    
    URLRequest{
        
        url    = base_url.."/user/exists?username="..user,
        
        method = "GET",
        
        headers = make_headers(),
        
        on_complete = function(self,response_object)
			print(response_object.body)
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end

--[[
2. User Info

Request

GET /gameservice/rest/user HTTP/1.1

Accept: application/json

Content-Type: application/json

Authorization: Basic dTE6dTE=

Response

{"id":2,"username":"u1","email":"u1@u1.com","allowAchievementMessages":false,"allowHighScoresMessages":false}
--]]
function Game_Server:user_info(user,pwd, callback)
    
    URLRequest{
        
        url    = base_url.."/user",
        
        method = "GET",
        
        headers = make_headers(user,pwd),
        
        on_complete = function(self,response_object)
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end
--[[
2. Get Buddy List

Request

GET /gameservice/rest/user HTTP/1.1

Accept: application/json

Content-Type: application/json

Authorization: Basic dTE6dTE=

Response

{"id":2,"username":"u1","email":"u1@u1.com","allowAchievementMessages":false,"allowHighScoresMessages":false}
--]]
function Game_Server:get_buddy_list(user,pwd, callback)
    
    URLRequest{
        
        url    = base_url.."/user/1/buddy-list",
        
        method = "GET",
        
        headers = make_headers(user,pwd),
        
        on_complete = function(self,response_object)
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end
--[[
3. Create Buddy Invitation

Request

POST /gameservice/rest/user/2/invitation HTTP/1.1

Accept: application/json

Content-Type: application/json

Authorization: Basic dTE6dTE=

{"recipient":"u2"}

Response

{"id":1,"status":"PENDING","recipientId":3,"recipient":"u2","requestor":"u1","created":1316692278605,"updated":1316692278605,"requestorId":2}
--]]
function Game_Server:create_buddy_invitation(to)
    
    URLRequest{
        
        url    = base_url.."/user/2/invitation",
        
        method = "POST",
        
        headers = make_headers(user,pwd),
        
        body = '{"recipient":'..to..'}',
        
        on_complete = function(self,response_object)
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end

--[[
4. Get Received Buddy Invitation

Request

GET /gameservice/rest/user/3/invitation?type=RECEIVED HTTP/1.1

Accept: application/json

Content-Type: application/json

Authorization: Basic dTI6dTI=

Response

{"invitations":[{"id":1,"status":"PENDING","recipientId":3,"recipient":"u2","requestor":"u1","created":1316692278605,"updated":1316692278605,"requestorId":2}]}
--]]
function Game_Server:get_buddy_invitation()
    
    URLRequest{
        
        url    = base_url.."/user/3/invitation?type=RECEIVED",
        
        method = "GET",
        
        headers = make_headers(user,pwd),
        
        on_complete = function(self,response_object)
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end

--[[
5. Accept Buddy Invitation

Request

 

PUT /gameservice/rest/user/3/invitation/1 HTTP/1.1
Accept: application/json
Content-Type: application/json
Authorization: Basic dTI6dTI=
{"status":"ACCEPTED"}
 
Response
{"id":1,"status":"ACCEPTED","recipientId":3,"recipient":"u2","requestor":"u1","created":1316692278605,"updated":1316692278715,"requestorId":2}
--]]
function Game_Server:accept_buddy_invitation()
    
    URLRequest{
        
        url    = base_url.."/user/3/invitation/1",
        
        method = "PUT",
        
        headers = make_headers(user,pwd),
        
        body = '{"status":"ACCEPTED"}',
        
        on_complete = function(self,response_object)
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end







--------------------------------------------------------------------------------
-- Vendor & Game Definition Services                                          --
--------------------------------------------------------------------------------

--[[
6. Create Vendor
 
Request
 

POST /gameservice/rest/vendor HTTP/1.1

Accept: application/json

Content-Type: application/json

Authorization: Basic dTM6dTM=

{"name":"v1-u1"}

Response

{"name":"v1-u1","id":1,"games":[],"primaryContactId":2,"primaryContactName":"u1"}
--]]
function Game_Server:create_vendor(user,pwd,vendor,callback)
    
    URLRequest{
        
        url    = base_url.."/vendor",
        
        method = "POST",
        
        headers = make_headers(user,pwd),
        
        body = '{"name":"'..vendor..'"}',
        
        on_complete = function(self,response_object)
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end

--[[
6. Check Vendor Exists
 
Request
 
 
GET /gameservice/rest/game/exists?name=g10-v1-u1 HTTP/1.1

Accept: application/json

Content-Type: application/json

Authorization: Basic dTM6dTM=

{"name":"v1-u1"}

Response

{"value":false}
--]]
function Game_Server:check_vendor_exists(user,pwd,vendor,callback)
    
    URLRequest{
        
        url    = base_url..'/vendor/exists?name='..uri:escape(vendor),
        
        method = "GET",
        
        headers = make_headers(user,pwd),
        
        on_complete = function(self,response_object)
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end


--[[

7. Create Game

Request

POST /gameservice/rest/game HTTP/1.1

Accept: application/json

Content-Type: application/json

Authorization: Basic dTE6dTE=

{
	"name":"g10-v1-u1",
	"appId":"g10-v1-u1.us.world",
	"leaderboardFlag":true,
	"achievementsFlag":true,
	"minPlayers":1,
	"maxPlayers":3,
	"vendorId":1
}

Response

{
	"name":"g10-v1-u1",
	"id":1,
	"vendorName":"v1-u1",
	"vendorId":1,
	"maxPlayers":3,
	"minPlayers":1,
	"leaderboardFlag":true,
	"achievementsFlag":true,
	"appId":"g10-v1-u1.us.world"
}
--]]
function Game_Server:create_game(user,pwd,t,callback)
    
	assert(type(t) == "table")
	dumptable(t)
	
	assert(t.game_name               ~= nil )
	assert(t.appId                   ~= nil )
	assert(t.leaderboardFlag         ~= nil )
	assert(t.achievementsFlag        ~= nil )
	assert(t.allowWildCardInvitation ~= nil )
	assert(t.turnBasedFlag           ~= nil )
	assert(t.vendorName              ~= nil )
	assert(t.vendorId                ~= nil )

    URLRequest{
        
        url    = base_url.."/game",
        
        method = "POST",
        
        headers = make_headers(user,pwd),
        
        body ='{'..
            '"name":"'                   .. t.game_name                         ..'",'..
            '"appId":"'                  .. t.appId                             ..'",'..
            '"leaderboardFlag":'         .. tostring(t.leaderboardFlag)         ..','..
            '"achievementsFlag":'        .. tostring(t.achievementsFlag)        ..','..
            '"minPlayers":'              .. t.minPlayers                        ..','..
            '"maxPlayers":'              .. t.maxPlayers                        ..','..
            '"allowWildCardInvitation":' .. tostring(t.allowWildCardInvitation) ..','..
            '"turnBasedFlag":'           .. tostring(t.turnBasedFlag)           ..','..
            '"vendorId":'                .. t.vendorId                          ..
        '}',
        
        on_complete = function(self,response_object)
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end


--[[

7. Check Game Exists

Request

GET /gameservice/rest/game/exists?name=g11-v1-u1 HTTP/1.1

Accept: application/json

Content-Type: application/json

Authorization: Basic dTE6dTE=


Response

{"value":false}
--]]
function Game_Server:check_game_exists(user,pwd,game_name,callback)
    
    URLRequest{
        
        url    = base_url..'/game/exists?name='..uri:escape(game_name),
        
        method = "GET",
        
        headers = make_headers(user,pwd),
        
        on_complete = function(self,response_object)
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end



--------------------------------------------------------------------------------
-- Gameplay Services                                                          --
--------------------------------------------------------------------------------

--[[
8. Create Game Play Session

Request

POST /gameservice/rest/gameplay HTTP/1.1

Accept: application/json

Content-Type: application/json

Authorization: Basic dTE6dTE=

{"gameId":1}

Response

{"id":1,"startTime":null,"endTime":null,"gameId":1,"players":[{"username":"u1","userId":2}],"created":1316692279093,"updated":1316692279093,"gameName":"g10-v1-u1","ownerId":2,"ownerName":"u1"}
--]]
function Game_Server:create_gameplay_session(user,pwd,game_id,callback)
    
    URLRequest{
        
        url    = base_url.."/gameplay",
        
        method = "POST",
        
        headers = make_headers(user,pwd),
        
        body = '{"gameId":'..game_id..'}',
        
        on_complete = function(self,response_object)
			print(self.url)
			dumptable(self.headers)
			print(self.body)
			print(response_object.body)
			
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end
 
--[[
 

9. Send Game Play Invitation

﻿﻿﻿Request

POST /gameservice/rest/gameplay/1/invitation HTTP/1.1

Accept: application/json

Content-Type: application/json

Authorization: Basic dTE6dTE=

{"recipientId":3}

Response

{"id":1,"status":"PENDING","gameId":null,"recipientId":3,"gameSessionId":1,"created":1316692279131,"updated":1316692279131,"requestorId":2}
--]]
function Game_Server:send_gameplay_invitation(to)
    
    URLRequest{
        
        url    = base_url.."/gameplay/1/invitation",
        
        method = "POST",
        
        headers = make_headers(user,pwd),
        
        body = '{"recipientId":'..to..'}',
        
        on_complete = function(self,response_object)
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end
 
--[[
 

9. Get Game Play Invitations

﻿﻿﻿Request

GET /gameservice/rest/game/1/invitations?max=10 HTTP/1.1

Accept: application/json

Content-Type: application/json

Authorization: Basic dTE6dTE=

{"recipientId":3}

Response

{
	"invitations":[
		{
			"id":1,
			"status":"PENDING",
			"gameId":1,
			"recipientId":null,
			"gameSessionId":1,
			"created":1317853688809,
			"updated":1317853699657,
			"requestorId":2
		}
	]
}

--]]
function Game_Server:get_gameplay_invitation(user,pwd,game_id,max_num,callback)
    
    URLRequest{
        
        url    = base_url.."/game/"..game_id.."/invitations?max="..max_num,
        
        method = "GET",
        
        headers = make_headers(user,pwd),
        
        on_complete = function(self,response_object)
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end
function Game_Server:get_gameplay_summary(user,pwd,game_id,callback)
    
    URLRequest{
        
        url    = base_url.."/game/"..game_id.."/summary",
        
        method = "GET",
        
        headers = make_headers(user,pwd),
        
        on_complete = function(self,response_object)
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end
function Game_Server:set_gameplay_summary(user,pwd,game_id,detail,callback)
    
    URLRequest{
        
        url    = base_url.."/game/"..game_id.."/summary",
        
        method = "POST",
        
        headers = make_headers(user,pwd),
		
		body = '{"detail":"'..detail..'"}',
        
        on_complete = function(self,response_object)
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end
 
 
 
--[[
 

10. Get Game Play Events ( This is how one gets Game Play invitations )

 

Request
GET /gameservice/rest/gameplay/events HTTP/1.1
Accept: application/json
Content-Type: application/json
Authorization: Basic dTI6dTI=
 
Response
{"events":[
	{
		"id":1,
		"subject":"Buddy Invitation from u1",
		"eventType":"BUDDY_LIST_INVITATION",
		"recipientId":3,
		"sourceId":2,
		"sourceUsername":"u1",
		"targetId":1
	},
	{
		"id":3,
		"subject":"Game play request from u1",
		"eventType":"GAME_PLAY_INVITATION",
		"recipientId":3,
		"sourceId":2,
		"sourceUsername":"u1",
		"targetId":1
	}
]}
--]]
function Game_Server:get_gameplay_events(user,pwd,callback)
    
    URLRequest{
        
        url    = base_url.."/events",
        
        method = "GET",
        
        headers = make_headers(user,pwd),
        
        on_complete = function(self,response_object)
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end
 
--[[

11. Accept Game Play Invitation

Request

POST /gameservice/rest/gameplay/1/invitation/1/update HTTP/1.1

Accept: application/json

Content-Type: application/json

Authorization: Basic dTI6dTI=

{"status":"ACCEPTED"}

Response

{"id":1,"status":"ACCEPTED","gameId":null,"recipientId":null,"gameSessionId":1,"created":1316692279131,"updated":1316692279254,"requestorId":2}
--]]
function Game_Server:accept_gameplay_invitation(user,pwd,invite_id,callback)
    
    URLRequest{
        
        url    = base_url.."/gameplay/invitation/"..invite_id.."/update",
        
        method = "POST",
        
        headers = make_headers(user,pwd),
        
        body = '{"status":"ACCEPTED"}',
        
        on_complete = function(self,response_object)
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end
 
--[[
 

12. Start Game Play Session

Request﻿

POST /gameservice/rest/gameplay/1/start HTTP/1.1

Accept: application/json

Content-Type: application/json

Authorization: Basic dTE6dTE=

{"turnId":3,"gameSessionId":1,"gameState":"MQ=="}

Response

{"key":"ZwX0erk5Fjd7a2rd3p2KP7Rgo5AJzXZjB8ynsjGa1vI="}
--]]
function Game_Server:start_gameplay_session(user,pwd,turnId,gameSessionId,gameState,callback)
    
    URLRequest{
        
        url    = base_url.."/gameplay/"..gameSessionId.."/start",
        
        method = "POST",
        
        headers = make_headers(user,pwd),
        
        body = '{"turnId":'..turnId..',"gameSessionId":'..gameSessionId..',"gameState":"'..gameState..'"}',
        
        on_complete = function(self,response_object)
			print(self.url)
			dumptable(self.headers)
			print(self.body)
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end
 
--[[
 
2a. Send Game Play Invitation

Request
POST /gameservice/rest/gameplay/1/invitation HTTP/1.1
Accept: application/json
Content-Type: application/json
Authorization: Basic dTE6dTE=
{"recipientId":null}

Response
{"id":1,"status":"PENDING","gameId":1,"recipientId":null,"gameSessionId":1,"created":1317853688809,"updated":1317853688809,"requestorId":2}

--]]
function Game_Server:send_invitation(user,pwd,session_id,recipientId,callback)
    
	assert(type(session_id) == "number")
	
    URLRequest{
        
        url    = base_url.."/gameplay/"..session_id.."/invitation",
        
        method = "POST",
        
        headers = make_headers(user,pwd),
		
		body = ( type(recipientId) == "string" and
			
			'{"recipientId":"'.. recipientId ..'"}' or
			
			'{"recipientId":null}'),
        
        on_complete = function(self,response_object)
			print(self.url)
			dumptable(self.headers)
			print(self.body)
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end


--[[
 

13. Get Game Play Session State

Request

GET /gameservice/rest/gameplay/1/state HTTP/1.1

Accept: application/json

Content-Type: application/json

Authorization: Basic dTE6dTE=

Response

{"key":"ZUTGu9lAqFxZW3+hBpoJEnQR7GNacBpIUv7xSRHG1OE=","id":7,"state":"Nw==","gameSessionId":1,"turnId":3,"created":1316692280119,"updated":1316692280119,"turnUsername":"u2","gameEnded":false}
--]]
function Game_Server:get_gameplay_session(user,pwd,session_id,callback)
    
    URLRequest{
        
        url    = base_url.."/gameplay/"..session_id.."/state",
        
        method = "GET",
        
        headers = make_headers(user,pwd),
        
        on_complete = function(self,response_object)
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end
 --[[
 

13. Get Game Play Session State

Request

GET /gameservice/rest/gameplay/1/state HTTP/1.1

Accept: application/json

Content-Type: application/json

Authorization: Basic dTE6dTE=

Response

{"key":"ZUTGu9lAqFxZW3+hBpoJEnQR7GNacBpIUv7xSRHG1OE=","id":7,"state":"Nw==","gameSessionId":1,"turnId":3,"created":1316692280119,"updated":1316692280119,"turnUsername":"u2","gameEnded":false}
--]]
function Game_Server:get_all_gameplay_sessions(user,pwd,callback)
    
    URLRequest{
        
        url    = base_url.."/gameplay",
        
        method = "GET",
        
        headers = make_headers(user,pwd),
        
        on_complete = function(self,response_object)
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end
--[[
 

14. Update Game Play Session

Request

POST /gameservice/rest/gameplay/1/update HTTP/1.1

Accept: application/json

Content-Type: application/json

Authorization: Basic dTI6dTI=

{"turnId":2,"gameSessionId":1,"gameState":"OA=="}

Response

{"key":"fDLasp3i2YAi61/001KUC4QdYrxNy1/vvl44Gs4X92Q="}
--]]
function Game_Server:update_gameplay_session(user,pwd,turnId,gameSessionId,gameState,callback)
    
    URLRequest{
        
        url    = base_url.."/gameplay/"..gameSessionId.."/update",
        
        method = "POST",
        
        headers = make_headers(user,pwd),
        
        body = '{"turnId":"'..turnId..'","gameSessionId":'..gameSessionId..',"gameState":"'..gameState..'"}',
        
        on_complete = function(self,response_object)
			
			print(self.url)
			print(self.body)
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end
 
--[[
 

15. End Game Play Session

Request

POST /gameservice/rest/gameplay/1/end HTTP/1.1

Accept: application/json

Content-Type: application/json

Authorization: Basic dTI6dTI=

{"turnId":null,"gameSessionId":1,"gameState":"MTA="}

Response

{"key":"pyNemr4+pphXKd1+Nvcl6bFubLMWAqnt/BYsWzTMKAQ="}
--]]
function Game_Server:end_gameplay_session(user,pwd,gameSessionId,gameState,callback)
    
    URLRequest{
        
        url    = base_url.."/gameplay/"..gameSessionId.."/end",
        
        method = "POST",
        
        headers = make_headers(user,pwd),
        
        body = '{"turnId":null,"gameSessionId":'..gameSessionId..',"gameState":"'..gameState..'"}',
        
        on_complete = function(self,response_object)
			print("ENDING A SESSION")
			print(self.url)
			print(self.body)
			print(response_object.body)
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end
 
 
 
 
 



--------------------------------------------------------------------------------
-- Leader Board Services                                                      --
--------------------------------------------------------------------------------
--[[

16. Post Game Score

Request

POST /gameservice/rest/game/1/score HTTP/1.1

Accept: application/json

Content-Type: application/json

Authorization: Basic dTE6dTE=

{"points":100}

Response

{"id":2,"userName":"u2","points":100,"gameId":1,"userId":3,"gameName":"g10-v1-u1"}
--]]
function Game_Server:post_game_score(score)
    
    URLRequest{
        
        url    = base_url.."/game/1/score",
        
        method = "POST",
        
        headers = make_headers(user,pwd),
        
        body = '{"points":'..score..'}',
        
        on_complete = function(self,response_object)
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end
 
--[[
 

17. Get Game Scores -- only USER SCORES

Request

GET /gameservice/rest/game/1/score?type=USER_TOP_SCORES HTTP/1.1

Accept: application/json

Content-Type: application/json

Authorization: Basic dTE6dTE=

Response

{"scoreList":[{"id":1,"userName":"u1","points":40,"gameId":1,"userId":2,"gameName":"g10-v1-u1"}]}
--]]
function Game_Server:get_user_scores()
    
    URLRequest{
        
        url    = base_url.."/game/1/score?type=USER_TOP_SCORES",
        
        method = "GET",
        
        headers = make_headers(user,pwd),
        
        on_complete = function(self,response_object)
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end
 
--[[

 

18. Get Games Scores -- BUDDY SCORES

Request

GET /gameservice/rest/game/1/score?type=BUDDY_TOP_SCORES HTTP/1.1

Accept: application/json

Content-Type: application/json

Authorization: Basic dTE6dTE=

Response

{"scoreList":[{"id":2,"userName":"u2","points":100,"gameId":1,"userId":3,"gameName":"g10-v1-u1"}]}
--]]
function Game_Server:get_buddy_scores()
    
    URLRequest{
        
        url    = base_url.."/game/1/score?type=BUDDY_TOP_SCORES",
        
        method = "GET",
        
        headers = make_headers(user,pwd),
        
        on_complete = function(self,response_object)
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end
 
--[[

 

19. Get Game Scores -- TOP SCORES

Request

GET /gameservice/rest/game/1/score?type=TOP_SCORES HTTP/1.1

Accept: application/json

Content-Type: application/json

Authorization: Basic dTE6dTE=

Response

{"scoreList":[

    {
        "id":2,
        "userName":"u2",
        "points":100,
        "gameId":1,
        "userId":3,
        "gameName":"g10-v1-u1"
    },
    {
        "id":2,
        "userName":"u2",
        "points":100,
        "gameId":1,
        "userId":3,
        "gameName":"g10-v1-u1"
    }
]}
--]]
function Game_Server:get_top_scores()
    
    URLRequest{
        
        url    = base_url.."/game/1/score?type=TOP_SCORES",
        
        method = "GET",
        
        headers = make_headers(user,pwd),
        
        on_complete = function(self,response_object)
			
			response_check(self,response_object,callback)
			
		end,
        
    }:send()
    
end


return Game_Server








































