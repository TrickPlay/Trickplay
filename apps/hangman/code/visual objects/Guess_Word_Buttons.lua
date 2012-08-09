

local controller = Group{ name = "Guess Word", x = 90, y = 510,  }

local keybd_bgs      = {}
local keybd_letters  = {}
local letter_scores  = {}
local right_side_txt = {}
local chex_n_x_s = {}

local img_srcs,
    get_letters,
    right_side_list,
    num_remaining,
    letter_values,
    win_lose_txt,
    game_server,
    make_button,
    guess_word,
    keybd_list,
    make_list,
    make_word,
    guessing,
    session,
    list,
    mesg,
    ls,
    sb,
    sk

local A = "A"

local function end_guessing()
    list:set_state("UNFOCUSED")
    guessing = false
    session:toggle_phase()
    right_side_list:show_button(1)
    session:clear_letter()
    session:remove_view(sk)
    
    controller:change_message("Saving...")
    right_side_list:blacken_text(2)
    screen:grab_key_focus()
    keybd_list:animate{
        duration = 300,
        opacity  = 0,
        on_completed = function()
            
            keybd_list:hide()
            
        end
    }
    
    for i,o in pairs(chex_n_x_s) do
        o:unparent()
    end
    
    chex_n_x_s = {}
    
    
end

