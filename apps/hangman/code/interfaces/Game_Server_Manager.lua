
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

local user_id, vendorId, game_id

function Game_Server:init(t)
    
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
    
end


function Game_Server:user_id()
    
    return user_id
    
end
function Game_Server:login(t)
    
    if type(t) ~= "table" then
        
        error("Invalid parameter must pass a table",2)
        
    end
    
    user        = t.user        or error("Must pass in a username,       this requirement will be deprecated once the app is able to grab the trickplay user_id",2)
    pswd        = t.pswd        or error("Must pass in a password,       this requirement will be deprecated once the app is able to grab the trickplay user_id",2)
    email       = t.email       or error("Must pass in a email,          this requirement will be deprecated once the app is able to grab the trickplay user_id",2)
    game_def    = t.game_definition or error("Must pass in a game_definition,    this requirement will be deprecated once the app is able to grab the trickplay user_id",2)
    local callback = t.callback or error("Must pass in a callback,    this requirement will be deprecated once the app is able to grab the trickplay user_id",2)
    
    print("Checking if user exists")
    interface:check_user_exists(  user,  function(t)
        
        local f = function(t)
            
            t = t.users and t.users[1] or t
            
            user_id = t.id or error("unexpected interaction with the Gameserver, user_id is nil")
            
            assert(type(user_id) == "number", "user_id is not a number, is type "..type(user_id) )
            
            dumptable(t)
            
            print("checking if vendor exists")
            interface:check_vendor_exists(user,pswd,vendor_name, function(t)
                
                local f = function(t)
                    
                    vendor_id = t.id or error("unexpected interaction with the Gameserver, vendor_id is nil")
                    
                    assert(type(vendor_id) == "number", "user_id is not a number, is type "..type(user_id) )
                    
                    dumptable(t)
                    
                    print("checking if game exists")
                    interface:check_game_exists(user,pswd,game_name, function(t)
                        
                        local f = function(t)
                            
                            game_id = t.id or error("unexpected interaction with the Gameserver, game_id is nil")
                            
                            dumptable(t)
                            
                            callback(t)
                            
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

function Game_Server:update(session,callback)
    
    interface:update_gameplay_session(
        user,
        pswd,
        user_id,
        session.id,
        session.state,
        callback
    )
    
end

function Game_Server:respond(session,callback)
    
    interface:update_gameplay_session(
        user,
        pswd,
        session.opponent_id,
        session.id,
        session.state,
        callback
    )
    
end

function Game_Server:get_session_state(session,callback)
    
    interface:get_gameplay_session(
        user,
        pswd,
        session.id,
        callback
    )
    
end

function Game_Server:get_a_wild_card_invite(callback)
    
    interface:get_gameplay_invitation(
        user,
        pswd,
        game_id,
        1,
        callback
    )
    
end
function Game_Server:accept_invite(invite_id,callback)
    
    interface:accept_gameplay_invitation(
        user,
        pswd,
        invite_id,
        callback
    )
    
end
function Game_Server:get_list_of_sessions(callback)
    
    interface:get_all_gameplay_sessions( user, pswd, function(t)
        
        local gamesessions = {}
        
        local total_num = # t.gameSessionList
        local curr_num  = 0
        
        if total_num == 0 then
            
            callback{}
            
            return
            
        end
        
        --for now I need to call get_session_state for each session in the list
        for i,sesh in pairs(t.gameSessionList) do
            
            --if it has state data, then change the code to stop being wasteful
            if sesh.state ~= nil or sesh.gamePlayState ~= nil  then 
                
                print("got session_state! ",sesh.state,sesh.gamePlayState )
                error("gameserver changed and you don't have to do this anymore",2)
                
            -- otherwise call get session for each
            else
                
                self:get_session_state( sesh, function(t)
                    
                    --build the table
                    table.insert(gamesessions,t)
                    
                    curr_num = curr_num + 1
                    
                    print("received: "..curr_num/total_num .."   session: "..i)
                    
                    --once the total number of sessions have been collected, return
                    if curr_num == total_num then
                        
                        callback(gamesessions)
                        
                    --if somehow there were more callbacks then calls...
                    elseif curr_num > total_num then
                        
                        error("impossibru!!!")
                        
                    end
                    
                end)
                
            end
            
        end
        
    end)
    
    
end

return Game_Server