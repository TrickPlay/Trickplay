
--colors
local x_off = {155,155,155}
local x_on  = {255,  0,  0}

local your_turn      = "ffffff"
local awaiting_reply = x_off




--constructor
local make_mme = function(t)--score_limit,box_w,entry_h,mml)
    
    if type(t) ~= "table" then error("must pass a table as the parameter",2) end
    
    --attributes
    local mml          = t.mml         or error( "must pass mml",         2 )
    local box_w        = t.box_w       or error( "must pass box_w",       2 )
    local entry_h      = t.entry_h     or error( "must pass entry_h",     2 )
    local score_limit  = t.score_limit or error( "must pass get_letters", 2 )
    local sesh_ref     = t.sesh           -- set later
    local prev_my_turn = nil              -- set later
    
    
    print("MAKE_MME",sesh_ref)
    
    --Object
    local entry = Group{}
    
    
    --visual pieces
    ----------------------------------------------------------------------------
    local my_x_s    = {}
    local their_x_s = {}
    
    for i = 1,score_limit do
        
        my_x_s[i] = Text{
            text  = "X",
            font  = g_font .. " Bold 28px",
            color = x_off,
            y     = 5,
        }
        my_x_s[i].x = box_w/2 - (my_x_s[i].w+5)*(i-1) - my_x_s[i].w - 10
        
        their_x_s[i] = Text{
            text  = "X",
            font  = g_font .. " Bold 28px",
            color = x_off,
            y     = 5,
        }
        their_x_s[i].x = box_w/2 + (their_x_s[i].w+5)*(i-1)+ 10
        
    end
    
    local my_name = Text{
        text  = "Waiting for a player",
        font  = g_font .. " Medium 28px",
        color = awaiting_reply,
        x     = 10,
        y     = 5,
    }
    
    local their_name = Text{
        text  = "",
        font  = g_font .. " Medium 28px",
        color = your_turn,
        x     = box_w - 10,
        y     = 5,
    }
    their_name.anchor_point = {their_name.w,0}
    
    local whore_line = Rectangle{
        w = box_w-6,
        h = 2,
        x = 3,
        y = entry_h - 2,
        color = "ffffff",
    }
    
    local vert_line = Rectangle{
        w = 2,
        h = entry_h-20,
        x = box_w/2-1,
        y = 8,
        color = "ffffff",
    }
    
    entry:add(unpack(my_x_s))
    entry:add(unpack(their_x_s))
    entry:add(my_name,their_name,whore_line,vert_line)
    ----------------------------------------------------------------------------
    
    
    --methods
    ----------------------------------------------------------------------------
    function entry:set_session_reference(session)
        
        sesh_ref = session
        
        self:update()
        
    end
    function entry:my_turn()
        
        return sesh_ref.my_turn
        
    end
    function entry:update()
        
        assert(sesh_ref ~= nil)
        print("entry updated")
        for i = 1,score_limit do
            
            my_x_s[i].color    = (i <= sesh_ref.my_score)    and x_on or x_off
            
            their_x_s[i].color = (i <= sesh_ref.opponent_score) and x_on or x_off
            
        end
        
        my_name.text  = (sesh_ref.my_turn and "Your Turn") or (sesh_ref.opponent_name and "Waiting for...") or "Waiting for a player"
        my_name.color =  sesh_ref.my_turn and  your_turn   or  awaiting_reply
        
        their_name.text         =  sesh_ref.opponent_name or ""
        their_name.color        =  your_turn
        their_name.anchor_point = {their_name.w,0}
        
        if sesh_ref.my_score == score_limit then
            
            my_name.text  = "You lost against..."
            
            my_name.color = awaiting_reply
            
            mml:move_to_old_games(self)
            
        elseif sesh_ref.opponent_score == score_limit then
            
            my_name.text = "You won against..."
            
            my_name.color = awaiting_reply
            
            mml:move_to_old_games(self)
            
        elseif prev_my_turn ~= sesh_ref.my_turn then
            
            prev_my_turn = sesh_ref.my_turn
            
            -- if its my turn now
            if prev_my_turn then
                
                mml:move_to_my_turn(self)
                
            -- if its no longer my turn
            else
                
                mml:move_to_their_turn(self)
                
            end
            
            mml:update_y_s()
            
        end
        
    end
    
    function entry:get_session()
        
        return sesh_ref
        
    end
    ----------------------------------------------------------------------------
    
    if sesh_ref ~= nil then
        print("sesh_ref is present")
        sesh_ref:add_view(entry)
        
    end
    
    return entry
end

return make_mme