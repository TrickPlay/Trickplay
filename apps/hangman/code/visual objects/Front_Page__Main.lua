local self = Group{}

local my_turn_list, their_turn_list, list_of_lists, status, win_loss_text, entry_info
local list_entry, game_state, guess_word, make_word, ls, game_history, swing_sign

local loaded = false

function self:init(t)
    
    if type(t) ~= "table" then error("must pass a table as the parameter",2) end
    
    if t.clipped_list == nil then error("must pass clipped_list", 2) end
    if t.side_buttons == nil then error("must pass side_buttons", 2) end
    if t.make_frame   == nil then error("must pass make_frame",   2) end
    
    game_server   = t.game_server  or error("must pass game_server",   2)
    game_state    = t.game_state   or error("must pass game_state",    2)
    list_entry    = t.list_entry   or error("must pass list_entry",    2)
    guess_word    = t.guess_word   or error("must pass guess_word",    2)
    make_word     = t.make_word    or error("must pass make_word",     2)
    game_history  = t.game_history or error("must pass game_history",  2)
    swing_sign    = t.swing_sign   or error("must pass swing_sign",    2)
    ls            = t.ls           or error("must pass ls",            2)
    
    
    self:add(  Clone{source=t.img_srcs.their_move_bg, x = 319, y= 675}  )
    self:add(  Clone{source=t.img_srcs.my_move_bg,    x = 729, y= 675}  )
    
    self:add( Text{
        text = "Their Move",
        font = g_font.." 42px",
        color = {0,0,0},
        w     = t.img_srcs.their_move_bg.w,
        alignment = "CENTER",
        wrap = true,
        x     = 319-2,
        y     = 720-2,
    }, Text{
        text = "Their Move",
        font = g_font.." 42px",
        color = "b7b7b7",
        w     = t.img_srcs.their_move_bg.w,
        alignment = "CENTER",
        wrap = true,
        x     = 319,
        y     = 720,
    })
    self:add( Text{
        text = "My Move",
        font = g_font.." bold 42px",
        color = {0,0,0},
        w     = t.img_srcs.their_move_bg.w,
        alignment = "CENTER",
        wrap = true,
        x     = 729-2,
        y     = 720-2,
    }, Text{
        text = "My Move",
        font = g_font.." bold 42px",
        color = "b7b7b7",
        w     = t.img_srcs.their_move_bg.w,
        alignment = "CENTER",
        wrap = true,
        x     = 729,
        y     = 720,
    })
    --Components
    their_turn_list = t.clipped_list:make{
        x = 319,
        y = 780,
        w = 350,
        h = 270,
        empty_string = "No Active Sessions",
        name = "'Their Turn'",
        on_focus = function(entry)
            
            if entry == nil then
                
                return false
                
            else
                
                swing_sign:new_text(entry:status())
                
                return true
                
            end
            
        end
    }
    my_turn_list    = t.clipped_list:make{
        x = 728,
        y = 780,
        w = 351,
        h = 300,
        empty_string = "No Active Sessions",
        name = "'My Turn'",
        on_focus = function(entry)
            
            if entry == nil then
                
                return false
                
            else
                
                swing_sign:new_text(entry:status())
                
                return true
                
            end
            
        end
    }
    side_buttons    = t.side_buttons:make{
        on_focus = function() swing_sign:new_text(false) end,
        x = 1120, y = 784, spacing = 874-784-66, buttons = {
            {name = "New Game", color = "r", select = function()
                    
                    print("New Game")
                    
                    status.text = "Searching for Games"
                    
                    game_server:get_a_wild_card_invite(
                        function(match_id)
                            print("Called back from game_server:get_a_wild_card_invite(), result is:",match_id)
                            status.stop = true
                            if match_id == nil then -- TODO, find what would be passed
                                
                                make_word:set_session(game_state:make())
                                
                                app_state.state = "MAKE_WORD"
                                
                            else
                                game_server:accept_invite(match_id, 
                                
                                    function(t)
                                        
                                        print("Making GameState from accepted invite: ", match_id)
                                        t = game_state:make(t)
                                        
                                        game_server:update(t,function()
                                            --dumptable(t:get_data())
                                            
                                            guess_word:reset()
                                            guess_word:guess_word(t)
                                            ls:reset()
                                            
                                            t = list_entry:make(t)
                                            --my_turn_list:add_entry(t, false)
                                            
                                            app_state.state = "GUESS_WORD"
                                        end)
                                        
                                    end
                                )
                                --[[
                                game_server:accept_invite(t.id,function() end)
                                
                                local f = function(t)
                                    
                                    t = game_state:make(t)
                                    
                                    game_server:update(t,function()
                                        --dumptable(t:get_data())
                                        
                                        guess_word:reset()
                                        guess_word:guess_word(t)
                                        ls:reset()
                                        
                                        t = list_entry:make(t)
                                        --my_turn_list:add_entry(t, false)
                                        
                                        app_state.state = "GUESS_WORD"
                                    end)
                                    
                                end
                                
                                if t.state == json.null or t.state == nil then
                                    
                                    game_server:get_session_state(t.gameSessionId,f)
                                    
                                else
                                    
                                    f(t)
                                    
                                end
                                --]]
                            end
                            
                        end
                    )
                end
            },
            {name = "Log Out",  color = "g", select = function()
                    
                    game_state.check_server:stop()
                    
                    game_server:update_game_history(function()
                        app_state.state   = "LOADING"
                    end)
                    
                    g_user.name = ""
                    
                    self:reset()
                    
                    settings.username = nil
                    settings.password = nil
                    screen:grab_key_focus()
                    
                end
            },
            {name = "Quit",     color = "b", select = function()
                screen:grab_key_focus()
                game_server:update_game_history(function()
                    print("updated")
                    exit()
                end)
            end},
        }
    }
    
    list_of_lists = t.make_list{
        orientation = "HORIZONTAL",
        elements = { their_turn_list, my_turn_list, side_buttons},
        display_passive_focus = false,
        resets_focus_to = 3,
    }
    
    --list_of_lists:define_key_event(keys.RED,    side_buttons.buttons[1].select)
    --list_of_lists:define_key_event(keys.GREEN,  side_buttons.buttons[2].select)
    --list_of_lists:define_key_event(keys.BLUE,   side_buttons.buttons[3].select)
    
    status = Text{
        x            = screen_w - 50,
        y            = screen_h - 50,
        w            = 400,
        font         = g_font .. " 40px",
        color        = "ffffff",
        ellipsize    = "END",
        alignment    = "RIGHT",
        on_text_changed = function(self)
            
            self.w = -1
            
            if self.w > 500 then self.w = 500 end
            
            status.anchor_point = { status.w, status.h/2 }
            status.position = {screen_w - 50,screen_h - 50}
            status:move_anchor_point( status.w/2, status.h/2 )
        end
    }
    status:move_anchor_point( status.w, status.h/2 )
    
    local scale_t = {}
    status.wobble = Timeline{
        duration     = 1000,
        loop         = true,
        on_new_frame = function(tl,ms,p)
            
            scale_t[1] = 1-.05*math.sin(math.pi*2*p)
            scale_t[2] = 1+.05*math.sin(math.pi*2*p)
            
            status.scale = scale_t
            
        end,
        on_started = function()
            
            status.stop = false
            
        end,
        on_completed = function()
            
            if status.stop then
                
                print("stop wobbling")
                
                status.wobble:stop()
                
            end
            
        end
    }
    
    win_loss_text = Text{
        x              = screen.w/2,
        y              = 80,
        font           = g_font .. " bold 40px",
        color          = "ffffff",
        on_text_changed = function(self)
            
            self.anchor_point = {self.w/2,self.h/2}
            
        end,
    }
    
    entry_info = Text{
        x              = 825,
        y              = 650,
        font           = g_font .. " 40px",
        color          = "ffffff",
        on_text_changed = function(self)
            print(self.text)
            self.anchor_point = {self.w/2,self.h/2}
            
        end,
    }
    
    self:add(status,win_loss_text,entry_info,list_of_lists)
    
