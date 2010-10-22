
dofile( "controller.lua" )
dofile("hud.lua")
curr_level = nil
-- Alex's code

game_is_running = false
splash = Group{z=10}
splash:add(

    Image{ name = "logo",src = "assets/splash/AirCombatLogo.png", position = {screen.w/2,screen.h/2-80}},
    Image{ name = "instr", src = "assets/splash/InstructionBar.png", position = {50,screen.h - 120}},
    Image{ name = "start",src = "assets/splash/StartButton.png", position = {screen.w/2,screen.h/2+240}}
)
local logo = splash:find_child("logo")
logo.anchor_point = {logo.w/2,logo.h/2}
--[[
local instr = splash:find_child("instr")
instr.anchor_point = {instr.w/2,instr.h/2}
--]]
local startt = splash:find_child("start")
startt.anchor_point = {startt.w/2,startt.h/2}
screen:add(splash)
-------------------------------------------------------------------------------

function clamp( v , min , max )

    if v < min then return min        
    elseif v > max then return max        
    else return v        
    end

end

-------------------------------------------------------------------------------

assets =
{
    water           = Image{ src  = "assets/water.png" },
    my_plane_strip  = Image{ src  = "assets/player.png" },
    my_bullet       = Image{ src  = "assets/bullet.png" },
    enemy1          = Image{ src  = "assets/e1_4x_test.png" },
    enemy2          = Image{ src  = "assets/e2_4x_test.png" },
    enemy3          = Image{ src  = "assets/e3_4x_test.png" },
    enemy_bullet    = Image{ src  = "assets/enemybullet1.png" },
    explosion1      = Image{ src  = "assets/explosion1_strip6.png" },
    explosion2      = Image{ src  = "assets/explosion2_strip7.png" },
    island1         = Image{ src  = "assets/island1.png" },
    island2         = Image{ src  = "assets/island2.png" },
    island3         = Image{ src  = "assets/island3.png" },
    score           = Text{  font = my_font , text = "+10" , color = "FFFF00" },
    g_over          = Text{  font = my_font , text = "GAMEOVER" , color = "FFFFFF" },
    up_life         = Text{  font = my_font , text = "+1 Life"  , color = "FFFFFF" },
    level1          = Text{  font = my_font , text = "LEVEL 1"  , color = "FFFFFF" },
	prop1           = Image{ src  = "assets/prop1.png" },
	prop2           = Image{ src  = "assets/prop2.png" },
	prop3           = Image{ src  = "assets/prop3.png" },
	gun_l			= Image{ src  = "assets/cannon_left.png" },
	gun_r			= Image{ src  = "assets/cannon_right.png" },
}
for _ , v in pairs( assets ) do
    
    v.opacity = 0
        
    screen:add( v )
    
end

-------------------------------------------------------------------------------

ENEMY_PLANE_MIN_SPEED       = 105

ENEMY_PLANE_MAX_SPEED       = 150

ENEMY_FREQUENCY             = 1--0.8

ENEMY_SHOOTER_PERCENTAGE    = 20--deprecated

-------------------------------------------------------------------------------
dofile("GameLoop.lua")
-------------------------------------------------------------------------------
-- This one deals with the water and occasional islands
dofile("land.lua")
-------------------------------------------------------------------------------
-- This is my plane. It spawns bullets
dofile("my_plane.lua")
-------------------------------------------------------------------------------
-- This thing renders nothing, it just spawns enemies

dofile("enemies.lua")
-------------------------------------------------------------------------------
-- This table contains all the things that are moving on the screen
function start_game()
add_to_render_list( my_plane )
end
add_to_render_list( water )

--add_to_render_list( enemies )


paused = false




dofile("Levels.lua")
-------------------------------------------------------------------------------

screen:show()


-------------------------------------------------------------------------------
-- Game loop, renders everything in the render list
--[[
--Pablo's performance measuring code
local c = 0
local t = 0
local ma = 0
local mi = 1000
local sw = Stopwatch()
--]]
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

-------------------------------------------------------------------------------
-- Event handler

function screen.on_key_down( screen , key )

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
			curr_level = levels[1]
		elseif key == keys.t then
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
			add_to_render_list({
                                speed = 40,
                                text = Text{font = my_font , text = "Test Mode"  , color = "FFFFFF"},
                                
                                setup = function( self )
                                        self.text.position = { screen.w/2,screen.h/2}
                                        self.text.anchor_point = { self.text.w / 2 , self.text.h / 2 }
                                        self.text.opacity = 255;
                                        screen:add( self.text )
                                    end,
                                    
                                render = function( self , seconds )
                                        local o = self.text.opacity - self.speed * seconds
                                        local scale = self.text.scale
                                        scale = { scale[ 1 ] + ( 2 * seconds ) , scale[ 2 ] + ( 2 * seconds ) }
                                        if o <= 0 then
                                            remove_from_render_list( self )
                                            screen:remove( self.text )
                                        else
                                            self.text.opacity = o
                                            self.text.scale = scale
                                        end
                                    end,
                            })

		end
    elseif key == keys.space then
        
        paused = not paused
	elseif key == keys.q then
		add_to_render_list(formations.row_fly_in_left,50,200)
	elseif key == keys.p then
		add_to_render_list(formations.row_fly_in_right,2000,1500)
	elseif key == keys.a then
		add_to_render_list(formations.loop_from_left)
	elseif key == keys.l then
		add_to_render_list(formations.loop_from_right)
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
    elseif not paused then
    
        for _ , item in ipairs( render_list ) do
       
            pcall( item.on_key , item , key )
       
        end

    end
	
end

-------------------------------------------------------------------------------
--saves high score
function app:on_closing()
	settings.high_score = high_score
end
math.randomseed( os.time() )
