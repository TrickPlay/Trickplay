
local keybd_bgs      = {}
local keybd_letters  = {}
local letter_scores  = {}
local right_side_txt = {}


local controller = Group{ name = "Make Word", x = 490, y = 700, }

local img_srcs,
    main_menu_list,
    letter_values,
    word_count_n,
    word_count_t,
    get_letters,
    make_button,
    game_server,
    check_word,
    make_list,
    session,
    list,
    mesg,
    ls,
    sk

local letter_slot_i = 1

function controller:init(t)
    
    if type(t) ~= "table" then error("must pass a table as the parameter", 2) end
    
    img_srcs       = t.img_srcs       or error("must pass img_srcs",       2)
    get_letters    = t.get_letters    or error("must pass get_letters",    2)
    letter_values  = t.letter_values  or error("must pass letter_values",  2)
    make_button    = t.make_button    or error("must pass make_button",    2)
    make_list      = t.make_list      or error("must pass make_list",      2)
    game_server    = t.game_server    or error("must pass img_srcs",       2)
    ls             = t.letter_slots   or error("must pass letter_slots",   2)
    check_word     = t.check_word     or error("must pass check_word",     2)
    guess_word     = t.guess_word     or error("must pass guess_word",     2)
    main_menu      = t.main_menu      or error("must pass main_menu",      2)
    sk             = t.sk             or error("must pass sk",             2)
    
    
    --Key board
    for i = 1, (t.num_letters or error("must pass num_letters",2)) do
        
        keybd_bgs[i] =make_button{
            clone           = true,
            unfocus_fades   = false,
            unfocused_image = img_srcs.keybd_off,
            focused_image   = img_srcs.keybd_on,
            select_function = function()
                
                if letter_slot_i > ls:num_slots() then return end
                
                if keybd_letters[i].used then return end
                
                right_side_txt[1].color = "ffffff"
                
                ls:put_letter( keybd_letters[i].text, letter_slot_i )
                
                word_count_n = word_count_n + letter_values[keybd_letters[i].text]
                
                word_count_t.text = "Word Count: "..word_count_n
                
                keybd_letters[i].used  = true
                keybd_letters[i].color = "000000"
                
                letter_slot_i = letter_slot_i + 1
                
            end,
        }
        keybd_bgs[i]:set{
            anchor_point = {
                img_srcs.keybd_off.w/2,
                img_srcs.keybd_off.h/2
            },
            x = img_srcs.keybd_off.w/2  +  (5 + img_srcs.keybd_off.w)*(i-1),
            y = 310,
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
            text  = "",
            position = keybd_bgs[i].position,
        }
        keybd_letters[i].used = false
        
        letter_scores[i] = Text{
            color = "888888",
            font  = (t.font or error("must pass font",2)) .. " 30px",
            text  = "",
            x     = keybd_bgs[i].x,
            y     = keybd_bgs[i].y+50,
        }
        
    end
    
    mesg = Text{
        font  = t.font.." 30px",
        text  = "Create a word for the other player to guess",
        color = "999999",
        x     = (5 + img_srcs.keybd_off.w)*(t.num_letters/2),
        y     = 20,
    }
    mesg.anchor_point = {mesg.w/2,0}
    
    
    word_count_n = 0
    
    word_count_t = Text{
        text = "Word Count: "..word_count_n,
        color = "999999",
        font  = t.font.." 30px",
        x     = -400,
        y     = 20,
    }
    
    
    
    
    
    local right_side_bar = {}
    right_side_bar[1] =make_button{
        clone           = true,
        unfocus_fades   = false,
        select_function = function()
            
            print("play word")
            local s = string.lower(ls:get_word())
            
            if s:len() == 0 then return end
            
            if check_word(s) then
                
                session.word = s
                
                session:opponents_turn()
                
                session:toggle_phase()
                
                session:remove_view(sk)
                
                controller:change_message("Sending...")
                
                list:set_state("UNFOCUSED")
                
                if session.opponent_name == false then
                    
                    main_menu:add_entry(session,"MAKE_A_WORD")
                    
                    game_server:launch_wildcard_session(session,function(id)
                        
                        print("got id back")
                        
                        app_state.state = "MAIN_PAGE"
                        
                        session.id = id
                        session = nil
                        
                    end)
                    
                else
                    
                    session:update_views()
                    
                    game_server:respond(session,function()
                        app_state.state = "MAIN_PAGE"
                        session = nil
                        
                        
                    end)
                    
                    
                end
                
            else
                
                controller:change_message(s:upper().." is not in the dictionary. Please try something else.")
                
            end
            
        end,
        unfocused_image = img_srcs.button_r,
        focused_image   = img_srcs.button_f,
    }
    right_side_bar[1].x = keybd_bgs[#keybd_bgs].x+480
    right_side_bar[1].y = 0
    right_side_txt[1] = Text{
        color = "ffffff",
        text  = "Play Word",
        font  = t.font .. " Bold 28px",
        x     = right_side_bar[1].x+30,
        y     = right_side_bar[1].y+15,
    }
    
    right_side_bar[2] =make_button{
        clone           = true,
        unfocus_fades   = false,
        select_function = function()     
            print("reset")
            right_side_txt[1].color = "000000"
            for i,l in pairs(keybd_letters) do
                
                l.color = "ffffff"
                l.used  = false
                
            end
            
            letter_slot_i = 1
            word_count_n = 0
            
            word_count_t.text = "Word Count: "..word_count_n
            ls:reset()
            
        end,
        unfocused_image = img_srcs.button_g,
        focused_image   = img_srcs.button_f,
    }
    right_side_bar[2].x = right_side_bar[1].x
    right_side_bar[2].y = right_side_bar[1].y + img_srcs.button_f.h + 20
    right_side_txt[2] = Text{
        color = "ffffff",
        text  = "Reset",
        font  = t.font .. " Bold 28px",
        x     = right_side_bar[2].x+30,
        y     = right_side_bar[2].y+15,
    }
    
    right_side_bar[3] =make_button{
        clone           = true,
        unfocus_fades   = false,
        select_function = function()
            print("Main Menu")
            list:set_state("UNFOCUSED")
            screen:grab_key_focus()
            session:remove_view(sk)
            session:update_views()
            session = nil
            app_state.state = "MAIN_PAGE"
        end,
        unfocused_image = img_srcs.button_y,
        focused_image   = img_srcs.button_f,
    }
    right_side_bar[3].x = right_side_bar[1].x
    right_side_bar[3].y = right_side_bar[2].y + img_srcs.button_f.h + 20
    right_side_txt[3] = Text{
        color = "ffffff",
        text  = "Menu",
        font  = t.font .. " Bold 28px",
        x     = right_side_bar[3].x+30,
        y     = right_side_bar[3].y+15,
    }
    
    right_side_bar[4] =make_button{
        clone           = true,
        unfocus_fades   = false,
        select_function = function()
            
            print("quit")
            screen:grab_key_focus()
                game_server:update_game_history(function()
                    exit()
                end)
            
        end,
        unfocused_image = img_srcs.button_b,
        focused_image   = img_srcs.button_f,
    }
    right_side_bar[4].x = right_side_bar[1].x
    right_side_bar[4].y = right_side_bar[3].y + img_srcs.button_f.h + 20
    right_side_txt[4] = Text{
        color = "ffffff",
        text  = "Quit",
        font  = t.font .. " Bold 28px",
        x     = right_side_bar[4].x+30,
        y     = right_side_bar[4].y+15,
    }
    
    
    local right_side_list = t.make_list{
        orientation = "VERTICAL",
        elements = right_side_bar,
        display_passive_focus = false,
        resets_focus_to = 1,
    }
    
    keybd_bgs[# keybd_bgs + 1] = right_side_list
    
    list = t.make_list{
        orientation = "HORIZONTAL",
        elements = keybd_bgs,
        display_passive_focus = false,
        resets_focus_to = 1,
        wrap = true,
    }
    
    list:define_key_event(keys.RED,    right_side_bar[1].select)
    list:define_key_event(keys.GREEN,  right_side_bar[2].select)
    list:define_key_event(keys.YELLOW, right_side_bar[3].select)
    list:define_key_event(keys.BLUE,   right_side_bar[4].select)
    
    controller:add(--[[word_count_t,--]]list,mesg)
    controller:add(unpack(keybd_letters))
    --controller:add(unpack(letter_scores))
    controller:add(unpack(right_side_txt))
    
end

function controller:change_message(t)
    
    mesg.text = t
    
    mesg.anchor_point = {
        mesg.w/2, 0
    }
    
end
function controller:new_letters()
    
    local letters = get_letters(# keybd_letters)
    
    for i,l in pairs(letters) do
        
        keybd_letters[i].used = false
        
        keybd_letters[i].text  = l
        keybd_letters[i].color = "ffffff"
        
        keybd_letters[i].anchor_point = {
            keybd_letters[i].w/2,
            keybd_letters[i].h/2
        }
        
        letter_scores[i].text = letter_values[l]
        
        letter_scores[i].anchor_point = {
            letter_scores[i].w/2,
            letter_scores[i].h/2
        }
        
    end
    
    letter_slot_i = 1
    
    word_count_n = 0
    
    word_count_t.text = "Word Count: "..word_count_n
    
    controller:change_message("Create a word for "..(session.opponent_name or "the other player").." to guess")
end

function controller:gain_focus(num)
    list:set_state("FOCUSED")
    bg:slide_out_hangman()
end
function controller:set_session(s)
    session = s
    
    if s.opponent_name then
        
        sk:animate{
            duration = 300,
            opacity  = 255,
        }
        
    else
        
        sk:animate{
            duration = 300,
            opacity  = 0,
        }
        
    end
    session:add_view(sk)
    right_side_txt[1].color = "000000"
end

return controller












