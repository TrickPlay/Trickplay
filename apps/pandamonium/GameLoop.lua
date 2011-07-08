local top_wall
local top_wall_y = screen_h
local walls = {}

local jump_thresh = screen_h / 4

local idle_loop = function( ... )
	
	--print(...)
	--print("ye",panda:get_vy())
	--physics:draw_debug()
	
	if panda:get_y() < jump_thresh and panda:get_vy() < 0 then
		--print("ye",panda:get_vy())
		dy = jump_thresh - panda:get_y()
		top_wall_y = top_wall_y + dy
		
		bg.y = (bg.y + dy/4) % bg.base_size[2] - bg.base_size[2]
		
		---[[
		panda:scroll_by( dy )
		
		for w,_ in pairs(walls) do
            
            if not w:scroll_by(dy) then
				
				walls[w] = nil
				
			end
            
        end
		--]]
	end
	
	while top_wall_y > 0 do
		
		top_wall        = make_wall(-1,top_wall_y-screen_h)
		walls[top_wall] = top_wall
		
		top_wall        = make_wall( 1,top_wall_y-screen_h)
		walls[top_wall] = top_wall
		
		top_wall_y = top_wall.y-screen_h/2
		
		panda:raise_to_top()
		
	end
	
end

return idle_loop