screen_w = screen.w
screen_h = screen.h

screen:show()

assets_path = "assets/"
audio_path  = "audio/"
code_path   = "code/"

APP_STATE_MAIN_PAGE = "MAIN_PAGE"
APP_STATE_LOADING = "LOADING"
APP_STATE_LOADING_NO_SPLASH = "LOADING_NO_SPLASH"
APP_STATE_GUESS_WORD = "GUESS_WORD"
APP_STATE_MAKE_WORD = "MAKE_WORD"
APP_STATE_MAKE_PAGE = "MAKE_PAGE"

hangman_game_config = function()
    return {
		app_id = {name = app.id, version = 1 },
        name = app.id,
        description = app.name,
        category = "word games",
        turn_policy = "roundrobin",
        game_type = "correspondence",
        join_after_start = true,
        min_players_for_start = 1,
        max_duration_per_turn = 2*60*1000,  -- only applicable for online  game_type
        abort_when_player_leaves = true, -- only applicable for online game_type
        roles = {
        		{ name = "p1" },
        		{ name = "p2", cannot_start = true }
        }
        
    }
end

function main()
    
    local font = "FreeSans"
    
    g_font     = "IM FELL English SC"
    app_state  = nil
    
    do
        
        local wins, losses
        local local_t = {
            wins   = 0,
            losses = 0
        }
        g_user = {
            name   = "",
            id     = false,
        }
        
        g_user = setmetatable(
            g_user,
            {
                __index = function(t,k)
                    return local_t[k]
                end,
                __newindex = function(t,k,v)
                    dumptable(g_user)
                    if local_t[k] then
                        
                        local_t[k] = v > 9999 and 9999 or v
                        
                    end
                    
                end,
            }
        )
    end
    
    
    ----------------------------------------------------------------------------
    -- Generic functions                                                      --
    ----------------------------------------------------------------------------
    local function make_frame(x,y,w,h)
        
        if not (x and y and w and h) then error("invalid args",2) end
        
        local c = Canvas( w, h )
        c:set_source_color( "#ffffffff" )
        c.line_width = 2
        c:round_rectangle( 1, 1, w-2, h-2, 8 )
        c:stroke()
        c = c:Image()
        c.x = x
        c.y = y
        return c
    end
    
    ----------------------------------------------------------------------------
    -- Clone Sources                                                          --
    ----------------------------------------------------------------------------
    local clone_srcs = Group{ name = "Clone Sources"}
    
    screen:add(clone_srcs)
    
    clone_srcs:hide()
    
    --there are more image declarations in "/code/visual ojects/Background.lua"
    -- each of those images are only used once, so they are left out of this Clone.source table
    local img_srcs = {
        
        --Menus
        keybd_off = Image{ src = assets_path .. "make or guess word/keyboard-button.png"},
        keybd_on  = Image{ src = assets_path .. "make or guess word/keyboard-button-focus.png"},
        
        button_r = Image{ src = assets_path .. "general_menu/button-red.png"},
        button_g = Image{ src = assets_path .. "general_menu/button-green.png"},
        button_y = Image{ src = assets_path .. "general_menu/button-yellow.png"},
        button_b = Image{ src = assets_path .. "general_menu/button-blue.png"},
        button_f = Image{ src = assets_path .. "general_menu/button-focus.png"},
        button = {
            Image{ src = assets_path .. "general_menu/button1.png"},
            Image{ src = assets_path .. "general_menu/button2.png"},
            Image{ src = assets_path .. "general_menu/button3.png"},
        },
        
        mm_focus  = Image{ src = assets_path .. "general_menu/focus-list.png"},
        
        --Main Menu
        game_hist_bg  = Image{ src = assets_path.. "main menu/grave-score.png"      },
        my_move_bg    = Image{ src = assets_path.. "main menu/grave-your-move.png"  },
        their_move_bg = Image{ src = assets_path.. "main menu/grave-their-move.png" },
        hr            = Image{ src = assets_path.. "main menu/grave-hr.png"         },
        sign          = Image{ src = assets_path.. "main menu/sign.png"             },
        
        --Guess a Word
        check      = Image{ src = assets_path .. "make or guess word/checkmark.png"},
        x          = Image{ src = assets_path .. "make or guess word/x.png"},
        lose_match = Image{ src = assets_path .. "alerts/alert-you-lose-match.png"},
        lose_round = Image{ src = assets_path .. "alerts/alert-you-lose-round.png"},
        win_match  = Image{ src = assets_path .. "alerts/alert-you-win-match.png"},
        win_round  = Image{ src = assets_path .. "alerts/alert-you-win-round.png"},
        
        --Letter Slots
        letter_bg_off = Image{ src = assets_path .. "make or guess word/letter-well-off.png"},
        letter_bg_on  = Image{ src = assets_path .. "make or guess word/letter-well-on.png"},
        q_mark        = Image{ src = assets_path .. "make or guess word/qmark.png"},
        
        --Score Keeper
        x_on       = Image{ src = assets_path .. "score_keeper/X-on.png" },
        x_off      = Image{ src = assets_path .. "score_keeper/X-off.png" },
        player_box = Image{ src = assets_path .. "score_keeper/player-name-off.png"},
        vs         = Image{ src = assets_path .. "score_keeper/vs.png" },
        
        --Strike Bar
        strike_off  = Image{ src = assets_path .. "make or guess word/strike-off.png" },
        strike_on   = Image{ src = assets_path .. "make or guess word/strike-on.png"  },
        strikes_txt = Image{ src = assets_path .. "make or guess word/strikes.png"    },
    }
    
    for k,v in pairs(img_srcs) do
        
        if type(v) == "table" then
            
            for kk,vv in pairs(v) do clone_srcs:add(vv) end
            
        else  clone_srcs:add(v) end
        
    end
    
    ----------------------------------------------------------------------------
    -- DoFiles                                                                --
    ----------------------------------------------------------------------------
    
    
    -- 'libraries'
    make_button  = dofile( code_path .. "visual objects/Button.lua"             )
    make_list    = dofile( code_path .. "visual objects/Visual_List_Object.lua" )
    Clipped_List = dofile( code_path .. "visual objects/Clipped_List.lua"       )
    Side_Buttons = dofile( code_path .. "visual objects/Side_Color_Buttons.lua" )
    
    -- server interface components
    -------------------------------------
    Game_State = dofile( code_path .. "gameplay objects/Gamplay_State.lua"   )
    gsm        = dofile( code_path .. "interfaces/Game_Server_Manager.lua"   )
    
    -- 'in game' visual components
    -------------------------------------
    --    sub-components
    Letter_Slots       = dofile( code_path .. "visual objects/Letter_Slots.lua"        )
    Strike_Bar         = dofile( code_path .. "visual objects/Strike_Bar.lua"          )
    Score_Keeper       = dofile( code_path .. "visual objects/Score_Keeper.lua"        )
    --    main pieces
    Guess_Word_Buttons = dofile( code_path .. "visual objects/Guess_Word_Buttons.lua"  )
    Make_Word_Buttons  = dofile( code_path .. "visual objects/Make_A_Word_Buttons.lua" )
    
    -- 'out of game' menus/visual pieces
    -------------------------------------
    --    sub-components
    Main_Menu_Entry    = dofile( code_path .. "visual objects/Main_Menu_Entry.lua" )
    Clipped_List       = dofile( code_path .. "visual objects/Clipped_List.lua"    )
    Game_History       = dofile( code_path .. "visual objects/Game_History.lua"    )
    Swing_Sign         = dofile( code_path .. "visual objects/Swing_Sign.lua"      )
    --    main pieces
    bg, logo           = dofile( code_path .. "visual objects/Background.lua"      )
    Splash_Buttons     = dofile( code_path .. "visual objects/Splash_Buttons.lua"  )
    Main_Menu          = dofile( code_path .. "visual objects/Front_Page__Main.lua")
    
    -- logic pieces
    -------------------------------------
    get_letters,
    letter_values = dofile(code_path .. "gameplay objects/Scrabble_Bag.lua")
    check_word    = dofile(code_path .. "gameplay objects/Spell_Check.lua"  )
    
    bg.opacity = 0
    Letter_Slots.opacity = 0
    Strike_Bar.opacity   = 0
    Score_Keeper.opacity = 0
    Main_Menu.opacity    = 0
    Guess_Word_Buttons.opacity = 0
    Make_Word_Buttons.opacity  = 0
    Game_History.opacity  = 0
    Swing_Sign.opacity    = 0
    
    screen:add(
        bg,
        Letter_Slots,
        Strike_Bar,
        Score_Keeper,
        Guess_Word_Buttons,
        Make_Word_Buttons,
        Splash_Buttons,
        Main_Menu,
        Game_History,
        Swing_Sign
    )
    
    ----------------------------------------------------------------------------
    -- Link components together                                               --
    ----------------------------------------------------------------------------
    
    Game_State:init{game_server = gsm}
    
    Letter_Slots:init{
        num_slots = 8,
        font      = font,
        img_srcs  = img_srcs,
        lights_up_on_complete = Guess_Word_Buttons:get_gain_focus(),
    }
    
    Side_Buttons:init{
        img_srcs    = img_srcs,
        make_list   = make_list,
        make_button = make_button,
    }
    
    Strike_Bar:init{
        num_strikes = 6,
        img_srcs    = img_srcs,
        bg          = bg,
    }
    
    Score_Keeper:init{
        font        = font,
        make_button = make_button,
        max_x_s     = 3,
        img_srcs    = img_srcs,
    }
    
    Guess_Word_Buttons:init{
        
        font          = font,
        
        make_list     = make_list,
        make_button   = make_button,
        side_buttons = Side_Buttons,
        
        get_letters   = get_letters,
        letter_values = letter_values,
        letter_slots  = Letter_Slots,
        strike_bar    = Strike_Bar,
        make_word     = Make_Word_Buttons,
        sk            = Score_Keeper,
        
        game_server   = gsm,
        
        num_letters   = 12,
        img_srcs      = img_srcs,
    }
    
    
    Make_Word_Buttons:init{
        
        font          = font,
        bg            = bg,
        
        make_list     = make_list,
        make_button   = make_button,
        side_buttons = Side_Buttons,
        
        get_letters   = get_letters,
        letter_values = letter_values,
        
        game_server    = gsm,
        num_letters    = 12,
        img_srcs       = img_srcs,
        letter_slots   = Letter_Slots,
        check_word     = check_word,
        guess_word     = Guess_Word_Buttons,
        main_menu      = Main_Menu,
        sk             = Score_Keeper,
        main_menu_list = Main_Menu_List,
    }
    
    Splash_Buttons:init{
        font           = font,
        make_list      = make_list,
        make_button    = make_button,
        img_srcs       = img_srcs,
        game_server    = gsm,
        front_page     = Main_Menu,
        side_buttons = Side_Buttons,
        
        game_definition = hangman_game_config,
        
    }
    
    Clipped_List:init{
        img_srcs     = img_srcs,
    }
    
    Main_Menu_Entry:init{
        logic       = Main_Menu,
        box_w       = 350,
        entry_h     = 48,
        score_limit = 3,
        img_srcs    = img_srcs,
        guess_word  = Guess_Word_Buttons,
        make_word   = Make_Word_Buttons,
        ls          = Letter_Slots,
    }
    
    Main_Menu:init{
        make_frame   = make_frame,
        clipped_list = Clipped_List,
        side_buttons = Side_Buttons,
        list_entry   = Main_Menu_Entry,
        game_state   = Game_State,
        ls           = Letter_Slots,
        guess_word   = Guess_Word_Buttons,
        make_word    = Make_Word_Buttons,
        game_server  = gsm,
        make_list    = make_list,
        game_history = Game_History,
        img_srcs     = img_srcs,
        swing_sign   = Swing_Sign,
    }
    
    Swing_Sign:init{
        img_srcs     = img_srcs,
    }
    
    Game_History:init{
        make_frame  = make_frame,
        img_srcs    = img_srcs,
        game_server = gsm,
    }
    
    Clipped_List:init{
        img_srcs    = img_srcs,
    }
    
    ----------------------------------------------------------------------------
    -- GameState / Animations                                                 --
    ----------------------------------------------------------------------------
    
    local on_started = {
        ["LOADING_NO_SPLASH"]    = function()
                    bg:slide_in_hangman()
                    bg:scale_in_logo()
                    bg:slide_in_gallows()
        end,
        ["LOADING"]    = function() end,
        ["MAIN_PAGE"]  = function() end,
        ["MAKE_WORD"]  = function()
            
            Letter_Slots:reset()
            
            Make_Word_Buttons:new_letters()
            
        end,
        ["GUESS_WORD"] = function()
            
            Guess_Word_Buttons:hide_continue()
            
        end,
    }
    
    local on_completed = {
        ["LOADING_NO_SPLASH"]    = function()
        end,
        ["LOADING"]    = function()
            bg:slide_in_hangman()
            bg:scale_in_logo()
            bg:slide_in_gallows()
            Splash_Buttons:gain_focus()
            
        end,
        ["MAIN_PAGE"]  = function()
            
            Main_Menu:gain_focus()
            
        end,
        ["MAKE_WORD"]  = function()
            
            Make_Word_Buttons:gain_focus()
            
        end,
        ["GUESS_WORD"] = function()
            
            bg:slide_out_hangman()
            Guess_Word_Buttons:gain_focus()
            
        end,
    }
    
    app_state = AnimationState{
        duration = 300,
        transitions = {
            {
                source = "*",          target = APP_STATE_LOADING_NO_SPLASH, duration = 300,
                keys   = {
                    {bg,                 "opacity", 255},
                    {Splash_Buttons,     "opacity",   0},
                    {Letter_Slots,       "opacity",   0},
                    {Strike_Bar,         "opacity",   0},
                    {Swing_Sign,         "opacity",   0},
                    {Score_Keeper,       "opacity",   0},
                    {Guess_Word_Buttons, "opacity",   0},
                    {Make_Word_Buttons,  "opacity",   0},
                    {Main_Menu,          "opacity",   0},
                    {Game_History,       "opacity",   0},
                },
            },
            {
                source = "*",          target = APP_STATE_LOADING, duration = 300,
                keys   = {
                    {bg,                 "opacity", 255},
                    {Splash_Buttons,     "opacity", 255},
                    {Letter_Slots,       "opacity",   0},
                    {Strike_Bar,         "opacity",   0},
                    {Swing_Sign,         "opacity",   0},
                    {Score_Keeper,       "opacity",   0},
                    {Guess_Word_Buttons, "opacity",   0},
                    {Make_Word_Buttons,  "opacity",   0},
                    {Main_Menu,          "opacity",   0},
                    {Game_History,       "opacity",   0},
                },
            },
            {
                source = "*",          target = APP_STATE_MAIN_PAGE, duration = 300,
                keys   = {
                    {bg,                 "opacity", 255},
                    {logo,               "opacity", 255},
                    {Letter_Slots,       "opacity",   0},
                    {Strike_Bar,         "opacity",   0},
                    {Swing_Sign,         "opacity", 255},
                    {Score_Keeper,       "opacity",   0},
                    {Guess_Word_Buttons, "opacity",   0},
                    {Make_Word_Buttons,  "opacity",   0},
                    {Splash_Buttons,     "opacity",   0},
                    {Main_Menu,          "opacity", 255},
                    {Game_History,       "opacity", 255},
                },
            },
            {
                source = "*",        target = APP_STATE_MAKE_WORD, duration = 300,
                keys = {
                    {bg,                 "opacity", 255},
                    {logo,               "opacity",   0},
                    {Letter_Slots,       "opacity", 255},
                    {Strike_Bar,         "opacity",   0},
                    {Swing_Sign,         "opacity",   0},
                    {Score_Keeper,       "opacity", 255},
                    {Guess_Word_Buttons, "opacity",   0},
                    {Make_Word_Buttons,  "opacity", 255},
                    {Main_Menu,          "opacity",   0},
                    {Game_History,       "opacity",   0},
                },
            },
            {
                source = "*",        target = APP_STATE_GUESS_WORD, duration = 300,
                keys   = {
                    {bg,                 "opacity", 255},
                    {logo,               "opacity",   0},
                    {Letter_Slots,       "opacity", 255},
                    {Strike_Bar,         "opacity", 255},
                    {Swing_Sign,         "opacity",   0},
                    {Score_Keeper,       "opacity", 255},
                    {Guess_Word_Buttons, "opacity", 255},
                    {Make_Word_Buttons,  "opacity",   0},
                    {Main_Menu,          "opacity",   0},
                    {Game_History,       "opacity",   0},
                },
            },
        },
    }
    
    app_state.timeline.on_started = function(self)
        
        print("on_started",app_state.state)
        
        on_started[app_state.state]()
        
    end
    
    app_state.timeline.on_completed = function(self)
        
        print("on_completed",app_state.state)
        
        on_completed[app_state.state]()
        
    end
    
    if settings.username then
        
        g_user.name = settings.username
        
        gsm:init{
            
            screen_name = g_user.name,
            
            on_connection = function(t)
                if t then
                    
                    g_user.id = gsm:get_user_id()
                    
                    gsm:register_game(
                        
                        hangman_game_config(),
                        
                        function(success)
                            
                            app_state.state = APP_STATE_MAIN_PAGE
                            
                            Main_Menu:setup_lists()
                            
                        end
                    
                    )
                    
                else
                    app_state.state = APP_STATE_LOADING
                    
                    --TODO: need to try again
                end
            end,
            
        }
        
        app_state.state = APP_STATE_LOADING_NO_SPLASH
    else
        app_state.state = APP_STATE_LOADING
    end

    --for all of the locals in the 'init' functions
    collectgarbage("collect")
    
    
    mediaplayer:load("glee-1.mp4")
    
    function mediaplayer:on_loaded()
        
        mediaplayer:play()
        
    end
    function mediaplayer:on_end_of_stream()
        mediaplayer:seek(0)
        mediaplayer:play()
    end
    
    
end

dolater(main)
