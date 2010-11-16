--[[
    Air Combat
--]]

my_font = "kroeger 06_65 40px"


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
dofile("Levels.lua")

--The splash Items
layers.splash:add(
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
    },
    Image
    {
	name     = "start",
	src      = "assets/splash/StartButton.png",
	position = {screen_w/2,screen_h/2+240}
    }
)
layers.splash:foreach_child(function(c)
    c.anchor_point = {c.w/2,c.h/2}
end)


function start_game()
add_to_render_list( my_plane )
end
add_to_render_list( lvlbg[1] )

--add_to_render_list( enemies )

-------------------------------------------------------------------------------



local test_text = Text
	{
	    font = my_font,
	    text =  "Test Mode\n\n"..
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
    layers.splash.opacity = 0
end
-------------------------------------------------------------------------------
-- Event handler
local keys = {
    ["SPLASH"] =
    {
        [keys.Return] = function()
            
            out_splash__in_hud()
            
            state.curr_mode  = "CAMPAIGN"
            state.curr_level = 1
            
            my_plane.bombing_mode = false
            add_to_render_list(my_plane)
            add_to_render_list(levels[state.curr_level])
            
        end,
        [keys.t] = function()
            
            out_splash__in_hud()
            my_plane.bombing_mode = false
            
            state.curr_mode  = "TEST_MODE"
            state.curr_level = 0
            add_to_render_list(my_plane)
            test_text.opacity = 255
            
        end,
        [keys["2"]] = function()
            
            out_splash__in_hud()
            my_plane.bombing_mode = true
            
            state.curr_mode  = "CAMPAIGN"
            state.curr_level = 2
            
            add_to_render_list(my_plane)
            remove_from_render_list(lvlbg[1])
            add_to_render_list(lvlbg[2])
            my_plane.shadow.opacity = 255
            my_plane.bombing_crosshair.opacity = 255
            add_to_render_list(levels[state.curr_level])
            
        end,
        [keys["3"]] = function()
            
            out_splash__in_hud()
            my_plane.bombing_mode = true
            
            state.curr_mode  = "CAMPAIGN"
            state.curr_level = 3
            
            add_to_render_list(my_plane)
            remove_from_render_list(lvlbg[1])
            add_to_render_list(lvlbg[3])
            my_plane.shadow.opacity = 255
            my_plane.bombing_crosshair.opacity = 255
            add_to_render_list(levels[state.curr_level])
            
        end,
    },
    ["TEST_MODE"] =
    {
        --enemies
        [keys.q] = function()
            formations.row_from_side(5,150,  -100,1000,  50,300,  200)
        end,
        [keys.w] = function()
            formations.row_from_side(5,150,  screen_w+100,1000,  screen_w-50,300,  screen_w-200)
        end,
        [keys.e] = function()
            formations.one_loop(2,150,200,200,300,-1)
        end,
        [keys.r] = function()
            formations.one_loop(2,150,screen_w-200,screen_w-200,300,1)
        end,
        [keys.t] = function()
            formations.cluster(500)
        end,
        [keys.y] = function()
            formations.zig_zag(500,400,-30)
        end,
        [keys.u] = function()
            add_to_render_list(enemies.turret(),500,-100)
        end,
        [keys.i] = function()
            formations.hor_row_tanks(1,-200,3,150)
        end,
        [keys.o] = function()
            formations.vert_row_tanks(200,-1,3,150)
        end,
        --bosses
        [keys.m] = function()
            formations.zepp_boss(900)
        end,
        [keys.n] = function()
            add_to_render_list(enemies.battleship(),500,300, 40,true)
        end,
        [keys.b] = function()
            add_to_render_list(enemies.destroyer(),500,300, 40,true)
        end,
        --powerups
        [keys.z] = function()
            add_to_render_list(powerups.guns(300))
        end,
        [keys.x] = function()
            add_to_render_list(powerups.health(500))
        end,
        [keys.c] = function()
            add_to_render_list(powerups.life(400))
        end,
        --other
        [keys.s] = function()
            water:add_dock(1,1)
            --add_to_render_list(smoke())
        end,
        [keys.h] = function()
            if test_text.opacity == 255 then
                test_text.opacity = 0
            else
                test_text.opacity = 255
            end
        end,
        [keys["1"]] = function()
            remove_from_render_list(lvlbg[state.curr_level])
            state.curr_level = 1
            add_to_render_list(lvlbg[state.curr_level])
        end,
        [keys["2"]] = function()
            remove_from_render_list(lvlbg[state.curr_level])
            state.curr_level = 2
            add_to_render_list(lvlbg[state.curr_level])
        end,
        [keys["3"]]= function()
            remove_from_render_list(lvlbg[state.curr_level])
            state.curr_level = 3
            add_to_render_list(lvlbg[state.curr_level])
        end,
        [keys["4"]] = function()
            my_plane.firing_powerup=4
        end,
        [keys["5"]] = function()
            my_plane.firing_powerup=5
        end,
        [keys["9"]] = function()
            my_plane:hit()
        end,
        [keys["0"]] = function()
            my_plane:heal()
        end,
        [keys["8"]] = function()
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
    }
}

local press
local second_press
--moves through all the items in the render list
--i.e. performs the game loop
function idle.on_idle( idle , seconds )
    if press ~= nil then
        if press == keys.Space then
            state.paused = not state.paused
        elseif keys[state.curr_mode][press] then keys[state.curr_mode][press]()--second_press)
        end
        press = nil
        --second_press = nil
    end
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
        for item,render in pairs( render_list ) do
            render( item , seconds ) 
        end

        process_collisions( )
        
    end
    
