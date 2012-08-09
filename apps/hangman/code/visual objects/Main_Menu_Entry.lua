
local all_mmes = {}
setmetatable(all_mmes,{__mode = "k"})

local mme = {}

local logic, box_w, entry_h, score_limit, guess_word, make_word, img_srcs

local function update_times()
    
    for entry,sesh in pairs(all_mmes) do
        
        sesh:update_time()
        
    end
    
    if app_state.state == "MAIN_PAGE" then logic:report_win_loss() end
    
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
    img_srcs     = t.img_srcs    or error( "must pass img_srcs",    2 )
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
        text  = "invite pending",
        font  = g_font .. " Medium 36px",
        color = "b7b7b7",
        x     = 20,
        y     = 3,
    }
    local their_name_s = Text{
        text  = "invite pending",
        font  = g_font .. " Medium 36px",
        color = "000000",
        x     = 20-2,
        y     = 3-2,
    }
    
    local time_remaining = Text{
        text  = "",
        font  = g_font .. " Medium 28px",
        color = "aaaa00",
        x     = box_w - 10,
        y     = 12,
        on_text_changed = function(self)
            
            self.anchor_point = {self.w,0}
            
        end,
    }
    
    local top_line = Clone{source = img_srcs.hr, y = -1}--[[Rectangle{
        w = box_w-6,
        h = 2,
        x = 3,
        y = -1,
        color = "a7a7a7",
    }]]
    local btm_line = Clone{source = img_srcs.hr, y = entry_h-1}--[[Rectangle{
        w = box_w-6,
        h = 2,
        x = 3,
        y = entry_h -1,
        color = "a7a7a7",
    }]]
    
    entry:add(their_name_s,their_name,top_line,btm_line,time_remaining)
    
    
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
        
        if not sesh_ref.opponent_name then
            their_name.text     = "Invite Pending"
            their_name_s.text   = "Invite Pending"
            
            their_name.w           = -1
            their_name.ellipsize   = "NONE"
            their_name_s.w         = -1
            their_name_s.ellipsize = "NONE"
        else
            their_name.text     = sesh_ref.opponent_name
            their_name_s.text   = sesh_ref.opponent_name
            their_name.w           = 190
            their_name.ellipsize   = "END"
            their_name_s.w         = 190
            their_name_s.ellipsize = "END"
        end
        time_remaining.text = sesh_ref.time_rem      or ""
        
        if sesh_ref.my_score == score_limit then
            
            print("IIIIIII LOST!!!!!!!")
            
            logic:lost_against(self)
            
            sesh_ref:remove_view(self)
            
            all_mmes[self] = nil
            
            --self:delete()
            
        elseif sesh_ref.opponent_score == score_limit then
            
            print("IIIIIII WON!!!!!!!")
            
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
            
            return "Waiting for an opponent to join the game."
            
        else
            
            if sesh_ref.phase == "MAKING" then
                
                return "Waiting for opponent to make a word."--"..sesh_ref.opponent_name.."
                
            else
                
                return "Waiting for opponent to guess '"..sesh_ref.word.."'."--"..sesh_ref.opponent_name.."
                
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
        
        print("deleted")
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