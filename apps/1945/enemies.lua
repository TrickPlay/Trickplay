--Spawns enemies

--Enemy Spawner launches enemy formations
--Formations:
--		Figure_8	flies in from top
--		Row			flies in from side
--		cluster		formation of 3 from the top


--base images for clones



function fire_bullet(enemy)
    local bullet =
    {
        speed = 500,
        num_frames = 1,
        image = Clone
        {
            source = imgs.enemy_bullet ,
            opacity = 255,
            anchor_point =
            {
                imgs.enemy_bullet.w/2,
                imgs.enemy_bullet.h/2
            },
            position =
            {
                enemy.group.x,
                enemy.group.y
            },
        },
        
        type = TYPE_ENEMY_BULLET,
            
        setup = function( self )
            mediaplayer:play_sound("audio/Air Combat Enemy Fire.mp3")

		--enemies are assumed to be facing downwards
		local deg    = enemy.group.z_rotation[1] + 90
		
		--set up the velocities for x and y
		self.speed_x = math.cos(deg*math.pi/180) * self.speed
		self.speed_y = math.sin(deg*math.pi/180) * self.speed
		
                layers.air_bullets:add( self.image )
            end,
                
            render = function( self , seconds )
            
		--calculate the next position of the bullet
		local x = self.image.x + self.speed_x *seconds
		local y = self.image.y + self.speed_y *seconds
		--remove it from the screen, if it travels off screen
                if y > screen.h or x > screen.w or y < 0 or x < 0 then
                    remove_from_render_list( self )
                    self.image:unparent()
		--otherwise, update the position
                else
                    local start_point = self.image.center
                    self.image.y = y
		    self.image.x = x
		    --check for collisions
            
            table.insert(bad_guys_collision_list,
                {
                    obj = self,
                    x1  = self.image.x-self.image.w/2,
                    x2  = self.image.x+self.image.w/2,
                    y1  = self.image.y-self.image.h/2,
                    y2  = self.image.y+self.image.h/2,
                }
            )
            --[[
                    add_to_collision_list(
                        self,
			self.image.center,
			self.image.center,
			{ 4 , 4 },
			TYPE_MY_PLANE
                    )
                    --]]
                end
                
            end,
            
            collision =
                function( self , other )
                    if other.type == TYPE_MY_BULLET then return end
                    remove_from_render_list( self )
                    self.image:unparent()
                end
        }
	add_to_render_list( bullet )
end

--assumes that 0 degrees for the object is when it faces the downward direction
--assumes that the anchor point of the object is already set to its center
function face(start_x,start_y,dest_x,dest_y, dir)

	local dist_x   = dest_x - start_x
	local dist_y   = dest_y - start_y
    
    local deg = 180/math.pi*math.atan2(dist_y,
	                                   dist_x) -90

	if dir == -1 and deg > 0 then deg = deg - 360 end
	if dir == 1  and deg < 0 then deg = deg + 360 end
    return deg
    
--[[
	--base angle, will point to the bottom_left
	local deg = 180/math.pi*math.atan2(math.abs(dist_y),
	                                   math.abs(dist_x))
	--if the target is above it
	if dist_y < 0 then deg = deg+90 end
	--if the target is to the right
	if dist_x > 0 then deg = deg*-1 end
	if deg < 0 then deg = 360+deg end
	if deg >= 360 then deg = deg - 360 end
    
    if dir == -1 then deg = deg - 360 end
	--obj.z_rotation = {deg,0,0}
	return deg
    --]]
