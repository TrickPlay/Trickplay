--[[
    Air Combat
--]]

play_sound_wrapper = function(sound)
	--mediaplayer:play_sound(sound)
end

my_font = "Arcade Normal, 32px"

local recycled_tables = {}

function make_table()
    
    if #recycled_tables ~= 0 then
        
	return table.remove(recycled_tables)
	
    else
        
	return {}
	
    end
    
end

function recycle_table(t)
    
    table.insert(recycled_tables,t)
    
end

cursor = Clone()

function button(p)--(x,y,txt,on_e,on_l,anchor_center)
    
    assert( type(p) == "table", "expected tabled parameters")
    assert( p.size == "large" or p.size == "small" )
    assert( p.x ~= nil and p.y ~= nil and p.text ~= nil )
    assert( p.on_enter     == nil or type(p.on_enter)     == "function" )
    assert( p.on_leave     == nil or type(p.on_leave)     == "function" )
    assert( p.on_button_up == nil or type(p.on_button_up) == "function" )
    
    local btn = Group{name="Button: "..p.text,x=p.x,y=p.y}
    
    local text = Text{
	text  = p.text,
	--font  = "Arcade Normal, 24px",
	color = "FFFFFF",
    }
    
    if p.size == "small" then
	
	text.font  = "Arcade Normal, 24px"
	
    else
	
	text.font  = "Arcade Normal, 48px"
	
    end
    
    local bg_l = Clone{}
    local bg_m = Clone{}
    local bg_r = Clone{}
    
    function btn:get_focus()
	if using_keys then
	    cursor.keys_on = self
	end
	if p.size == "small" then
	    bg_l.source = base_imgs.button.sm_start_f
	    bg_m.source = base_imgs.button.sm_mid_f
	    bg_r.source = base_imgs.button.sm_end_f
	else
	    bg_l.source = base_imgs.button.lg_start_f
	    bg_m.source = base_imgs.button.lg_mid_f
	    bg_r.source = base_imgs.button.lg_end_f
	end
	text.color  = "fffacc"
	btn.focused = true
    end
    
    function btn:lose_focus()
	if using_keys and cursor.keys_on == self then
	    cursor.keys_on = nil
	end
	if p.size == "small" then
	    bg_l.source = base_imgs.button.sm_start
	    bg_m.source = base_imgs.button.sm_mid
	    bg_r.source = base_imgs.button.sm_end
	else
	    bg_l.source = base_imgs.button.lg_start
	    bg_m.source = base_imgs.button.lg_mid
	    bg_r.source = base_imgs.button.lg_end
	end
	text.color  = "5c5e66"
	btn.focused = false
    end
    
    btn:lose_focus()
    
    bg_m.x            = bg_l.w
    if p.w then
	bg_m.w        = p.w - 2*bg_l.w
    else
	bg_m.w        = (text.w+20)
    end
    
    bg_r.x            = bg_m.x+bg_m.w
    --r.anchor_point = {bg_r.w,0}
    --r.y_rotation   = {180,0,0}
    
    text.anchor_point = {text.w/2,text.h/2}
    text.y            = bg_m.h/2
    text.x            = bg_m.x + bg_m.w/2
    
    btn.size          = { text.x*2, bg_m.h }
    
    btn:add( bg_l, bg_m, bg_r, text )
    
    function btn:on_enter()
	
	cursor.last_on = btn.on_enter
	
	cursor.on_obj = btn
	
	btn:get_focus()
	
	cursor.on_nothing = false
	
	if p.on_enter then p.on_enter() end
	
    end
    
    function btn:on_leave()
	
	cursor.last_on = nil
	
	btn:lose_focus()
	
	cursor.on_nothing = true
	
	if p.on_leave then p.on_leave() end
	
    end
    
    btn.on_button_up = p.on_button_up
    
    if p.anchor_center then
	
	btn.anchor_point = { text.x, bg_m.h/2 }
	
    end
    
    return btn
