--umbrella group for all members of the splash screen
local images = Group{}
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
images:add(Image{src="assets/background-start.jpg",scale={2,2}})
images:add(unpack(difficulty_items))
screen:add(images)
images:hide()

local focus = Image{src="assets/focus-rectangle-start.png",x=difficulty_items[1].x+button_backing.w/2,y=difficulty_items[1].y+button_backing.h/2}
focus.anchor_point={focus.w/2,focus.h/2}
images:add(focus)

local exit_focus  = Image{src="assets/focus-exit-btn.png",x=29,y=978}
local exit_button = Image{src="assets/button-exit.png",x=29,y=978}
exit_focus:hide()
images:add(exit_focus,exit_button)

function splash_fade_in()
    images:show()
end
function splash_fade_out()
    images:hide()
end


local exit_sel = false

local exit_button_key_handler = {
    [keys.OK] = function()
        exit()
    end,
    [keys.Right] = function()
        exit_focus:hide()
        focus:show()
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
            focus.y = focus.y+button_backing.h+38
        end
    end,
    [keys.Up] = function()
        if diff_i > 1 then
            diff_i = diff_i - 1
            focus.y = focus.y-(button_backing.h+38)
        end
    end,
    [keys.Left] = function()
        exit_focus:show()
        focus:hide()
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