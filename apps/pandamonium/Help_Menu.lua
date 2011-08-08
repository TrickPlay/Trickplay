
local Help = Group{name = "Help",y=600,x_rotation = {-100,0,0}}
Help:hide()
local help_font = "Baveuse 45px"

local done

do
    
	local first_line  = 0
	local second_line = first_line +  50
	local item_line   = second_line + 100
	
	
	local collect       = Text{--Clone{
		--source       = assets.title,
		font         = help_font,
		text         = "Collect",
		position     = {screen.w/4+30, first_line}
		
	}
	collect = make_text(collect,"yellow")
	local coins       = Text{--Clone{
		--source       = assets.title,
		font         = help_font,
		text         = "Coins",
		position     = {collect.x, second_line}
		
	}
	coins = make_text(coins,"yellow")
	
	local coin1  = Clone{ source = assets.coin_front, x = collect.x-60, y= item_line,scale      = {.8,.8} }
	coin1.anchor_point = {coin1.w/2,coin1.h/2}
	local coin2  = Clone{ source = assets.coin_front, x = collect.x+60, y= item_line,scale      = {.8,.8} }
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
			position     = {screen.w/2, item_line},
			scale      = {.8,.8},
		}
	f_work.anchor_point = {f_work.w/2,f_work.h/2}
	
	local avoid       = Text{--Clone{
		--source       = assets.title,
		font         = help_font,
		text         = "Avoid",
		position     = {3*screen.w/4-30, first_line}
		
	}
	avoid = make_text(avoid,"yellow")
	
	local bomb       = Text{--Clone{
		--source       = assets.title,
		font         = help_font,
		text         = "Bombs",
		position     = {avoid.x, second_line}
		
	}
	bomb = make_text(bomb,"yellow")
	
	local f_cracker =  Clone{
			source = assets.firecracker,
			position     = {avoid.x+25, item_line},
			scale      = {.8,.8},
		}
	f_cracker.anchor_point = {f_cracker.w/2,f_cracker.h/2}
	
	local dont_fall       = Text{--Clone{
		--source       = assets.title,
		font         = "Baveuse 60px",
		text         = "...and Don't Fall!",
		alignment    = "CENTER",
		position     = {screen.w/2, item_line+120}
		
	}
	dont_fall = make_text(dont_fall,"yellow")
	
	done       = Text{--Clone{
		--source       = assets.title,
		font         = "Baveuse 70px",
		text         = "Done",
		alignment    = "CENTER",
		position     = {screen.w/2, dont_fall.y+120}
		
	}
	done = make_text(done,"green")
	--[[
	local backing = Rectangle{
		w= 1600,
		h= 600,
		color = "000000",
		opacity = 255*.6,
		y=item_line+50,
		x=screen_w/2,
	}
	--]]
	
	local backing = Canvas(1300,700)
	
	
	backing.line_join = "ROUND"

	backing:round_rectangle(20,20,backing.w-40,backing.h-40,100)
	
	backing:set_source_linear_pattern( backing.w/2, 0, backing.w/2, backing.h )
	backing:add_source_pattern_color_stop( 0, "5d8917") 
	backing:add_source_pattern_color_stop( .7, "000000") 
	backing:fill(true)
	backing.line_width = 4
	backing:set_source_color("ffffff")
	backing:stroke(true)
	backing:clip(true)
	
	backing = backing:Image{
		position     = {screen_w/2,item_line+130},
		anchor_point = {backing.w/2,backing.h/2}
	}
	
	backing.anchor_point = {backing.w/2,backing.h/2}
    
    Help:add(backing,collect,coins,avoid,bomb,f_work,catch,rocket,coin1,coin2,f_cracker,dont_fall,done)
    
	Help:move_anchor_point(screen_w/2,backing.y+backing.h)
end

local sel_scale = 1.2

local unsel_scale = 1

local mag = .02

local first_pass = true

local wobble = Timeline{
	
	duration     = 700,
	loop         = true,
	on_new_frame = function(_,ms,p)
		
		if first_pass then
			
			mag = .03 + .2*(1-p)
			
		end
		
		done.scale = {
			sel_scale+mag*math.sin(math.pi*2*p),
			sel_scale-mag*math.sin(math.pi*2*p)
		}
		
	end,
	on_completed = function() first_pass = false end
}


local curr_x_rot = 0
	GameState:add_state_change_function(
		function()
			--wobble:stop()
			curr_x_rot = Help.x_rotation[1]
			Help:show()
			Help:complete_animation()
			
			Help.x_rotation = {curr_x_rot,0,0}
			
			Help:raise_to_top()
			--physics:stop()
			Help:animate{
				duration = 1000,
				mode = "EASE_OUT_BOUNCE",
				--y        = 600,
				x_rotation = 0,
				on_completed = function()
					screen.on_key_down = Help.on_key_down
					wobble:start()
					first_pass = true
				end
			}
		end,
		"SPLASH", "HELP"
	)

	GameState:add_state_change_function(
		function()
			wobble:stop()
			curr_y = Help.y
			
			Help:complete_animation()
			
			Help.y = curr_y
			
			Help:animate{
				duration = 600,
				
				--y        = screen_h+200,
				x_rotation = -100,
				on_completed = function()
					screen.on_key_down = Splash.on_key_down
					physics:start()
					Help:hide()
				end
			}
		end,
		"HELP", "SPLASH"
	)
	
	
	
	
	
do
	
	local keys = {
		
		[keys.OK] = function()
			
			GameState:change_state_to("SPLASH")
			
		end,
	}
	
	function Help:on_key_down(k)    if keys[k] then    keys[k]()    end    end
end

layers.menu:add(Help)

return Help