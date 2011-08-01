local Splash = Group{name = "Splash",opacity = 0}

local sel_scale = 1.2

local unsel_scale = 1

--Visual Components
local title      = Text{--Clone{
	--source       = assets.title,
	font         = "Baveuse 130px",
	text         = "Pandamonium",
	color        = "ffffff",
	position     = {screen.w/2, 80}
	
}

title = make_text(title,"green")

local start     = Text{--Clone{
	--source       = assets.title,
	font         = "Baveuse 70px",
	text         = "START",
	color        = "ffffff",
	position     = {screen.w/2, 250}
	
}
start = make_text(start,"green")

local h_score     = Text{--Clone{
	--source       = assets.title,
	font         = "Baveuse 70px",
	text         = "highscores",
	color        = "ffffff",
	position     = {screen.w/2, 350}
	
}
h_score = make_text(h_score,"green")

local quit       = Text{--Clone{
	--source       = assets.title,
	font         = "Baveuse 70px",
	text         = "QUIT",
	color        = "ffffff",
	position     = {screen.w/2, 450}
	
}
quit = make_text(quit,"green")
--[[
local arrow      = Clone{
	source       = assets.arrow,
	anchor_point = {assets.arrow.w, assets.arrow.h/2},
	position     = {screen.w/2-50, start.y},
}
--]]
Splash:add(title,start,h_score,quit)--,arrow)


--arrow index, and its selectable items
local index = 1

local menu_items = {
	start,
	h_score,
	quit
}

--the move animation for the arrow
--[[
do
	local curr_y = 0
	
	function arrow:move_to(i)
		
		curr_y = arrow.y
		
		arrow:complete_animation()
		
		arrow.y = curr_y
		
		arrow:animate{
			duration = 200,
			y        = menu_items[i].y
		}
	end
end
--]]
local mag = .02

local first_pass = true

local wobble = Timeline{
	
	duration     = 700,
	loop         = true,
	on_new_frame = function(_,ms,p)
		
		if first_pass then
			
			mag = .03 + .2*(1-p)
			
		end
		
		menu_items[index].scale = {
			sel_scale+mag*math.sin(math.pi*2*p),
			sel_scale-mag*math.sin(math.pi*2*p)
		}
		--[[
		menu_items[index].z_rotation = {
			.5*math.sin(math.pi*2*p),
			0,0
		}
		--]]
	end,
	on_completed = function() first_pass = false end
}

local curr_scale, curr_o = 0, 0 
local function select(i)
	
	if index == i then return end
	
	assert(
		i > 0    and    i <= # menu_items,
		"Tried to select "..i.." in the 'Start' menu"
	)
	
	wobble:stop()
	
	first_pass = true
	
	curr_scale = menu_items[index].scale[1]
	
	curr_o     = menu_items[index].opacity
	
	menu_items[index]:complete_animation()
	
	menu_items[index].scale   = { curr_scale, curr_scale }
	
	menu_items[index].opacity = curr_o
	
	
	curr_scale = menu_items[i].scale[1]
	
	curr_o     = menu_items[i].opacity
	
	menu_items[i]:complete_animation()
	
	menu_items[i].scale   = { curr_scale, curr_scale }
	
	menu_items[i].opacity = curr_o
	
	
	menu_items[index]:animate{
		duration   = 100,
		scale      = { unsel_scale, unsel_scale },
		z_rotation = 0,
		opacity    = 255*.7,
	}
	
	menu_items[i]:animate{
		duration     = 100,
		scale        = { sel_scale, sel_scale },
		opacity      = 255,
		on_completed = function()
			wobble:start()
		end
	}
	
	index = i
	
end

--the press enter functions
function quit:press_enter()    exit()    end

function start:press_enter()    GameState:change_state_to("GAME")    end
function h_score:press_enter()    GameState:change_state_to("VIEW_HIGHSCORE")    end

--the state change animations (fading the Splash screen in and out)
do
	--upval
	local curr_opacity
	
	--fade out
	GameState:add_state_change_function(
		function()
			wobble:stop()
			curr_opacity = Splash.opacity
			
			Splash:complete_animation()
			
			Splash.opacity = curr_opacity
			
			Splash:animate{
				duration = 300,
				opacity  = 0,
			}
		end,
		"SPLASH", nil
	)
	
	--fade in
	GameState:add_state_change_function(
		function()
			
			index = 1
			
			for i,item in pairs(menu_items) do
				
				if i == index then
					
					item.scale = {   sel_scale,   sel_scale }
					
					wobble:start()
					
				else
					
					item.scale = { unsel_scale, unsel_scale }
					
				end
				
			end
			
			--arrow.y = menu_items[index].y
			
			curr_opacity = Splash.opacity
			
			Splash:complete_animation()
			
			Splash.opacity = curr_opacity
			
			Splash:raise_to_top()
			
			Splash:animate{
				duration = 300,
				opacity  = 255,
				on_completed = function()
					screen.on_key_down = Splash.on_key_down
				end
			}
			mediaplayer:play_sound("audio/start-sound.mp3")
		end,
		
		nil, "SPLASH"
	)
end

--Key Handler for the splash screen
do
	
	local keys = {
		
		[keys.Down] = function()
			
			if index == # menu_items then return end
			
			select(index + 1)
			
			--index = index + 1
			
			--arrow:move_to(index)
			
		end,
		[keys.Up] = function()
			
			if index == 1 then return end
			
			select(index - 1)
			
			--index = index - 1
			
			--arrow:move_to(index)
			
		end,
		[keys.OK] = function()
			
			menu_items[index]:press_enter()
			
		end,
	}
	
	function Splash:on_key_down(k)    if keys[k] then    keys[k]()    end    end
end

layers.menu:add(Splash)

return Splash