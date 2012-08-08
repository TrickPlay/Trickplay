local top_wall_y = 0--screen_h

local jump_thresh = screen_h / 4

local panda_y

local real_max_dist = 570
local difficulty_increase = 10
local curr_max_dist = screen_h/5

local idle_loop = function(_, dt, __ )
	
	for obj,func in pairs(to_be_deleted) do
		--print("del1", obj)
		func(obj)
		to_be_deleted[obj]  = nil
		World:remove(obj)
	end
	
	Animation_Loop:loop(dt)
	
	panda_y = panda:get_y()
	
	--if the panda crossed the jump threshhold (while jumping upwards), then scroll up
	if panda_y < jump_thresh and panda:get_vy() < 0 then
		
		--the amount to scroll by
		dy = jump_thresh - panda_y
		
		--lower the top_wall y position upval
		top_wall_y = top_wall_y + dy
		
		--scroll the tiles background by a lesser amount
		bg.y = (bg.y + dy/3) % bg.base_size[2] - bg.base_size[2]
		
		--place the panda at the threshold
		panda:scroll_by( dy )
		
		--move all the branches and everything down
		World:scroll_by(dy)
		
		next_branch_y = next_branch_y + dy
		
	elseif panda_y > screen_h*3/2 then
		GameState:change_state_to("PLAY_AGAIN")
	end
	
	--if the top walls are now in view, add 2 more walls
	while next_branch_y > -screen_h/2 do
		
		--2 new walls
		--World:add_next_walls(top_wall_y-screen_h)
		
		--update top_wall y position (need to subtract by half its height
		--because physics bodies automatically anchor to the center)
		--top_wall_y = top_wall_y-screen_h
		
		World:add_branch(next_branch_y)
		
		--setup the next position
		next_branch_y = next_branch_y - math.random(curr_max_dist-100,curr_max_dist)
		
		--make sure that the difficulty caps at the max possible jump distance
		if curr_max_dist < real_max_dist then
			
			curr_max_dist = curr_max_dist + difficulty_increase
			
		end
		
	end
	
end

GameState:add_state_change_function(
	function()
		top_wall_y    = 0
		curr_max_dist = screen_h/5
		next_branch_y = screen_h/2
	end,
	nil, "GAME"
)

return idle_loop