end
--[[
function move_to(obj,dest_x,dest_y,speed,seconds)

	local dist_x   = dest_x - obj.x
	local dir_x    = dest_x/math.abs(dist_x)
	local dist_y   = dest_y - obj.y
	local dir_y    = dest_y/math.abs(dist_y)
	local tot_dist = dir_x*dist_x + dir_y*dist_y

	local dir_x = dest

	local speed_x = dist_x / tot_dist * speed
	local speed_y = dist_y / tot_dist * speed

	local new_x = obj.x + speed_x*seconds
	local new_y = obj.y + speed_y*seconds
	if     dir_x == -1 and new_x < dest_x then new_x = dest_x 
	elseif dir_x ==  1 and new_x > dest_x then new_x = dest_x end
	if     dir_y == -1 and new_y < dest_y then new_y = dest_y 
	elseif dir_y ==  1 and new_y > dest_y then new_y = dest_y end

	obj.x = new_x
	obj.y = new_y
        
        
end
--assumes that 0 degrees for the object is when it faces the downward direction
--don't use for more than half rotations (i.e. setup 2 back to back or something
--  stupid like that for full rotations)
function prep_bank_to( start_x,  start_y, 
	                    dest_x,   dest_y, 
	                  center_x,center_y, dir)
--	assert(math.pow((center_x - start_x),2)+math.pow((center_y - start_y),2) == 
--	       math.pow((  dest_x - start_x),2)+math.pow((  dest_y - start_y),2))

	local start_deg = math.atan2(start_x-center_x,start_y-center_x)*180/math.pi
	local   end_deg = math.atan2( dest_x-center_x, dest_y-center_x)*180/math.pi

	if start_deg < 0 then start_deg = start_deg + 360 end
	if   end_deg < 0 then   end_deg =   end_deg + 360 end

	local deg_remaining = dir*(end_deg - start_deg)
	if deg_remaining < 0 then
		if dir == -1 then
			deg_remaining = start_deg + (360 - end_deg)
		else
			deg_remaining = (360 - start_deg) + end_deg
		end
	end
	return {
		radius  = math.sqrt(math.pow((center_x - start_x),2)+math.pow((center_y - start_y),2)),
		dir     = dir,
		dest    = {
			x   = dest_x,
			y   = dest_y,
			deg = end_deg},
		center  =
        {
			x   = center_x,
			y   = center_y
        },
		deg_remaining = deg_remaining,
		deg_total = deg_remaining
	}
end
--assumes z_rotation of object arrives tangential to circle rotation
function inc_banking(prep, obj, speed, seconds)
	local deg_travelled = speed*seconds/(math.pi*2*prep.radius)*360
	prep.deg_remaining = prep.deg_remaining - deg_travelled 
	local new_deg = (prep.dir*deg_travelled + obj.z_rotation[1])
	if prep.deg_remaining <= 0 then
		obj.z_rotation = {prep.dest.deg,0,0}
		obj.x = prep.dest.x
		obj.y = prep.dest.y
		prep.deg_remaining = prep.deg
		return false
	end


	obj.z_rotation = {new_deg,0,0}

--	local new_x, new_y
	if prep.dir == 1 then -- clockwise
		obj.x = prep.center.x+prep.radius*math.cos((new_deg*math.pi/180))
		obj.y = prep.center.y+prep.radius*math.sin((new_deg*math.pi/180))
	else--counter clockwise
		obj.x = prep.center.x-prep.radius*math.cos((new_deg*math.pi/180))
		obj.y = prep.center.y-prep.radius*math.sin((new_deg*math.pi/180))
	end

	return true
	
end

function bank(obj,radius,deg_limit,center, speed, seconds, dir)
	assert( obj )
--	if obj.z_rotation[1] < 0 then
	assert( dir == -1 or dir == 1 )
	assert( deg_limit <=360 and deg_limit >= -360)
	--local radius = math.pow(axis[1]-obj.x,2)+math.pow
	local ret_val = true
	local deg_travelled = speed*seconds/(math.pi*2*radius)*360
	local new_deg = (dir*deg_travelled + obj.z_rotation[1])
	if (dir == -1 and new_deg < deg_limit) or
	   (dir ==  1 and new_deg > deg_limit) then

		new_deg = deg_limit
		ret_val = false
	end

	obj.z_rotation = {new_deg,0,0}

--	local new_x, new_y
	if dir == 1 then -- clockwise
		obj.x = center[1]+radius*math.cos((new_deg*math.pi/180))
		obj.y = center[2]+radius*math.sin((new_deg*math.pi/180))
	else--counter clockwise
		obj.x = center[1]-radius*math.cos((new_deg*math.pi/180))
		obj.y = center[2]-radius*math.sin((new_deg*math.pi/180))
	end
	return ret_val
end

--]]
explosions =
{
	big = function(x,y) return {
        image = Clone{ source = imgs.explosion3 },
        group = nil,
        duration = 0.3, 
        time = 0,
        setup = function( self )
            mediaplayer:play_sound("audio/Air Combat Enemy Explosion.mp3")

            self.group = Group
			{
				size =
				{
					self.image.w / 7 ,
					self.image.h
				},
				clip =
				{
					0 ,
					0 ,
					self.image.w / 7 ,
					self.image.h
				},
				children = { self.image },
				anchor_point =
				{
					( self.image.w / 7 ) / 2 ,
					  self.image.h / 2
				},
                position = {x,y},
			}
                    
			layers.planes:add( self.group )
        end,
                
		render = function( self , seconds )
			self.time = self.time + seconds
				
			if self.time > self.duration then
					
				remove_from_render_list( self )
				self.group:unparent()
					
			else
				local frame = math.floor( self.time /
					( self.duration / 7 ) )
				self.image.x = - ( ( self.image.w / 7 )
					* frame )
			end
        end,
	} end,
	small = function(x,y) return {
        image = Clone{ source = imgs.explosion1 },
        group = nil,
        duration = 0.2, 
        time = 0,
        setup = function( self )
            mediaplayer:play_sound("audio/Air Combat Enemy Explosion.mp3")

            self.group = Group
			{
				size =
				{
					self.image.w / 6 ,
					self.image.h
				},
				clip =
				{
					0 ,
					0 ,
					self.image.w / 6 ,
					self.image.h
				},
				children = { self.image },
				anchor_point =
				{
					( self.image.w / 6 ) / 2 ,
					  self.image.h / 2
				},
                position = {x,y},
			}
                    
			layers.planes:add( self.group )
        end,
                
		render = function( self , seconds )
			self.time = self.time + seconds
				
			if self.time > self.duration then
					
				remove_from_render_list( self )
				self.group:unparent()
					
			else
				local frame = math.floor( self.time /
					( self.duration / 6 ) )
				self.image.x = - ( ( self.image.w / 6 )
					* frame )
			end
        end,
	} end
}




