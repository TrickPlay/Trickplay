screen_w = screen.w
screen_h = screen.h

screen:show()

assets_path = "assets/"
audio_path  = "audio/"
code_path   = "code/"

local hangman_game_definition = function(vendor_name,vendor_id)
    return {
        game_name               = app.name,
        appId                   = app.name,
        leaderboardFlag         = false,
        achievementsFlag        = false,
        allowWildCardInvitation = true,
        turnBasedFlag           = true,
        vendorName              = vendor_name,
        vendorId                = vendor_id,
        minPlayers              = 2,
        maxPlayers              = 2,
    }
end

function main()
    
    local font = "Free Sans"
    
    g_font     = "Free Sans"
    app_state  = nil
    g_username = nil
    
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
        
        mm_focus  = Image{ src = assets_path .. "general_menu/focus-list.png"},
        
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
    
    for k,v in pairs(img_srcs) do     clone_srcs:add(v)    end
    
    ----------------------------------------------------------------------------
    -- DoFiles                                                                --
    ----------------------------------------------------------------------------
    
    
    -- 'libraries'
    make_button = dofile( code_path .. "visual objects/Button.lua"             )
    make_list   = dofile( code_path .. "visual objects/Visual_List_Object.lua" )
    
    -- server interface components
    -------------------------------------
    set_GS_username,
    make_GS_from_existing,
    create_new_GS = dofile( code_path .. "gameplay objects/Gamplay_State.lua"   )
    gsi           = dofile( code_path .. "interfaces/Game_Server_Interface.lua" )
    gsm           = dofile( code_path .. "interfaces/Game_Server_Manager.lua"   )
    
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
    Main_Menu_List     = dofile( code_path .. "visual objects/Main_Menu_List.lua"  )
    --    main pieces
    bg, logo           = dofile( code_path .. "visual objects/Background.lua"      )
    Splash_Buttons     = dofile( code_path .. "visual objects/Splash_Buttons.lua"  )
    Main_Menu          = dofile( code_path .. "visual objects/Main_Menu.lua"       )
    
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
    
    screen:add(
        bg,
        Letter_Slots,
        Strike_Bar,
        Score_Keeper,
        Guess_Word_Buttons,
        Make_Word_Buttons,
        Splash_Buttons,
        Main_Menu
    )
    
    ----------------------------------------------------------------------------
    -- Link components together                                               --
    ----------------------------------------------------------------------------
    
    gsm:init{ interface = gsi }
    
    Letter_Slots:init{
        num_slots = 8,
        font      = font,
        img_srcs  = img_srcs,
        lights_up_on_complete = Guess_Word_Buttons:get_gain_focus(),
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
        
        make_list     = make_list,
        make_button   = make_button,
        
        get_letters   = get_letters,
        letter_values = letter_values,
        
        game_server    = gsm,
        num_letters   = 12,
        img_srcs      = img_srcs,
        letter_slots  = Letter_Slots,
        check_word    = check_word,
        guess_word    = Guess_Word_Buttons,
        main_menu     = Main_Menu,
        sk            = Score_Keeper,
        main_menu_list = Main_Menu_List,
        create_game_state = create_new_GS,
    }
    
    Splash_Buttons:init{
        font           = font,
        make_list      = make_list,
        make_button    = make_button,
        img_srcs       = img_srcs,
        game_server    = gsm,
        main_menu_list = Main_Menu_List,
        
        game_definition = hangman_game_definition,
        set_GS_username = set_GS_username,
        
    }
    
    Main_Menu:init{
        
        font          = font,
        
        make_list     = make_list,
        make_button   = make_button,
        
        img_srcs      = img_srcs,
        
        game_server    = gsm,
        guess_word     = Guess_Word_Buttons,
        make_word      = Make_Word_Buttons,
        ls             = Letter_Slots,
        main_menu_list = Main_Menu_List,
        
        create_game_state = make_GS_from_existing,
        new_game_state    = create_new_GS,
    }
    
    Main_Menu_List:init{
        img_srcs    = img_srcs,
        make_entry  = Main_Menu_Entry,
        guess_word    = Guess_Word_Buttons,
        make_word      = Make_Word_Buttons,
        main_menu   = Main_Menu,
        game_server = gsm,
        create_game_state = make_GS_from_existing,
    }
    
    ----------------------------------------------------------------------------
    -- GameState / Animations                                                 --
    ----------------------------------------------------------------------------
    
    local on_started = {
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
                source = "*",          target = "LOADING",
                keys   = {
                    {bg,             "opacity", 255},
                    {Splash_Buttons, "opacity", 255},
                },
            },
            {
                source = "*",          target = "MAIN_PAGE",
                keys   = {
                    {bg,                 "opacity", 255},
                    {logo,               "opacity", 255},
                    {Letter_Slots,       "opacity",   0},
                    {Strike_Bar,         "opacity",   0},
                    {Score_Keeper,       "opacity",   0},
                    {Guess_Word_Buttons, "opacity",   0},
                    {Make_Word_Buttons,  "opacity",   0},
                    {Splash_Buttons,     "opacity",   0},
                    {Main_Menu,          "opacity", 255},
                },
            },
            {
                source = "*",        target = "MAKE_WORD",
                keys = {
                    {bg,                 "opacity", 255},
                    {logo,               "opacity", 255},
                    {Letter_Slots,       "opacity", 255},
                    {Strike_Bar,         "opacity",   0},
                    {Score_Keeper,       "opacity", 255},
                    {Guess_Word_Buttons, "opacity",   0},
                    {Make_Word_Buttons,  "opacity", 255},
                    {Main_Menu,          "opacity",   0},
                },
            },
            {
                source = "*",        target = "GUESS_WORD",
                keys   = {
                    {bg,                 "opacity", 255},
                    {logo,               "opacity",   0},
                    {Letter_Slots,       "opacity", 255},
                    {Strike_Bar,         "opacity", 255},
                    {Score_Keeper,       "opacity", 255},
                    {Guess_Word_Buttons, "opacity", 255},
                    {Make_Word_Buttons,  "opacity",   0},
                    {Main_Menu,          "opacity",   0},
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
    
    app_state.state = "LOADING"
    
    --for all of the locals in the 'init' functions
    collectgarbage("collect")
end

dolater(main)
