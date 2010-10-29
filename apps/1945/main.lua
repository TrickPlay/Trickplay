--[[
    Air Combat
--]]


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
local splash = Group{}
splash:add(
    Image
    {
	name     = "logo",
	src      = "assets/splash/AirCombatLogo.png",
	position = {screen.w/2,screen.h/2-80}
    },
    Image
    {
	name     = "instr",
	src      = "assets/splash/InstructionBar.png",
	position = {50,screen.h - 120}
    },
    Image
    {
	name     = "start",
	src      = "assets/splash/StartButton.png",
	position = {screen.w/2,screen.h/2+240}
    }
)
splash:foreach_child(function(c)
    c.anchor_point = {c.w/2,c.h/2}
end)


function start_game()
add_to_render_list( my_plane )
end
add_to_render_list( water )
screen:add(splash)

--add_to_render_list( enemies )

-------------------------------------------------------------------------------


--moves through all the items in the render list
--i.e. performs the game loop
function idle.on_idle( idle , seconds )

    if not paused then

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
        for _ , item in ipairs( render_list ) do
            item.render( item , seconds ) 
        end
	
        process_collisions( )
        
    end
    
end
local test_text = function() return {
	speed = 60,
	text = Text
	{
	    font = my_font,
	    text =  "Test Mode\n\n"..
	            "q    row  in  from  left\n"..
	            "p    row  in  from  right\n"..
	            "a    loop  from  left\n"..
	            "l    loop  from  right\n"..
	            "z    zeppelin\n\n"..
	            "1 2 3 4 5       bullet   powerups\n\n"..
	            "h    to  display  this  text  again",
	    color = "FFFFFF"
	},
    setup = function( self )
        self.text.position     = {    screen.w/2 , 0}
        self.text.anchor_point = { self.text.w/2 , 0}
	    if self.text.parent == nil then
                screen:add( self.text )
	    end
    end,
    render = function( self , seconds )
	    self.text.y = self.text.y + self.speed*seconds
	    if self.text.y > screen.h then
            self.text:unparent()
            remove_from_render_list(self)
	    end
    end,
} end

out_splash__in_hud = function()
    splash.opacity = 0
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
            
            add_to_render_list(my_plane)
            add_to_render_list(levels[state.curr_level])
            
        end,
        [keys.t] = function()
            
            out_splash__in_hud()
            
            state.curr_mode  = "TEST_MODE"
            
            add_to_render_list(my_plane)
            add_to_render_list(test_text())
            
        end,
    },
    ["TEST_MODE"] =
    {
        [keys.q] = function()
            formations.row_from_side(5,150,  -100,1000,  50,300,  200)
        end,
        [keys.p] = function()
            formations.row_from_side(5,150,  screen.w+100,1000,  screen.w-50,300,  screen.w-200)
        end,
        [keys.a] = function()
            formations.one_loop(2,150,200,200,300,-1)
        end,
        [keys.l] = function()
            formations.one_loop(2,150,1200,1200,300,1)
        end,
        [keys.z] = function()
            formations.zepp_boss(900)
        end,
        [keys.h] = function()
            add_to_render_list(test_text())
        end,
        [keys["1"]] = function()
            my_plane.firing_powerup=1
        end,
        [keys["2"]] = function()
            my_plane.firing_powerup=2
        end,
        [keys["3"]]= function()
            my_plane.firing_powerup=3
        end,
        [keys["4"]] = function()
            my_plane.firing_powerup=4
        end,
        [keys["5"]] = function()
            my_plane.firing_powerup=5
        end,
        [keys.Right] = function()
        print("got here")
            my_plane:on_key(keys.Right)
        end,
        [keys.Left] = function()
            my_plane:on_key(keys.Left)
        end,
        [keys.Up] = function()
            my_plane:on_key(keys.Up)
        end,
        [keys.Down] = function()
            my_plane:on_key(keys.Down)
        end,
        [keys.Return] = function()
            my_plane:on_key(keys.Return)
        end,
    },
    ["CAMPAIGN"] =
    {
        [keys.Right] = function()
            my_plane:on_key(keys.Right)
        end,
        [keys.Left] = function()
            my_plane:on_key(keys.Left)
        end,
        [keys.Up] = function()
            my_plane:on_key(keys.Up)
        end,
        [keys.Down] = function()
            my_plane:on_key(keys.Down)
        end,
        [keys.Return] = function()
            my_plane:on_key(keys.Return)
        end,
        [keys.space] = function()
            state.paused = not (state.paused)
        end
    }
}
    
function screen.on_key_down( screen , key )

    assert(keys[state.curr_mode])
    
    if state.paused == true and key == keys.Space then
        state.paused = false
    elseif keys[state.curr_mode][key] then keys[state.curr_mode][key]()
    end
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
screen:show()
