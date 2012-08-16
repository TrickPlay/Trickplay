local Splash = Group{name = "Splash",opacity = 0}

local sel_scale = 1.2

local unsel_scale = 1

local menu_items = {}
--Visual Components

local scrim = Rectangle{size = screen.size,color="000000",opacity = 0}


do
	local title      = Text{--Clone{
		--source       = assets.title,
		font         = "Sigmar 160px",
		text         = "Pandamonium",
		color        = "ffffff",
		position     = {screen.w/2, 110}
		
	}
	
	title = make_text(title,"green")
	
	local start     = Text{--Clone{
		--source       = assets.title,
		font         = "Sigmar 70px",
		text         = "Play",
		position     = {screen.w/2, 300}
		
	}
	start = make_text(start,"green")
	
	local h_score     = Text{--Clone{
		--source       = assets.title,
		font         = "Sigmar 70px",
		text         = "highscores",
		position     = {screen.w/2, start.y+100}
		
	}
	h_score = make_text(h_score,"green")
	
	local help       = Text{--Clone{
		--source       = assets.title,
		font         = "Sigmar 70px",
		text         = "help",
		position     = {screen.w/2, h_score.y+100}
		
	}
	help = make_text(help,"green")
	
	local quit       = Text{--Clone{
		--source       = assets.title,
		font         = "Sigmar 70px",
		text         = "QUIT",
		position     = {screen.w/2, help.y+100}
		
	}
	quit = make_text(quit,"green")
	
	
	--[[
	local arrow      = Clone{
		source       = assets.arrow,
		anchor_point = {assets.arrow.w, assets.arrow.h/2},
		position     = {screen.w/2-50, start.y},
	}
	--]]
	
	
	
	
	Splash:add(title,start,h_score,help,quit,scrim)--,arrow)
	
	
	
	
	
	function start:press_enter()   physics:stop(); GameState:change_state_to("GAME")    end
	function h_score:press_enter()    GameState:change_state_to("VIEW_HIGHSCORE")    end
	function help:press_enter()   physics:stop(); GameState:change_state_to("HELP")     end
	function quit:press_enter()    exit()    end
	
	menu_items[1] = start
	menu_items[2] = h_score
	menu_items[3] = help
	menu_items[4] = quit
end

--arrow index, and its selectable items
local index = 1

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

local wobble = {
	
	duration     = .7,
	loop         = true,
	on_step = function(ms,p)
		
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
	on_loop = function() first_pass = false end
}

local curr_scale, curr_o = 0, 0

local prev_i = 0
local unsel_s = Interval( 1,unsel_scale)
local sel_s   = Interval( 1,  sel_scale)
local unsel_o = Interval( 1,     .7*255)
local sel_o   = Interval( 1,        255)
local select_anim = {
	duration = .1,
	on_step = function(s,p)
		
		menu_items[prev_i].opacity = unsel_o:get_value(p)
		menu_items[ index].opacity =   sel_o:get_value(p)
		
		menu_items[prev_i].scale = { unsel_s:get_value(p), unsel_s:get_value(p) }
		menu_items[ index].scale = {   sel_s:get_value(p),   sel_s:get_value(p) }
	end,
	on_completed = function()
		Animation_Loop:add_animation(wobble)
	end
}
local function select(i)
	
	if index == i then return end
	
	assert(
		i > 0    and    i <= # menu_items,
		"Tried to select "..i.." in the 'Start' menu"
	)
	
	--wobble:stop()
	Animation_Loop:delete_animation(wobble)
	
	first_pass = true
	--[[
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
			--wobble:start()
			Animation_Loop:add_animation(wobble)
		end
	}
	
	index = i
	--]]
	
	prev_i = index
	index  = i
	
	unsel_s.from = menu_items[prev_i].scale[1]
	sel_s.from   = menu_items[index].scale[1]
	unsel_o.from = menu_items[prev_i].opacity
	sel_o.from   = menu_items[index].opacity

	Animation_Loop:add_animation(select_anim)
end

--the press enter functions







local backing = Clone{ source = assets.ground,y = screen_h - assets.ground.h }

local floor = physics:Body(
	Group{
		name = "splash floor",
		size = { screen.w , 200 } ,
	} ,
	{
		type    = "static" ,
		bounce  = 0,
		density = 1,
		filter  = surface_filter,
	}
)

local branch = branch_constructor( -1, 700,300 )

floor.on_begin_contact = panda.bounce
floor.position = {screen_w/2,screen_h}
layers.ground:add(backing,floor)
floor:lower_to_bottom()







--the state change animations (fading the Splash screen in and out)
do
	--upval
	local curr_opacity
	
	--fade out
	GameState:add_state_change_function(
		function(old,new)
			
			
			
			--wobble:stop()
			Animation_Loop:delete_animation(wobble)
			
			if new == "HELP" then
				
				screen.on_key_down = nil
				
				curr_opacity = scrim.opacity
				
				scrim:complete_animation()
				
				scrim.opacity = curr_opacity
				
				scrim:animate{
					duration = 300,
					opacity  = 255*.6,
				}
				
				return
			end
			
			curr_opacity = Splash.opacity
			
			Splash:complete_animation()
			
			Splash.opacity = curr_opacity
			
			branch:animate{
				duration = 300,
				opacity  = 0,
				on_completed = function()
					
					
					branch:recycle()
				end
			}
			
			backing:animate{
				duration = 300,
				opacity  = 0,
				on_completed = function()
					
					floor:unparent()
					backing:unparent()
				end
			}
			
			
			Splash:animate{
				duration = 300,
				opacity  = 0,
				on_completed = function()
					Splash:unparent()
					Splash:clear()
					menu_items = {}
					collectgarbage("collect")
					
					--physics:start()
					GameState:add_state_change_function(
						function()
							
							error("Tried to relaunch the splash screen")
							
						end,
						
						nil, "SPLASH"
					)
				end
			}
		end,
		"SPLASH", nil
	)
	
	--fade in
	GameState:add_state_change_function(
		function(old, new)
			
			index = 1
			
			for i,item in pairs(menu_items) do
				
				if i == index then
					
					item.scale = {   sel_scale,   sel_scale }
					
					item.opacity = 255
					
					--wobble:start()
					Animation_Loop:add_animation(wobble)
					
				else
					
					item.scale = { unsel_scale, unsel_scale }
					
					item.opacity = 255*.7
				end
				
			end
			
			if old == "HELP" then
				
				curr_opacity = scrim.opacity
				
				scrim:complete_animation()
				
				scrim.opacity = curr_opacity
				
				scrim:animate{
					duration = 600,
					opacity  = 0,
					on_completed = function()
						physics:start()
						screen.on_key_down = Splash.on_key_down
					end
				}
				
				return
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
			
		end,
		
		nil, "SPLASH"
	)
end

--Key Handler for the splash screen
do
	
	local keys = {
		
		[keys.Left] = function()
			panda:on_key_down(keys.Left)
		end,
		[keys.Right] = function()
			panda:on_key_down(keys.Right)
		end,
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
w = wobble
return Splash