function controller:init(t)
    
    if type(t) ~= "table" then error("must pass a table as the parameter",2) end
    
    img_srcs      = t.img_srcs      or error( "must pass img_srcs",      2 )
    get_letters   = t.get_letters   or error( "must pass get_letters",   2 )
    letter_values = t.letter_values or error( "must pass letter_values", 2 )
    make_button   = t.make_button   or error( "must pass make_button",   2 )
    make_list     = t.make_list     or error( "must pass make_list",     2 )
    make_word     = t.make_word     or error( "must pass make_word",     2 )
    game_server   = t.game_server   or error( "must pass img_srcs",      2 )
    ls            = t.letter_slots  or error( "must pass letter_slots",  2 )
    sb            = t.strike_bar    or error( "must pass strike_bar",    2 )
    sk            = t.sk            or error( "must pass sk",            2 )
    
    
    --Key board
    for i = 1, 26 do
        
        keybd_bgs[i]        = make_button{
            clone           = true,
            unfocus_fades   = false,
            select_function = function() print("entered letter "..keybd_letters[i].text) end,
            unfocused_image = img_srcs.keybd_off,
            focused_image   = img_srcs.keybd_on,
            select_function = function()
                
                local l = keybd_letters[i]
                local t = string.lower(l.text)
                
                session:add_letter(t)
                
                if l.checked or l.x_ed or not guessing then return end
                
                local at_least_one = false
                local i = string.find(guess_word,t)
                
                while( i ~= nil ) do
                    
                    at_least_one = ls:put_letter(string.upper(t),i) or at_least_one
                    
                    num_remaining = num_remaining - 1
                    
                    i = i + 1
                    
                    i = string.find(guess_word,t,i)
                    
                end
                
                if at_least_one then
                    
                    controller:put_check_on_letter(l)
                    
                    if guess_word:upper() == ls:get_word() then
                        
                        end_guessing()
                        
                        game_server:update(session,function()
                            print("updated")
                            controller:change_message("")
                            right_side_list:set_state("FOCUSED")
                        end)
                        
                        
                        list:set_state("UNFOCUSED")
                        
                        win_lose_txt.source = img_srcs.win_round
                        
                        win_lose_txt.anchor_point = {win_lose_txt.w/2,win_lose_txt.h/2}
                        win_lose_txt.scale = {2,2}
                        
                        win_lose_txt:animate{duration = 300, opacity = 255, scale = {1,1}}
                        
                        mediaplayer:play_sound("audio/you-win.mp3")
                        
                        print("you win")
                        
                    end
                    
                else
                    
                    controller:put_x_on_letter(l)
                    
                    if sb:add_strike() then
                        
                        session.my_score = session.my_score + 1
                        
                        if session.my_score == 3 then
                            win_lose_txt.source = img_srcs.lose_match
                        else
                            win_lose_txt.source = img_srcs.lose_round
                        end
                        
                        win_lose_txt.anchor_point = {win_lose_txt.w/2,win_lose_txt.h/2}
                        win_lose_txt.scale = {2,2}
                        
                        win_lose_txt:animate{duration = 300, opacity = 255, scale = {1,1}}
                        
                        session:update_views()
                        
                        end_guessing()
                        
                        game_server:update(session,function()
                            print("updated")
                            controller:change_message("")
                            dolater(bg:killing()+100,function() right_side_list:set_state("FOCUSED") end)
                        end)
                        bg:slide_in_hangman()
                        
                        ls:fill_in(guess_word)
                        
                        mediaplayer:play_sound("audio/you-lose.mp3")
                        
                        print("you lose")
                        --exit()
                    end
                    
                end
                
            end
        }
        keybd_bgs[i]:set{
            anchor_point = {
                img_srcs.keybd_off.w/2,
                img_srcs.keybd_off.h/2
            },
            x = img_srcs.keybd_off.w/2  +  (5 + img_srcs.keybd_off.w)*(i-1),
            y = 500,
        }
        --[[Clone{
            source = img_srcs.keybd_off,
            anchor_point = {
                img_srcs.keybd_off.w/2,
                img_srcs.keybd_off.h/2
            },
            x = img_srcs.keybd_off.w/2 + img_srcs.keybd_off.w*(i-1),
            y = 200,
        }--]]
        
        keybd_letters[i] = Text{
            color = "ffffff",
            font  = (t.font or error("must pass font",2)) .. " bold 40px",
            text  = string.char(A:byte() + i-1),
            position = keybd_bgs[i].position,
        }
        keybd_letters[i].anchor_point = {
            keybd_letters[i].w/2,
            keybd_letters[i].h/2
        }
        
    end
    
    keybd_list = t.make_list{
        orientation = "HORIZONTAL",
        elements = keybd_bgs,
        display_passive_focus = false,
    }
    keybd_list:add(unpack(keybd_letters))
    
    
    
    
    
    
    mesg = Text{
        font    = t.font.." 30px",
        text    = "",
        color   = "999999",
        x       = 862,
        y       = 222,
    }
    
    win_lose_txt = Clone{
        x = mesg.x,
        y = -370,
        opacity = 0
    }
    
    right_side_list = t.side_buttons:make{
        resets_focus_to = 1, resets_focus_secondary = 2,
        x = keybd_bgs[#keybd_bgs].x+82, y = 192, spacing = 874-784-66, buttons = {
            {name = "Continue", select = function()
                
                --if not right_side_bar[1].is_visible then return end
                print("continue")
                ls:light_down()
                make_word:set_session(session)
                
                if session.my_score == 3 then
                    
                    session.viewing = false
                    
                    screen:grab_key_focus()
                    
                    controller:change_message("Ending Session...")
                    
                    game_server:end_session(
                        session,
                        function(t)
                            
                            print("Session Ended. Leaving....")
                            
                            game_server:leave_match(
                                session,
                                function(t)
                                    print("left")
                                    session = nil
                                    controller:change_message("")
                                    print("successfully updated")
                                    
                                    app_state.state = "MAIN_PAGE"
                                end
                            )
                        end
                    )
                    
                else
                    app_state.state = "MAKE_WORD"
                    session = nil
                end
                bg:fade_out_vic()
                bg:slide_out_hangman()
            end},
            {name = "Give Up", select = function()
                
                if not guessing then return end
                
                session.my_score = session.my_score + 1
                
                if session.my_score == 3 then
                    win_lose_txt.source = img_srcs.lose_match
                else
                    win_lose_txt.source = img_srcs.lose_round
                end
                
                win_lose_txt.anchor_point = {win_lose_txt.w/2,win_lose_txt.h/2}
                win_lose_txt.scale = {2,2}
                
                win_lose_txt:animate{duration = 300, opacity = 255, scale = {1,1}}
                
                session:update_views()
                
                end_guessing()
                game_server:update(session,function()
                    print("updated")
                    controller:change_message("")
                    dolater(bg:killing()+100,function() right_side_list:set_state("FOCUSED") end)
                end)
                bg:fill_in_victim()
                bg:slide_in_hangman()
                
                ls:fill_in(guess_word)
                
                
                print("give up")
                
            end},
            {name = "Menu", select = function()
                print("Menu")
                
                list:set_state("UNFOCUSED")
                screen:grab_key_focus()
                session:remove_view(sk)
                session:update_views()
                session.viewing = false
                
                bg:fade_out_vic()
                
                controller:change_message("Saving...")
                
                
                if session.my_score == 3 then
                    
                    
                    controller:change_message("Ending Session...")
                    
                    game_server:end_session(
                        session,
                        function(t)
                            
                            print("Session Ended. Leaving....")
                            
                            game_server:leave_match(
                                session,
                                function(t)
                                    print("left")
                                    session = nil
                                    controller:change_message("")
                                    print("successfully updated")
                                    
                                    app_state.state = "MAIN_PAGE"
                                end
                            )
                        end
                    )
                    
                else
                    
                    game_server:update(
                        session,
                        function(t)
                            session = nil
                            controller:change_message("")
                            print("successfully updated")
                            if not guessing then 
                                
                                bg:slide_out_hangman()
                                
                            end
                            
                            app_state.state = "MAIN_PAGE"
                        end
                    )
                    
                end
            end},
            {name = "Quit", select = function()
                list:set_state("UNFOCUSED")
                screen:grab_key_focus()
                controller:change_message("Saving...")
                session.viewing = false
                game_server:update(
                    session,
                    function(t)
                        game_server:update_game_history(function()
                            exit()
                            
                            print("successfully updated")
                        end)
                        
                    end
                )
            end},
        }
    } 
    
    
    list = t.make_list{
        orientation = "HORIZONTAL",
        elements = {keybd_list, right_side_list},
        display_passive_focus = false,
        resets_focus_to = 1,
        wrap = true,
    }
    
    keybd_list:define_key_event(keys.Up, function() list:on_key_down(keys.Right) end )
    
    function controller:hide_continue()
        right_side_list:hide_button(1)
    end
    
    --list:define_key_event(keys.RED,    right_side_bar[1].select)
    --list:define_key_event(keys.GREEN,  right_side_bar[2].select)
    --list:define_key_event(keys.YELLOW, right_side_bar[3].select)
    --list:define_key_event(keys.BLUE,   right_side_bar[4].select)
    
    controller:add(list,mesg,win_lose_txt)
    controller:add(unpack(letter_scores))
    