end


do
    
    local wins   = {}
    local losses = {}
    
    local  win_text = "You've won against: "
    local lose_text = "You've lost against: "
    
    local animating = false
    
    local function setup_win_text()
        
        local text = ""
        
        animating = true
        
        if #wins ~= 0 then text = text..win_text end
        
        for i = 1, #wins do
            if i == #wins then
                text = text..wins[i]
            elseif i == 3 then
                text = text.. ((#wins-i) == 1 and "and 1 other." or "and "..(#wins-i).." others.")
                break
            else
                text = text..wins[i]..", "
            end
        end
        
        return text
    end
    
    local function setup_lose_text()
        
        local text = ""
        
        animating = true
        
        if #losses ~= 0 then text = text..lose_text end
        
        for i = 1, #losses do
            if i == #losses then
                text = text..losses[i]
            elseif i == 3 then
                text = text.. ((#losses-i) == 1 and "and 1 other." or "and "..(#losses-i).." others.")
                break
            else
                text = text..losses[i]..", "
            end
        end
        
        return text
    end
    local wl_tl = Timeline{
        duration = 10000,
        mode         = "EASE_IN_QUINT",
        on_new_frame = function(tl,ms,p)
            win_loss_text.opacity = 255*(1-p)
        end,
        on_completed = function(self)
            if #wins ~= 0 or #losses ~= 0 then
                
                win_loss_text.text    = setup_text()
                win_loss_text.opacity = 255
                
                wins   = {}
                losses = {}
                
                self:start()
                
            else
                animating = false
            end
        end
    }
    
    function self:add_win(name)
        table.insert(   wins,  name   )
    end
    
    function self:add_loss(name)
        table.insert(   losses,  name   )
    end
    
    
    function self:report_win_loss()
        
        if not swing_sign:holding() then
            
            --wl_tl:on_completed()
            swing_sign:new_text(setup_win_text(),6000)
            swing_sign:new_text(setup_lose_text(),6000)
            
            wins   = {}
            losses = {}
            
        end
        
    end
    
end

--called from list_entry's
function self:won_against(entry)
    
    their_turn_list:remove_entry(entry,function()
        
        local session = entry:get_session()
        
        if not session.i_counted_score then
        
            session.i_counted_score = true
            
            game_server:update(
                
                session,  function(t)
                    
                    g_user.wins = g_user.wins + 1
                    
                    if g_user.wins > 9999 then g_user.wins = 9999 end
                    
                    game_history:set_wins( g_user.wins )
                    
                end
            )
            
        end
        
        self:add_win(session.opponent_name)
        
    end)

    
end

function self:lost_against(entry)
    
    my_turn_list:remove_entry( entry, function()
        
        local session = entry:get_session()
        
        if not session.i_counted_score then
        
            session.i_counted_score = true
            
            game_server:update(
                
                session,  function(t)
                    
                    g_user.losses = g_user.losses + 1
                    
                    if g_user.losses > 9999 then g_user.losses = 9999 end
                    
                    game_history:set_losses( g_user.losses )
                    
                end
            )
            
        end
        
        self:add_loss(session.opponent_name)
        
    end)
    
end

function self:move_to_my_turn(entry)
    
    print("move to my turn")
    
    their_turn_list:remove_entry(entry,function()
        
        my_turn_list:add_entry(entry)
        
    end)
    
end

function self:move_to_their_turn(entry)
    
    print("move to their turn")
    
    my_turn_list:remove_entry(entry,function()
        
        their_turn_list:add_entry(entry)
        
    end)
    
end

function self:add_entry(sesh)
    print("gahhhhhhhh")
    sesh = list_entry:make(sesh)
    
end

function self:reset()
    
    loaded = false
    
    my_turn_list:reset()
    their_turn_list:reset()
    
end

function self:setup_lists()
    print("FrontPage:setup_lists(). Getting list of sessions...")
    status.text = "Logging in"
    status.wobble:start()
    
    game_server:get_list_of_sessions(function(sessions)
        print("got list of sessions")
        --game_state.check_server:start()
        
        
        status.stop = true
        
        loaded = true
        
        self:gain_focus()
        --[[
        if # sessions == 0 then
            print("no sessions")
            
            
        else
            --]]
            for i,sesh in pairs(sessions) do
                
                --make a session object
                sesh = game_state:make(sesh)
                
                print("make sesh",sesh.i_counted_score,sesh.opponent_counted_score)
                
                if sesh.i_counted_score then
                    
                    print("I already marked a win/loss for this session, deleting")
                    
                    sesh:delete()
                    
                elseif sesh.opponent_counted_score then
                    print("My opponent marked a win/loss for this session, I should do the same")
                    --[[
                    game_server:end_session(sesh,function()
                        print("sesh "..sesh.match_id.." terminated")
                        sesh:delete()
                    end)
                    --]]
                    
                    if sesh.opponent_score == 3 then
                        self:add_win(sesh.opponent_name)
                        
                        sesh.i_counted_score = true
                        
                        game_server:update(
                            
                            sesh,  function(t)
                                
                                g_user.wins = g_user.wins + 1
                                
                                if g_user.wins > 9999 then g_user.wins = 9999 end
                                
                                game_history:set_wins( g_user.wins )
                                
                            end
                        )
                        
                        
                    else
                    
                        sesh.i_counted_score = true
                        
                        game_server:update(
                            
                            sesh,  function(t)
                                
                                g_user.losses = g_user.losses + 1
                                
                                if g_user.losses > 9999 then g_user.losses = 9999 end
                                
                                game_history:set_losses( g_user.losses )
                                
                            end
                        )
                    
                    
                    
                        self:add_loss(sesh.opponent_name)
                        g_user.losses = g_user.losses + 1
                        game_history:set_losses( g_user.losses )
                    end
                    
                else
                    
                    sesh = list_entry:make(sesh)
                    
                end
                
            end
            
        --end
        
        --game_history:set_wins(   g_user.wins   )
        --game_history:set_losses( g_user.losses )
        game_state.check_server:on_timer()
    end)
    
end

function self:gain_focus(t)
    
    if not loaded then return end
    
    list_of_lists:set_state("FOCUSED")
    
    status.text = "Logged in as "..g_user.name
    
end

return self
