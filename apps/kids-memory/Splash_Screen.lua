--umbrella group for all members of the splash screen
local splash_screen = Group{}
local button_backing = Image{src="assets/button-start.png"}
screen:add(button_backing)
button_backing:hide()
local difficulty_items = {
    Group{},
    Group{},
    Group{},
}
for i = 1,#difficulty_items do
    difficulty_items[i]:add(Clone{source = button_backing})
    difficulty_items[i].position={1255,96+(i-1)*(button_backing.h+38)}
end
local t = Image{src="assets/level-start-easy.png",position={button_backing.w/2,button_backing.h/2}}
t.anchor_point={t.w/2,t.h/2}

difficulty_items[1]:add(t)
t = Image{src="assets/level-start-medium.png",position={button_backing.w/2,button_backing.h/2}}
t.anchor_point={t.w/2,t.h/2}
difficulty_items[2]:add(t)
t = Image{src="assets/level-start-hard.png",position={button_backing.w/2,button_backing.h/2}}
t.anchor_point={t.w/2,t.h/2}
difficulty_items[3]:add(t)
local diff_i = 1
splash_screen:add(Image{src="assets/background-start.jpg",scale={2,2}})
screen:add(splash_screen)
splash_screen:hide()

local focus = Image{src="assets/focus-rectangle-start.png",x=difficulty_items[1].x+button_backing.w/2,y=difficulty_items[1].y+button_backing.h/2}
focus.anchor_point={focus.w/2,focus.h/2}
splash_screen:add(focus)
splash_screen:add(unpack(difficulty_items))

local exit_focus  = Image{src="assets/focus-exit-btn.png",x=29,y=978}
local exit_button = Image{src="assets/button-exit.png",x=29,y=978}
exit_focus.opacity=0
splash_screen:add(exit_focus,exit_button)

function splash_fade_in()
    splash_screen:show()
end
function splash_fade_out()
    splash_screen:hide()
end

local focus_tl = nil

local function anim_focus(targ_x,targ_y)
    if focus_tl ~= nil then
        focus_tl:stop()
        focus_tl:on_completed()
        focus_tl=nil
    end
    focus_tl = Timeline{duration=200}
    local ani_mode = Alpha{timeline=focus_tl,mode="EASE_OUT_CIRC"}
    local curr_x = focus.x
    local curr_y = focus.y
    function focus_tl:on_new_frame(_,p)
        local p = ani_mode.alpha
        focus.x = curr_x + (targ_x-curr_x)*p
        focus.y = curr_y + (targ_y-curr_y)*p
    end
    function focus_tl:on_completed()
        
        focus.x = targ_x
        focus.y = targ_y
        focus_tl = nil
    end

    focus_tl:start()
end
local function corner_get_focus()
    if focus_tl ~= nil then
        focus_tl:stop()
        focus_tl:on_completed()
        focus_tl=nil
    end
    focus_tl = Timeline{duration=200}
    function focus_tl:on_new_frame(_,p)
        exit_focus.opacity = 255*p
        focus.opacity = 255*(1-p)
    end
    function focus_tl:on_completed()
        
        focus.opacity = 0
        exit_focus.opacity = 255
        focus_tl = nil
    end
    focus_tl:start()
end
local function corner_lose_focus()
    if focus_tl ~= nil then
        focus_tl:stop()
        focus_tl:on_completed()
        focus_tl=nil
    end
    focus_tl = Timeline{duration=200}
    function focus_tl:on_new_frame(_,p)
        exit_focus.opacity = 255*(1-p)
        focus.opacity = 255*(p)
    end
    function focus_tl:on_completed()
        
        focus.opacity = 255
        exit_focus.opacity = 0
        focus_tl = nil
    end
    focus_tl:start()
end




local exit_sel = false

local exit_button_key_handler = {
    [keys.OK] = function()
        exit()
    end,
    [keys.Right] = function()
        corner_lose_focus()
        exit_sel = false
    end,
}

local key_handler = {
    [keys.OK] = function()
        game_state.board = {}
        game_state.difficulty = diff_i
        game_state.in_game=true
        give_keys("GAME")
    end,
    [keys.Down] = function()
        if diff_i < 3 then
            diff_i = diff_i + 1
            anim_focus(focus.x, focus.y+button_backing.h+38)
        end
    end,
    [keys.Up] = function()
        if diff_i > 1 then
            diff_i = diff_i - 1
            anim_focus(focus.x, focus.y-(button_backing.h+38))
        end
    end,
    [keys.Left] = function()
        corner_get_focus()
        exit_sel = true
    end,
}

splash_on_key_down = function(key)
    
    if exit_sel and exit_button_key_handler[key] then
        exit_button_key_handler[key]()
    elseif key_handler[key] then
        key_handler[key]()
    else
        print("Splash Screen Key handler does not support the key "..key)
    end
end