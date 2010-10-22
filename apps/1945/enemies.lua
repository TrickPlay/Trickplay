--Spawns enemies

--Enemy Spawner launches enemy formations
--Formations:
--		Figure_8	flies in from top
--		Row			flies in from side
--		cluster		formation of 3 from the top
local imgs = 
{
	enemy_1 = Image{ src = "assets/enemy1.png" },
    enemy1          = Image{ src = "assets/e1_4x_test.png" },
    enemy2          = Image{ src = "assets/e2_4x_test.png" },
    enemy3          = Image{ src = "assets/e3_4x_test.png" },
	zepp            = Image{ src = "assets/zeppelin.png"   },
}

for _ , v in pairs( imgs ) do
    
    v.opacity = 0
        
    screen:add( v )
    
end

function fire_bullet(enemy)
    local bullet =
        {
            speed = 500,
            
            image = Clone{ source = assets.enemy_bullet , opacity = 255 },
            
            setup = function( self )
					local deg      = enemy.group.z_rotation[1] +90
					local dir_y=1
local dir_x=1
		--			if (deg > 0 and deg < 180) or deg < -180 then dir_x = -1
		--			else dir_x = 1
		--			end
		--			if (deg < 270 and deg > 90) or (deg < -90 and deg > -270) then dir_y = -1
		--			else dir_y = 1
		--			end

			--		deg = math.abs(deg)
			--		if deg > 90 then deg = deg - (math.floor(deg/90)*90) end

            		local dist_x   = math.cos(deg*math.pi/180)--deg/90
--					local dir_x    = dest_x/math.abs(dist_x)
					local dist_y   = math.sin(deg*math.pi/180)--1-deg/90
--					local dir_y    = dest_y/math.abs(dist_y)
--					local tot_dist = dist_x + dist_y


					self.speed_x = dir_x*dist_x / 1 * self.speed
					self.speed_y = dir_y*dist_y / 1 * self.speed
--print(deg," ",dir_x,dir_y," ",dist_x,dist_y," ",self.speed_x,self.speed_y)
                self.image.anchor_point = { self.image.w / 2 , self.image.h / 2 }
                self.image.position = {enemy.group.x,enemy.group.y}
                self.image.y = self.image.y + 10
                screen:add( self.image )
            end,
                
            render = function( self , seconds )
            
				local x = self.image.x + self.speed_x *seconds
				local y = self.image.y + self.speed_y *seconds
--print(x,y)
                --local y = self.image.y + self.speed * seconds
                if y > screen.h or x > screen.w or y < 0 or x < 0 then
                    remove_from_render_list( self )
                    screen:remove( self.image )
--print("end")
                else
                    local start_point = self.image.center
                    self.image.y = y
					self.image.x = x
                    add_to_collision_list(
                        self,
						start_point,
						self.image.center,
						{ 4 , 4 },
						TYPE_MY_PLANE
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
                                    
end

--assumes that 0 degrees for the object is when it faces the downward direction
--assumes that the anchor point of the object is already set to its center
function face(obj,dest_x,dest_y,wrap)

	local dist_x   = dest_x - obj.x
	local dist_y   = dest_y - obj.y

	--base angle, will point to the bottom_left
	local deg = 180/math.pi*math.atan2(math.abs(dist_y),
	                                   math.abs(dist_x))
print("1",deg)
	--if the target is above it
	if dist_y < 0 then deg = deg+90 end
print("2",deg)
	--if the target is to the right
	if dist_x > 0 then deg = deg*-1 end
print("3",deg)
	if deg < 0 then deg = 360+deg end
	if deg >= 360 then deg = deg - 360 end
	obj.z_rotation = {deg,0,0}
	return deg
end

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
print(deg_remaining)
	return {
		radius  = math.sqrt(math.pow((center_x - start_x),2)+math.pow((center_y - start_y),2)),
		dir     = dir,
		dest    = {
			x   = dest_x,
			y   = dest_y,
			deg = end_deg},
		center  = {
			x   = center_x,
			y   = center_y},
		deg_remaining = deg_remaining,
		deg_total = deg_remaining
	}
end
--assumes z_rotation of object arrives tangential to circle rotation
function inc_banking(prep, obj, speed, seconds)
	local deg_travelled = speed*seconds/(math.pi*2*prep.radius)*360
	prep.deg_remaining = prep.deg_remaining - deg_travelled 
	local new_deg = (prep.dir*deg_travelled + obj.z_rotation[1])
--[[
	if (dir == -1 and new_deg < deg_limit) or
	   (dir ==  1 and new_deg > deg_limit) then

		new_deg = deg_limit
		ret_val = false
	end
--]]


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
--[[
function bank(gg,rad,deg_limit,cent, sp, sec, quad,dir)
	assert(gg)
	local deg_travelled = sp*sec/(math.pi*2*rad)*360
	local new_deg = dir*deg_travelled + gg.z_rotation[1]
	if new_deg >= deg_limit  then
		gg.z_rotation = { deg_limit,0,0}
		return false
	end

	gg.z_rotation    = {new_deg,0.0}

	if quad == 1 then
		gg.x = cent[1] + math.cos((-1*new_deg)*math.pi/180)*rad
		gg.y = cent[2] - math.sin((-1*new_deg)*math.pi/180)*rad
	elseif quad == 2 then
		gg.x = cent[1] - math.sin((-1*new_deg-90)*math.pi/180)*rad
		gg.y = cent[2] - math.cos((-1*new_deg-90)*math.pi/180)*rad
	elseif quad == 3 then
	elseif quad == 4 then
	else
		error("only 4 quadrants, received quad ="..quad)
	end
	--	local new_x = center[1] - 
	return true
end
--]]



formations = 
{
	zepp =
	{
				type    = TYPE_ENEMY_PLANE,
				shoot_time = 2.5,
				last_shot_time =2,
		z=5,
		health = 20,
		group = nil,
		image = Clone{source=imgs.zepp},
		stage = 1,
		approach_speed = 40,
		speed = 15,

		prop1 = {},
		prop2 = {},
		prop_index,
		prop_animation = function(self)
			self.prop1[self.prop_index].opacity=0
			self.prop2[self.prop_index].opacity=0
			self.prop_index = self.prop_index%3+1
			self.prop1[self.prop_index].opacity=255
			self.prop2[self.prop_index].opacity=255
		end,
		is_boss = false,
		on_dead = function(self) 
			curr_level:level_complete()
		end,
		setup = function(self,start_x,start_y, am_boss)
			if am_boss then
				self.is_boss = true				
			end
			self.prop1 = { 
				Clone{source=assets.prop1,
				      anchor_point={assets.prop1.w/2,assets.prop1.h/2},
				      x=37,y=248
				},
				Clone{source=assets.prop2,
				      anchor_point={assets.prop2.w/2,assets.prop2.h/2},
				      x=37,y=248,
				      opacity=0
				},
				Clone{source=assets.prop3,
				      anchor_point={assets.prop3.w/2,assets.prop3.h/2},
				      x=37,y=248,
				      opacity=0
				}
			}

			self.prop2 = { 
				Clone{source=assets.prop1,
				      anchor_point={assets.prop1.w/2,assets.prop1.h/2},
				      x=202,y=248
				},
				Clone{source=assets.prop2,
				      anchor_point={assets.prop2.w/2,assets.prop2.h/2},
				      x=202,y=248,
				      opacity=0
				},
				Clone{source=assets.prop3,
				      anchor_point={assets.prop3.w/2,assets.prop3.h/2},
				      x=202,y=248,
				      opacity=0
				}
			}
			self.prop_index = 1
			self.guns = 
			{
				l = Clone
				{
					source = assets.gun_l,
					anchor_point =
					{
						3 * assets.gun_l.w / 5,
						    assets.gun_l.h / 2
					},
					clip =
					{
						2 * assets.gun_r.w / 5,
						0,
						    assets.gun_r.w / 5,
						    assets.gun_r.h
					}
				},
				r = Clone
				{
					source = assets.gun_r,
					anchor_point = 
					{
						2 * assets.gun_r.w / 5,
						    assets.gun_l.h / 2
					},
					clip = 
					{
						2 * assets.gun_r.w / 5,
						0,
						    assets.gun_r.w / 5,
						    assets.gun_r.h
					}
				}
			}

			self.gun_g = {
				l=Group{children={self.guns.l},x= 60,y=130},
				r=Group{children={self.guns.r},x=180,y=130}
			}
			self.group = Group
            {
               	position = { start_x, start_y },
				children = {self.image}
			}
			screen:add(self.group)
            self.group:add( unpack(self.prop1))
            self.group:add( unpack(self.prop2))
			self.group:add(self.gun_g.l,self.gun_g.r)

			fthis = self.guns.r
		end,
		render = function(self,seconds)
			self:prop_animation()

			local stages = {
				function() -- enter screen at a slightly faster speed
					self.group.y = self.group.y +self.approach_speed*seconds
					if self.group.y >= -100 then
						self.stage = 2
					end
				end,
				function() -- slow down to attack speed and start shooting
               		local r  = math.random(1,20)
                    self.last_shot_time = self.last_shot_time + seconds
					local mock_obj = {}

					-- these x,y values are used for rotations and bullet trajectories
					local targ = { --user plane is the target
						x = (my_plane.group.x+my_plane.image.w/2), 
						y = (my_plane.group.y+my_plane.image.h/2)
					}
					local zepp = {
						r = { --absolute position of the zeppelin's right gun
							x = (self.gun_g.r.x+self.group.x-self.group.anchor_point[1]),
							y = (self.gun_g.r.y+self.group.y-self.group.anchor_point[2])
						},
						l = { --absolute position of the zeppelin's left gun
							x = (self.gun_g.l.x+self.group.x-self.group.anchor_point[1]),
							y = (self.gun_g.l.y+self.group.y-self.group.anchor_point[2])
						}
					}
					--if the target is to right, shoot with the right cannon
					if targ.x > zepp.r.x then
					
						self.guns.r.z_rotation = {180/math.pi*
							math.atan2(targ.y-zepp.r.y,targ.x-zepp.r.x),0,0}
						mock_obj = {
							group = {
								z_rotation = { self.guns.r.z_rotation[1]-90,0,0},
								x = zepp.r.x,
								y = zepp.r.y
							}
						}

                        --print(self.last_shot_time,self.shoot_time)
                        if self.last_shot_time >= self.shoot_time and r == 8 then
                        
                            self.last_shot_time = 0--self.last_shot_time - self.shoot_time - r
                            fire_bullet(mock_obj)
						end
					-- if the target is to the left, shoot with the left cannon
					elseif targ.x < zepp.l.x then
						self.guns.l.z_rotation = {180/math.pi*
							math.atan2(zepp.l.y-targ.y,zepp.l.x-targ.x),0,0}
						mock_obj = {
							group = {
								z_rotation = { self.guns.l.z_rotation[1]+90,0,0},
								x = zepp.l.x,
								y = zepp.l.y
							}
						}
                        if self.last_shot_time >= self.shoot_time and r == 8 then
                        
                            self.last_shot_time = 0--self.last_shot_time - self.shoot_time - r
                            fire_bullet(mock_obj)

						end
					--if the target is directly in front of or behind the zepplin, then fire
					--both cannons in that direction
					else 
						if targ.y < zepp.l.y then -- in front
		
							self.guns.r.z_rotation = { -90,0,0}
							mock_obj = {
								group = {
									z_rotation = {self.guns.r.z_rotation[1]-90,0,0},
									x=zepp.r.x,
									y=zepp.r.y
								}
							}
                            if self.last_shot_time >= self.shoot_time and r == 8 then
                                fire_bullet(mock_obj)
							end
							self.guns.l.z_rotation = {90,0,0}
							mock_obj = {
								group = {
									z_rotation = {90+self.guns.l.z_rotation[1],0,0},
									x=zepp.l.x,
									y=zepp.l.y
								}
							}
                            if self.last_shot_time >= self.shoot_time and r == 8 then
                                self.last_shot_time = 0--self.last_shot_time - self.shoot_time - r
                                fire_bullet(mock_obj)
							end

						else -- behind

							self.guns.r.z_rotation = { 90,0,0}
							mock_obj = {
								group = {
									z_rotation = {self.guns.r.z_rotation[1]-90,0,0},
									x=zepp.r.x,
									y=zepp.r.y
								}
							}
	                        if self.last_shot_time >= self.shoot_time and r == 8 then
    	                        fire_bullet(mock_obj)
							end
	
							self.guns.l.z_rotation = {-90,0,0}
							mock_obj = {
								group = {
									z_rotation = {90+self.guns.l.z_rotation[1],0,0},
									x=zepp.l.x,
									y=zepp.l.y
								}
							}
    	                    if self.last_shot_time >= self.shoot_time and r == 8 then
        	                    
            	                    self.last_shot_time = 0--self.last_shot_time - self.shoot_time - r
                	                fire_bullet(mock_obj)
                                

							end

						end

					end
					--move the zeppelin down
					self.group.y = self.group.y +self.speed*seconds
				end
			}
			stages[self.stage]()
			--check if its off screen
			if self.group.y >= screen.h + self.image.h then
				self.group:unparent()
				remove_from_render_list(self)
			end
    	    add_to_collision_list(
        		self,
                { self.group.x + self.image.w / 2 , self.group.y + self.image.h / 2 },
                { self.group.x + self.image.w / 2 , self.group.y + self.image.h / 2 },
                { self.image.w,self.image.h,},
                TYPE_MY_BULLET
            )
		end,
		collision = function( self , other )
			if self.health > 1 then 
				self.health = self.health - 1 
				return
			end
			if self.is_boss then
				self:on_dead()
			end
			print("before")
            screen:remove( self.group )
			print("after")
            remove_from_render_list( self )
                
            -- Explode
            local enemy = self
            local explosion =
            {
                image = Clone{ source = assets.explosion1 , opacity = 255 },
                group = nil,
                duration = 0.2, 
                time = 0,
                setup = function( self )
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
                render = function( self , seconds )
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
	},
	row_fly_in_left = 
	{
		num     = 5,
	--	end_y   = start_y+screen.h*3/4,
		add_enemy = function( self, num, start_x, start_y, rot_at_x, rot_at_y, i, targ_x )
			return
			{
				num     = num,
				index   = i,
				type    = TYPE_ENEMY_PLANE,
				stage   = 1,
				preps   = {},
				speed   = 305,
				speed_x = nil,
				speed_y = nil,
				center  = nil,
				image   = Clone{source = imgs.enemy_1},
				group   = nil,
				enemies = self,
				shoot_time = 4,
				last_shot_time =2,


				prop = {},
				prop_index = 1,
				prop_animation = function(self)
					self.prop[self.prop_index].opacity=0
					self.prop_index = self.prop_index%3+1
					self.prop[self.prop_index].opacity=255
				end,


				setup = function(self)
					self.prop = { 
						Clone{source=assets.prop1,
						      anchor_point={assets.prop1.w/2,assets.prop1.h/2},
						      x=self.image.w/2,y=self.image.h
						},
						Clone{source=assets.prop2,
						      anchor_point={assets.prop2.w/2,assets.prop2.h/2},
						      x=self.image.w/2,y=self.image.h,
						      opacity=0
						},
						Clone{source=assets.prop3,
						      anchor_point={assets.prop3.w/2,assets.prop3.h/2},
						      x=self.image.w/2,y=self.image.h,
						      opacity=0
						}
					}



					local radius   = 200
					local dist_x   = math.abs(rot_at_x-start_x)
					local dist_y   = math.abs(rot_at_y-start_y)
					local tot_dist = dist_y + dist_x
--					local rot      = math.atan2(dist_y,dist_x)*180/math.pi+90+45
					self.speed_x   = self.speed*dist_x/tot_dist -- self.image.w/6
					self.speed_y   = self.speed*dist_y/tot_dist
print(rot,dist_y,dist_x)
					self.group = Group
                    {
                    	position    = { start_x, start_y },
                    	size        = {       self.image.w/3, self.image.h   },
				--		clip        = { 0, 0, self.image.w/3, self.image.h   },
						anchor_point = { self.image.w/2, self.image.h/2 },
			--			z_rotation  = { (rot),  0,0 },
						children    = { self.image, unpack(self.prop) }
					}
					local rot = face(self.group,rot_at_x,rot_at_y)

					self.center    = {radius*math.cos((rot-180)*math.pi/180)+rot_at_x, -- x
					                  radius*math.sin((rot-180)*math.pi/180)+rot_at_y} -- y


	--				self.preps[2] = prep_bank_to(rot_at_x,rot_at_y,self.center[1],self.center[2]-radius,
	--					self.center[1],self.center[2],1)
					screen:add( self.group )
print("left",targ_x)
				if targ_x == nil or targ_x < self.center[1] then targ_x = self.center[1] end
--print("success",rot_at_x,self.center[1],self.center[2], rot )
				end,



				render = function(self,seconds)
assert(self)
--if self.index == 1 then print("render   ",self.group.x, self.group.y) end
            --        local x = self.image.x - self.image.w / 3
                    
             --       if x == - self.image.w then x = 0 end
               --     self.image.x = x
					self:prop_animation()

					local radius = 200
					local stages = {}
					stages =
					{
						-- move to rotation point
						function()
--print("stage1")
							self.group.y = self.group.y -self.speed_y*seconds
							self.group.x = self.group.x +self.speed_x*seconds
							if self.group.y <= rot_at_y then
								self.stage = 2
								self.group.y = self.group.y +self.speed_y*seconds
								self.group.x = self.group.x -self.speed_x*seconds
								stages[2]()
							end
						end,
						--bank to the 'line up' position
						function()
							--if not inc_banking(self.preps[2],self.group,self.speed,seconds) then
							if not bank(self.group,radius,270,self.center,self.speed,seconds,1) then
								self.stage = 3
								stages[3]()
							end
						end,
						--move across the screen
						function()
							if self.group.x >= targ_x+(num-(self.index-1))*150 then
								self.group.x = targ_x+(num-(self.index-1))*150
								self.stage = 4
								stages[4]()
							end
							self.group.x = self.group.x +self.speed*seconds
						end,
						--bank downwards
						function()
							if not bank(self.group,50,360,{targ_x+(num-(self.index-1))*150,self.center[2]-200+50},self.speed,seconds,1) then
								self.stage = 5
								stages[5]()
							end
						end,
						--move down
						function()
							self.group.y = self.group.y +100*seconds
               		         local r = math.random()*2
                            self.last_shot_time = self.last_shot_time + seconds + r
                            --print(self.last_shot_time,self.shoot_time)
                            if self.last_shot_time >= self.shoot_time and math.random(1,20) == 8 then
                            
                                self.last_shot_time = self.last_shot_time - self.shoot_time - r
                                fire_bullet(self)
                                
			                else
                                self.last_shot_time = self.last_shot_time - r

							end
							if self.group.y >= screen.h + self.image.h then
								self.group:unparent()
								remove_from_render_list(self)
							end

						end
					}
					stages[self.stage]()
                        add_to_collision_list(
                            
                            self,
                            { self.group.x + self.group.w / 2 , self.group.y + self.group.h / 2 },
                            { self.group.x + self.group.w / 2 , self.group.y + self.group.h / 2 },
                            { self.group.w , self.group.h },
                            TYPE_MY_BULLET
                        )


				end,
                collision = function( self , other )
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
                        setup = function( self )
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
                        render = function( self , seconds )
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
		render = function() end,
		collision = function() end,
		setup = function(self,rot_x,targ_x)
print("settingup",rot_x,targ_x)
local num=5
			local start_x = -100 --math.random(0,1)*(screen.w+imgs.enemy1.w/3) - imgs.enemy1.w/3 --assumes a strip with 3 imgs
			local start_y = 1000 --math.random(0,200)+screen.h*3/4
local rot_at_x   = rot_x
local rot_at_y   = 250

					local dist_x    = math.abs(rot_at_x-start_x)
					local dist_y    = math.abs(rot_at_y-start_y)

			for i = 1, 5 do
--print("start")
				local my_start_at_y = start_y + 150*(i-1)
				local my_start_at_x = (start_y - my_start_at_y)*dist_x/dist_y+start_x
--print("hi")
				add_to_render_list(self:add_enemy(num, my_start_at_x, my_start_at_y, rot_at_x, rot_at_y, i,targ_x))
--print("wtf")
			end
			remove_from_render_list( self )
		end,
	},





	row_fly_in_right = 
	{
		num     = 5,
	--	end_y   = start_y+screen.h*3/4,
		add_enemy = function( self, num, start_x, start_y, rot_at_x, rot_at_y, i )
			return
			{
				num     = num,
				index   = i,
				type    = TYPE_ENEMY_PLANE,
				stage   = 1,
				speed   = 305,
				speed_x = nil,
				speed_y = nil,
				center  = nil,
				image   = Clone{source = imgs.enemy_1},
				group   = nil,
				enemies = self,
				shoot_time = 4,
				last_shot_time =2,
				prop = {},
				prop_index = 1,
				prop_animation = function(self)
					self.prop[self.prop_index].opacity=0
					self.prop_index = self.prop_index%3+1
					self.prop[self.prop_index].opacity=255
				end,


				setup = function(self)
					self.prop = { 
						Clone{source=assets.prop1,
						      anchor_point={assets.prop1.w/2,assets.prop1.h/2},
						      x=self.image.w/2,y=self.image.h
						},
						Clone{source=assets.prop2,
						      anchor_point={assets.prop2.w/2,assets.prop2.h/2},
						      x=self.image.w/2,y=self.image.h,
						      opacity=0
						},
						Clone{source=assets.prop3,
						      anchor_point={assets.prop3.w/2,assets.prop3.h/2},
						      x=self.image.w/2,y=self.image.h,
						      opacity=0
						}
					}
					local radius   = 200
					local dist_x   = math.abs(rot_at_x-start_x)
					local dist_y   = math.abs(rot_at_y-start_y)
					local tot_dist = math.abs(dist_y) + math.abs(dist_x)
				--	local rot      = math.atan2(math.abs(dist_y),math.abs(dist_x))*-180/math.pi-90-45
print(rot,dist_y,dist_x)
					self.speed_x   = self.speed*dist_x/tot_dist -- self.image.w/6
					self.speed_y   = self.speed*dist_y/tot_dist
					self.group = Group
                    {
                    	position    = { start_x, start_y },
                    	size        = {       self.image.w/3, self.image.h   },
				--		clip        = { 0, 0, self.image.w/3, self.image.h   },
						anchor_point = { self.image.w/2, self.image.h/2 },
				--		z_rotation  = { rot,  0,0 },
						children    = { self.image,unpack(self.prop) }
					}
					local rot = face(self.group,rot_at_x,rot_at_y)
					self.center    = {rot_at_x-radius*math.cos((rot+180)*math.pi/180), -- x
					                  rot_at_y-radius*math.sin((rot+180)*math.pi/180) --y
					}

					screen:add( self.group )
print("success",rot_at_x,self.center[1],self.center[2]," ",rot )
				end,

				render = function(self,seconds)
assert(self)
--print("render   ",self.index)
              --      local x = self.image.x - self.image.w / 3
                    
              --      if x == - self.image.w then x = 0 end
              --      self.image.x = x
self:prop_animation()
					local radius = 200
					local stages = {}
					stages =
					{
						-- move to rotation point
						function()
--if self.index == 1 then print("stage1",self.group.x,self.group.y) end
							self.group.y = self.group.y -self.speed_y*seconds
							self.group.x = self.group.x -self.speed_x*seconds
							if self.group.y <= rot_at_y then
								self.stage = 2
								self.group.y = self.group.y +self.speed_y*seconds
								self.group.x = self.group.x -self.speed_x*seconds
								stages[2]()
							end
						end,
						--bank to the 'line up' position
						function()
							if not bank(self.group,radius,90,self.center,self.speed,seconds,-1) then
								self.stage = 3
								stages[3]()
							end
						end,
						--move across the screen
						function()
							if self.group.x <= self.center[1]-(num-(self.index-1))*150 then
								self.group.x = self.center[1]-(num-(self.index-1))*150
								self.stage = 4
								stages[4]()
							end
							self.group.x = self.group.x -self.speed*seconds
						end,
						--bank downwards
						function()
							if not bank(self.group,50,0,{self.center[1]-(num-(self.index-1))*150,self.center[2]-200+50},self.speed,seconds,-1) then
								self.stage = 5
								stages[5]()
							end
						end,
						--move down
						function()
							self.group.y = self.group.y +100*seconds
               		         local r = math.random()*2
                            self.last_shot_time = self.last_shot_time + seconds + r
                            --print(self.last_shot_time,self.shoot_time)
                            if self.last_shot_time >= self.shoot_time and math.random(1,20) == 8 then
                            
                                self.last_shot_time = self.last_shot_time - self.shoot_time - r
                                fire_bullet(self)
                                
			                else
                                self.last_shot_time = self.last_shot_time - r

							end
							if self.group.y >= screen.h + self.image.h then
								self.group:unparent()
								remove_from_render_list(self)
							end
						end
					}
					 stages[self.stage]()
                     add_to_collision_list(
                            
                            self,
                            { self.group.x + self.group.w / 2 , self.group.y + self.group.h / 2 },
                            { self.group.x + self.group.w / 2 , self.group.y + self.group.h / 2 },
                            { self.group.w , self.group.h },
                            TYPE_MY_BULLET
                        )

				end,
                collision = function( self , other )
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
                        setup = function( self )
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
                        render = function( self , seconds )
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
		render = function() end,
		collision = function() end,
		setup = function(self)
print("settingup")
local num=5
			local start_x = 2000 --math.random(0,1)*(screen.w+imgs.enemy1.w/3) - imgs.enemy1.w/3 --assumes a strip with 3 imgs
			local start_y = 1000 --math.random(0,200)+screen.h*3/4
local rot_at_x   = 1850
local rot_at_y   = 250

					local dist_x    = (rot_at_x-start_x)
					local dist_y    = (rot_at_y-start_y)

			for i = 1, 5 do
--print("start")
				local my_start_at_y = start_y + 150*(i-1)
				local my_start_at_x = -1*(start_y - my_start_at_y)*dist_x/dist_y+start_x
print("hi",my_start_at_x, my_start_at_y)
				add_to_render_list(self:add_enemy(num, my_start_at_x, my_start_at_y, rot_at_x, rot_at_y, i))
--print("wtf")
			end
			remove_from_render_list( self )
		end,
	},







	loop_from_left = 
	{
		num     = 2,
	--	end_y   = start_y+screen.h*3/4,
		add_enemy = function( self, num, start_x, start_y, rot_at_x, rot_at_y, i )
			return
			{
				num     = num,
				index   = i,
				type    = TYPE_ENEMY_PLANE,
				stage   = 1,
				speed   = 305,
				speed_x = nil,
				speed_y = nil,
				center  = nil,
				image   = Clone{source = imgs.enemy_1},
				group   = nil,
				enemies = self,
				shoot_time = 3,
				last_shot_time =0,

				prop = {},
				prop_index = 1,
				prop_animation = function(self)
					self.prop[self.prop_index].opacity=0
					self.prop_index = self.prop_index%3+1
					self.prop[self.prop_index].opacity=255
				end,


				setup = function(self)
					self.prop = { 
						Clone{source=assets.prop1,
						      anchor_point={assets.prop1.w/2,assets.prop1.h/2},
						      x=self.image.w/2,y=self.image.h
						},
						Clone{source=assets.prop2,
						      anchor_point={assets.prop2.w/2,assets.prop2.h/2},
						      x=self.image.w/2,y=self.image.h,
						      opacity=0
						},
						Clone{source=assets.prop3,
						      anchor_point={assets.prop3.w/2,assets.prop3.h/2},
						      x=self.image.w/2,y=self.image.h,
						      opacity=0
						}
					}


					local radius   = 200
					local dist_x   = math.abs(rot_at_x-start_x)
					local dist_y   = math.abs(rot_at_y-start_y)
					local tot_dist = math.abs(dist_y) + math.abs(dist_x)
					local rot      = 0--math.atan2(math.abs(dist_y),math.abs(dist_x))*-180/math.pi-90-45
print(rot,dist_y,dist_x)
	--				self.speed_x   = self.speed*dist_x/tot_dist -- self.image.w/6
	--				self.speed_y   = self.speed*dist_y/tot_dist
					self.centers   = {}
					self.centers[2]= {
							rot_at_x+250, -- x
					    	rot_at_y
					}
					self.centers[5]= {
							rot_at_x+250, -- x
					    	250
					}
		
					self.group = Group
                    {
                    	position    = { start_x, start_y },
                    	size        = {       self.image.w/3, self.image.h   },
				--		clip        = { 0, 0, self.image.w/3, self.image.h   },
						anchor_point = { self.image.w/2, self.image.h/2 },
						z_rotation  = { rot,  0,0 },
						children    = { self.image, unpack(self.prop) }
					}
					screen:add( self.group )
--print("success",rot_at_x,self.center[1],self.center[2]," ",rot )
				end,

				render = function(self,seconds)
assert(self)
--print("render   ",self.index)
               		         local r = math.random()*2

--                    local x = self.image.x - self.image.w / 3
  --                  
    --                if x == - self.image.w then x = 0 end
      --              self.image.x = x
self:prop_animation()
					local radius = 200
					local stages = {}
					stages =
					{
						-- move down
						function()
--if self.index == 1 then print("stage1",self.group.x,self.group.y) end
							self.group.y = self.group.y +self.speed/3*seconds
                            self.last_shot_time = self.last_shot_time + seconds + r

                            if self.last_shot_time >= self.shoot_time and math.random(4,10) == 8 then
                            
                                self.last_shot_time = 0--self.last_shot_time - self.shoot_time - r
                                fire_bullet(self)
                                
			                else
                                self.last_shot_time = self.last_shot_time - r

							end

							--self.group.x = self.group.x -self.speed*seconds
							if self.group.y >= rot_at_y then
								self.stage = 2
								self.group.y = self.group.y -self.speed/3*seconds
								stages[2]()
							end
						end,
						--bank to the right while firing
						function()
                            self.last_shot_time = self.last_shot_time + seconds + r

                            if self.last_shot_time >= self.shoot_time*2/3 and math.random(7,9) == 8 then
                            
                                self.last_shot_time = 0--self.last_shot_time - self.shoot_time - r
                                fire_bullet(self)
                                
			                else
                                self.last_shot_time = self.last_shot_time - r

							end

							if not bank(self.group,250,-80,self.centers[2],self.speed/2,seconds,-1) then
								self.stage = 3
								stages[3]()
							end
						end,
						function()
                            self.last_shot_time = self.last_shot_time + seconds + r

							if not bank(self.group,250,-180,self.centers[2],self.speed,seconds,-1) then
								self.stage = 4
								stages[4]()
							end
						end,
						function()
                            self.last_shot_time = self.last_shot_time + seconds + r

							self.group.y = self.group.y -self.speed*seconds
							--self.group.x = self.group.x -self.speed*seconds
							if self.group.y <= 250 then
								self.stage = 5
								self.group.y = self.group.y -self.speed*seconds
								stages[5]()
							end


						end,
						function()
                            self.last_shot_time = self.last_shot_time + seconds + r

							if not bank(self.group,250,-360,self.centers[5],self.speed,seconds,-1) then
								self.group.z_rotation={0,0,0}
								self.stage = 6
								stages[6]()
							end
						end,
						function()
--if self.index == 1 then print("stage1",self.group.x,self.group.y) end
							self.group.y = self.group.y +self.speed/3*seconds
                            self.last_shot_time = self.last_shot_time + seconds + r

                            if self.last_shot_time >= self.shoot_time and math.random(4,10) == 8 then
                            
                                self.last_shot_time = 0--self.last_shot_time - self.shoot_time - r
                                fire_bullet(self)
                                
			                else
                                self.last_shot_time = self.last_shot_time - r

							end

							--self.group.x = self.group.x -self.speed*seconds
							if self.group.y >= screen.h + self.image.h then
								self.group:unparent()
								remove_from_render_list(self)
							end
						end,

					}
					stages[self.stage]()
                        add_to_collision_list(
                            
                            self,
                            { self.group.x + self.group.w / 2 , self.group.y + self.group.h / 2 },
                            { self.group.x + self.group.w / 2 , self.group.y + self.group.h / 2 },
                            { self.group.w , self.group.h },
                            TYPE_MY_BULLET
                        )

				end,
                collision = function( self , other )
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
                        setup = function( self )
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
                        render = function( self , seconds )
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
		render = function() end,
		collision = function() end,
		setup = function(self)
		print("settingup loop left")
		local num=2
			local start_x = 200 --math.random(0,1)*(screen.w+imgs.enemy1.w/3) - imgs.enemy1.w/3 --assumes a strip with 3 imgs
			local start_y = -200 --math.random(0,200)+screen.h*3/4
local rot_at_x   = 200
local rot_at_y   = 300

					local dist_x    = (rot_at_x-start_x)
					local dist_y    = (rot_at_y-start_y)

			for i = 1, 2 do
--print("start")
				local my_start_at_y = start_y - 300*(i-1)
				local my_start_at_x = -1*(start_y - my_start_at_y)*dist_x/dist_y+start_x
print("hi",my_start_at_x, my_start_at_y)
				add_to_render_list(self:add_enemy(num, my_start_at_x, my_start_at_y, rot_at_x, rot_at_y, i))
--print("wtf")
			end
			remove_from_render_list( self )
		end,
	},






	loop_from_right = 
	{
		num     = 2,
	--	end_y   = start_y+screen.h*3/4,
		add_enemy = function( self, num, start_x, start_y, rot_at_x, rot_at_y, i )
			return
			{
				num     = num,
				index   = i,
				type    = TYPE_ENEMY_PLANE,
				stage   = 1,
				speed   = 305,
				speed_x = nil,
				speed_y = nil,
				center  = nil,
				image   = Clone{source = imgs.enemy_1},
				group   = nil,
				enemies = self,
				shoot_time = 3,
				last_shot_time =0,

				prop = {},
				prop_index = 1,
				prop_animation = function(self)
					self.prop[self.prop_index].opacity=0
					self.prop_index = self.prop_index%3+1
					self.prop[self.prop_index].opacity=255
				end,


				setup = function(self)
					self.prop = { 
						Clone{source=assets.prop1,
						      anchor_point={assets.prop1.w/2,assets.prop1.h/2},
						      x=self.image.w/2,y=self.image.h
						},
						Clone{source=assets.prop2,
						      anchor_point={assets.prop2.w/2,assets.prop2.h/2},
						      x=self.image.w/2,y=self.image.h,
						      opacity=0
						},
						Clone{source=assets.prop3,
						      anchor_point={assets.prop3.w/2,assets.prop3.h/2},
						      x=self.image.w/2,y=self.image.h,
						      opacity=0
						}
					}


					local radius   = 200
					local dist_x   = math.abs(rot_at_x-start_x)
					local dist_y   = math.abs(rot_at_y-start_y)
					local tot_dist = math.abs(dist_y) + math.abs(dist_x)
					local rot      = 0--math.atan2(math.abs(dist_y),math.abs(dist_x))*-180/math.pi-90-45
print(rot,dist_y,dist_x)
	--				self.speed_x   = self.speed*dist_x/tot_dist -- self.image.w/6
	--				self.speed_y   = self.speed*dist_y/tot_dist
					self.centers   = {}
					self.centers[2]= {
							rot_at_x-250, -- x
					    	rot_at_y
					}
					self.centers[5]= {
							rot_at_x-250, -- x
					    	250
					}
		
					self.group = Group
                    {
                    	position    = { start_x, start_y },
                    --	size        = {       self.image.w/3, self.image.h   },
					--	clip        = { 0, 0, self.image.w/3, self.image.h   },
						anchor_point = { self.image.w/2, self.image.h/2 },
						z_rotation  = { rot,  0,0 },
						children    = { self.image,unpack(self.prop) }
					}
					screen:add( self.group )
--print("success",rot_at_x,self.center[1],self.center[2]," ",rot )
				end,

				render = function(self,seconds)
assert(self)
--print("render   ",self.index)
               		         local r = math.random()*2

         --           local x = self.image.x - self.image.w / 3
                    
           --         if x == - self.image.w then x = 0 end
             --       self.image.x = x
self:prop_animation()

					local radius = 200
					local stages = {}
					stages =
					{
						-- move down
						function()
--if self.index == 1 then print("stage1",self.group.x,self.group.y) end
                            self.last_shot_time = self.last_shot_time + seconds + r

							self.group.y = self.group.y +self.speed/2*seconds
                            if self.last_shot_time >= self.shoot_time and math.random(4,10) == 8 then
                            
                                self.last_shot_time = 0--self.last_shot_time - self.shoot_time - r
                                fire_bullet(self)
                                
			                else
                                self.last_shot_time = self.last_shot_time - r

							end

							--self.group.x = self.group.x -self.speed*seconds
							if self.group.y >= rot_at_y then
								self.stage = 2
								self.group.y = self.group.y -self.speed/3*seconds
								stages[2]()
							end
						end,
						--bank to the right while firing
						function()
                            self.last_shot_time = self.last_shot_time + seconds + r

                            if self.last_shot_time >= self.shoot_time*2/3 and math.random(7,9) == 8 then
                            
                                self.last_shot_time = 0--self.last_shot_time - self.shoot_time - r
                                fire_bullet(self)
                                
			                else
                                self.last_shot_time = self.last_shot_time - r

							end

							if not bank(self.group,250,80,self.centers[2],self.speed/2,seconds,1) then
								self.stage = 3
								stages[3]()
							end
						end,
						function()
                            self.last_shot_time = self.last_shot_time + seconds + r

							if not bank(self.group,250,180,self.centers[2],self.speed,seconds,1) then
								self.stage = 4
								stages[4]()
							end
						end,
						function()
                            self.last_shot_time = self.last_shot_time + seconds + r

							self.group.y = self.group.y -self.speed*seconds
							--self.group.x = self.group.x -self.speed*seconds
							if self.group.y <= 250 then
								self.stage = 5
								self.group.y = self.group.y -self.speed*seconds
								stages[5]()
							end


						end,
						function()
                            self.last_shot_time = self.last_shot_time + seconds + r

							if not bank(self.group,250,360,self.centers[5],self.speed,seconds,1) then
								self.group.z_rotation={0,0,0}
								self.stage = 6
								stages[6]()
							end
						end,
						function()
--if self.index == 1 then print("stage1",self.group.x,self.group.y) end
                            self.last_shot_time = self.last_shot_time + seconds + r

							self.group.y = self.group.y +self.speed/2*seconds
                            if self.last_shot_time >= self.shoot_time and math.random(4,10) == 8 then
                            
                                self.last_shot_time = 0--self.last_shot_time - self.shoot_time - r
                                fire_bullet(self)
                                
			                else
                                self.last_shot_time = self.last_shot_time - r

							end

							--self.group.x = self.group.x -self.speed*seconds
							if self.group.y >= screen.h + self.image.h then
								self.group:unparent()
								remove_from_render_list(self)
							end
						end,

					}
					stages[self.stage]()
                        add_to_collision_list(
                            
                            self,
                            { self.group.x + self.group.w / 2 , self.group.y + self.group.h / 2 },
                            { self.group.x + self.group.w / 2 , self.group.y + self.group.h / 2 },
                            { self.group.w , self.group.h },
                            TYPE_MY_BULLET
                        )

				end,
                collision = function( self , other )
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
                        setup = function( self )
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
                        render = function( self , seconds )
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
		render = function() end,
		collision = function() end,
		setup = function(self)
		print("settingup loop left")
		local num=2
			local start_x = 1700 --math.random(0,1)*(screen.w+imgs.enemy1.w/3) - imgs.enemy1.w/3 --assumes a strip with 3 imgs
			local start_y = -200 --math.random(0,200)+screen.h*3/4
local rot_at_x   = 1700
local rot_at_y   = 300

					local dist_x    = (rot_at_x-start_x)
					local dist_y    = (rot_at_y-start_y)

			for i = 1, 2 do
--print("start")
				local my_start_at_y = start_y - 300*(i-1)
				local my_start_at_x = -1*(start_y - my_start_at_y)*dist_x/dist_y+start_x
print("hi",my_start_at_x, my_start_at_y)
				add_to_render_list(self:add_enemy(num, my_start_at_x, my_start_at_y, rot_at_x, rot_at_y, i))
--print("wtf")
			end
			remove_from_render_list( self )
		end,
	}


}

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

