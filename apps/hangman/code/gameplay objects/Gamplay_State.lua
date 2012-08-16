
local self = {}

local game_server



local reset_expiration = function() return os.time() + 60*2 end --24*60*60 end


all_seshs = {}
setmetatable(all_seshs,{__mode = "v"})

self.check_server = Timer{
    interval  = 5000,
    on_timer  = function()
        
        if g_user.name == nil then return end
        --print("check_server")
        game_server:get_list_of_sessions(function(t)
            --print("checked")
            --dumptable(t)
            --dumptable(all_seshs)
            for match_id,sesh in pairs(t) do
                
                --if sesh.gameState.match_id ~= json.null then
                    
                    if all_seshs[match_id] == nil then
                        
                        print("ignoring a gamesession")
                        
                    else
                        
                        all_seshs[match_id]:sync_callback(sesh)
                        
                    end
                    
                --end
                
            end
            
        end)
        
    end,
}

self.check_server:stop()


function self:init(t)
    
    if type(t) ~= "table" then error("must pass a table as the parameter",2) end
    
    game_server = t.game_server or error("must pass game_server",2)
    
end

local default_state = function()
    return {
                players = {
                    {name = g_user.name, score = 0, id = g_user.id, counted_score = false},
                    {name = false,       score = 0, id = false,     counted_score = false}
                },
                turn    = g_user.id, --waiting for wildcard opponent
                word    = false,
                viewing = false,
                phase   = "MAKING",
                letters = {},
                expires = reset_expiration(),
            }
end