enemies =
{
	basic_fighter = function() return {
		num   = nil,    --number of fighters in formation
		index = nil,    --number of this fighter in its formation
		
		type = TYPE_ENEMY_PLANE,
		
		stage  = 0,     --the current stage the fighter is in
		stages = {},    --the stages, must be set by formations{}
		approach_speed = 300,
		attack_speed   = 105,
		
		--graphics for the fighter
		num_prop_frames = 3,
		prop_index = 1,
		image  = Clone{source=imgs.enemy_1},
		prop   = Clone{source=imgs.prop1},
		prop_g = Group
		{
			clip =
			{
				0,
				0,
				imgs.prop1.w,
				imgs.prop1.h/3,--self.num_prop_frames still DNE 
			},
			
			anchor_point = {imgs.prop1.w/2,   imgs.prop1.h/2},
			position     = {imgs.enemy_1.w/2, imgs.enemy_1.h},
		},
		group  = Group{anchor_point = {imgs.enemy_1.w/2,imgs.enemy_1.h/2}},
		
		shoot_time      = 2,	--how frequently the plane shoots
		last_shot_time = math.random()*2,	--how long ago the plane last shot
		
		fire = function(f,secs)
			f.last_shot_time = f.last_shot_time +
				secs
				
			if f.last_shot_time >= f.shoot_time and
				math.random(1,20) == 8 then
					
				f.last_shot_time = 0
				fire_bullet(f)
			end
		end,
		
		setup = function(self)
			
			self.prop_g:add( self.prop )
			
			self.group:add( self.image, self.prop_g )
			
			layers.planes:add( self.group )
			
			--default fighter animation
			self.stages[0] = function(f,seconds)
				
				--fly downwards
				f.group.y = f.group.y + f.attack_speed*seconds
				
				--fire bullets
				f:fire(seconds)
				
				--see if you reached the end
				if f.group.y >= screen.h + self.image.h then
					self.group:unparent()
					remove_from_render_list(self)
				end
			end
			
		end,
		
		render = function(self,seconds)
			--animate the propeller
			self.prop_index = self.prop_index%
				self.num_prop_frames + 1
			self.prop.y = -(self.prop_index - 1)*self.prop.w/
				self.num_prop_frames
				
                                --print(self.group.x,self.group.y)
			--animate the fighter based on the current stage
			self.stages[self.stage](self,seconds)
			
			--check for collisions
            table.insert(bad_guys_collision_list,
                {
                    obj = self,
                    x1  = self.group.x-self.image.w/2,
                    x2  = self.group.x+self.image.w/2,
                    y1  = self.group.y-self.image.h/2,
                    y2  = self.group.y+self.image.h/2,
                }
            )
            --[[
			add_to_collision_list(
                            
				self,
				{
					self.group.x + self.group.w / 2 ,
					self.group.y + self.group.h / 2
				},
				{
					self.group.x + self.group.w / 2 ,
					self.group.y + self.group.h / 2
				},
				{
					self.group.w ,
					self.group.h
				},
				TYPE_MY_BULLET
                        )
                        --]]
		end,
		
                collision = function( self , other )
                    self.group:unparent()
                    remove_from_render_list( self )
                        
                    -- Explode
                    add_to_render_list(
			explosions.small(
			self.group.center[1],
			self.group.center[2])
			)
		end	
	} end,
	zeppelin  = function() return {
		health = 20,
		type = TYPE_ENEMY_PLANE,
        bulletholes = {},
		
		stage  = 0,	--the current stage the fighter is in
		stages = {},	--the stages, must be set by formations{}
		approach_speed = 40,
		attack_speed   = 15,
		
		
		num_prop_frames = 3,
		prop_index = 1,
		image    = Clone{source=imgs.zepp},
		
		is_boss = false,
		
		prop =
		{
			l = Clone{source=imgs.prop3},
			r = Clone{source=imgs.prop3},
			g_l = Group
			{
				clip =
				{
					0,
					0,
					imgs.prop3.w ,
					--self.num_prop_frames still DNE 
					imgs.prop3.h/3,
				},
				anchor_point = {imgs.prop3.w/2,
				                imgs.prop3.h/2},
				position     = {37,260},
			},
			g_r = Group
			{
				clip =
				{
					0,
					0,
					imgs.prop3.w ,
					--self.num_prop_frames still DNE 
					imgs.prop3.h/3,
				},
				anchor_point = {imgs.prop3.w/2,
				                imgs.prop3.h/2},
				position     = {202,260},
			},
		},
		
		guns =
		{
			
			l = Clone
			{
				source       = imgs.barrel,
				anchor_point = {0,imgs.barrel.h/2},
				z_rotation   = {90,0,0}
			},
			
			r = Clone
			{
				source       = imgs.barrel,
				anchor_point = {0,imgs.barrel.h/2},
				z_rotation   = {90,0,0}
			},
			
			g_l = Group
			{
				x =  57,
				y = 130,
			},
			
			g_r = Group
			{
				x = 180,
				y = 130,
			},
		},
		
		group    = Group{},
		
		shoot_time      = 3,	--how frequently the plane shoots
		last_shot_time = 2,	--how long ago the plane last shot
		
		
		rotate_guns_and_fire = function(self,secs)
			---[[
			--prep the variables that determine if its time to shoot
			local r  = math.random(1,20)
			self.last_shot_time = self.last_shot_time + secs
			
			--mock enemy-object which is passed to fire_bullet()
			local mock_obj = {}
			
			--these x,y values are used for rotations and
			--bullet trajectories
			
			--user plane is the target
			local targ =
			{ 
				x = (my_plane.group.x+my_plane.image.w/2), 
				y = (my_plane.group.y+my_plane.image.h/2)
			}
			local zepp =
			{
				r =
				{ --absolute position of the zeppelin's right gun
					x = (self.guns.g_r.x+self.group.x-self.group.anchor_point[1]),
					y = (self.guns.g_r.y+self.group.y-self.group.anchor_point[2])
				},
				l =
				{ --absolute position of the zeppelin's left gun
					x = (self.guns.g_l.x+self.group.x-
						self.group.anchor_point[1]),
					y = (self.guns.g_l.y+self.group.y-
						self.group.anchor_point[2])
				}
			}
			
			
			
			-- if the target is to right, shoot with the right
			-- cannon
			if targ.x > zepp.r.x then
				
				self.guns.r.z_rotation = {180/math.pi*
					math.atan2(targ.y-zepp.r.y,
					targ.x-zepp.r.x),0,0}
				mock_obj =
				{
					group =
					{
						z_rotation =
						{ self.guns.r.z_rotation[1]-90,
							0,0},
						x = zepp.r.x,
						y = zepp.r.y
					}
				}
				if self.last_shot_time >= self.shoot_time and
					r == 8 then
					
					
					self.last_shot_time = 0
					fire_bullet(mock_obj)
					
				end
			-- if the target is to the left, shoot with the left
			-- cannon
			elseif targ.x < zepp.l.x then
				
				self.guns.l.z_rotation = {180/math.pi*
					math.atan2(targ.y-zepp.r.y,
					targ.x-zepp.r.x),0,0}
				mock_obj =
				{
					group =
					{
						z_rotation =
						{self.guns.l.z_rotation[1]-90,
							0,0},
						x = zepp.l.x,
						y = zepp.l.y
					}
				}
				if self.last_shot_time >= self.shoot_time and
					r == 8 then
					
					self.last_shot_time = 0
					fire_bullet(mock_obj)
					
				end
				
			--if the target is directly in front of or behind the
			--zepplin, then fire both cannons in that direction
			else 
				if targ.y < zepp.l.y then -- in front
					
					self.guns.r.z_rotation = { -90,0,0}
					mock_obj =
					{
						group =
						{
							z_rotation =
							{self.guns.r.
								z_rotation[1]-90
								,0,0
							},
							x=zepp.r.x,
							y=zepp.r.y
						}
					}
					if self.last_shot_time >=
						self.shoot_time and r == 8 then
						
						fire_bullet(mock_obj)
					end
					self.guns.l.z_rotation = {-90,0,0}
					mock_obj =
					{
						group =
						{
							z_rotation =
							{self.guns.l.
								z_rotation[1]-90,
								0,0},
							x=zepp.l.x,
							y=zepp.l.y
						}
					}
					if self.last_shot_time >=
						self.shoot_time and r == 8 then
						
						self.last_shot_time = 0
						fire_bullet(mock_obj)
						
					end
				else -- behind
					
					self.guns.r.z_rotation = { 90,0,0}
					mock_obj =
					{
						group =
						{
							z_rotation =
							{self.guns.r.
								z_rotation[1]-
								90,0,0},
							x=zepp.r.x,
							y=zepp.r.y
						}
					}
		                        if self.last_shot_time >=
						self.shoot_time and r == 8 then
		    	                        
						fire_bullet(mock_obj)
					end
					
					self.guns.l.z_rotation = {90,0,0}
					mock_obj =
					{
						group =
						{
							z_rotation = {self.guns.l.z_rotation[1]-90,0,0},
							x=zepp.l.x,
							y=zepp.l.y
						}
					}
					
					if self.last_shot_time >= self.shoot_time and r == 8 then
						
						self.last_shot_time = 0
						fire_bullet(mock_obj)
						
					end
				end
			end
			--]]
		end,
		
		
		
		setup = function(self)
			
			self.prop.g_l:add( self.prop.l )
			self.prop.g_r:add( self.prop.r )
			
			self.guns.g_l:add( self.guns.l, Clone{source=imgs.cannon_l,x = -imgs.cannon_l.w+7,y = -imgs.cannon_l.h/2 } )
			self.guns.g_r:add( self.guns.r, Clone{source=imgs.cannon_r,x=-2,y = -imgs.cannon_l.h/2} )
			
			self.group:add(
				
				self.image,
				
				self.prop.g_l,
				self.prop.g_r,
				
				self.guns.g_l,
				self.guns.g_r
				
			)
			
			layers.air_doodads_1:add( self.group )
			
			
			--default zeppelin animation
			self.stages[0] = function(z)
				--fly downwards
				z.group.y = z.group.y +self.speed*seconds
				
				--fire bullets
				self:rotate_guns_and_fire()
				
				--see if you reached the end
				if z.group.y >= screen.h + z.image.h then
					z.group:unparent()
					remove_from_render_list(self)
				end
			end
			
		end,
		
		render = function(self,seconds)
			--animate the propellers
			self.prop_index = self.prop_index%
				self.num_prop_frames + 1
			self.prop.l.y = -(self.prop_index - 1)*self.prop.l.h/
				self.num_prop_frames
			self.prop.r.y = -(self.prop_index - 1)*self.prop.r.h/
				self.num_prop_frames
				
			--animate the zeppelin based on the current stage
			self.stages[self.stage](self,seconds)
			--[[			--check for collisions
            for i = 1,#self.bulletholes do
                table.insert(bad_guys_collision_list,
                {
                    obj = self.bulletholes[i],
                    x1  = self.group.x+self.bulletholes[i].image.x,
                    x2  = self.group.x+self.bulletholes[i].image.x+self.bulletholes[i].image.w,
                    y1  = self.group.y+self.bulletholes[i].image.y,
                    y2  = self.group.y+self.bulletholes[i].image.y+self.bulletholes[i].image.h,
                }

            )
            --]]
            table.insert(bad_guys_collision_list,
                {
                    obj = self,
                    x1  = self.group.x+self.guns.g_l.x+3*self.guns.l.w/4,
                    x2  = self.group.x+self.guns.g_r.x-3*self.guns.l.w/4-5,
                    y1  = self.group.y+80,
                    y2  = self.group.y+self.image.h-50,
                }
            )
            
            --[[
			add_to_collision_list(
                            
				self,
				{
					self.group.x + self.group.w / 2 ,
					self.group.y + self.group.h / 2
				},
				{
					self.group.x + self.group.w / 2 ,
					self.group.y + self.group.h / 2
				},
				{
					self.group.w ,
					self.group.h
				},
				TYPE_MY_BULLET
                        )
                        --]]
		end,
		
        collision = function( self , other, from_bullethole )
			if self.health > 1 then 
				self.health = self.health - 1
                if from_bullethole == nil then
                print("there")
                local dam = {}
                if other.group ~= nil then
                    --dam.image = Clone{source = imgs["z_d_"..math.random(1,4)]}
                    dam.image = Clone{source = imgs["z_d_"..math.random(1,7)]}
                    self.group:add(dam.image)
                    dam.image.x = other.group.x - self.group.x
                    dam.image.y = other.group.y - self.group.y
                    --[[
                    dam.collision = function(d,other)
                    print("here")
                        local x = d.image.x
                        local y = d.image.y
                        
                        d.image:unparent()
                        d ={}
                        
                        d.image = Clone{source = imgs["z_d_"..math.random(5,7)]}
                        d.image.x = x
                        d.image.y = y-4
                        self.group:add(dam.image)
                        self:collision(other,true)
                    end
                    --]]
                elseif other.image ~= nil then
                    --dam.image = Clone{source = imgs["z_d_"..math.random(1,4)]}
                    dam.image = Clone{source = imgs["z_d_"..math.random(1,7)]}
                    self.group:add(dam.image)
                    dam.image.x = other.image.x - self.group.x
                    dam.image.y = other.image.y - self.group.y
                    --[[
                    dam.collision = function(d,other)
                    print("here")
                        local x = d.image.x
                        local y = d.image.y
                        
                        d.image:unparent()
                        d = {}
                        
                        d.image = Clone{source = imgs["z_d_"..math.random(5,7)]}
                        d.image.x = x
                        d.image.y = y-4
                        self.group:add(dam.image)
                        self:collision(other,true)
                    end
                    --]]
                else
                    error("render_list object with out a .group or a .image collided with the zeppelin")
                end
                --table.insert(self.bulletholes,dam)
                end
                --if dam.y > 0 then dam.y =dam.y -50 end
				return
			end
			if self.is_boss then
				levels[state.curr_level]:level_complete()
			end
			self.group:unparent()
			remove_from_render_list( self )
                        
			-- Explode
            add_to_render_list(
			explosions.big(
			self.group.center[1],
			self.group.center[2])
			)
		end	
	} end,
}


