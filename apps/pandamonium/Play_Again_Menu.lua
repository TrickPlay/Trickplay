local Play_Again = Group{name = "Play Again",opacity = 0}

--Visual Components
local title      = Clone{
	source       = assets.title,
	anchor_point = {assets.title.w/2,assets.title.h/2},
	position     = {screen.w/2, 150},
}

local play_again = Clone{
	source       = assets.play_again,
	anchor_point = {0, assets.play_again.h/2},
	position     = {screen.w/2, 400},
}

local quit       = Clone{
	source       = assets.quit,
	anchor_point = {0, assets.quit.h/2},
	position     = {screen.w/2, 500},
}

local arrow      = Clone{
	source       = assets.arrow,
	anchor_point = {assets.arrow.w, assets.arrow.h/2},
	position     = {screen.w/2-50, play_again.y},
}

Play_Again:add(title,play_again,quit,arrow)


--arrow index, and its selectable items
local index = 1

local menu_items = {
	play_again,
	quit
}

--the move animation for the arrow
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

--the press enter functions
function quit:press_enter()    exit()    end

function play_again:press_enter()    GameState:change_state_to("GAME")    end

--the state change animations (fading the Play Again screen in and out)
do
	--upval
	local curr_opacity
	
	--fade out
	GameState:add_state_change_function(
		function()
			
			curr_opacity = Play_Again.opacity
			
			Play_Again:complete_animation()
			
			Play_Again.opacity = curr_opacity
			
			Play_Again:animate{
				duration = 300,
				opacity  = 0,
			}
		end,
		
		"PLAY_AGAIN", nil
	)
	
	--fade in
	GameState:add_state_change_function(
		function()
			
			index = 1
			
			arrow.y = menu_items[index].y
			
			curr_opacity = Play_Again.opacity
			
			Play_Again:complete_animation()
			
			Play_Again.opacity = curr_opacity
			
			Play_Again:raise_to_top()
			
			Play_Again:animate{
				duration = 500,
				opacity  = 255,
				on_completed = function()
					screen.on_key_down = Play_Again.on_key_down
					physics:stop()
				end
			}
			
		end,
		
		nil, "PLAY_AGAIN"
	)
end

--Key Handler for the splash screen
do
	
	local keys = {
		
		[keys.Down] = function()
			
			if index == # menu_items then return end
			
			index = index + 1
			
			arrow:move_to(index)
			
		end,
		[keys.Up] = function()
			
			if index == 1 then return end
			
			index = index - 1
			
			arrow:move_to(index)
			
		end,
		[keys.OK] = function()
			
			menu_items[index]:press_enter()
			
		end,
	}
	
	function Play_Again:on_key_down(k)    if keys[k] then    keys[k]()    end    end
end

layers.menu:add(Play_Again)

return Play_Again