end

function controller:reset()
    
    for i,o in pairs(chex_n_x_s) do
        o:unparent()
    end
    
    chex_n_x_s = {}
    
    for i,l in pairs(keybd_letters) do
        
        l.checked = false
        l.x_ed    = false
        
    end
    
    guess_word    = nil
    num_remaining = nil
end

function controller:guess_word(s)
    
    session = s
    
    session.viewing = true
    
    game_server:update(session,function() print("Updated server - Guess Word Vieiwing session") end)
    
    session:add_view(sk)
    
    guess_word = session.word
    
    
    num_remaining = guess_word:len()
    
end

function controller:change_message(t)
    
    mesg.text = t
    
end

function controller:put_check_on_letter(l)
    
    --local i = l:byte() - A:byte() + 1
    
    chex_n_x_s[# chex_n_x_s + 1] = Clone{
        source       = img_srcs.check,
        x            = l.x + 15,
        y            = l.y - 25,
        anchor_point = {img_srcs.check.w/2,img_srcs.check.h/2},
    }
    
    l.checked = true
    
    controller:add(chex_n_x_s[# chex_n_x_s])
    
end

function controller:put_x_on_letter(l)
    
    --local i = l:byte() - A:byte() + 1
    
    chex_n_x_s[# chex_n_x_s + 1] = Clone{
        source       = img_srcs.x,
        x            = l.x + 15,
        y            = l.y - 25,
        anchor_point = {img_srcs.x.w/2,img_srcs.x.h/2},
    }
    
    l.x_ed = true
    
    controller:add(chex_n_x_s[# chex_n_x_s])
    
end

function controller:get_gain_focus()
    
    return function()
        
        --focus in the keyboard
        list:set_state("FOCUSED")
        
    end
    
end

function controller:gain_focus()
    
    right_side_list:hide_button(1)
    
    sb:num_strikes(0)
    
    guessing = true
    
    local i,l
    
    --find the last vowel in the word
    i,_,l = guess_word:lower():find( "([aeiouy])[^aeiouy]-$" )
    
    --give that hint to the user
    ls:put_letter(l:upper(),i)
    
    local letters = session.letters
    
    for i = 1,#letters do
        local l = letters[i]
    --for i,l in ipairs(letters) do
        print(i,l,l:upper():byte() - A:byte()+1)
        keybd_bgs[l:upper():byte() - A:byte()+1]:select()
        
    end
    ls:light_up(# guess_word)
    bg:reset()
    screen:grab_key_focus()
    
    keybd_list:show()
    keybd_list.opacity = 255
    
    win_lose_txt.opacity = 0
    right_side_list:whiten_text(2)
end


return controller