-- Functions for formation movements


--moves the object according to its speed and its z_rotation
--0 is assumed to be when the object is facing down
local move = function(group, speed, secs)
	assert(group)
        local x = secs*speed*math.cos((group.z_rotation[1]+90)*math.pi/180)
        local y = secs*speed*math.sin((group.z_rotation[1]+90)*math.pi/180)
	group.x = group.x + x
	
	group.y = group.y + y
	
        return x,y
end



local COUNTER   = -1
local CLOCKWISE =  1

local turn = function(group, radius, dir, speed, secs)
    assert( group )
    assert( dir == COUNTER or dir == CLOCKWISE )
    
    local deg_travelled = speed*secs/(math.pi*2*radius)*360
    local curr_deg = group.z_rotation[1]
    local next_deg = dir*deg_travelled + curr_deg
    
    --center of rotation
    local center =
    {
        x = group.x - dir * radius*math.cos(curr_deg*math.pi/180),
        y = group.y - dir * radius*math.sin(curr_deg*math.pi/180)
    }
--print(center.x,center.y)
    
    group.z_rotation = {next_deg,0,0}	
    group.x = center.x+dir*radius*math.cos((next_deg*math.pi/180))
    group.y = center.y+dir*radius*math.sin((next_deg*math.pi/180))
    --print(center.x,center.y," ",group.x,group.y)
    return deg_travelled
