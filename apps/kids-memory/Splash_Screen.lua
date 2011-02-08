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

local exit_focus  = Image{src="assets/focus-exit-btn.png",x=8,y=957}
local exit_button = Image{src="assets/button-exit.png",x=29,y=978}
exit_focus.opacity=0
splash_screen:add(exit_focus,exit_button)

function splash_fade_in()
    splash_screen:show()
end
function splash_fade_out()
    splash_screen:hide()
end

local anim_focus = {
    duration = {200},
    mode   = {"EASE_OUT_CIRC"},
    setup  = function(self)
        self.curr_x = focus.x
        self.curr_y = focus.y
    end,
    stages = {
        function(self,delta,p)
            focus.x = self.curr_x + (self.targ_x-self.curr_x)*p
            focus.y = self.curr_y + (self.targ_y-self.curr_y)*p
        end
    }
}
local corner_get_focus = {
    duration = {200},
    stages = {
        function(self,delta,p)
            exit_focus.opacity = 255*(p)
            focus.opacity = 255*(1-p)
        end
    }
}

local corner_lose_focus = {
    duration = {200},
    stages = {
        function(self,delta,p)
            exit_focus.opacity = 255*(1-p)
            focus.opacity = 255*(p)
        end
    }
}


local exit_sel = false

local exit_button_key_handler = {
    [keys.OK] = function()
        play_sound_wrapper(audio.button)
        exit()
    end,
    [keys.Right] = function()
        --corner_lose_focus()
        --table.insert(animate_list,corner_lose_focus)
        animate_list[corner_lose_focus]=corner_lose_focus
        exit_sel = false
        play_sound_wrapper(audio.move_focus)
    end,
}

local key_handler = {
    [keys.OK] = function()
        game_state.board = {}
        game_state.difficulty = diff_i
        game_state.in_game=true
        give_keys("GAME")
        play_sound_wrapper(audio.button)
    end,
    [keys.Down] = function()
        if diff_i < 3 then
            diff_i = diff_i + 1
            --anim_focus(focus.x, focus.y+button_backing.h+38)
            anim_focus.targ_x = focus.x
            anim_focus.targ_y = focus.y+button_backing.h+38
            --table.insert(animate_list,anim_focus)
            animate_list[anim_focus]=anim_focus
            play_sound_wrapper(audio.move_focus)
        end
    end,
    [keys.Up] = function()
        if diff_i > 1 then
            diff_i = diff_i - 1
            --anim_focus(focus.x, focus.y-(button_backing.h+38))
            anim_focus.targ_x = focus.x
            anim_focus.targ_y = focus.y-(button_backing.h+38)
            --table.insert(animate_list,anim_focus)
            animate_list[anim_focus]=anim_focus
            play_sound_wrapper(audio.move_focus)
        end
    end,
    [keys.Left] = function()
        --corner_get_focus()
        --table.insert(animate_list,corner_get_focus)
        animate_list[corner_get_focus]=corner_get_focus
        exit_sel = true
        play_sound_wrapper(audio.move_focus)
    end,
}

splash_on_key_down = function(key)
    
    if exit_sel and exit_button_key_handler[key] then
        exit_button_key_handler[key]()
    elseif not exit_sel and key_handler[key] then
        key_handler[key]()
    else
        print("Splash Screen Key handler does not support the key "..key)
    end
end