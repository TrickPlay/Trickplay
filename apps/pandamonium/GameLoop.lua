local top_wall_y = screen_h

local jump_thresh = screen_h / 4
local first_time = true
local idle_loop = function( ... )
	
	--if the panda crossed the jump threshhold (while jumping upwards), then scroll up
	if panda:get_y() < jump_thresh and panda:get_vy() < 0 then
		
		--the amount to scroll by
		dy = jump_thresh - panda:get_y()
		
		--lower the top_wall y position upval
		top_wall_y = top_wall_y + dy
		
		--scroll the tiles background by a lesser amount
		bg.y = (bg.y + dy/3) % bg.base_size[2] - bg.base_size[2]
		
		--place the panda at the threshold
		panda:scroll_by( dy )
		
		--move all the branches and everything down
		World:scroll_by(dy)
		
	end
	
	--if the top walls are now in view, add 2 more walls
	while top_wall_y > 0 do
		
		--2 new walls
		if first_time then
			World:add_first_walls(top_wall_y-screen_h)
			first_time = false
		else
			World:add_next_walls(top_wall_y-screen_h)
		end
		
		
		--update top_wall y position (need to subtract by half its height
		--because physics bodies automatically anchor to the center)
		top_wall_y = top_wall_y-screen_h
		
		--raise the panda above the new branches
		panda:raise_to_top()
		
	end
	
end

return idle_loop