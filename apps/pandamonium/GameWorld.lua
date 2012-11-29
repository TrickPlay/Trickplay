--------------------------------------------------------------------------------
-- Screen Object
--
-- Used to keep track of when things have fallen off the screen
--------------------------------------------------------------------------------

local Game_Screen = physics:Body(
	
	Group{size=screen.size},
	
	{
		type   = "static",
		sensor = true,
		filter = all_filter
	}
)
Game_Screen.position = {screen_w/2,screen_h/2}

local handle_ref = {}

local body

Game_Screen.on_end_contact = function(_,contact)
	--print("the fuck")
	body = contact.bodies[2]
	
	if body == Game_Screen.handle then body = contact.bodies[1] end
	
	if handle_ref[ body ] == nil then return end
	
	dolater(
		handle_ref[ body ].recycle,
		handle_ref[ body ]
	)
	
	handle_ref[ body ] = nil
end

layers.bg:add(Game_Screen)

--------------------------------------------------------------------------------
-- Wall Object
--
-- contains the hopper horizontally
--------------------------------------------------------------------------------

local wall_properties = {
	type = "static" ,
	bounce = 0,
	density = 1,
	filter  = surface_filter,
}

local r_wall = physics:Body(
	
	Group{ name = "wall", size = { 100 , 3*screen_h }, },
	
	wall_properties
)

local l_wall = physics:Body(
	
	Group{ name = "wall", size = { 100 , 3*screen_h }, },
	
	wall_properties
)

l_wall.position = {        0,  screen_h/2 }
r_wall.position = { screen_w,  screen_h/2 }

layers.bg:add(   l_wall, r_wall   )






--[[
--recycled walls
local old_walls = {}

--upval, used in the wall constructors and in   World:add_next_branches()
local wall

local wall_properties = {
	type = "static" ,
	bounce = 0,
	density = 1,
	filter  = surface_filter,
}

local new_wall = function()
	
	wall = physics:Body(
		
		Group{ name = "wall", size = { 100 , screen_h }, },
		
		wall_properties
	)
		
	function wall:recycle()
		
		for _,b in pairs(self.branches) do      b:recycle()      end
		
		self.branches = {}
		
		self:unparent()
		
		table.insert(old_walls,self)
		
	end
	
	local y
	
	function wall:scroll_by(dy)
		
		y = self.y + dy
		
		if y > screen_h*2 then
			
			self:recycle()
			
			return false
			
		else
			
			self.y = y
			
			for _,b in pairs(self.branches) do      b:scroll_by(dy)      end
			
			return true
			
		end
		
	end
	
	return wall
	
end

local wall_constructor = function()
	
	return table.remove(old_walls) or new_wall()
	
end
--]]
-----------------------------------------
-- Floor Object
-----------------------------------------

local backing = Clone{ source = assets.ground }
local floor = physics:Body(
    Group{
		name = "floor",
		size = { screen.w , 200 } ,
	} ,
    {
		type    = "static" ,
		bounce  = 0,
		density = 1,
		filter  = surface_filter,
	}
)
floor.position = {screen.w/2,screen.h}
floor.on_begin_contact = panda.bounce

function floor:recycle()
	
	self:unparent()
	
	backing:unparent()
	
end

function floor:scroll_by(dy)
	
	self.y = self.y + dy
	
	backing.y = backing.y + dy
	
	--i don't know why i have to do this
	if backing.y > screen_h then
		floor:recycle()
		handle_ref[ floor.handle ] = nil
	end
	
end

function floor:fade_in_prep()

	backing.opacity = 0
	
	floor.y   = screen_h 
	
	backing.y = screen_h - backing.h
	
	
	layers.ground:add( floor, backing )
	
	
	
end

function floor:fade_in(p)
	
	backing.opacity = 255*p
	
end

-----------------------------------------
--World Object
-----------------------------------------

local World = {}

local real_max_dist = 400
local difficulty_increase = 2

local active_objects = {}

local l_wall, r_wall, side, curr_max_dist, next_branch_y

local left_wall_fade_in_prep = function(b)
	b.opacity    = 0
	b.y_rotation = {90,-b.w/2,0}
end
local left_wall_fade_in = function(b,p)
	b.opacity    =  255*p
	b.y_rotation = {90*(1-p),-b.w/2,0}
end
local right_wall_fade_in_prep = function(b)
	b.opacity    = 0
	b.y_rotation = {90,0,0}
	b.anchor_point = {
		0,
		b.h/2
	}
	b.x = b.x + b.w/2
