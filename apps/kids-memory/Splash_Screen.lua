--umbrella group for all members of the splash screen
local images = Group{}

local difficulty_items = {
    Text{font="Sans 32px",text="Easy",x=300,y=300},
    Text{font="Sans 32px",text="Medium",x=500,y=300},
    Text{font="Sans 32px",text="Hard",x=700,y=300},
}
local diff_i = 1
images:add(Rectangle{w=screen_w,h=screen_h,color="452342"})
images:add(unpack(difficulty_items))
screen:add(images)
images:hide()

local focus = Rectangle{name="focus",w=100,h=100,color="FFFFFF",x=350,y=350}
images:add(focus)

function splash_fade_in()
    images:show()
end
function splash_fade_out()
    images:hide()
end




local key_handler = {
    [keys.OK] = function()
        game_state.board = {}
        game_state.difficulty = diff_i
        game_state.in_game=true
        give_keys("GAME")
    end,
    [keys.Right] = function()
        if diff_i < 3 then
            diff_i = diff_i + 1
            focus.x = 100+200*diff_i
        end
    end,
    [keys.Left] = function()
        if diff_i > 1 then
            diff_i = diff_i - 1
            focus.x = 100+200*diff_i
        end
    end,
}

splash_on_key_down = function(key)
    
    if key_handler[key] then
        key_handler[key]()
    else
        print("Splash Screen Key handler does not support the key "..key)
    end
end