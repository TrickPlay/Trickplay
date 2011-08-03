local Splash = Group{name = "Splash",opacity = 0}

local sel_scale = 1.2

local unsel_scale = 1

local menu_items = {}
--Visual Components
do
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
		position     = {screen.w/2, 250}
		
	}
	start = make_text(start,"green")
	
	local h_score     = Text{--Clone{
		--source       = assets.title,
		font         = "Baveuse 70px",
		text         = "highscores",
		position     = {screen.w/2, 350}
		
	}
	h_score = make_text(h_score,"green")
	
	local quit       = Text{--Clone{
		--source       = assets.title,
		font         = "Baveuse 70px",
		text         = "QUIT",
		position     = {screen.w/2, 450}
		
	}
	quit = make_text(quit,"green")
	
	local help_font = "Baveuse 45px"
	
	local first_line  = 620
	local second_line = 670
	local item_line   = 770
	
	
	local collect       = Text{--Clone{
		--source       = assets.title,
		font         = help_font,
		text         = "Collect",
		position     = {screen.w/5, first_line}
		
	}
	collect = make_text(collect,"yellow")
	local coins       = Text{--Clone{
		--source       = assets.title,
		font         = help_font,
		text         = "Coins",
		position     = {screen.w/5, second_line}
		
	}
	coins = make_text(coins,"yellow")
	
	local coin1  = Clone{ source = assets.coin_front, x = screen_w/5-80, y= item_line }
	coin1.anchor_point = {coin1.w/2,coin1.h/2}
	local coin2  = Clone{ source = assets.coin_front, x = screen_w/5+80, y= item_line }
	coin2.anchor_point = {coin2.w/2,coin2.h/2}
	local catch   = Text{--Clone{
		--source       = assets.title,
		font         = help_font,
		text         = "Catch",
		position     = {screen.w/2, first_line}
		
	}
	catch = make_text(catch,"yellow")
	local rocket   = Text{--Clone{
		--source       = assets.title,
		font         = help_font,
		text         = "Rockets",
		position     = {screen.w/2, second_line}
		
	}
	rocket = make_text(rocket,"yellow")
	local f_work = Clone{
			source = assets.firework,
			z_rotation = {90,0,0},
			position     = {screen.w/2, item_line}
		}
	f_work.anchor_point = {f_work.w/2,f_work.h/2}
	
	local avoid       = Text{--Clone{
		--source       = assets.title,
		font         = help_font,
		text         = "Avoid",
		position     = {4*screen.w/5, first_line}
		
	}
	avoid = make_text(avoid,"yellow")
	
	local bomb       = Text{--Clone{
		--source       = assets.title,
		font         = help_font,
		text         = "Bombs",
		position     = {4*screen.w/5, second_line}
		
	}
	bomb = make_text(bomb,"yellow")
	
	local f_cracker =  Clone{
			source = assets.firecracker,
			position     = {4*screen.w/5+25, item_line}
		}
	f_cracker.anchor_point = {f_cracker.w/2,f_cracker.h/2}
	
	local dont_fall       = Text{--Clone{
		--source       = assets.title,
		font         = "Baveuse 70px",
		text         = "Don't Fall!",
		alignment    = "CENTER",
		position     = {screen.w/2, 970}
		
	}
	dont_fall = make_text(dont_fall,"yellow")
	
	local backing = Rectangle{
		w= 1600,
		h= 340,
		color = "000000",
		opacity = 255*.4,
		y=item_line-50,
		x=screen_w/2,
	}
	
	backing.anchor_point = {backing.w/2,backing.h/2}
	--[[
	local arrow      = Clone{
		source       = assets.arrow,
		anchor_point = {assets.arrow.w, assets.arrow.h/2},
		position     = {screen.w/2-50, start.y},
	}
	--]]
	Splash:add(backing,title,start,h_score,quit,collect,coins,avoid,bomb,f_work,catch,rocket,coin1,coin2,f_cracker,dont_fall)--,arrow)
	
	
	
	
	function start:press_enter()    GameState:change_state_to("GAME")    end
	function h_score:press_enter()    GameState:change_state_to("VIEW_HIGHSCORE")    end
	function quit:press_enter()    exit()    end
	
	menu_items[1] = start
	menu_items[2] = h_score
	menu_items[3] = quit
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
				on_completed = function()
					Splash:unparent()
					Splash:clear()
					menu_items = {}
					collectgarbage("collect")
					
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