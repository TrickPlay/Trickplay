--[[
    Air Combat
--]]

my_font = "kroeger 06_65 40px"

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
	name     = "arrow",
	src      = "assets/splash/Arrow.png",
	position = {screen_w/2-300,screen_h/2+240}
    }
)
local splash_i = 1
local splash_limit = 1
if type(settings.salvage_list) == "table" and #settings.salvage_list > 0 then
    layers.splash:add(
        Text{text="Continue Old Game",font=my_font,color = "FFFFFF", x = screen_w/2, y = screen_h/2+240},
        Text{text="Start New Game",font=my_font,color = "FFFFFF", x = screen_w/2, y = screen_h/2+300}
    )
    splash_limit = 2
else
    layers.splash:add(
        Text{text="Start New Game",font=my_font,color = "FFFFFF", x = screen_w/2, y = screen_h/2+240}
    )
end
layers.splash:add(
        Text{name="level report",text="",font=my_font,color = "FFFFFF", x = screen_w/2, y = screen_h/2-240}
    )
layers.splash:add(
        Text{name = "Next Level",text="Next Level",font=my_font,color = "FFFFFF", x = screen_w/2, y = screen_h/2+240, opacity=0},
        Text{name = "Replay Level",text="Replay Level",font=my_font,color = "FFFFFF", x = screen_w/2, y = screen_h/2+300, opacity=0}
    )
    layers.splash:add(
        Text{name = "save",text="Save and Exit",font=my_font,color = "FFFFFF", x = screen_w/2, y = screen_h/2+240, opacity=0},
        Text{name = "exit",text="Exit",font=my_font,color = "FFFFFF", x = screen_w/2, y = screen_h/2+300, opacity=0}
    )
layers.splash:foreach_child(function(c)
    c.anchor_point = {c.w/2,c.h/2}
end)


function start_game()
add_to_render_list( my_plane )
end
add_to_render_list( lvlbg[1] )

--add_to_render_list( enemies )

--------------------------------------------------------------------------------

--modal menus
dofile("menus.lua")
game_over_save = Menu_Game_Over_Save_Highscore()
game_over_no_save = Menu_Game_Over_No_Save()
high_score_menu = Menu_High_Scores()
level_completed = Menu_Level_Complete()

game_over_save:set_ptr_to_h_scores(high_score_menu)
game_over_no_save:set_ptr_to_h_scores(high_score_menu)

level_completed:set_ptr_to_g_over(game_over_save)


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
    layers.splash:foreach_child(function(c)
        c.opacity = 0
    end)
end

lvl_end_i = 1
--------------------------------------------------------------------------------
-- Event handler
local keys = {
    ["SPLASH"] =
    {
        [keys.Up] = function()
            if splash_i - 1 >= 1 then
                splash_i = splash_i - 1
                layers.splash:find_child("arrow").y = screen_h/2+240 +60*(splash_i-1)
            end
        end,
        [keys.Down] = function()
            if splash_i + 1 <= splash_limit then
                splash_i = splash_i + 1
                layers.splash:find_child("arrow").y = screen_h/2+240 +60*(splash_i-1)
            end
        end,
        [keys.Return] = function()
            
            if splash_i == 1 and splash_limit == 2 then
                out_splash__in_hud()
                recurse_and_apply(state,settings.state)
                
                if state.in_lvl_complete then
                    level_completed:animate_in(string.format("%06d",state.menu))
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
                    local f
                    for _,i in ipairs(settings.salvage_list) do
                        f = _G
                        for j = 1,#i.func do
                            print(i.func[j])
                            f = f[ i.func[j] ]
                        end
                        print("done\n\n")
                        f(unpack(i.table_params))
                        print("?")
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
                print("done done")
            else
                out_splash__in_hud()
                
                state.curr_mode  = "CAMPAIGN"
                state.curr_level = 1
                
                add_to_render_list(my_plane)
                add_to_render_list(levels[state.curr_level])
            end
            
            
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
            
            state.curr_mode  = "CAMPAIGN"
            state.curr_level = 2
            
            add_to_render_list(my_plane)
            remove_from_render_list(lvlbg[1])
            add_to_render_list(lvlbg[2])

            add_to_render_list(levels[state.curr_level])
            
        end,
        [keys["3"]] = function()
            
            out_splash__in_hud()
            
            state.curr_mode  = "CAMPAIGN"
            state.curr_level = 3
            
            add_to_render_list(my_plane)
            remove_from_render_list(lvlbg[1])
            add_to_render_list(lvlbg[3])

            add_to_render_list(levels[state.curr_level])
            
        end,
        [keys["4"]] = function()
            
            out_splash__in_hud()
            
            state.curr_mode  = "CAMPAIGN"
            state.curr_level = 4
            
            add_to_render_list(my_plane)
            remove_from_render_list(lvlbg[1])
            add_to_render_list(lvlbg[4])

            add_to_render_list(levels[state.curr_level])
            
        end,
        [keys.o] = function()
            
            if type(settings.salvage_list) == "table" and #settings.salvage_list > 0 then
                print("salvage list is size ",#settings.salvage_list)
                out_splash__in_hud()
                local f
                for _,i in ipairs(settings.salvage_list) do
                    f = _G
                    for j = 1,#i.func do
                        print(i.func[j])
                        f = f[ i.func[j] ]
                    end
                    print("done\n\n")
                    f(unpack(i.table_params))
                    print("?")
                end
                
                recurse_and_apply(state,settings.state)
                redo_score_text()
                for i = 1, state.hud.num_lives do
                    lives[i].opacity=255
                end
                
                print("done done")
            else
                print("No salvage list saved, cannot restore an old game")
            end

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
        [keys.p] = function()
            enemies.jeep(false,500,-100)
        end,
        --bosses
        [keys.m] = function()
            enemies.zeppelin(900)
        end,
        [keys.n] = function()
            enemies.battleship(500,300, 40,true)
        end,
        [keys.b] = function()
            enemies.destroyer(500,300, 40,true)
        end,
        [keys.l] = function()
            enemies.trench(500)
        end,
        [keys.k] = function()
            add_to_render_list(enemies.big_tank(),200,200)
        end,
        [keys.v] = function()
            enemies.final_boss(false)
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
        


--print("\n")
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
    
    settings.salvage_list = {}
    print("start")
    local temp_table = {}
    local s
    for render_item,  render_f in pairs(render_list) do
        if  render_item.salvage then
        print("salvage_call")
            s = render_item:salvage()
        print("before", #temp_table, s)
            table.insert(temp_table,s)
            print("after", #temp_table, s,"\n")
        end
    end
    print("um")
    dumptable(temp_table)
    settings.salvage_list = temp_table
    print("done", #settings.salvage_list, s)
    settings.state = {}
    temp_table = {}
    recurse_and_apply(temp_table, state)
    settings.state = temp_table
    --dumptable(temp_table)
    --dumptable(settings.state)--]]
end
math.randomseed( os.time() )
mediaplayer:play_sound("audio/Air Combat Launch.mp3")

screen:show()
