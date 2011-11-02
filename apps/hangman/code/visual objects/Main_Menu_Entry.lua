
local all_mmes = {}
setmetatable(all_mmes,{__mode = "k"})

local mme = {}

local logic, box_w, entry_h, score_limit, guess_word, make_word

local function update_times()
    
    for entry,sesh in pairs(all_mmes) do
        
        sesh:update_time()
        
    end
    
end

local clock = Timer{
    interval  = 1000,
    on_timer  = update_times,
}


function mme:init(t)
    
    if type(t) ~= "table" then error("must pass a table as the parameter",2) end
    
    logic        = t.logic       or error( "must pass logic",       2 )
    box_w        = t.box_w       or error( "must pass box_w",       2 )
    entry_h      = t.entry_h     or error( "must pass entry_h",     2 )
    score_limit  = t.score_limit or error( "must pass score_limit", 2 )
    guess_word   = t.guess_word  or error( "must pass guess_word",  2 )
    make_word    = t.make_word   or error( "must pass make_word",   2 )
    ls           = t.ls          or error( "must pass ls",          2 )
    
end

--constructor
function mme:make(sesh)
    
    --attributes
    local sesh_ref     = sesh 
    local prev_my_turn = nil  
    
    
    print("MAKE_MME",sesh_ref)
    
    --Object
    local entry = Group{}
    
    --visual pieces
    ----------------------------------------------------------------------------
    
    local their_name = Text{
        text  = "Invite Pending",
        font  = g_font .. " Medium 28px",
        color = "ffffff",
        x     = 10,
        y     = 5,
    }
    
    local time_remaining = Text{
        text  = "7 days",
        font  = g_font .. " Medium 28px",
        color = "aaaa00",
        x     = box_w - 10,
        y     = 5,
    }
    time_remaining.anchor_point = {time_remaining.w,0}
    
    local whore_line = Rectangle{
        w = box_w-6,
        h = 2,
        x = 3,
        y = entry_h - 2,
        color = "ffffff",
    }
    
    entry:add(their_name,whore_line,time_remaining)
    
    
    --methods
    ----------------------------------------------------------------------------
    
    function entry:set_session_reference(session)
        
        sesh_ref = session
        
        all_mmes[entry] = sesh_ref
        
        self:update()
        
    end
    function entry:my_turn()
        
        return sesh_ref.my_turn
        
    end
    function entry:update()
        
        assert(sesh_ref ~= nil)
        
        
        their_name.text     = sesh_ref.opponent_name or "Invite Pending"
        time_remaining.text = sesh_ref.time_rem      or ""
        
        if sesh_ref.my_score == score_limit then
            
            print("IIIIIII LOST!!!!!!!")
            
            sesh_ref.i_counted_score = true
            
            logic:lost_against(self)
            
            sesh_ref:remove_view(self)
            
            all_mmes[self] = nil
            
            --self:delete()
            
        elseif sesh_ref.opponent_score == score_limit then
            
            print("IIIIIII WON!!!!!!!")
            
            sesh_ref.i_counted_score = true
            
            logic:won_against(self)
            
            sesh_ref:remove_view(self)
            
            all_mmes[self] = nil
            
            --self:delete()
            
        elseif prev_my_turn ~= sesh_ref.my_turn then
            
            prev_my_turn = sesh_ref.my_turn
            
            -- if its my turn now
            if prev_my_turn then
                
                logic:move_to_my_turn(self)
                
            -- if its no longer my turn
            else
                
                logic:move_to_their_turn(self)
                
            end
            
        end
        
    end
    
    
    function entry:status()
        
        if sesh_ref.my_turn then
            
            if sesh_ref.phase == "MAKING" then
                
                return "Your turn to make a word."
                
            else
                
                return "Your turn to guess."
                
            end
            
        elseif sesh_ref.opponent_name == false then
            
            return "Waiting for an opponent."
            
        else
            
            if sesh_ref.phase == "MAKING" then
                
                return "Waiting on "..sesh_ref.opponent_name.." to make a word."
                
            else
                
                return "Waiting on "..sesh_ref.opponent_name.." to guess the word '"..sesh_ref.word.."'."
                
            end
            
        end
        
    end
    
    function entry:select()
        
        if not sesh_ref.my_turn then return end
        
        if sesh_ref.phase == "MAKING" then
            
            make_word:set_session(sesh_ref)
            
            app_state.state = "MAKE_WORD"
            
        else
            guess_word:reset()
            guess_word:guess_word(sesh_ref)
            ls:reset()
            
            app_state.state = "GUESS_WORD"
        end
    end
    
    function entry:delete()
        
        self:unparent()
        
        if sesh_ref ~= nil then   sesh_ref:remove_view(self)   end
        
        all_mmes[self] = nil
        
        
        
    end
    
    
    
    function entry:get_session()
        
        return sesh_ref
        
    end
    ----------------------------------------------------------------------------
    
    all_mmes[entry] = sesh_ref
    if sesh_ref ~= nil then   sesh_ref:add_view(entry)   end
    print("hurrrrr")
    
    return entry
end

return mme