end


formations = 
{
    zepp_boss = function(x)
    
        local zepp = enemies.zeppelin()
        
        zepp.group.x = x
        zepp.group.y = -zepp.image.h
        zepp.is_boss = true
        
        zepp.stages =
        {
            -- enter screen at a slightly faster speed
            function(z,secs)
                
                move(z.group,z.approach_speed,secs)
                
                if z.group.y >= -100 then
                    z.stage = 2
                end
            end,
            
            -- slow down to attack speed and start shooting
            function(z,secs) 
            
                move(z.group,z.attack_speed,secs)
                z:rotate_guns_and_fire(secs)
                --check if it left the screen
                if z.group.y >= screen.h +
                    z.image.h then
                    z.group:unparent()
                    remove_from_render_list(z)
                    
                end
            end
        }
		zepp.stage = 1
		
		add_to_render_list(zepp)
		
    end,
	
	row_from_side = function(
			num,      -- number of fighters in the formation
            spacing,  -- spacing between the fighters
			
			start_x,  -- start position of the first fighter
			start_y,
			
			rot_at_x, -- position where each fighter performs 
			rot_at_y, --     the first turn
			
			targ_x    -- position where the last fighter turns
		)                 --     to attack
		
        assert(math.abs(targ_x-rot_at_x) >= 100)
        local dir, e
        if targ_x > start_x then
            dir = CLOCKWISE
        else
            dir = COUNTER
        end
		
        local rot       = face(start_x,start_y,rot_at_x,rot_at_y,dir)
        local x_spacing = -spacing*math.cos((rot+90)*math.pi/180)
        local y_spacing = -spacing*math.sin((rot+90)*math.pi/180)
        
		for i = 1,num do
            
			e = enemies.basic_fighter()
            
            e.group.z_rotation = {rot,0,0}
            e.group.x = start_x + x_spacing*(i-1)
            e.group.y = start_y + y_spacing*(i-1)
            
			e.stages =
			{
				
				-- move to rotation point
				function(f,secs)
					move(f.group, f.approach_speed, secs)
					
					if f.group.y <= rot_at_y then
						f.stage = 2
						f.group.y = rot_at_y
						f.group.x = rot_at_x
					end
				end,
                
				--bank to the 'line up' position
				function(f,secs)
					
					f.deg_counter[f.stage] = f.deg_counter[f.stage] +
                        turn(f.group, 150, dir, f.approach_speed,secs)
                    
                    
                    local l = dir*270
                    if math.abs(f.deg_counter[f.stage]) >= math.abs(l-rot) then
                        print(f.deg_counter[f.stage])
                        f.stage = f.stage + 1
                        
                        f.group.z_rotation = {l,0,0}
                        --f.group.x = math.abs(100*math.cos(l * 180/math.pi))
                        --f.group.y = math.abs(100*math.sin(l * 180/math.pi))
                    end
				end,
                
				--move across the screen
				function(f,secs)
 					
                    move(f.group, f.approach_speed, secs)
                    
                    local limit = targ_x + dir*spacing*(num-i)
					
					if (dir == 1 and f.group.x >= limit) or
                        (dir == -1 and f.group.x <= limit) then
                        
                        f.stage   = f.stage + 1
						--f.group.y = rot_at_y
						f.group.x = limit
                        --f.stages[f.stage](f,secs)
                        
					end
                end,
                
				--bank downwards to attack
				function(f,secs)
					
					f.deg_counter[f.stage] = f.deg_counter[f.stage] +
                        turn(f.group, 100, dir, f.approach_speed,secs)
                    
                    if math.abs(f.deg_counter[f.stage]) >= 90 then
                        
                        f.stage = f.stage + 1
                        f.group.z_rotation = {0,0,0}
                    end
				end,
                
                --move down and attack
				function(f,secs)
 					
                    move(f.group, f.attack_speed, secs)
					
					f:fire(secs)
                    
                    if f.group.y >= screen.h + f.image.h then
					    f.group:unparent()
					    remove_from_render_list(f)
                    end
                end,
			}
            e.deg_counter = {}
            for j = 1,#e.stages do
                e.deg_counter[j] = 0
            end
            e.stage = 1
            add_to_render_list(e)
		end
	end,
    
    cluster = function(x)
        
        e1 = enemies.basic_fighter()
        e2 = enemies.basic_fighter()
        e3 = enemies.basic_fighter()
        
        e1.group.position = {x-e2.image.w,-2*e2.image.h}
        e2.group.position = {x,-e2.image.h}
        e3.group.position = {x+e2.image.w,-2*e2.image.h}
        
        add_to_render_list(e1)
        add_to_render_list(e2)
        add_to_render_list(e3)

    end,
    zig_zag = function(x,r)
        e = enemies.basic_fighter()
        e.group.x = x
        e.shoot_time      = 1.5
        e.deg_counter = {}
        e.stages =
        {
            --enter the screen
            function(f,secs)
                move(f.group,f.attack_speed,secs)
                    
                f:fire(secs)
                    
                if f.group.y >= f.image.h/2 then
                        f.stage = f.stage + 1
                end
            end,
            --initial bank
            function(f,secs)
                    
                f.deg_counter[f.stage] = f.deg_counter[f.stage] +
                    turn(f.group,r,1,f.attack_speed,secs)
                    
                f:fire(secs)
                    
                if f.deg_counter[f.stage] >= 45 then
                    f.deg_counter[f.stage] = 0
                    f.stage = f.stage + 1
                        
                    f.group.z_rotation = {45,0,0}
                end
                    
            end,
            --zig
            function(f,secs)
                    
                f.deg_counter[f.stage] = f.deg_counter[f.stage] +
                    turn(f.group,r,-1,f.attack_speed,secs)
                    
                f:fire(secs)
                    
                if f.group.y >= screen.h + f.image.h then
					f.group:unparent()
					remove_from_render_list(f)
                end
                if f.deg_counter[f.stage] >= 90 then
                    f.deg_counter[f.stage] = 0
                    f.stage = f.stage + 1
                        
                    f.group.z_rotation = {-45,0,0}
                end
            end,
            --zag
            function(f,secs)
                    
                f.deg_counter[f.stage] = f.deg_counter[f.stage] +
                    turn(f.group,r,1,f.attack_speed,secs)
                    
                f:fire(secs)
                if f.group.y >= screen.h + f.image.h then
					f.group:unparent()
					remove_from_render_list(f)
                end
                if f.deg_counter[f.stage] >= 90 then
                    f.deg_counter[f.stage] = 0
                    f.stage = f.stage - 1
                        
                    f.group.z_rotation = {45,0,0}
                end
                    
            end,
        }
        for j = 1,#e.stages do
            e.deg_counter[j] = 0
        end
        e.stage = 1
        add_to_render_list(e)
    end,

	
    one_loop = function(
                num,      -- number of fighters in the formation
                spacing,  -- spacing between the fighters
                
                start_x,  -- start position of the first fighter
                
                rot_at_x, -- position where each fighter performs 
                rot_at_y, --     the first turn
                
                dir       -- the direction of the loop
        )
        
        local e
        for i = 1,num do
            e = enemies.basic_fighter()
            e.group.position = {start_x,-e.image.h - spacing*(i-1)}
            e.deg_counter = {}
            e.stages =
            {
                --move down to the rotation position
                function(f,secs)
                    move(f.group,f.attack_speed,secs)
                    
                    f:fire(secs)
                    
                    if f.group.y >= rot_at_y then
                        f.stage = f.stage + 1
                        f.group.y = rot_at_y
                    end
                end,
                
                -- bank and fire
                function(f,secs)
                    
                    f.deg_counter[f.stage] = f.deg_counter[f.stage] +
                        turn(f.group,250,dir,f.attack_speed,secs)
                    
                    f:fire(secs)
                    
                    if f.deg_counter[f.stage] >= 80 then
                        f.deg_counter[f.stage] = 0
                        f.stage = f.stage + 1
                        
                        f.group.z_rotation = {dir*80,0,0}
                        --f.group.x = math.abs(250*math.cos(80 * 180/math.pi))
                        --f.group.y = math.abs(250*math.sin(80 * 180/math.pi))
                    end
                    
                end,
                
                --finish banking
                function(f,secs)
                    
                    f.deg_counter[f.stage] = f.deg_counter[f.stage] +
                        turn(f.group,250,dir,f.approach_speed,secs)
                    

                    if f.deg_counter[f.stage] >= (180-80) then
                        f.deg_counter[f.stage] = 0
                        f.stage = f.stage + 1
                        
                        f.group.z_rotation = {180,0,0}
                        --f.group.x = math.abs(250*math.cos(180 * 180/math.pi))
                        --f.group.y = math.abs(250*math.sin(180 * 180/math.pi))
                    end
                end,
                
                --move up to the next 180 degree bank
                function(f,secs)
                    move(f.group,f.approach_speed,secs)
                    
                    
                    if f.group.y <= (rot_at_y-50) then
                        
                        f.stage = f.stage + 1
                        f.group.y = rot_at_y - 50
                        
                    end
                end,
                
                --bank back around
                function(f,secs)
                    
                    f.deg_counter[f.stage] = f.deg_counter[f.stage] +
                        turn(f.group,250,dir,f.attack_speed,secs)
                    
                    --[[
                    local deg = 180*dir
                    local y_curr = math.abs(250*math.sin(f.group.
                        z_rotation[1]*180/math.pi))
                    local y_limit = math.abs(250*math.sin(deg * 180/math.pi))
                    if y_curr < y_limit then
                        
                        f.stage = f.stage + 1
                        
                        f.group.z_rotation = {deg,0,0}
                        f.group.x = math.abs(250*math.cos(deg * 180/math.pi))
                        f.group.y = math.abs(250*math.sin(deg * 180/math.pi))
                    end
                    --]]
                    if f.deg_counter[f.stage] >= (180) then
                        f.deg_counter[f.stage] = 0
                        f.stage = f.stage + 1
                        
                        f.group.z_rotation = {0,0,0}
                        --f.group.x = math.abs(250*math.cos(0 * 180/math.pi))
                        --f.group.y = math.abs(250*math.sin(0 * 180/math.pi))
                    end                    
                end,
                --move down and attack
                function(f,secs)
                        
                    move(f.group, f.attack_speed, secs)
                        
                    f:fire(secs)
                                            
                    if f.group.y >= screen.h + f.image.h then
                        f.group:unparent()
                        remove_from_render_list(f)
                    end
                end,
            }
            for j = 1,#e.stages do
                e.deg_counter[j] = 0
            end
            e.stage = 1
            add_to_render_list(e)
        end
    end,
        
        
        
        
}
--[[
enemies =
{
    count = 0,
    time  = 0,
    enemy_seconds = ENEMY_FREQUENCY,
    images = { assets.enemy1 , assets.enemy2 , assets.enemy3 , assets.enemy4 , assets.enemy5 },
    setup  =  function( self ) end,
        
    -- Spawn a new enemy
    
    new_enemy =
    
        function( self , image , speed , position )
        
            return
            {
                type = TYPE_ENEMY_PLANE,
                
                enemies = self,
                
                speed = nil, 
                
                image = nil,
                
                group = nil,
                
                shoots = false,
                
                shoot_time = 4,--0.5 + math.random(), -- seconds
                
                last_shot_time = 2,
                
                setup =
                
                    function( self )
                    
                        if not image then
                        
                            self.image = Clone{ source = self.enemies.images[ math.random( #self.enemies.images ) ] , opacity = 255 }
                            
                        else
                        
                            self.image = Clone{ source = image , opacity = 255 }
                        end
                        
                        if speed then
                        
                            self.speed = speed
                            
                        else
                        
                            self.speed = math.random( ENEMY_PLANE_MIN_SPEED , ENEMY_PLANE_MAX_SPEED )
                            
                        end
                        
                        local position = position
                        
                        if not position then
                        
                            position = { math.random( 0 , screen.w - self.image.w ) , - self.image.h }
                        
                        end
                    
                        self.group = Group
                            {
                                size = { self.image.w / 3 , self.image.h },
                                position = position,
                                clip = { 0 , 0 , self.image.w / 3 , self.image.h },
                                children = { self.image }
                            }
                            
                        screen:add( self.group )
                        
                        self.shoots = true-- math.random( 100 ) < ENEMY_SHOOTER_PERCENTAGE
                    
                    end,
                    
                render =
                
                    function( self , seconds )
                    
                        -- Flip
                        
                        local x = self.image.x - self.image.w / 3
                        
                        if x == - self.image.w then
                        
                            x = 0
                            
                        end
                        
                        self.image.x = x
                        
                        -- Move
                        
                        local y = self.group.y + self.speed * seconds
                        
                        if y > screen.h then
                        
                            screen:remove( self.group )
                            
                            remove_from_render_list( self )
                            
                            self.enemies.count = self.enemies.count - 1
                        
                        else
                        
                            add_to_collision_list(
                                
                                self,
                                { self.group.x + self.group.w / 2 , self.group.y + self.group.h / 2 },
                                { self.group.x + self.group.w / 2 , y + self.group.h / 2 },
                                { self.group.w , self.group.h },
                                TYPE_MY_BULLET
                            )
                        
                            self.group.y = y
                            
                        end
                        
                        -- Shoot
                        
                        --if self.shoots then
                        local r = math.random()*2
                            self.last_shot_time = self.last_shot_time + seconds + r
                            --print(self.last_shot_time,self.shoot_time)
                            if self.last_shot_time >= self.shoot_time and math.random(1,20) == 8 then
                            
                                self.last_shot_time = self.last_shot_time - self.shoot_time - r
                                
                                local enemy = self
                                
                                local bullet =
                                    {
                                        speed = enemy.speed * 1.5,
                                        
                                        image = Clone{ source = assets.enemy_bullet , opacity = 255 },
                                        
                                        setup =
                                        
                                            function( self )
                                            
                                                self.image.anchor_point = { self.image.w / 2 , self.image.h / 2 }
                                                
                                                self.image.position = enemy.group.center
                                                
                                                self.image.y = self.image.y + 10
                                                
                                                --self.image.y = self.image.y + 10
                                                
                                                screen:add( self.image )
                                            
                                            end,
                                            
                                        render =
                                        
                                            function( self , seconds )
                                            
                                                local y = self.image.y + self.speed * seconds
                                                
                                                if y > screen.h then
                                                
                                                    remove_from_render_list( self )
                                                    
                                                    screen:remove( self.image )
                                                
                                                else
                                                
                                                    local start_point = self.image.center
                                                
                                                    self.image.y = y
                                                    
                                                    add_to_collision_list(
                                                    
                                                        self , start_point , self.image.center , { 4 , 4 } , TYPE_MY_PLANE
                                                    
                                                    )
                                                
                                                end
                                            
                                            end,
                                            
                                        collision =
                                        
                                            function( self , other )
                                            
                                                remove_from_render_list( self )
                                                
                                                screen:remove( self.image )
                                            
                                            end
                                    }
                                    
                                add_to_render_list( bullet )
                                
			                else
                                self.last_shot_time = self.last_shot_time - r
                            end
                        
                        --end
                    
                    end,
                    
                collision =
                
                    function( self , other )
                    
                        screen:remove( self.group )
                        
                        remove_from_render_list( self )
                        
                        self.enemies.count = self.enemies.count - 1
                        
                        -- Explode
                        
                        local enemy = self
                        
                        local explosion =
                            
                            {
                                image = Clone{ source = assets.explosion1 , opacity = 255 },
                                
                                group = nil,
                                
                                duration = 0.2, 
                                
                                time = 0,
                                
                                setup =
                                
                                    function( self )
                                    
                                        self.group = Group
                                            {
                                                size = { self.image.w / 6 , self.image.h },
                                                position = enemy.group.center,
                                                clip = { 0 , 0 , self.image.w / 6 , self.image.h },
                                                children = { self.image },
                                                anchor_point = { ( self.image.w / 6 ) / 2 , self.image.h / 2 }
                                            }
                                        
                                        screen:add( self.group )
                                        
                                    end,
                                    
                                render =
                                
                                    function( self , seconds )
                                    
                                        self.time = self.time + seconds
                                        
                                        if self.time > self.duration then
                                            
                                            remove_from_render_list( self )
                                            
                                            screen:remove( self.group )
                                        
                                        else
                                        
                                            local frame = math.floor( self.time / ( self.duration / 6 ) )
                                            
                                            self.image.x = - ( ( self.image.w / 6 ) * frame )
                                        
                                        end
                                    
                                    end,
                            }
                        
                        add_to_render_list( explosion )
                    
                    end,
            }
            
        end,
    
    -- Figure out if it is time to spawn a new enemy
    
    render =
    
        function( self , seconds )
        
            self.time = self.time + seconds
            
            if self.time >= self.enemy_seconds then
            
                if math.random(100) < 10 then
                
                    local image = self.images[ math.random( #self.images ) ]
                    
                    local speed = math.random( ENEMY_PLANE_MIN_SPEED , ENEMY_PLANE_MAX_SPEED )
                    
                    local count = 3
                    
                    local w = image.w / 3
                    
                    local left = math.random( 0 , screen.w - ( count * w ) )
                    
                    add_to_render_list( self:new_enemy( image , speed , { left , - image.h * 2 } ) )
                    add_to_render_list( self:new_enemy( image , speed , { left + w , - image.h } ) )
                    add_to_render_list( self:new_enemy( image , speed , { left + w * 2 , - image.h * 2 } ) )
                    
                    self.count = self.count + count
                
                else
            
                    add_to_render_list( self:new_enemy() )
                
                    self.count = self.count + 1
                    
                end
                
                self.time = self.time - self.enemy_seconds
            
            end
        
        end,
}
--]]
