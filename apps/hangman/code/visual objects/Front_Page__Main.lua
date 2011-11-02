local self = Group{}

local my_turn_list, their_turn_list, list_of_lists, status, report_win_loss, entry_info
local list_entry, game_state,guess_word,make_word, ls, game_history

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
    ls            = t.ls           or error("must pass ls",            2)
    
    
    self:add(  t.make_frame(400,750,400,275)  )
    self:add(  t.make_frame(850,750,400,275)  )
    
    self:add( Text{
        text = "Their Move",
        font = g_font .. " bold 35px",
        color = "ffffff",
        x     = 515,
        y     = 700,
    })
    self:add( Text{
        text = "My Move",
        font = g_font .. " bold 35px",
        color = "ffffff",
        x     = 980,
        y     = 700,
    })
    --Components
    their_turn_list = t.clipped_list:make{x = 400+2, y = 750+2, w = 400-4, h = 275-4, empty_string = "No Active Sessions", name = "'Their Turn'", on_focus = function(entry) entry_info.text = entry:status() end}
    my_turn_list    = t.clipped_list:make{x = 850+2, y = 750+2, w = 400-4, h = 275-4, empty_string = "No Active Sessions", name = "'My Turn'",    on_focus = function(entry) entry_info.text = entry:status() end}
    side_buttons    = t.side_buttons:make{
        on_focus = function() entry_info.text = "" end,
        x = 1300, y = 750, spacing = 20, buttons = {
            {name = "New Game", color = "r", select = function()
                    
                    print("New Game")
                    
                    status.text = "Searching for Games"
                    
                    game_server:get_a_wild_card_invite(
                        function(t)
                            dumptable(t)
                            status.stop = true
                            if # t.invitations == 0 then
                                
                                make_word:set_session(game_state:make())
                                
                                app_state.state = "MAKE_WORD"
                                
                            else
                                
                                t = t.invitations[1]
                                
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
                                    
                                    game_server:get_session_state(t,f)
                                    
                                else
                                    
                                    f(t)
                                    
                                end
                                
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
                    
                    g_user.name        = nil
                    
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
    
    list_of_lists:define_key_event(keys.RED,    side_buttons.buttons[1].select)
    list_of_lists:define_key_event(keys.GREEN,  side_buttons.buttons[2].select)
    list_of_lists:define_key_event(keys.BLUE,   side_buttons.buttons[3].select)
    
    status = Text{
        x            = screen_w - 50,
        y            = screen_h - 50,
        w            = 300,
        font         = g_font .. " 40px",
        color        = "ffffff",
        ellipsize    = "END",
        alignment    = "RIGHT",
        anchor_point = {300,40},
    }
    status:move_anchor_point( status.w/2, status.h/2 )
    
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
    
    report_win_loss = Text{
        x              = screen.w/2,
        y              = 80,
        font           = g_font .. " 40px",
        color          = "ffffff",
        on_text_change = function(self)
            
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
    
    self:add(status,report_win_loss,entry_info,list_of_lists)
    
end

--called from list_entry's
function self:won_against(entry)
    
    their_turn_list:remove_entry(entry,function()
        print("winner")
        g_user.wins = g_user.wins + 1
        
        game_history:set_wins( g_user.wins )
        
    end)
    
end

function self:lost_against(entry)
    
    my_turn_list:remove_entry(entry,function()
        print("loser",g_user.losses)
        g_user.losses = g_user.losses + 1
        print("loser",g_user.losses)
        
        game_history:set_losses( g_user.losses )
        
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
    print(333)
    status.text = "Logging in"
    status.wobble:start()
    
    game_server:get_list_of_sessions(function(sessions)
        
        game_state.check_server:start()
        
        status.stop = true
        
        loaded = true
        
        self:gain_focus()
        
        if # sessions == 0 then
            
            
            
        else
            
            for i,sesh in pairs(sessions) do
                
                --make a session object
                sesh = game_state:make(sesh.gameState)
                print("make sesh",sesh.i_counted_score,sesh.opponent_counted_score)
                if sesh.opponent_counted_score then
                    print("weeeeeeeee")
                    game_server:end_session(sesh,function()
                        print("sesh "..sesh.id.." terminated")
                        sesh:delete()
                    end)
                    
                    if not sesh.i_counted_score then
                        
                        sesh.i_counted_score = true
                        
                        if sesh.opponent_score == 3 then
                            g_user.wins = g_user.wins + 1
                            game_history:set_wins( g_user.wins )
                        else
                            g_user.losses = g_user.losses + 1
                            game_history:set_wins( g_user.losses )
                        end
                    end
                    
                elseif not sesh.i_counted_score then
                    
                    sesh = list_entry:make(sesh)
                    
                end
                
            end
            
        end
        
        game_history:set_wins(   g_user.wins   )
        game_history:set_losses( g_user.losses )
        
    end)
    
end

function self:gain_focus(t)
    
    if not loaded then return end
    
    list_of_lists:set_state("FOCUSED")
    
    status.text = "Logged in as "..g_user.name
    
end

return self