end
local right_wall_fade_in = function(b,p)
	b.opacity    = 255*p
	b.y_rotation = {90*p+90,0,0}
end
local right_wall_fade_in_complete = function(b)
	b.opacity    = 255
	b.anchor_point = {
		b.w/2,
		b.h/2
	}
	b.x = b.x - b.w/2
end
local wall_fade_out = function(b,p)
	b.opacity    = 255*(1-p)
end
local wall_fade_out_complete = function(b)
	b:recycle()
	
end

local last_sides = 0
local prev_side  = 0
local item_on_last_branch = 0
local retval = false
function World:add_branch(y,x_dist)
	
	--pick a random side
	side = 3-2*math.random(1,2)
	
	--make sure that same side wasn't randomly chosen too
	--many times in a row
	if     last_sides == -2 and side == -1 then side =  1
	elseif last_sides ==  2 and side ==  1 then side = -1 end
	last_sides = last_sides + side
	branch = nil
	if math.random(1,8) == 1 then
		
		branch = firework:add_to_screen(
			screen_w/2+side*400,
			next_branch_y-200
		)
		
		retval = true
		
	end
	if branch == nil then
		
		branch = branch_constructor(
			side,
			next_branch_y-200,
			900+30*math.random(0,3)-x_dist
		)
		
		--translate the side value to the wall object
		if     side == -1 then
			
			branch.fade_in_prep      = left_wall_fade_in_prep
			branch.fade_in           = left_wall_fade_in
			branch.fade_in_complete  = nil
			branch.fade_out          = wall_fade_out
			branch.fade_out_complete = wall_fade_out_complete
			
		elseif side ==  1 then
			
			branch.fade_in_prep      = right_wall_fade_in_prep
			branch.fade_in           = right_wall_fade_in
			branch.fade_in_complete  = right_wall_fade_in_complete
			branch.fade_out          = wall_fade_out
			branch.fade_out_complete = wall_fade_out_complete
			
		else   error("invalid side") end
		
		r   = math.random(1,10)
		p_i = math.random(1,2)
		if item_on_last_branch <= 0 then
			if r == 1 then
				local c = Coin:plus(branch.palms[1].x,branch.y-200)
				for _,c in ipairs(c) do handle_ref[c.handle] = c end
				item_on_last_branch = 2
			elseif r == 2 then
				local p = branch.palms
				local c = Coin:three_in_a_row(p[p_i].x, p[p_i].y-240)
				for _,c in ipairs(c) do handle_ref[c.handle] = c end
				item_on_last_branch = 2
			elseif r <= 6 then
				
				local p = branch.palms
				local c = Coin:single(p[p_i].x,p[p_i].y-130)
				
				handle_ref[c.handle] = c
				
				item_on_last_branch = 0
				
			elseif r <= 9 then
				local p = branch.palms
				local c = make_firecracker(p[p_i].x,p[p_i].y-120)
				
				handle_ref[c.handle] = c
				
				item_on_last_branch = 0
			end
		else
			item_on_last_branch = item_on_last_branch - 1
		end
		
		retval = false
		
	end
	handle_ref[branch.handle] = branch
	
	prev_side = side
	
	return retval
end

local fade_ins = {}
local fade_outs

local start_game_tl = Timeline{
	duration = 500,
	on_new_frame = function(self,msecs,p)
		
		for _,obj in pairs(fade_outs) do
			if obj.fade_out then obj:fade_out(p) end
		end
		for _,obj in pairs(handle_ref) do
			if obj.fade_in then obj:fade_in(p) end
		end
		
	end,
	on_completed = function()
		
		
		for _,obj in pairs(handle_ref) do
			if obj.fade_in_complete then obj:fade_in_complete() end
		end
		for _,obj in pairs(fade_outs) do
			if obj.fade_out_complete then obj:fade_out_complete() end
		end
		--print('ffff')
		physics:start()
	end
}

GameState:add_state_change_function(
	function()
		Animation_Loop:delete_animation(World.update)
	end,
	"GAME",nil
)