local make_from_existing = function(p_data)
    
	print("make from existing")
    
    assert(g_user.name ~= nil)
    
    if type(p_data) == "string" then
        
        p_data = json:parse()
        
    end
    
    if type(p_data)   ~= "table" then error("must pass valid parameter", 2) end
    
    print("Creating a Session Object with the following data:")
    dumptable(p_data)
    
    
    --sanity check on its state
    if p_data.state == json.null then
        
        dumptable(p_data)
        
        error("got a sesssion with no data",2)
    end
    
    if type(p_data.match_state) == "table" and type(p_data.match_state.opaque) == "string" then
        
        p_data.state = json:parse(base64_decode(p_data.match_state.opaque))
        
    end
    if type(p_data.state) == "table" then dumptable(p_data.state) 
    else
    		error("No state. This should never happen",2)
	end
    if p_data.state.state then error("got a state.state",2) end
    
    
    
    
    ----------------------------------------------------------------------------
    --  Object                                                                --
    ----------------------------------------------------------------------------
    local session = {}
    
    --attributes
    local data = p_data
    
    local views = {}
    
    local synching = false -- TODO refactor this in/out
    local time_rem
    local pause_time = data.state.expires - os.time()
    
    -- if this is not a game started by me
    if data.state.players[1].id ~= g_user.id then
        
        --if the second name is not me
        if data.state.players[2].id ~= g_user.id then
            
            --and as long as its not false
            if data.state.players[2].id ~= false then
                
                error(
                    "this game already has 2 players: "..
                    data.state.players[1].name..","..
                    data.state.players[2].name,
                    2
                )
                
            end
            
            --it is a wild card game
            data.state.players[2].name = g_user.name
            data.state.players[2].id   = g_user.id
            data.state.expires = reset_expiration()
            data.state.turn = g_user.id
        end
        
    end
    
    
    
    
    function session:add_view(view)
        
        views[view] = true
        
        view:update(self)
        
    end
    
    function session:remove_view(view)
        print("session:remove_view()")
        if views[view] then
            
            views[view] = nil
            
        else
            
            print("Warning, was not a view")
            
        end
        
        if self.i_counted_score then
            
            if self.opponent_counted_score then
                
                game_server:end_session(self,function()
                    
                    print("Session "..self.match_id.." terminated")
                    
                    self:delete()
                    
                end)
                
            else
                dumptable(data)
                game_server:update(self,function() end)
                
            end
            
        end
        print("end of it")
    end
    
    function session:update_views()
        
        for v,_ in pairs(views) do
            
            v:update(self)
            
        end
        
    end
    
    function session:toggle_phase()
        
        data.state.phase = self.phase == "GUESSING" and "MAKING" or "GUESSING"
        
        data.state.expires = reset_expiration()
        if pause_time then pause_time = data.state.expires - os.time() end
    end
    
    function session:opponents_turn()
        
        data.state.turn = self.opponent_id
        
    end
    
    function session:add_letter(l)
        
        assert(type(l) == "string")
        
        table.insert(data.state.letters,l)
        
    end
    
    function session:clear_letter()
        
        data.state.letters = {}
        
    end
    
    function session:abort(new_state)--t)
        
        if new_state == nil or new_state == "" then
            print("WARNING. abort called with no state")
            
        end
        
        --sanity check on its state
        if new_state == json.null then 
            
            dumptable(data)
            
            error("got a sesssion with no data",2)
        end
        
        if type(new_state) == "string" then
            
            data.state = json:parse(base64_decode(new_state))
            
        end
        
        if data.state.state then error("got a state.state",2) end
        
        
        if self.my_turn then
            print("I Expired. Leaving Match.")
            
            if session.viewing then
                
                --list:set_state("UNFOCUSED")
                screen:grab_key_focus()
                
                session.viewing = false
                
                bg:fade_out_vic()
                bg:slide_out_hangman()
                app_state.state = "MAIN_PAGE"
            end
            
            session.my_score = 3
        elseif not self.opponent_counted_score and not synching then
            print("They Expired. Leaving Match.")
            session.opponent_score = 3
        end
        session:update_views()
        
        game_server:leave_match(session,function()
            
            session:delete()
            
        end)
        
        return false
        
    end
   
    function session:sync_callback(new_state)--t)
        
        if new_state == nil or new_state == "" then
            print("WARNING. Sync_Callback called with no state")
            return
        end
        
        --sanity check on its state
        if new_state == json.null then 
            
            dumptable(data)
            
            error("got a sesssion with no data",2)
        end
        
        if type(new_state) == "string" then
            
            data.state = json:parse(base64_decode(new_state))
            
        end
        
        if data.state.state then error("got a state.state",2) end
        
        
        session:update_views()
        
        if session.i_counted_score and session.opponent_counted_score then
            
            game_server:leave_match(session,function()
                
                session:delete()
                
            end)
            
        end
        
        return false
        
    end
    function session:delete()
        print(self.match_id)
        all_seshs[self.match_id] = nil
        
    end
    function session:sync(callback)
        
        game_server:get_session_state(self.match_id,function(t)
            
            callback(  self:sync_callback(t)  )
            
        end)
        
    end
    function session:update_time(curr_time)
        
        if session.opponent_name == false then
            time_rem = ""
            self:update_views()
            return
        end
        --[[
        if session.viewing then
            time_rem = "Viewing"
            self:update_views()
            return
        end
        --]]
        delta = os.difftime(
            data.state.expires,
            os.time()
        )
        --print(delta)
        if delta < 0 then
            
            time_rem = "Checking..."
            if self.my_turn then
                
                print("I Expired. Waiting for Server to call Abort")
                
                game_server:end_session(
                    session,
                    function()
                        session:abort()
                    end
                )
                
            elseif not self.opponent_counted_score and not synching then
                print("They Expired. Waiting for Server to call Abort")
            end
            
            
            
            --[=[
            if self.my_turn then
                print("i expired")
                self.my_score = 3
                
                --problem if lose internet here
                
                --gsm:update(self)
                --g_user.wins = g_user.wins + 1
                --gsm:set_game_history{wins = g_user.wins, losses = g_user.losses}
                game_server:update(self,function() end)
                
                
            elseif not self.opponent_counted_score and not synching then
                synching = true
                print("they expired")
                --wait 5 seconds and check
                time_rem = "Checking..."
                
                dolater(
                    5000,
                    self.sync,
                    self,
                    function(no_change)
                        synching = false
                        --print("got response")
                        if no_change then
                            print("no change")
                            self.opponent_score = 3
                            dumptable(data)
                            
                        --[[ 
                        if changes then 
                        elseif self.opponent_counted_score then
                            print("changes")
                            assert(self.opponent_score == 3)
                            
                            g_user.wins = g_user.wins + 1
                            
                            game_server:set_game_history(
                                
                                {wins = g_user.wins, losses = g_user.losses},
                                
                                function()
                                    game_server:end_session(self,function()
                                        print("Session "..sesh.id.." terminated")
                                        sesh:delete()
                                    end)
                                end
                                
                            )
                            --]]
                        end
                        self:update_views()
                        
                    end
                )
                --]=]
                
            --end
            
        else
            
            delta = os.date( "!*t", delta )
            
            delta.year = delta.year - 1970
            delta.yday = delta.yday - 1 + 365 * delta.year
            
            if delta.yday > 1 then
                
                time_rem = delta.yday.." days"
                
            elseif delta.yday > 0 then
                
                time_rem = "1 day"
                
            elseif delta.hour > 1 then
                
                time_rem = delta.hour .. " hours"
                
            elseif delta.hour > 0 then
                
                time_rem = "1 hour"
                
            elseif delta.min > 1 then
                
                time_rem = delta.min .. " mins"
                
            else
                
                time_rem = "1 min"
                
            end
            
        end
        
        self:update_views()
        
    end
    
    --Meta Table gets/sets
    ----------------------------------------------------------------------------
    local me = function()
        if data.state.players[1].id == g_user.id then
            
            return data.state.players[1] 
            
        else
            
            return data.state.players[2]
            
        end
    end
    
    local opponent = function()
        if data.state.players[1].id == g_user.id then
            
            return data.state.players[2] 
            
        else
            
            return data.state.players[1]
            
        end
    end
    local meta_set = {
        i_counted_score = function(v) me().counted_score = v end,
        my_score        = function(v) me().score         = v end,
        word            = function(v) data.state.word    = v end,
        match_id        = function(v) all_seshs[v] = session; data.match_id = v end,
        opponent_score  = function(v) opponent().score = v  end,
        opponent_name   = function(v) opponent().name  = v  end,
        viewing         = function(v)
            
            data.state.viewing = v
            
            if v then
                pause_time = data.state.expires - os.time()
            else
                data.state.expires = os.time() + (pause_time or 0)
                pause_time = nil
            end
        end,
    }
    local meta_get = {
        i_counted_score = function() return me().counted_score end,
        opponent_name   = function() return opponent().name    end,
        opponent_score  = function() return opponent().score   end,
        opponent_id     = function() return opponent().id      end,
        time_rem        = function() return time_rem           end,
        my_score        = function() return me().score         end,
        word            = function() return data.state.word    end,
        letters         = function() return data.state.letters end,
        phase           = function() return data.state.phase   end,
        match_id        = function() return data.match_id      end,
        viewing         = function() return data.state.viewing end,
        
        my_turn                 = function() return data.state.turn == g_user.id end,
        opaque_state            = function() return base64_encode(json:stringify(data.state)) end,
        opponent_counted_score  = function() return opponent().counted_score    end,
    }
    
    setmetatable(
        session,
        {
            __newindex = function(t,k,v)
                
                if meta_set[k] then return meta_set[k](v) end
                
            end,
            __index = function(t,k)
                
                if meta_get[k] then return meta_get[k]() end
                
            end,
        }
    )
    ----------------------------------------------------------------------------
    
    if session.match_id then all_seshs[session.match_id] = session end
    
    dumptable(p_data)
    
    return session
end

--if turn = false then call get update

function self:make(t)
    
    return make_from_existing(
        t or {
            match_id = false,
            state = default_state(),
        }
    )
    
end

return self