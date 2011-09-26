--print = function() end

local splash_bg = Image{name="Splash BG", src = "splash.png" }

local function main()
	
	
	mediaplayer.on_loaded = mediaplayer.play

	math.randomseed(os.time())
	
	--CONSTANTS
	--	Global
	function sin(val) return math.sin(math.pi/180*val) end
	function cos(val) return math.cos(math.pi/180*val) end
	function tan(val) return math.tan(math.pi/180*val) end
	
	pixels_per_mile = 70
	PIXELS_PER_MILE = 70
	lane_dist = 960*2/3
	NUM_LANES = 4
	screen_w = screen.w
	screen_h = screen.h
	DRAW_THRESH = 50000
	
	--local braking_rate = 100/4.32
	--local damping_effect = 1000
	
	
	--possible lane positions for spawned selfs
	local pos = {
		-lane_dist*3/2,
		-lane_dist/2,
		lane_dist/2,
		lane_dist*3/2
	}
	
	
	--	Local
	STRAFE_CAP      = 1300
	total_dead_time = 3
	
	io = {
		throttle_position = 0,
		turn_impulse      = 0,
	}
	
	
	
	
	
	--group that contains all of the clone sources
	clone_sources = Group{
		name="clone_sources",
		extra = {
			--this function receives a table, recurses through it,
			--adding all Trickplay objects found
			add_all = function(self,table,ignore)
				
				assert(type(table) == "table", "")
				
				for _,v in pairs(table) do
					if type(v) == "table" then
						self:add_all(v,ignore)
					elseif type(v) == "userdata" then
						self:add(v)
					--if user opted to ignore non-userdata entries
					elseif ignore ~= true then
						error(
							"Group "..self.name.." in function \"add_all(table t)\""..
							" encountered a table entry or type \""..type(v).."\", key \""..
							k.."\" and value \""..v.."\". Entries need to be of type \"table\""..
							" or of type \"userdata\" (TP Object)"
						)
					end
				end
			end
		}
	}
	screen:add(clone_sources)
	clone_sources:hide()
	
	
	
	
	dofile("Utils.lua")
	
	STATES, Game_State, Idle_Loop = dofile("App_Framework.lua")
	
	hud, splash, end_game = dofile("HUD, Splash, End_Game.lua")
	
	dofile("User_Input.lua")
	
	Doodads = dofile("Doodads.lua")

	sections = dofile("Sections.lua")
	
	world, road = dofile("3D_World.lua")
	
	user_car = dofile("User_Car.lua")
	
	Doodads.user_car_ref = user_car
	
	world.other_cars_ref = dofile("Other_Cars.lua")
	
	splash_bg:raise_to_top()
	
	screen:add(hud,splash,end_game)
	
	Game_State:add_state_change_function(
		function(old_state,new_state)
			screen:remove(splash_bg)
			splash_bg = nil
			print("gggg")
		end,
		STATES.SPLASH,
		STATES.PLAYING
	)
	Game_State:change_state_to(STATES.SPLASH)
	
	Idle_Loop:resume()
	app.on_closing = function()
		settings.highscore = Game_State.highscore
	end
	
	--remove any temporary variables,tables, or functions that were created in
	--the setting up of this app
	collectgarbage("collect")
end
-------------------------------------------------------------------------------

Assets = dofile( "Assets" )

do

    local r = Rectangle
    {
        color = "00000099",
        size = { 0 , 20 },
        x = 10,
        y = screen.h - 26
    }
    
    splash_bg.scale = { screen.w / splash_bg.w , screen.h / splash_bg.h }
    screen:add( splash_bg , r )
    screen:show()
    
    local function progress( percent , src , failed )
        r.w = ( screen.w - 20 ) * percent
    end
    
    local function finished()
        screen:remove( r )
        r = nil
        main()
    end
    
    Assets:queue_app_contents()
    
    Assets:load( progress , finished )
end
