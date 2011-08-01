
screen:show()

screen_w = screen.w
screen_h = screen.h

function sin(t) return math.sin(math.pi/180*t) end
function cos(t) return math.cos(math.pi/180*t) end
function tan(t) return math.tan(math.pi/180*t) end


--define the scale to the physics engine
physics.pixels_per_meter = 200

-- Gravity
physics.gravity = { 0 , 15 }

CATEGORY_UNCOLLIDABLE = 1
CATEGORY_PLATFORM     = 2
CATEGORY_PANDA_BODY   = 3
CATEGORY_PANDA_FEET   = 4
CATEGORY_ITEM         = 5
CATEGORY_ALL          = 5

uncollidable_filter = {
	--group = -1,
	category = CATEGORY_UNCOLLIDABLE,
	--mask = {}
}
panda_body_filter = {
	--group = -1,
	category = CATEGORY_PANDA_BODY,
	mask = {CATEGORY_ITEM}
}
panda_hopper_surface_filter = {
	category = CATEGORY_PANDA_FEET,
	mask = {
		CATEGORY_ITEM,
		CATEGORY_PLATFORM,
	}
}
surface_filter = {
	category = CATEGORY_PLATFORM,
	mask = {
		CATEGORY_PANDA_FEET,
	}
}
items_filter = {
	category = CATEGORY_ITEM,
	mask = {
		CATEGORY_PANDA_FEET,
		CATEGORY_PANDA_BODY,
	}
}
all_filter = {
	category = CATEGORY_ALL,
	mask = {
		CATEGORY_UNCOLLIDABLE,
		CATEGORY_PLATFORM,    
		CATEGORY_PANDA_BODY,  
		CATEGORY_PANDA_FEET,  
		CATEGORY_ITEM,        
		CATEGORY_ALL         
	}
}

to_be_deleted = {}
--------------------------------------------------------------------------------
-- Layers - prevents the need to call raise_to_top
--------------------------------------------------------------------------------
layers = {
	clone_srcs = Group{ name = "LAYER - clone_srcs" },
	bg         = Group{ name = "LAYER -         bg" },
	ground     = Group{ name = "LAYER -     ground" },
	branches   = Group{ name = "LAYER -   branches" },
	items      = Group{ name = "LAYER -      items" },
	hopper     = Group{ name = "LAYER -     hopper" },
	hud        = Group{ name = "LAYER -        hud" },
	menu       = Group{ name = "LAYER -       menu" },
}

screen:add(
	layers.clone_srcs,
	layers.bg,
	layers.ground,   
	layers.branches, 
	layers.items,    
	layers.hopper,   
	layers.hud,      
	layers.menu     
)

layers.hopper.opacity = 0









highscores = settings.highscores

if highscores == nil then
	
	highscores = {}
	
	for i = 1 , 8 do
		
		highscores[i] = {name = "AAA", score = 0}
		
	end
	
end

app.on_closing = function()
	settings.highscores = highscores
end
--------------------------------------------------------------------------------
-- pandamonium text - creates the gradient and inner glow effects
--------------------------------------------------------------------------------

colors = {
	
	yellow = {
		top_g  = "ffe44a",
		btm_g  = "815e13",
		stroke = "2d2c17",
		glow   = {255,240,30},
	},
	
	green = {
		top_g  = "e2e92c",
		btm_g  = "5d8917",
		stroke = "2f3a24",
		glow   = {199,241,30},
	}
	
}

local shadow_offset = 10

make_text = function(t,color)
	
	local c = Canvas(t.w+shadow_offset,t.h+shadow_offset)
	
	c.line_join="ROUND"
	
	c:move_to(shadow_offset/2,shadow_offset/2)
	
	c:set_source_color({0,0,0,32})
	c:text_element_path(t)
	
	c:fill(true)
	for i = 20,6,-2 do
		c.line_width = i
		c:set_source_color({0,0,0,26-i})
		c:stroke(true)
	end
	
	c:new_path()
	
	c:move_to(0,0)
	c:text_element_path(t)
	c:clip(true)
	c:set_source_linear_pattern( c.w/2, 0, c.w/2, c.h-shadow_offset )
	c:add_source_pattern_color_stop( 0, colors[color].top_g)--"e2e92c" ) 
	c:add_source_pattern_color_stop( 1, colors[color].btm_g)--"5d8917" ) 
	c:fill(true)
	
	
	
	for i = 28,6,-2 do
		c.line_width = i
		colors[color].glow[4] = 30-i
		c:set_source_color(colors[color].glow)--{199,241,30,30-i})
		c:stroke(true)
	end
	
	
	c:reset_clip()
	
	c.line_width = 2
	c:set_source_color(colors[color].stroke)--"2f3a24")
	c:stroke(true)
	
	return c:Image{
		position     = t.position,
		anchor_point = {t.w/2-shadow_offset,t.h/2-shadow_offset}
	}
end







--------------------------------------------------------------------------------
-- dofiles - the only globals are what you see here
--           no globals are declared within the files
--------------------------------------------------------------------------------

-- declares in the Enumeration class
Enum               = dofile("Utils.lua")

-- use the Enum as a state machine
GameState          = Enum{ "OFFLINE", "SPLASH", "GAME", "SAVE_HIGHSCORE","VIEW_HIGHSCORE"}

Animation_Loop     = dofile("Animation_Loop.lua")

assets, bg, coin_src, sparkles_src = dofile("Assets.lua")

hud                = dofile("hud.lua")

panda              = dofile("Panda.lua")

Splash             = dofile("Splash_Menu.lua")

Play_Again         = dofile("Play_Again_Menu.lua")

Effects            = dofile("Effects.lua")

Coin, firework     = dofile("Items.lua")

branch_constructor = dofile("Branches.lua")

World              = dofile("GameWorld.lua")

--physics.on_step    = dofile("GameLoop.lua")

physics.on_step    = Animation_Loop.loop
--Splash:fade_in()
GameState:change_state_to("SPLASH")













--









function controllers.on_controller_connected( controllers , controller )
	--setup the accelerometer callbacks
	if controller.has_accelerometer then
		local max_vx = 5
		controller.on_accelerometer = function(self, x, y, z)
			
			
			
			
			panda:set_vx(10*x)
			
			---[[
			
			--]]
			--[[
			if x < 0 then
				
				
			else
			end
			
			panda:impulse(x*3,0)
			--]]
			
		end
		
		
		controller:start_accelerometer("L",.1)
	end
end