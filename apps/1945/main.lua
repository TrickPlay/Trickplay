
dofile( "controller.lua" )
dofile("hud.lua")

-- Alex's code

game_is_running = false
local splash = Group{z=10}
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
    water           = Image{ src = "assets/water.png" },
    my_plane_strip  = Image{ src = "assets/my_plane.png" },
    my_bullet       = Image{ src = "assets/bullet.png" },
    enemy1          = Image{ src = "assets/e1_4x_test.png" },
    enemy2          = Image{ src = "assets/e2_4x_test.png" },
    enemy3          = Image{ src = "assets/e3_4x_test.png" },
    enemy_bullet    = Image{ src = "assets/enemybullet1.png" },
    explosion1      = Image{ src = "assets/explosion1_strip6.png" },
    explosion2      = Image{ src = "assets/explosion2_strip7.png" },
    island1         = Image{ src = "assets/island1.png" },
    island2         = Image{ src = "assets/island2.png" },
    island3         = Image{ src = "assets/island3.png" },
    score           = Text{ font = "Highway Gothic Wide 24px" , text = "+10" , color = "FFFF00" },
    g_over          = Text{ font = "Highway Gothic Wide 24px" , text = "GAMEOVER" , color = "FFFFFF" },
    up_life         = Text{ font = "Highway Gothic Wide 24px" , text = "+1 Life"  , color = "FFFFFF" },
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

add_to_render_list( enemies )


paused = false

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
       
            pcall( item.render , item , seconds ) 

        end
        
        process_collisions( )
        
    end
    
end

-------------------------------------------------------------------------------
-- Event handler

function screen.on_key_down( screen , key )

    if not game_is_running then
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
    elseif key == keys.space then
        
        paused = not paused
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
