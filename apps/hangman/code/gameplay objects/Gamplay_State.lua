local u_id

local set_username = function(id)
    u_id = id
end

local make_from_existing = function(p_data)
    
    assert(g_username ~= nil)
    
    if type(p_data) == "string" then
        
        p_data = json:parse()
        
    end
    
    if type(p_data)   ~= "table" then error("must pass valid parameter", 2) end
    
    print("Creating a Session Object with the following data:")
    dumptable(p_data)
    
    
    --sanity check on its state
    if p_data.state == json.null then error("got a sesssion with no data",2) end
    
    if type(p_data.state) == "string" then
        
        p_data.state = json:parse(base64_decode(p_data.state))
        
    end
    
    if p_data.state.state then error("got a state.state",2) end
    
    
    
    
    ----------------------------------------------------------------------------
    --  Object                                                                --
    ----------------------------------------------------------------------------
    local session = {}
    
    --attributes
    local data = p_data
    
    local views = {}
    
    
    
    
    -- if this is not a game started by me
    if data.state.players[1].name ~= g_username then
        
        --if the second name is not me
        if data.state.players[2].name ~= g_username then
            
            --and as long as its not false
            if data.state.players[2].name ~= false then
                
                error(
                    "this game already has 2 players: "..
                    data.state.players[1].name..","..
                    data.state.players[2].name,
                    2
                )
                
            end
            
            --it is a wild card game
            data.state.players[2].name = g_username
            data.state.players[2].id   = u_id
            
            data.state.turn = g_username
        end
        
    end
    
    
    
    
    function session:add_view(view)
        
        views[view] = true
        
        view:update(self)
        
    end
    
    function session:remove_view(view)
        
        if views[view] then
            
            views[view] = nil
            
        else
            
            print("Warning, was not a view")
            
        end
        
    end
    
    function session:update_views()
        
        for v,_ in pairs(views) do
            
            v:update(self)
            
        end
        
    end
    
    function session:toggle_phase()
        
        data.state.phase = self.phase == "GUESSING" and "MAKING" or "GUESSING"
        
    end
    
    function session:opponents_turn()
        
        data.state.turn = self.opponent_name
        
    end
    
    function session:add_letter(l)
        
        assert(type(l) == "string")
        
        table.insert(data.state.letters,l)
        
    end
    
    function session:clear_letter()
        
        data.state.letters = {}
        
    end
    
    
    --Meta Table gets/sets
    ----------------------------------------------------------------------------
    local me = function()
        if data.state.players[1].name == g_username then
            
            return data.state.players[1] 
            
        else
            
            return data.state.players[2]
            
        end
    end
    
    local opponent = function()
        if data.state.players[1].name == g_username then
            
            return data.state.players[2] 
            
        else
            
            return data.state.players[1]
            
        end
    end
    
    local meta_set = {
        my_score = function(v) me().score       = v end,
        word     = function(v) data.state.word  = v end,
        id       = function(v) data.gameSessionId = v; dumptable(data) end,
    }
    local meta_get = {
        opponent_name  = function() return opponent().name    end,
        opponent_score = function() return opponent().score   end,
        opponent_id    = function() return opponent().id      end,
        my_score       = function() return me().score         end,
        word           = function() return data.state.word    end,
        letters        = function() return data.state.letters end,
        phase          = function() return data.state.phase   end,
        id             = function() dumptable(data);return data.gameSessionId end,
        
        my_turn        = function() return data.state.turn == g_username end,
        state          = function() return base64_encode(json:stringify(data.state)) end,
    }
    
    setmetatable(
        session,
        {
            __newindex = function(t,k,v)
                print(t,k,v)
                
                if meta_set[k] then return meta_set[k](v) end
                
                
            end,
            __index = function(t,k)
                print(t,k)
                if meta_get[k] then return meta_get[k]() end
                
            end,
        }
    )
    ----------------------------------------------------------------------------
    
    dumptable(p_data)
    
    return session
end

--if turn = false then call get update

local create_new_game = function()
    
    return make_from_existing{
        gameSessionId = false,
        state = {
            players = { {name = g_username,score = 0, id = u_id}, {name = false,score = 0, id = false} },
            turn    = g_username, --waiting for wildcard opponent
            word    = false,
            phase   = "MAKING",
            letters = {},
        }
    }
    
end

return set_username, make_from_existing, create_new_game