end
key_down = nil


dofile("Class.lua")
--global variables
dofile( "globals.lua")
--code for the smart phone accelerometers
dofile( "controller.lua")
--code for the top bar
dofile( "hud.lua")
--functions of the game loop
--	add_to_render_list()
--	remove_from_render_list()
--	process_collisions()
dofile("GameLoop.lua")

--All these files consist of tables which get added to the Game Loop
dofile("land.lua")
dofile("my_plane.lua")
dofile("enemies.lua")
dofile("enemies/final_boss.lua")
dofile("Levels.lua")

using_keys = true

function cursor:switch_to_target()
    self.source       = base_imgs.cursor.game
    self.opacity      = 255*.5
    self.anchor_point = {self.w/2,self.h/2}
    self.is_target    = true
end

function cursor:switch_to_pointer()
    self.source       = base_imgs.cursor.menu
    self.opacity      = 255
    self.anchor_point = {0,0}
    self.is_target    = false
end

cursor:switch_to_pointer()

cursor.on_nothing = true

cursor:hide()

screen:add(cursor)

controllers:start_pointer()


screen.reactive = true

screen.on_motion = function(_,x,y)
    
    if  using_keys  then
	
	using_keys = false
	
	cursor:show()
	
	if   cursor.keys_on ~= nil   then   cursor.keys_on:lose_focus()   end
	
	if   cursor.last_on ~= nil   then   cursor.last_on(cursor.on_obj)   end
	
	if state.curr_mode == "CAMPAIGN" then pause_btn:to_mouse() end
	
    end
    
    cursor.x = x
    
    cursor.y = y
    
end

screen.on_button_down = function()
    
    if  using_keys  then
	
	using_keys = false
	
	cursor:show()
	
	if   cursor.keys_on ~= nil   then   cursor.keys_on:lose_focus()   end
	
	if   cursor.last_on ~= nil   then   cursor.last_on(cursor.on_obj)   end
	
	--pause_btn:to_mouse()
	if state.curr_mode == "CAMPAIGN" then pause_btn:to_mouse() end
    end
    
end

screen.on_button_up = function()
    
    if not cursor.on_nothing or cursor.is_target then
	
	key_down( keys.Return )
	
    end
    
end

