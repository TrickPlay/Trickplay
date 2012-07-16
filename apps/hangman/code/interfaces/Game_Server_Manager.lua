
--------------------------------------------------------------------------------
-- The Game Server Object                                                     --
--------------------------------------------------------------------------------
local Game_Server = {}

--attributes
local initialized = false

--the user
local user, pswd, email

--the vendor
local vendor_name = app.id:match(  "[^%.]+%.[^%.]+"  ) --yeilds 'com.trickplay'vendorId

print("vendor name: '"..vendor_name.."'")
local game_name   = app.name --yeilds 'The Hangman's Challenge'
print("game name:   '"..game_name.."'")

local vendorId, game_id

function Game_Server:init(t)
    --[[ TODO
    
    --call open_app
    
    --check if user has hangman registered
    
    --if not register hangman game with user
    --]]
    
    ---[[
    if initialized then
        
        error("Game_Server Library has already been initialized",2)
        
    end
    
    if type(t) ~= "table" then
        
        error("Invalid parameter must pass a table",2)
        
    end
    
    interface = t.interface or error("Must pass in a interface",2)
    
    --check to see if vendor exists (to get vendorID), else create it
    --check to see if game exists (to get gameID), else create it
    
    initialized = true
    --]]
end
function Game_Server:login(t)
    
    --[[ TODO
    
    
        if on_ready already happened, then call login_callback & session_callback
        
        if not, then setup on_ready to call login_callback & session_callback
        
    --]]
    
    
    
    if type(t) ~= "table" then
        
        error("Invalid parameter must pass a table",2)
        
    end
    
    user        = t.user        or error("Must pass in a username,       this requirement will be deprecated once the app is able to grab the trickplay user_id",2)
    pswd        = t.pswd        or error("Must pass in a password,       this requirement will be deprecated once the app is able to grab the trickplay user_id",2)
    email       = t.email       or error("Must pass in a email,          this requirement will be deprecated once the app is able to grab the trickplay user_id",2)
    game_def    = t.game_definition or error("Must pass in a game_definition,    this requirement will be deprecated once the app is able to grab the trickplay user_id",2)
    local login_callback = t.login_callback or error("Must pass in a login_callback,    this requirement will be deprecated once the app is able to grab the trickplay user_id",2)
    local session_callback = t.session_callback or error("Must pass in a session_callback,    this requirement will be deprecated once the app is able to grab the trickplay user_id",2)
    
    print("Checking if user exists")
    interface:check_user_exists(  user,  function(t)
        
        local f = function(t)
            
            if t == 401 then
                login_callback( false )
                return
            end
            
            login_callback( true )
            
            t = t.users and t.users[1] or t
            
            g_user.id = t.id or error("unexpected interaction with the Gameserver, user_id is nil")
            
            assert(type(g_user.id) == "number", "user_id is not a number, is type "..type(user_id) )
            
            dumptable(t)
            
            print("checking if vendor exists")
            interface:check_vendor_exists( user,pswd,vendor_name, function(t)
                
                local f = function(t)
                    
                    vendor_id = t.id or error("unexpected interaction with the Gameserver, vendor_id is nil")
                    
                    assert(type(vendor_id) == "number", "user_id is not a number, is type "..type(user_id) )
                    
                    dumptable(t)
                    
                    print("checking if game exists")
                    interface:check_game_exists(user,pswd,game_name, function(t)
                        
                        local f = function(t)
                            
                            game_id = t.id or error("unexpected interaction with the Gameserver, game_id is nil")
                            
                            interface:get_gameplay_summary(
                                user,pswd,game_id, function(t)
                                    
                                    if t.detail == json.null then
                                        print("set")
                                        interface:set_gameplay_summary(
                                            user,pswd,game_id, base64_encode(json:stringify{wins = 0, losses = 0}), function(t)
                                                
                                                g_user.wins   = 0
                                                g_user.losses = 0
                                                
                                                session_callback()
                                                
                                            end
                                        )
                                        
                                    else
                                        print("get")
                                        t = json:parse(base64_decode(t.detail))
                                        dumptable(t)
                                        g_user.wins   = t.wins
                                        g_user.losses = t.losses
                                        session_callback()
                                        
                                        
                                    end
                                    
                                end
                            )
                            
                            
                            
                            return true
                            
                        end
                        
                        if t.id ~= json.null then
                            
                            print("game exists")
                            f(t)
                            
                        else
                            
                            print("game doesn't exist, creating")
                            interface:create_game(
                                user,
                                pswd,
                                game_def(vendor_name,vendor_id),
                                f
                            )
                            
                        end
                        
                    end)
                    
                end
                
                if t.id and t.id ~= json.null then
                    
                    print("vendor exists")
                    f(t)
                    
                else
                    
                    print("vendor doesn't exist, creating")
                    interface:create_vendor(
                        user,
                        pswd,
                        vendor_name,
                        f
                    )
                    
                end
                
            end)
            
        end
        
        if t.value then
            
            print("user exists, getting info")
            interface:user_info(user,pswd,f)
            
        else
            
            print("user doesn't exist, creating")
            interface:create_user(user,email,pswd,f)
            
        end
        
    end)
    