end

local double_press = false
local double_press_timer = Timer{interval=500}
double_press_timer.on_timer = function()
    double_press_timer:stop()
    double_press = false
end
function screen.on_key_down( screen , key )
--[[
    if double_press  then
        second_press = key
        if press == nil then
            press = key
        end
        double_press_timer:stop()
        double_press = false
        print("dub press")
    else--]]
        press = key
        --if second_press ~= nil then
        --    second_press = nil
        --end
        --double_press_timer:start()
        --double_press = true
    --end
--[[
    assert(keys[state.curr_mode])
    
    if state.paused == true and key == keys.Space then
        state.paused = false
    elseif keys[state.curr_mode][key] then keys[state.curr_mode][key]()
    end
    --]]
--[[
    if not game_is_running then
		if key == keys.Return then
	        
            start_game()
			splash.opacity = 0
			game_is_running = true
			--end_game.opacity = 0
			number_of_lives = 3
			point_counter = 0
			redo_score_text()
			lives[1].opacity=255
			lives[3].opacity=255
			lives[2].opacity=255
			add_to_render_list(levels[1])
			state.curr_mode  = "LEVEL 1"
			state.curr_level = 1
			add_to_render_list( my_plane )
            
		elseif key == keys.t then
			state.curr_mode = "TEST MODE"
			splash.opacity = 0
			game_is_running = true
			--end_game.opacity = 0
			number_of_lives = 3
			point_counter = 0
			redo_score_text()
			lives[1].opacity=255
			lives[3].opacity=255
			lives[2].opacity=255
			add_to_render_list( test_text() )
			add_to_render_list( my_plane )
            
            
		end
    elseif key == keys.space then
        
        paused = not paused
    elseif not paused then
    
        for _ , item in ipairs( render_list ) do
       
            pcall( item.on_key , item , key )
       
        end

    end
	if state.curr_mode == "TEST MODE" then
		if key == keys.q then
			--add_to_render_list(formations.row_fly_in_left,50,200)
                        formations.row_from_side(5,150,  -100,1000,  50,300,  200)
		elseif key == keys.p then
			--add_to_render_list(formations.row_fly_in_right,2000,1500)
                        formations.row_from_side(5,150,  screen.w+100,1000,  screen.w-50,300,  screen.w-200)
		elseif key == keys.a then
			--add_to_render_list(formations.loop_from_left)
                        formations.one_loop(2,150,200,200,300,-1)
		elseif key == keys.l then
			--add_to_render_list(formations.loop_from_right)
                        formations.one_loop(2,150,1200,1200,300,1)
		elseif key == keys.z then
			--add_to_render_list(formations.zepp, 150,-400, false )
                        formations.zepp_boss(900)
		elseif key == keys.h then
			add_to_render_list(test_text)
		elseif key == keys["1"] then
			my_plane.firing_powerup=1
		elseif key == keys["2"] then
			my_plane.firing_powerup=2
		elseif key == keys["3"] then
			my_plane.firing_powerup=3
		elseif key == keys["4"] then
			my_plane.firing_powerup=4
		elseif key == keys["5"] then
			my_plane.firing_powerup=5
		end
	end
    --]]
end

-------------------------------------------------------------------------------
--saves high score
function app:on_closing()
	settings.high_score = high_score
end
math.randomseed( os.time() )
mediaplayer:play_sound("audio/Air Combat Launch.mp3")

screen:show()
