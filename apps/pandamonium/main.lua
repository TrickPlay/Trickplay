
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

to_be_deleted = {}
-----------------------------------------------------
-- Layers - prevents the need to call raise_to_top
-----------------------------------------------------
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

-----------------------------------------------------
-- dofiles - the only globals are what you see here
--           no globals are declared within the files
-----------------------------------------------------

-- declares in the Enumeration class
Enum               = dofile("Utils.lua")

-- use the Enum as a state machine
GameState          = Enum{"OFFLINE", "SPLASH", "GAME", "PLAY_AGAIN"}

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

physics.on_step    = dofile("GameLoop.lua")

physics.on_step    = Animation_Loop.loop
--Splash:fade_in()
GameState:change_state_to("SPLASH")