end


function Game_Server:launch_wildcard_session(session,callback)
    
    --[[ TODO
    this function gets called after the user creates the word for a new game
    
    so, create the match & send_turn, allowing any opponent to join
    --]]
    
    
    if session == nil then error("must pass session",2) end
    
    interface:create_gameplay_session(user,pswd,game_id,function(t)
        
        
        callback(t.id)
        
        interface:send_invitation(
            user,pswd,t.id,nil, function()
                
                dumptable(session)
                interface:start_gameplay_session(
                    user,
                    pswd,
                    "null",
                    session.id,
                    session.state,
                    function(t) end
                )
                
            end
        )
    end)
    
end

function Game_Server:update_game_history(callback)
    --[[
    
        this function updates the Win Loss Record of the logged in user
    --]]
    
    
    interface:set_gameplay_summary(
        user,pswd,game_id, base64_encode(json:stringify{wins = g_user.wins, losses = g_user.losses}), callback
    )
    
end

function Game_Server:update(session,callback)
    --[[
    
        this function is used to save game state, does not imply that this users turn is over
    --]]
    
    
    if session == nil then error("must pass session",2) end
    
    interface:update_gameplay_session(
        user,
        pswd,
        g_user.id,
        session.id,
        session.state,
        callback
    )
    
end

function Game_Server:end_session(session,callback)
    --[[
    
        this function is used to end a match, (if a user loses the match, or times out)
    --]]
    
    if session == nil then error("must pass session",2) end
    
    interface:end_gameplay_session(
        user,
        pswd,
        session.id,
        session.state,
        callback
    )
    
end

function Game_Server:respond(session,callback)
    --[[
    
        this function is send_turn, it also appears to update the gamestate
    --]]
    
    
    if session == nil then error("must pass session",2) end
    
    interface:update_gameplay_session(
        user,
        pswd,
        session.opponent_id,
        session.id,
        session.state,
        callback
    )
    
end

function Game_Server:get_session_state(id,callback)
    --[[
    
        gets the current state of a particular match
    --]]
    
    
    if id == nil then error("must pass id",2) end
    
    interface:get_gameplay_session(
        user,
        pswd,
        id,
        callback
    )
    
end

function Game_Server:get_a_wild_card_invite(callback)
    --[[
    
        checks to see if there is are any games ( gs:join_match() )
    --]]
    
    
    interface:get_gameplay_invitation(
        user,
        pswd,
        game_id,
        1,
        callback
    )
    
end
function Game_Server:accept_invite(invite_id,callback)
    --[[
    
        this function is used to join a match
    --]]
    
    
    if invite_id == nil then error("must pass invite_id",2) end
    
    interface:accept_gameplay_invitation(
        user,
        pswd,
        invite_id,
        callback
    )
    
end

function Game_Server:get_list_of_sessions(callback)
    --[[
    
        this function is used to get the list of matches that the player is currently involved in
    --]]
    
    
    interface:get_all_gameplay_sessions( user, pswd, function(t)
        
        callback(t.gameSessionList)
        
    end)
    
    
end

return Game_Server