--The splash Items
local splash_screen = Group{}
layers.splash:add( splash_screen )
splash_screen:add(
    Image
    {
	name     = "logo",
	src      = "assets/splash/AirCombatLogo.png",
	position = {screen.w/2,screen_h/2-80}
    },
    Image
    {
	name     = "instr",
	src      = "assets/splash/InstructionBar.png",
	position = {screen_w/2,screen_h - 120}
    }
)
local splash_unreactive
local splash_i = 1
local splash_limit = 1
if (type(settings.salvage_list) == "table" and #settings.salvage_list > 0) or
    (settings.state ~= nil and settings.state.in_lvl_complete) then
    
    local b1 = button{
	size     = "large",
	x        = screen_w/2,
	y        = screen_h/2+160,
	text     = "Continue Old Game",
	on_enter = function() splash_i = 1 end
    }
    local b2 = button{
	size     = "large",
	x        = screen_w/2,
	y        = screen_h/2+300,
	text     = "Start New Game",
	w        = b1.w,
	on_enter = function() splash_i = 2 end
    }
    
    b1.reactive = true
    b2.reactive = true
    
    splash_screen:add(b1,b2)
    
    splash_limit = 2
    
    b1:get_focus()
    
    splash_unreactive = function()
	b1.reactive = false
	b2.reactive = false
    end
else
    
    local b1 = button{
	size     = "large",
	x        = screen_w/2,
	y        = screen_h/2+240,
	text     = "Start New Game",
	on_enter = function() splash_i = 1 end
    }
    
    b1.reactive = true
    
    splash_screen:add(b1)
    
    b1:get_focus()
    
    splash_unreactive = function()
	b1.reactive = false
    end
end

splash_screen:add(
        Text{name="level report",text="",font=my_font,color = "FFFFFF", x = screen_w/2, y = screen_h/2-240}
    )
splash_screen:add(
        Text{name = "Next Level",text="Next Level",font=my_font,color = "FFFFFF", x = screen_w/2, y = screen_h/2+240, opacity=0},
        Text{name = "Replay Level",text="Replay Level",font=my_font,color = "FFFFFF", x = screen_w/2, y = screen_h/2+300, opacity=0}
    )
    splash_screen:add(
        Text{name = "save",text="Save and Exit",font=my_font,color = "FFFFFF", x = screen_w/2, y = screen_h/2+240, opacity=0},
        Text{name = "exit",text="Exit",font=my_font,color = "FFFFFF", x = screen_w/2, y = screen_h/2+300, opacity=0}
    )
splash_screen:foreach_child(function(c)
    c.anchor_point = {c.w/2,c.h/2}
end)


function start_game()
add_to_render_list( my_plane )
end
add_to_render_list( lvlbg[1] )

--add_to_render_list( enemies )

dont_save_game = true

function launch_new_game()
    
    --cursor stuff
    cursor.last_on = pause_btn.to_mouse
    cursor.on_obj  = pause_btn
    cursor:switch_to_target()
    if not using_keys then
	pause_btn:to_mouse()
    end
    
    --State Stuff
    state.curr_mode  = "CAMPAIGN"
    state.curr_level = 1
    state.hud.num_lives = 3
    for i = 1, #lives do
	if i <= state.hud.num_lives then
	    lives[i].opacity=255
	else
	    lives[i].opacity=0
	end
    end
    state.hud.curr_score = 0
    redo_score_text()
    
    dont_save_game = false
    
    --Render List stuff
    remove_all_from_render_list()
    load_imgs[state.curr_level]()
    add_to_render_list(lvlbg[1])
    add_to_render_list(my_plane)
    add_to_render_list(levels[state.curr_level])
end


--------------------------------------------------------------------------------
--modal menus

dofile("menus.lua")
game_over_save = Menu_Game_Over_Save_Highscore()
game_over_no_save = Menu_Game_Over_No_Save()
high_score_menu = Menu_High_Scores()
level_completed = Menu_Level_Complete()

game_over_save:set_ptr_to_h_scores(high_score_menu)
game_over_no_save:set_ptr_to_h_scores(high_score_menu)

level_completed:set_ptr_to_g_over_save(    game_over_save    )
level_completed:set_ptr_to_g_over_no_save( game_over_no_save )


local test_text = Text
	{
	    font = my_font,
	    text =
		"Test Mode\n\n"..
                "q-y    enemy formations\n"..
	        "n-m    big enemies\n\n"..
                "z-c    powerup\n"..
	        "1-5    bullet   powerups\n\n"..
                "9      plane gets hit\n"..
                "0      plane heals\n\n"..
	        "h      toggles  this  text\n\n"..
                "fyi, you don't die",
	    color = "FFFFFF",
        opacity = 0
	}
    test_text.position     = {    screen_w/2 , 100}
    test_text.anchor_point = { test_text.w/2 , 0}
    layers.air_doodads_1:add( test_text )


out_splash__in_hud = function()
    splash_screen:clear()
end

lvl_end_i = 1
--------------------------------------------------------------------------------
-- Event handler
local key_events = {
    ["SPLASH"] =
    {
        [keys.Up] = function()
            if splash_i - 1 >= 1 then
                splash_i = splash_i - 1
                layers.splash:find_child("Button: Continue Old Game"):get_focus()
                layers.splash:find_child("Button: Start New Game"   ):lose_focus()
            end
        end,
        [keys.Down] = function()
            if splash_i + 1 <= splash_limit then
                splash_i = splash_i + 1
                layers.splash:find_child("Button: Continue Old Game"):lose_focus()
                layers.splash:find_child("Button: Start New Game"   ):get_focus()
            end
        end,
        [keys.Return] = function()
            
	    splash_unreactive()
	    
	    out_splash__in_hud()
	    
	    
            if splash_i == 1 and splash_limit == 2 then
                
		cursor:switch_to_target()
		
		cursor.last_on = pause_btn.to_mouse
		cursor.on_obj  = pause_btn
		
		
		if not using_keys then
		    pause_btn:to_mouse()
		end
                
		recurse_and_apply(state,settings.state)
                
                if state.in_lvl_complete then
                    
                    level_completed:animate_in(string.format("%06d",state.menu), true)
                    add_to_render_list(my_plane)
                    redo_score_text()
                    for i = 1,#lives do
                        if i<= state.hud.num_lives then
                            lives[i].opacity=255
                        else
                            lives[i].opacity=0
                        end
                    end
                else
                    load_imgs[state.curr_level]()
                    local f
                    for _,i in ipairs(settings.salvage_list) do
                        f = _G
                        for j = 1,#i.func do
                            --print(i.func[j])
                            f = f[ i.func[j] ]
                        end
                        --print("done\n\n")
                        f(unpack(i.table_params))
                        --print("?")
                    end
                    
                    for i = 1,#lives do
                        if i<= state.hud.num_lives then
                            lives[i].opacity=255
                        else
                            lives[i].opacity=0
                        end
                    end
                    redo_score_text()
                    for i = 1, state.hud.num_lives do
                        lives[i].opacity=255
                    end
                end
                --print("done done")
            else
                launch_new_game()
		--[[
                state.curr_mode  = "CAMPAIGN"
                state.curr_level = 1
                
                add_to_render_list(my_plane)
                add_to_render_list(levels[state.curr_level])
                load_imgs[state.curr_level]()
		--]]
            end
            
            
        end,
        [keys["0"]] = function()
            
            out_splash__in_hud()
            my_plane.bombing_mode = false
            
            state.curr_mode  = "TEST_MODE"
            state.curr_level = 0
            add_to_render_list(my_plane)
            --test_text.opacity = 255
            
        end,
        [keys["2"]] = function()
            
	    splash_unreactive()
	    
	    cursor:switch_to_target()
	    
            out_splash__in_hud()
            
            state.curr_mode  = "CAMPAIGN"
            state.curr_level = 2
            load_imgs[2]()
            add_to_render_list(my_plane)
            remove_from_render_list(lvlbg[1])
            add_to_render_list(lvlbg[2])

            add_to_render_list(levels[state.curr_level])
            
        end,
        [keys["3"]] = function()
            
	    splash_unreactive()
	    
	    cursor:switch_to_target()
	    
            out_splash__in_hud()
            
            state.curr_mode  = "CAMPAIGN"
            state.curr_level = 3
            load_imgs[3]()
            add_to_render_list(my_plane)
            remove_from_render_list(lvlbg[1])
            add_to_render_list(lvlbg[3])

            add_to_render_list(levels[state.curr_level])
            
        end,
        [keys["4"]] = function()
            
	    splash_unreactive()
	    
	    cursor:switch_to_target()
	    
            out_splash__in_hud()
            
            state.curr_mode  = "CAMPAIGN"
            state.curr_level = 4
            load_imgs[4]()
            add_to_render_list(my_plane)
            remove_from_render_list(lvlbg[1])
            add_to_render_list(lvlbg[4])

            add_to_render_list(levels[state.curr_level])
            
        end,
        [keys.o] = function()
            
            if type(settings.salvage_list) == "table" and #settings.salvage_list > 0 then
                --print("salvage list is size ",#settings.salvage_list)
                out_splash__in_hud()
                local f
                for _,i in ipairs(settings.salvage_list) do
                    f = _G
                    for j = 1,#i.func do
                        --print(i.func[j])
                        f = f[ i.func[j] ]
                    end
                    --print("done\n\n")
                    f(unpack(i.table_params))
                    --print("?")
                end
                
                recurse_and_apply(state,settings.state)
                redo_score_text()
                for i = 1, state.hud.num_lives do
                    lives[i].opacity=255
                end
                
                --print("done done")
            else
                --print("No salvage list saved, cannot restore an old game")
            end

        end,
    },
    ["TEST_MODE"] =
    {
        --enemies
        [keys["1"]] = function()
            formations.row_from_side(5,150,  -100,1000,  50,300,  200)
        end,
        [keys.w] = function()
            formations.row_from_side(5,150,  screen_w+100,1000,  screen_w-50,300,  screen_w-200)
        end,
        [keys["2"]] = function()
            formations.one_loop(2,150,200,200,300,-1)
        end,
        [keys.r] = function()
            formations.one_loop(2,150,screen_w-200,screen_w-200,300,1)
        end,
        [keys["3"]] = function()
            formations.cluster(500)
        end,
        [keys.y] = function()
            formations.zig_zag(500,400,-30)
        end,
        [keys["4"]] = function()
            enemies.turret(500,-100)
        end,
        [keys.i] = function()
            formations.hor_row_tanks(1,-200,3,150)
        end,
        [keys["5"]] = function()
            formations.vert_row_tanks(200,-1,3,150)
        end,
        [keys.p] = function()
            enemies.jeep(false,500,-100)
        end,
        --bosses
        [keys["6"]] = function()
            enemies.zeppelin(900)
        end,
        [keys["7"]] = function()
            enemies.battleship(500,300, 40,true)
        end,
        [keys["8"]] = function()
            enemies.destroyer(500,300, 40,true)
        end,
        [keys.l] = function()
            enemies.trench(500)
        end,
        [keys.k] = function()
            add_to_render_list(enemies.big_tank(),200,200)
        end,
        [keys["9"]] = function()
            enemies.final_boss(false)
        end,
        [keys.a] = function()
            add_to_render_list(wake(100,100))
        end,
        --powerups
        [keys.z] = function()
            add_to_render_list(powerups.guns(300,true))
        end,
        [keys.x] = function()
            add_to_render_list(powerups.health(500,true))
        end,
        [keys.c] = function()
            add_to_render_list(powerups.life(400,true))
        end,
        [keys.g] = function()
            level_completed:animate_in(string.format("%06d",33333))
        end,
        [keys.d] = function()
            game_over_save:animate_in(string.format("%06d",33333),3)
        end,
        [keys.j] = function()
            game_over_no_save:animate_in(string.format("%06d",33333))
        end,
        [keys.f] = function()
            high_score_menu:animate_in()
        end,
        --other
        [keys.s] = function()
            water:add_dock(1,1)
        end,
        [keys.h] = function()
            if test_text.opacity == 255 then
                test_text.opacity = 0
            else
                test_text.opacity = 255
            end
        end,
        --[[
        [keys["1"] ] = function()
            remove_from_render_list(lvlbg[state.curr_level])
            state.curr_level = 1
            add_to_render_list(lvlbg[state.curr_level])
        end,
        [keys["2"] ] = function()
            remove_from_render_list(lvlbg[state.curr_level])
            state.curr_level = 2
            add_to_render_list(lvlbg[state.curr_level])
        end,
        [keys["3"] ]= function()
            remove_from_render_list(lvlbg[state.curr_level])
            state.curr_level = 3
            add_to_render_list(lvlbg[state.curr_level])
        end,
        [keys["4"] ] = function()
            my_plane.firing_powerup=4
        end,
        [keys["5"] ] = function()
            my_plane.firing_powerup=5
        end,
        [keys["9"] ] = function()
            my_plane:hit()
        end,
        [keys["0"] ] = function()
            my_plane:heal()
        end,
        --]]
        [keys["0"]] = function()
            my_plane.bombing_mode = not my_plane.bombing_mode
        end,
        [keys.Right] = function(second)
            my_plane:on_key(keys.Right,second)
        end,
        [keys.Left] = function(second)
            my_plane:on_key(keys.Left,second)
        end,
        [keys.Up] = function(second)
            my_plane:on_key(keys.Up,second)
        end,
        [keys.Down] = function(second)
            my_plane:on_key(keys.Down,second)
        end,
        [keys.Return] = function(second)
            my_plane:on_key(keys.Return,second)
        end,
        [keys.space] = function()
            state.paused = not (state.paused)
        end
    },
    ["CAMPAIGN"] =
    {
        [keys.Right] = function(second)
            my_plane:on_key(keys.Right,second)
        end,
        [keys.Left] = function(second)
            my_plane:on_key(keys.Left,second)
        end,
        [keys.Up] = function(second)
            my_plane:on_key(keys.Up,second)
        end,
        [keys.Down] = function(second)
            my_plane:on_key(keys.Down,second)
        end,
        [keys.Return] = function(second)
            my_plane:on_key(keys.Return,second)
        end,
        [keys.space] = function()
            state.paused = not (state.paused)
        end
    },
    ["LEVEL_END"] = level_completed.keys,
    ["GAME_OVER_SAVE"]= game_over_save.keys,
    ["GAME_OVER"]  = game_over_no_save.keys,
    ["HIGH_SCORE"]  = high_score_menu.keys,
}

local press
local second_press
--moves through all the items in the render list
--i.e. performs the game loop

--idle.limit=1/60
--collectgarbage("stop")

function idle.on_idle( idle , seconds )
--[[
    if press ~= nil then
        if press == keys.Ok then
            press = keys.Return
        elseif press == keys.Space or press == keys.Pause then
            state.paused = not state.paused
        elseif keys[state.curr_mode][press] then keys[state.curr_mode][press]()--second_press)
        end
        press = nil
        --second_press = nil
    end
    --]]
    if not state.paused then

--[[
	--Pablo's performance measuring code
	if false then

		c = c + 1
		ma = math.max( seconds , ma )
		mi = math.min( seconds , mi )
		t = t + seconds
		if sw.elapsed >= 1000 then
			print( mi , ma , t / c , string.format( "%1.0f" , 1 / ( t / c ) ) )
			t = 0
			c= 0
			sw:start()
			ma = 0
			mi = 1000
			
		end
	end
--]]
    for item,render in pairs( just_added_list ) do
        render_list[item] = render
    end
    just_added_list = {}
    
        for item,render in pairs( render_list ) do
            render( item , seconds )

        end


--print("\n")
        process_collisions( )
        
    end
    
end

key_down = function(press)
    if press == keys.Ok then
	press = keys.Return
    elseif press == keys.Space or press == keys.Pause then
	state.paused = not state.paused
    elseif key_events[state.curr_mode][press] then
	key_events[state.curr_mode][press]()
    end
end
function screen.on_key_down( screen , press )
    
    if not using_keys then
	using_keys = true
	cursor:hide()
	pause_btn:to_keys()
    end
    
    key_down(press)

end


-------------------------------------------------------------------------------
--saves high score

function app:on_closing()
    
    --print(my_plane.dead)
    settings.state = {}
    local temp_table = {}
    recurse_and_apply(temp_table, state)
    settings.state = temp_table
    
    
    settings.salvage_list = {}
    if dont_save_game then return end
    --print("start")
    temp_table = {}
    local s
    for render_item,  render_f in pairs(render_list) do
        if  render_item.salvage then
        --print("salvage_call")
            s = render_item:salvage()
        --print("before", #temp_table, s)
            table.insert(temp_table,s)
            --print("after", #temp_table, s,"\n")
        end
    end
    --print("um")
    settings.salvage_list = temp_table
    --print("done", #settings.salvage_list, s)


end
math.randomseed( os.time() )
play_sound_wrapper("audio/Air Combat Launch.mp3")

screen:show()
