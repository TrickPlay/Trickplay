
local main_menu = Group{}

local    my_turn = {}
local their_turn = {}

local make_button, make_list, score_limit, box_w, box_h, entry_h, img_srcs, username, font, make_word,main_menu_list

local clip =  Group{}
local hl
local vis_range, mid_align, frame,create_game_state,game_server, event_text
local top_vis_i = 1

local no_sessions_text
local right_side_bar



local x_off = {155,155,155}
local x_on  = "ff0000"

local your_turn      = "ffffff"
local awaiting_reply = x_off
local loaded = false

--[[
local color
local color_t = {}

local loading_animation = Timeline{
    duration     = 2000,
    loop         = true,
    on_new_frame = function(tl,ms,p)
        
        color = 150 + 100*math.sin(math.pi*2*p)
        
        color_t[1] = color
        color_t[2] = color
        color_t[3] = color
        
        no_sessions_text.color = color_t
        
    end
}
--]]


function main_menu:init(t)
    
    if type(t) ~= "table" then error("must pass a table as the parameter",2) end
    
    make_button       = t.make_button       or error( "must pass make_button",       2 )
    make_list         = t.make_list         or error( "must pass make_list",         2 )
    main_menu_list    = t.main_menu_list    or error( "must pass main_menu_list",    2 )
    font              = t.font              or error( "must pass font",              2 )
    new_game_state    = t.new_game_state    or error( "must pass new_game_state",    2 )
    create_game_state = t.create_game_state or error( "must pass create_game_state", 2 )
    img_srcs          = t.img_srcs          or error( "must pass img_srcs",          2 )
    game_server       = t.game_server       or error( "must pass img_srcs",          2 )
    guess_word        = t.guess_word        or error( "must pass guess_word",        2 )
    make_word         = t.make_word         or error( "must pass make_word",         2 )
    ls                = t.ls                or error( "must pass ls",                2 )
    score_limit       = t.score_limit       or 3
    box_w             = t.box_w             or 750
    box_h             = t.box_h             or 275
    entry_h           = t.entry_h           or  48
    
    --[[
    vis_range = math.floor(box_h/entry_h)
    
    mid_align = (box_h - vis_range*entry_h)/2
    
    frame = Canvas( box_w, box_h )
    frame:set_source_color( "#ffffffff" )
    frame.line_width = 2
    frame:round_rectangle( 1, 1, frame.w-2, frame.h-2, 8 )
    frame:stroke()
    frame = frame:Image()
    
    frame.position = {400,750}
    
    hl = Clone{ source = img_srcs.mm_focus, x = 2, }--y = mid_align }
    
    clip.clip = { 2,2,box_w - 4,box_h - 4}
    
    clip:add( hl )
    
    clip.position = frame.position
    
    no_sessions_text = Text{
        text    = "No Active Sessions",
        font    = font .. " 30px",
        color   = awaiting_reply,
        x       = frame.x + frame.w/2,
        y       = 800,
        opacity = 0 ,
    }
    no_sessions_text.anchor_point = {
        no_sessions_text.w/2, 0
    }
    
    --]]
    
    local right_side_txt = {}
    right_side_bar = {}
    right_side_bar[1] =make_button{
        clone           = true,
        unfocus_fades   = false,
        select_function = function()
            print("New Game")
            event_text.opacity = 255
            game_server:get_a_wild_card_invite(function(t)
                dumptable(t)
                if # t.invitations == 0 then
                    
                    make_word:set_session(new_game_state())
                    
                    app_state.state = "MAKE_WORD"
                    
                else
                    
                    t = t.invitations[1]
                    
                    game_server:accept_invite(t.id,function() end)
                    
                    local f = function(t)
                        
                        t = create_game_state(t)
                        
                        --dumptable(t:get_data())
                        
                        guess_word:reset()
                        guess_word:guess_word(t)
                        ls:reset()
                        
                        main_menu_list:add_entry(t)
                        
                        app_state.state = "GUESS_WORD"
                    end
                    
                    if t.state == json.null or t.state == nil then
                        
                        game_server:get_session_state(t,f)
                        
                    else
                        
                        f(t)
                        
                    end
                    
                end
                
            end)
        end,
        unfocused_image = img_srcs.button_r,
        focused_image   = img_srcs.button_f,
    }
    right_side_bar[1].x = 400 + box_w + 40--frame.x + frame.w + 40
    right_side_bar[1].y = 750 -- frame.y
    right_side_txt[1] = Text{
        color = "ffffff",
        text  = "New Game",
        font  = t.font .. " Bold 28px",
        x     = right_side_bar[1].x+30,
        y     = right_side_bar[1].y+15,
    }
    
    right_side_bar[2] =make_button{
        clone           = true,
        unfocus_fades   = false,
        select_function = function() exit() end,
        unfocused_image = img_srcs.button_b,
        focused_image   = img_srcs.button_f,
    }
    right_side_bar[2].x = right_side_bar[1].x
    right_side_bar[2].y = right_side_bar[1].y + img_srcs.button_f.h + 20
    right_side_txt[2] = Text{
        color = "ffffff",
        text  = "Quit",
        font  = t.font .. " Bold 28px",
        x     = right_side_bar[2].x+30,
        y     = right_side_bar[2].y+15,
    }
    
    local right_side_list = t.make_list{
        orientation = "VERTICAL",
        elements = right_side_bar,
        display_passive_focus = false,
    }
    
    list = t.make_list{
        orientation = "HORIZONTAL",
        elements = {main_menu_list, right_side_list},
        display_passive_focus = false,
        resets_focus_to = 2,
    }
    
    list:define_key_event(keys.RED,  right_side_bar[1].select)
    list:define_key_event(keys.BLUE, right_side_bar[2].select)
    --[[
    
    clip.focus_anim = AnimationState{
        duration = 300,
        transitions = {
            {
                source = "*", target = "UNFOCUSED",
                keys = {
                    {hl, "opacity",   0},
                }
            },
            {
                source = "*", target = "FOCUSED",
                keys = {
                    {hl, "opacity", 255},
                }
            }
        }
    }
    --]]
    main_menu:add(frame,list,no_sessions_text,
        Text{
            text  = "Current Games",
            font  = font .. " Bold 30px",
            color = "ffffff",
            x     = 665,
            y     = 700,
        }
    )
    
    event_text  = Text{
        text    = "Searching for games",
        font    = font .. " 35px",
        color   = "ffffff",
        x       = right_side_bar[1].x + right_side_bar[1].w + 70,
        y       = right_side_bar[2].y + 70,
        opacity = 0,
    }
    
    main_menu:add(event_text)
    main_menu:add(unpack(right_side_txt))
end



function main_menu:loaded()
    
    loaded = true
    
end
function main_menu:gain_focus(t)
    
    event_text.opacity = 0
    
    if not loaded then
        main_menu_list:load_animation()
        return
    end
    
    list:set_state("FOCUSED")
    
end

return main_menu