GameState:add_state_change_function(
	function()
		for obj,func in pairs(to_be_deleted) do
			--print("del2", obj)
			func(obj)
			to_be_deleted[obj]  = nil
			active_objects[obj] = nil
		end
		curr_max_dist = 200
		next_branch_y = 5*screen_h/6
		
		Animation_Loop:add_animation(World.update)
		
		fade_outs = handle_ref
		
		handle_ref = {}
		
		World:add_branches()
		
		handle_ref[floor.handle] = floor
		
		for _,obj in pairs(fade_outs) do
			
			if obj.fade_out_prep then obj:fade_out_prep() end
			
		end
		
		for _,obj in pairs(handle_ref) do
			
			if obj.fade_in_prep then obj:fade_in_prep() end
			
		end
		
		start_game_tl:start()
		
	end,
	
	nil, "GAME"
)
World.remove = function( _,obj)
	
	handle_ref[obj.handle] = nil
	
end
--local r = Rectangle{w=5,h=20}
local dy
local jump_thresh = screen_h / 3
local panda_y
local p_hand = panda:get_hand()
local scroll_speed = nil
scroll_after = {
	
	duration = 1.2,
	
	on_step = function(s,p)
		--print(s)
		dy = scroll_speed*(1-p)*s
		
		bg.y = (bg.y + dy/3) % bg.base_size[2] - bg.base_size[2]
		
		--place the panda at the threshold
		panda:scroll_by( dy )
		
		--move all the branches and everything down
		--World:scroll_by(dy)
		for _,obj in pairs(handle_ref) do
			
			obj:scroll_by(dy)
			
		end
		
		Effects:scroll_by(dy)
		
	end,
	
	on_completed = function()
		--print("c")
		Timer{
		interval =300,
		on_timer = function(self)
			physics:stop()
			Animation_Loop:add_animation(World.update)
			if hud:get_score() > highscores[# highscores].score then
				GameState:change_state_to("SAVE_HIGHSCORE")
			else
				GameState:change_state_to("VIEW_HIGHSCORE")
			end
			mediaplayer:play_sound("audio/death-sound.mp3")
			self:stop()
		end
		}
	end
}


World.check_hopper = function()
	
	for obj,func in pairs(to_be_deleted) do
		
		func(obj)
		to_be_deleted[obj]  = nil
		World:remove(obj)
	end
	--r.x = p_hand.x
	--r.y = p_hand.y
	panda_y = panda:get_y()
	
	--if the panda crossed the jump threshhold (while jumping upwards), then scroll up
	if panda.rocket ~= nil and panda.rocket.y < jump_thresh then
		--the amount to scroll by
		dy = jump_thresh - panda.rocket.y
		panda.rocket:scroll_by( dy )
	elseif panda_y < jump_thresh and panda:get_vy() < 0 then
		
		--the amount to scroll by
		dy = jump_thresh - panda_y
		
	elseif panda_y > screen_h+200 and not panda.rocket and not firework.moving then
		
		--print("rocket",panda.rocket)
		
		panda.dead = true
		
		scroll_speed = -panda:get_vy()*physics.pixels_per_meter/7
		Animation_Loop:add_animation(scroll_after)
		--print(World.update)
		Animation_Loop:delete_animation(World.update)
		return
		
	else
		dy = 0
	end
	
	if dy ~= 0 then
	
		hud:add_to_dist(math.ceil(dy/200))
		--scroll the tiles background by a lesser amount
		bg.y = (bg.y + dy/3) % bg.base_size[2] - bg.base_size[2]
		
		--place the panda at the threshold
		panda:scroll_by( dy )
		
		--move all the branches and everything down
		--World:scroll_by(dy)
		for _,obj in pairs(handle_ref) do
			
			obj:scroll_by(dy)
			
		end
		
		Effects:scroll_by(dy)
		
		next_branch_y = next_branch_y + dy
		
	end
	
	World:add_branches()
	
end
--screen:add(r)

World.update = {on_step=World.check_hopper}


World.add_branches = function()
	
	--if the top walls are now in view, add 2 more walls
	while next_branch_y > -screen_h/2 do
		
		--if rocket
		if World:add_branch(next_branch_y,2.3*curr_max_dist) then
			
			next_branch_y = next_branch_y - 1200
			
		else
			--setup the next position
			next_branch_y = next_branch_y - real_max_dist--math.random(curr_max_dist-50,curr_max_dist)
		end
		
		
		
		--make sure that the difficulty caps at the max possible jump distance
		if  curr_max_dist < real_max_dist then
			
			curr_max_dist = curr_max_dist + difficulty_increase
			
		end
	end
end
function World:add(obj)
	handle_ref[obj.handle] = obj
end
firework.World = World

return World
