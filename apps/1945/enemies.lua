--Spawns enemies

--Enemy Spawner launches enemy formations
--Formations:
--		Figure_8	flies in from top
--		Row			flies in from side
--		cluster		formation of 3 from the top


--base images for clones



function fire_bullet(enemy,source)
    local bullet =
    {
        speed = 500,
        num_frames = 1,
        image = Clone
        {
            source = source ,
            opacity = 255,
            anchor_point =
            {
                source.w/2,
                source.h/2
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
                if y > screen_h or x > screen_w or y < 0 or x < 0 then
                    remove_from_render_list( self )
                    self.image:unparent()
		--otherwise, update the position
                else
                    local start_point = self.image.center
                    self.image.y = y
		    self.image.x = x
		    --check for collisions
            
            table.insert(b_guys_air,
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
function flak(x,y)
    dolater(add_to_render_list,
    {
        num   = 8,
        delays = {},
        flaks = {},
        groups = {},
        group = nil,
        duration = 0.2,
        hit = false,
        time = 0,
        setup = function( self )
            --mediaplayer:play_sound("audio/Air Combat Enemy Explosion.mp3")
            self.group = Group{ position = {x,y} }
            
            for i = 1,self.num do
                self.flaks[i] = Clone{ source = imgs.flak }
                self.groups[i] = Group
                {
                	size =
                	{
                		imgs.flak.w / 4 ,
                		imgs.flak.h
                	},
                	clip =
                	{
                		0 ,
                		0 ,
                		imgs.flak.w / 4 ,
                		imgs.flak.h
                	},
                	children = { self.flaks[i] },
                	anchor_point =
                	{
                		( imgs.flak.w / 4 ) / 2 ,
                		  imgs.flak.h / 2
                	},
                    position = {x,y},
                }
                self.delays[i] = math.ceil(i/2)-1--math.random() *.1
                self.group:add(self.groups[i])
                
                self.groups[i].x = math.random(-6,6)*4
                self.groups[i].y = math.random(-6,6)*4
            end
            
            
            
			layers.planes:add( self.group )
        end,
                
		render = function( self , seconds )
            
			self.time = self.time + seconds
			
			if self.time > (self.duration +.5)then
				
				remove_from_render_list( self )
                for i = 1,self.num do
                    self.flaks[i]:unparent()
                    self.groups[i]:unparent()
                end
				self.group:unparent()
				
			else
				
                for i = 1,self.num do
                    local frame = math.floor( self.time /
                        ( self.duration / 4 ) ) -self.delays[i]
                    self.flaks[i].x = - ( ( imgs.flak.w / 4 )
                    	* frame )
                end
				
			end
            if not self.hit then
            table.insert(b_guys_air,
                {
                    obj = self,
                    x1  = self.group.x-24-imgs.flak.w/8,
                    x2  = self.group.x+24-imgs.flak.w/8,
                    y1  = self.group.y-24-imgs.flak.h/2,
                    y2  = self.group.y+24-imgs.flak.h/2,
                }
            )
            end
        end,
        collision = function( self , other )
            
			self.hit = true
            
		end	
	}
    )
end
function fire_flak(enemy, dist_x,dist_y)
print("dists",dist_x,dist_y)
    local bullet =
    {
        dist_x = dist_x,
        dist_y = dist_y,
        speed = 600,
        num_frames = 1,
        image = Clone
        {
            source = imgs.t_bullet ,
            opacity = 255,
            anchor_point =
            {
                imgs.t_bullet.w/2,
                imgs.t_bullet.h/2
            },
            position =
            {
                enemy.group.x+imgs.t_bullet.w,
                enemy.group.y+imgs.t_bullet.h/2
            },
            z_rotation = {enemy.group.z_rotation[1]+90,0,0}
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
                self.dist_x = self.dist_x - math.abs(self.speed_x *seconds)
                self.dist_y = self.dist_y - math.abs(self.speed_y *seconds)
                --calculate the next position of the bullet
                local x = self.image.x + self.speed_x *seconds
                local y = self.image.y + self.speed_y *seconds
                --remove it from the screen, if it travels off screen
                if y > screen_h or x > screen_w or y < 0 or x < 0 then
                    remove_from_render_list( self )
                    self.image:unparent()
                --otherwise, update the position
                elseif self.dist_y < 0 and self.dist_x < 0 then
                    remove_from_render_list( self )
                    self.image:unparent()
                    flak(x,y)
                else
                    local start_point = self.image.center
                    self.image.y = y
		    self.image.x = x
		    --check for collisions
            --[[
            table.insert(b_guys_air,
                {
                    obj = self,
                    x1  = self.image.x-self.image.w/2,
                    x2  = self.image.x+self.image.w/2,
                    y1  = self.image.y-self.image.h/2,
                    y2  = self.image.y+self.image.h/2,
                }
            )--]]
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
	if dir ==  1 and deg < 0 then deg = deg + 360 end
    return deg
    
end

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
		image  = Clone{source=imgs.fighter},
		prop   = Clone{source=imgs.fighter_prop},
		prop_g = Group
		{
			clip =
			{
				0,
				0,
				imgs.fighter_prop.w,
				imgs.fighter_prop.h/3,--self.num_prop_frames still DNE 
			},
			
			anchor_point = {imgs.fighter_prop.w/2,   imgs.fighter_prop.h/2},
			position     = {imgs.fighter.w/2, imgs.fighter.h},
		},
		group  = Group{anchor_point = {imgs.fighter.w/2,imgs.fighter.h/2}},
		
		shoot_time      = 2,	--how frequently the plane shoots
		last_shot_time = math.random()*2,	--how long ago the plane last shot
		
		fire = function(f,secs)
			f.last_shot_time = f.last_shot_time +
				secs
				
			if f.last_shot_time >= f.shoot_time and
				math.random(1,20) == 8 then
					
				f.last_shot_time = 0
				fire_bullet(f,imgs.fighter_bullet)
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
				if f.group.y >= screen_h + self.image.h then
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
            table.insert(b_guys_air,
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
        
        e_fire_l_i = 0,
        e_fire_r_i = 0,
        
        e_fire_r = Clone{ source=imgs.engine_fire, opacity=0 },
        e_r_dam  = Clone{ source=imgs.z_d_e, opacity=0 },
        e_fire_l = Clone{ source=imgs.engine_fire, opacity=0 },
        e_l_dam  = Clone{ source=imgs.z_d_e,opacity=0 },
        
        e_fire_r_g = Group{position={185,260},clip={0,0,imgs.engine_fire.w/6,imgs.engine_fire.h}},
        e_fire_l_g = Group{position={ 22,260},clip={0,0,imgs.engine_fire.w/6,imgs.engine_fire.h}},
        
        right_engine_dam = 0,
        left_engine_dam = 0,
		
		is_boss = false,
		
		prop =
		{
			l = Clone{source=imgs.zepp_prop},
			r = Clone{source=imgs.zepp_prop},
			g_l = Group
			{
				clip =
				{
					0,
					0,
					imgs.zepp_prop.w ,
					--self.num_prop_frames still DNE 
					imgs.zepp_prop.h/3,
				},
				anchor_point = {imgs.zepp_prop.w/2,
				                imgs.zepp_prop.h/2},
				position     = {37,260},
			},
			g_r = Group
			{
				clip =
				{
					0,
					0,
					imgs.zepp_prop.w ,
					--self.num_prop_frames still DNE 
					imgs.zepp_prop.h/3,
				},
				anchor_point = {imgs.zepp_prop.w/2,
				                imgs.zepp_prop.h/2},
				position     = {202,260},
			},
		},
		
		guns =
		{
			
			l = Clone
			{
				source       = imgs.z_barrel,
				anchor_point = {0,imgs.z_barrel.h/2},
				z_rotation   = {90,0,0}
			},
			
			r = Clone
			{
				source       = imgs.z_barrel,
				anchor_point = {0,imgs.z_barrel.h/2},
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
				x = (my_plane.group.x+my_plane.image.w/(2*my_plane.num_frames)), 
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
					fire_bullet(mock_obj,imgs.z_bullet)
					
				end
			-- if the target is to the left, shoot with the left
			-- cannon
			elseif targ.x < zepp.l.x then
				
				self.guns.l.z_rotation = {180/math.pi*
					math.atan2(targ.y-zepp.l.y,
					targ.x-zepp.l.x),0,0}
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
					fire_bullet(mock_obj,imgs.z_bullet)
					
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
						
						fire_bullet(mock_obj,imgs.z_bullet)
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
						fire_bullet(mock_obj,imgs.z_bullet)
						
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
		    	                        
						fire_bullet(mock_obj,imgs.z_bullet)
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
						fire_bullet(mock_obj,imgs.z_bullet)
						
					end
				end
			end
			--]]
		end,
		
		
		
		setup = function(self)
			self.e_fire_l_g:add(self.e_l_dam, self.e_fire_l)
            self.e_fire_r_g:add(self.e_r_dam, self.e_fire_r)
			self.prop.g_l:add( self.prop.l )
			self.prop.g_r:add( self.prop.r )
			
			self.guns.g_l:add( self.guns.l, Clone{source=imgs.z_cannon_l,x = -imgs.z_cannon_l.w+7,y = -imgs.z_cannon_l.h/2 } )
			self.guns.g_r:add( self.guns.r, Clone{source=imgs.z_cannon_r,x=-2,y = -imgs.z_cannon_l.h/2} )
			
			self.group:add(
				
				self.image,
				
				self.prop.g_l,
				self.prop.g_r,
				
				self.guns.g_l,
				self.guns.g_r,
				
                self.e_fire_l_g,
                self.e_fire_r_g
			)
			
			layers.air_doodads_1:add( self.group )
			
			
			--default zeppelin animation
			self.stages[0] = function(z)
				--fly downwards
				z.group.y = z.group.y +self.speed*seconds
				
				--fire bullets
				self:rotate_guns_and_fire()
				
				--see if you reached the end
				if z.group.y >= screen_h + z.image.h then
					z.group:unparent()
					remove_from_render_list(self)
				end
			end
			
		end,
		
        fire_thresh = .1,
        fire_r = 0,
        fire_l = 0,
        
		render = function(self,seconds)
            if self.right_engine_dam > 1 then
                self.fire_r = self.fire_r + seconds
                if self.fire_r > self.fire_thresh then
                    self.fire_r = 0
                    self.e_fire_r_i = self.e_fire_r_i%6+1
                    self.e_fire_r.x = -(self.e_fire_r_i - 1)*self.e_fire_r.w/ 6
                end
            end
            if self.left_engine_dam > 1 then
                self.fire_l = self.fire_l + seconds
                if self.fire_l > self.fire_thresh then
                    self.fire_l = 0
                    self.e_fire_l_i = self.e_fire_l_i%6+1
                    self.e_fire_l.x = -(self.e_fire_l_i - 1)*self.e_fire_l.w/ 6
                end
            end
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
            table.insert(b_guys_air,
                {
                    obj = self,
                    x1  = self.group.x+self.guns.g_l.x+3*self.guns.l.w/4,
                    x2  = self.group.x+self.guns.g_r.x-3*self.guns.l.w/4-5,
                    y1  = self.group.y+80,
                    y2  = self.group.y+self.image.h-50,
                    p   = 0,
                }
            )
            
            
            table.insert(b_guys_air,
                {
                    obj = self,
                    x1  = self.group.x+self.prop.g_l.x-self.prop.l.w/2,
                    x2  = self.group.x+self.guns.g_l.x+self.prop.l.w/2,
                    y1  = self.group.y+self.prop.g_l.y-self.prop.l.h/2,
                    y2  = self.group.y+self.prop.g_l.y+self.prop.l.h/2,
                    p   = 1,
                }
            )
            
            table.insert(b_guys_air,
                {
                    obj = self,
                    x1  = self.group.x+self.prop.g_r.x-self.prop.r.w/2,
                    x2  = self.group.x+self.guns.g_r.x+self.prop.r.w/2,
                    y1  = self.group.y+self.prop.g_r.y-self.prop.r.h/2,
                    y2  = self.group.y+self.prop.g_r.y+self.prop.r.h/2,
                    p   = 2,
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
		
        collision = function( self , other, loc, from_bullethole )
			if self.health > 1 then 
				self.health = self.health - 1
                if from_bullethole == nil then
                print("there")
                local dam = {}
                if other.group ~= nil then
                    if loc == 0 then
                        dam.image = Clone{source = imgs["z_d_"..math.random(1,7)]}
                        self.group:add(dam.image)
                        dam.image.x = other.group.x - self.group.x
                        dam.image.y = other.group.y - self.group.y - math.random(20,100)
                    elseif loc == 1 then
                        self.left_engine_dam = self.left_engine_dam + 1
                        if self.left_engine_dam == 1 then
                            print(self.e_l_dam,self.e_l_dam.parent)
                            self.e_l_dam.opacity = 255
                        elseif self.left_engine_dam == 2 then
                            self.e_fire_l.opacity = 255
                        end
                    elseif loc == 2 then
                        self.right_engine_dam = self.right_engine_dam + 1
                        if self.right_engine_dam == 1 then
                            self.e_r_dam.opacity = 255
                        elseif self.right_engine_dam == 2 then
                            self.e_fire_r.opacity = 255
                        end
                    else
                        error("unexpected location given for zeppelin impact")
                    end
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
                    
                    if loc == 0 then
                        dam.image = Clone{source = imgs["z_d_"..math.random(1,7)]}
                        self.group:add(dam.image)
                        dam.image.x = other.image.x - self.group.x
                        dam.image.y = other.image.y - self.group.y - math.random(20,100)
                    elseif loc == 1 then
                        self.left_engine_dam = self.left_engine_dam + 1
                        if self.left_engine_dam == 1 then
                            self.e_l_dam.opacity = 255
                        elseif self.left_engine_dam == 2 then
                            self.e_fire_l.opacity = 255
                        end
                    elseif loc == 2 then
                        self.right_engine_dam = self.right_engine_dam + 1
                        if self.right_engine_dam == 1 then
                            self.e_r_dam.opacity = 255
                        elseif self.right_engine_dam == 2 then
                            self.e_fire_r.opacity = 255
                        end
                    else
                        error("unexpected location given for zeppelin impact")
                    end
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
    
    turret = function() return{
		type = TYPE_ENEMY_PLANE,
		
		stage  = 0,	--the current stage the fighter is in
		stages = {},	--the stages, must be set by formations{}
		approach_speed = 80,
		last_shot_time = 4,
        shoot_time = 2,
		image = Clone
        {
            source       = imgs.turret,
			anchor_point = {imgs.turret.w/2,imgs.turret.h/3},
			z_rotation   = {180,0,0}
        },
			
		group = Group{},
		
        rotate_guns_and_fire = function(self,secs)
			---[[
			--prep the variables that determine if its time to shoot
			
			
			--mock enemy-object which is passed to fire_bullet()
			--local mock_obj = {}
			
			--these x,y values are used for rotations and
			--bullet trajectories
			
			--user plane is the target
			local targ =
			{ 
				x = (my_plane.group.x+my_plane.image.w/(2*my_plane.num_frames)), 
				y = (my_plane.group.y+my_plane.img_h/2)
			}
			local me =
            {
                x = (self.group.x-self.group.anchor_point[1]),
				y = (self.group.y-self.group.anchor_point[2])
			}
			
            --rotate and fire the turret
            if me.y < screen_h + self.img_h and
               me.y >           -self.img_h then
                
                self.last_shot_time = self.last_shot_time + secs
                
                self.image.z_rotation =
                {
                    180/math.pi*math.atan2(
                        targ.y - me.y,
                        targ.x - me.x
                    )-90,
                    0,
                    0
                }
                
                local mock_obj =
				{
					group =
					{
						z_rotation =
						{self.image.z_rotation[1],
							0,0},
						x = self.group.x+self.img_h*math.cos(self.image.z_rotation[1]*math.pi/180+90),
						y = self.group.y+self.img_h*math.sin(self.image.z_rotation[1]*math.pi/180+90)
					}
				}

				if self.last_shot_time >= self.shoot_time and  (math.abs(me.x - targ.x) > 200 or
                    math.abs(me.y - targ.y) > 200) and
					math.random(1,20) == 8 then
					
					self.last_shot_time = 0
					fire_flak(mock_obj, math.abs(me.x - targ.x)-50, math.abs(me.y - targ.y)-50)
					
				end
            end
 
			
		end,
        setup = function(self,xxx,y_offset)
			
			self.group:add( self.image )
            self.group.x = xxx
            self.group.y = -self.image.h + y_offset
			
			layers.land_targets:add( self.group )
			
			
			--default battleship animation animation
			self.stages[0] = function(t,seconds)
				--fly downwards
				t.group.y = t.group.y +self.approach_speed*seconds
				
				--fire bullets
				t:rotate_guns_and_fire(seconds)
				
				--see if you reached the end
				if t.group.y >= screen_h + t.image.h then
					t.group:unparent()
					remove_from_render_list(t)
				end
			end
			
            
            self.img_h = self.image.h
		end,
		
		render = function(self,seconds)
				
			--animate the zeppelin based on the current stage
			self.stages[self.stage](self,seconds)
            
            table.insert(b_guys_land,
                {
                    obj = self,
                    x1  = self.group.x-self.image.w,--/2,
                    x2  = self.group.x+self.image.w,--/2,
                    y1  = self.group.y-self.image.w,--/2,
                    y2  = self.group.y+self.image.w,--/2,
                }
            )
		end,
		
        collision = function( self , other )
            
			self.group:unparent()
			remove_from_render_list( self )
            
			-- Explode
            add_to_render_list(
                explosions.small(
                    self.group.center[1],
                    self.group.center[2]
                )
			)
		end	
    } end,
    
    
    tank = function() return{
		type = TYPE_ENEMY_PLANE,
		
		stage  = 0,	--the current stage the fighter is in
		stages = {},	--the stages, must be set by formations{}
		approach_speed = 80,
		last_shot_time = 4,
        shoot_time     = 2,
		image = Clone
        {
            source       =  imgs.tank_turret,
			anchor_point = {imgs.tank_turret.w/2,imgs.tank_turret.h/3},
            position     = {imgs.tank_strip.w/6,imgs.tank_strip.h/2},
        },
        base_strip = Clone
        {
            source    = imgs.tank_strip
        },
        num_frames = 3,
		base_clip = Group{clip={0,0,imgs.tank_strip.w/3,imgs.tank_strip.h}},
		group = Group{},
		
        rotate_guns_and_fire = function(self,secs)
			---[[
			--prep the variables that determine if its time to shoot
			
			
			--mock enemy-object which is passed to fire_bullet()
			--local mock_obj = {}
			
			--these x,y values are used for rotations and
			--bullet trajectories
			
			--user plane is the target
			local targ =
			{ 
				x = (my_plane.group.x+my_plane.image.w/(2*my_plane.num_frames)), 
				y = (my_plane.group.y+my_plane.img_h/2)
			}
			local me =
            {
                x = (self.group.x-self.group.anchor_point[1]),
				y = (self.group.y-self.group.anchor_point[2])
			}
			
            --rotate and fire the turret
            if me.y < screen_h + self.img_h and
               me.y >           -self.img_h then
                
                self.last_shot_time = self.last_shot_time + secs
                
                self.image.z_rotation =
                {
                    180/math.pi*math.atan2(
                        targ.y - me.y,
                        targ.x - me.x
                    )-90,
                    0,
                    0
                }
                
                local mock_obj =
				{
					group =
					{
						z_rotation =
						{self.image.z_rotation[1],
							0,0},
						x = self.group.x+self.image.x+self.img_h*math.cos(self.image.z_rotation[1]*math.pi/180+90),
						y = self.group.y+self.image.y+self.img_h*math.sin(self.image.z_rotation[1]*math.pi/180+90)
					}
				}
                
				if self.last_shot_time >= self.shoot_time and  (math.abs(me.x - targ.x) > 200 or
                    math.abs(me.y - targ.y) > 200) and
					math.random(1,20) == 8 then
					
					self.last_shot_time = 0
					fire_flak(mock_obj, math.abs(me.x - targ.x)-50, math.abs(me.y - targ.y)-50)
					
				end
            end
 
			
		end,
        setup = function(self,xxx,y_offset)
			self.base_clip:add(self.base_strip)
			self.group:add( self.base_clip,self.image )
            self.group.x = xxx
            self.group.y = y_offset
			
			layers.land_targets:add( self.group )
			
			
			--default tank animation
			self.stages[0] = function(t,seconds)
				--move downwards
				t.group.y = t.group.y +t.approach_speed*seconds
				
				--fire bullets
				t:rotate_guns_and_fire(seconds)
				
				--see if you reached the end
				if t.group.y >= screen_h + t.base_strip.h then
                print("niogga")
					t.group:unparent()
					remove_from_render_list(t)
				end
			end
			
            
            self.img_h = self.image.h
		end,
		
        strip_thresh = .1,
        strip_time = 0,
        strip_i = 1,
        moving = true,
        
		render = function(self,seconds)
			
            if self.moving then
                self.strip_time = self.strip_time + seconds
                if self.strip_time > self.strip_thresh then
                    self.strip_time   = 0
                    self.strip_i      = self.strip_i%self.num_frames + 1
                    self.base_strip.x = -(self.strip_i-1)*self.base_strip.w/self.num_frames
                end
            end
			--animate the tank based on the current stage
			self.stages[self.stage](self,seconds)
            
            
            
            table.insert(b_guys_land,
                {
                    obj = self,
                    x1  = self.group.x,
                    x2  = self.group.x+self.base_strip.w/self.num_frames,
                    y1  = self.group.y,
                    y2  = self.group.y+self.base_strip.h,
                }
            )
		end,
		
        collision = function( self , other )
            
			self.group:unparent()
			remove_from_render_list( self )
            
			-- Explode
            add_to_render_list(
                explosions.small(
                    self.group.center[1],
                    self.group.center[2]
                )
			)
		end	
    } end,
    
    battleship = function() return{
        
		health = 5,
		type = TYPE_ENEMY_PLANE,
        bulletholes = {},
        moving = false,
        
        bow_wake_r =
        {
            Clone{source=imgs.bow_wake_1,opacity = 0,x=imgs.b_ship.w/2-12},
            Clone{source=imgs.bow_wake_2,opacity = 0,x=imgs.b_ship.w/2-12},
            Clone{source=imgs.bow_wake_3,opacity = 0,x=imgs.b_ship.w/2-12},
            Clone{source=imgs.bow_wake_4,opacity = 0,x=imgs.b_ship.w/2-12},
            Clone{source=imgs.bow_wake_5,opacity = 0,x=imgs.b_ship.w/2-12},
            Clone{source=imgs.bow_wake_6,opacity = 0,x=imgs.b_ship.w/2-12},
            Clone{source=imgs.bow_wake_7,opacity = 0,x=imgs.b_ship.w/2-12},
            Clone{source=imgs.bow_wake_8,opacity = 0,x=imgs.b_ship.w/2-12},
        },
        bow_wake_t =
        {
            Clone{source=imgs.bbow_wake_1,opacity = 0},
            Clone{source=imgs.bbow_wake_2,opacity = 0},
            Clone{source=imgs.bbow_wake_3,opacity = 0},
            Clone{source=imgs.bbow_wake_4,opacity = 0},
        },
        bow_wake_l =
        {
            Clone{source=imgs.bow_wake_1,opacity = 0,x=imgs.b_ship.w/2+12,y_rotation={180,0,0}},
            Clone{source=imgs.bow_wake_2,opacity = 0,x=imgs.b_ship.w/2+12,y_rotation={180,0,0}},
            Clone{source=imgs.bow_wake_3,opacity = 0,x=imgs.b_ship.w/2+12,y_rotation={180,0,0}},
            Clone{source=imgs.bow_wake_4,opacity = 0,x=imgs.b_ship.w/2+12,y_rotation={180,0,0}},
            Clone{source=imgs.bow_wake_5,opacity = 0,x=imgs.b_ship.w/2+12,y_rotation={180,0,0}},
            Clone{source=imgs.bow_wake_6,opacity = 0,x=imgs.b_ship.w/2+12,y_rotation={180,0,0}},
            Clone{source=imgs.bow_wake_7,opacity = 0,x=imgs.b_ship.w/2+12,y_rotation={180,0,0}},
            Clone{source=imgs.bow_wake_8,opacity = 0,x=imgs.b_ship.w/2+12,y_rotation={180,0,0}},
        },
        stern_wake =
        {
            Clone{source=imgs.stern_wake_1,opacity = 0,y=imgs.b_ship.h-imgs.stern_wake_1.h+40},
            Clone{source=imgs.stern_wake_2,opacity = 0,y=imgs.b_ship.h-imgs.stern_wake_2.h+40},
            Clone{source=imgs.stern_wake_3,opacity = 0,y=imgs.b_ship.h-imgs.stern_wake_3.h+40},
            Clone{source=imgs.stern_wake_4,opacity = 0,y=imgs.b_ship.h-imgs.stern_wake_4.h+40},
            Clone{source=imgs.stern_wake_5,opacity = 0,y=imgs.b_ship.h-imgs.stern_wake_5.h+40},
        },
		b_w_i = 1,
        s_w_i = 1,
		stage  = 0,	--the current stage the fighter is in
		stages = {},	--the stages, must be set by formations{}
		approach_speed = 80,
		--attack_speed   = 15,
		
		
		image    = Clone{source=imgs.b_ship},
		
		is_boss = false,
		
		
		guns =
		{
            bow = Clone
            {
                source       = imgs.turret,
				anchor_point = {imgs.turret.w/2,imgs.turret.h/3},
				z_rotation   = {180,0,0}
            },
            mid = Clone
            {
                source       = imgs.turret,
				anchor_point = {imgs.turret.w/2,imgs.turret.h/3},
				z_rotation   = {180,0,0}
            },
            stern = Clone
            {
                source       = imgs.turret,
				anchor_point = {imgs.turret.w/2,imgs.turret.h/3},
				z_rotation   = {180,0,0}
            },
			
			g_b = Group
			{
				x = imgs.b_ship.w/2,
				y = 130,
			},
			
			g_m = Group
			{
				x = imgs.b_ship.w/2,
				y = 190,
			},
            g_s = Group
			{
				x = imgs.b_ship.w/2,
				y = 410,
			},
		},
        
		group    = Group{},
		
		shoot_time      = 2 , --how frequently the ship shoots
		last_shot_time  =    --how long ago the ship last shot
        {
            b = math.random()*2,
            m = math.random()*2,
            s = math.random()*2
        },
        
		
		
		rotate_guns_and_fire = function(self,secs)
			---[[
			--prep the variables that determine if its time to shoot
			
			
			--mock enemy-object which is passed to fire_bullet()
			local mock_obj = {}
			
			--these x,y values are used for rotations and
			--bullet trajectories
			
			--user plane is the target
			local targ =
			{ 
				x = (my_plane.group.x+my_plane.image.w/(2*my_plane.num_frames)), 
				y = (my_plane.group.y+my_plane.img_h/2)
			}
			local b_ship =
			{
                b =
                {
                    x = (self.guns.g_b.x+self.group.x-self.group.anchor_point[1]),
					y = (self.guns.g_b.y+self.group.y-self.group.anchor_point[2])
                },
                m =
                {
                    x = (self.guns.g_m.x+self.group.x-self.group.anchor_point[1]),
					y = (self.guns.g_m.y+self.group.y-self.group.anchor_point[2])
                },
                s =
                {
                    x = (self.guns.g_s.x+self.group.x-self.group.anchor_point[1]),
					y = (self.guns.g_s.y+self.group.y-self.group.anchor_point[2])
                }
			}
			
            --rotate and fire the bow turret
            if b_ship.b.y < screen_h + self.turr_h and
               b_ship.b.y >           -self.turr_h then
                
                self.last_shot_time.b = self.last_shot_time.b + secs
                
                self.guns.bow.z_rotation =
                {
                    180/math.pi*math.atan2(
                        targ.y - b_ship.b.y,
                        targ.x - b_ship.b.x
                    )-90,
                    0,
                    0
                }
                
                mock_obj =
				{
					group =
					{
						z_rotation =
						{self.guns.bow.z_rotation[1],
							0,0},
						x = b_ship.b.x+self.turr_h*math.cos(self.guns.bow.z_rotation[1]*math.pi/180+90),
						y = b_ship.b.y+self.turr_h*math.sin(self.guns.bow.z_rotation[1]*math.pi/180+90)
					}
				}

				if self.last_shot_time.b >= self.shoot_time and  (math.abs(b_ship.b.x - targ.x) > 200 or
                    math.abs(b_ship.b.y - targ.y) > 200) and
					math.random(1,20) == 8 then
					
					self.last_shot_time.b = 0
					fire_flak(mock_obj, math.abs(b_ship.b.x - targ.x)-50, math.abs(b_ship.b.y - targ.y)-50)
					
				end
            end
            
            --rotate and fire the mid turret
            if b_ship.m.y < screen_h + self.turr_h and
               b_ship.m.y >           -self.turr_h then
                
                self.last_shot_time.m = self.last_shot_time.m + secs
                
                self.guns.mid.z_rotation =
                {
                    180/math.pi*math.atan2(
                        targ.y - b_ship.m.y,
                        targ.x - b_ship.m.x
                    )-90,
                    0,
                    0
                }
                
                mock_obj =
				{
					group =
					{
						z_rotation =
						{self.guns.mid.z_rotation[1],
							0,0},
						x = b_ship.m.x+self.turr_h*math.cos(self.guns.mid.z_rotation[1]*math.pi/180+90),
						y = b_ship.m.y+self.turr_h*math.sin(self.guns.mid.z_rotation[1]*math.pi/180+90)
					}
				}


				if self.last_shot_time.m >= self.shoot_time and  (math.abs(b_ship.m.x - targ.x) > 200 or
                    math.abs(b_ship.m.y - targ.y) > 200) and
					math.random(1,20) == 8 then
					
					self.last_shot_time.m = 0
					fire_flak(mock_obj, math.abs(b_ship.m.x - targ.x)-50, math.abs(b_ship.m.y - targ.y)-50)
					
				end
            end
            
            --rotate and fire the stern turret
            if b_ship.s.y < screen_h + self.turr_h and
               b_ship.s.y >           -self.turr_h then
                
                self.last_shot_time.s = self.last_shot_time.s + secs
                
                self.guns.stern.z_rotation =
                {
                    180/math.pi*math.atan2(
                        targ.y - b_ship.s.y,
                        targ.x - b_ship.s.x
                    )-90,
                    0,
                    0
                }
                
                mock_obj =
				{
					group =
					{
						z_rotation =
						{self.guns.stern.z_rotation[1],
							0,0},
						x = b_ship.s.x+self.turr_h*math.cos(self.guns.stern.z_rotation[1]*math.pi/180+90),
						y = b_ship.s.y+self.turr_h*math.sin(self.guns.stern.z_rotation[1]*math.pi/180+90)
					}
				}
                
                
				if self.last_shot_time.s >= self.shoot_time and  (math.abs(b_ship.s.x - targ.x) > 200 or
                    math.abs(b_ship.s.y - targ.y) > 200) and
					math.random(1,20) == 8 then
					
					self.last_shot_time.s = 0
					fire_flak(mock_obj, math.abs(b_ship.s.x - targ.x)-50, math.abs(b_ship.s.y - targ.y)-50)
					
				end
            end
			
		end,
		
		
		
		setup = function(self,xxx,y_offset,speed,moving)
			
            self.moving = moving
			self.approach_speed = speed
            
			self.guns.g_b:add( self.guns.bow )
			self.guns.g_m:add( self.guns.mid )
            self.guns.g_s:add( self.guns.stern)
            self.group:add(Clone{source=imgs.laminar})
			self.group:add(unpack(self.bow_wake_r))
            self.group:add(unpack(self.bow_wake_l))
            self.group:add(unpack(self.stern_wake))
            --self.group:add(unpack(self.bow_wake_t))

			self.group:add(
				
				self.image,
                
				self.guns.g_s,
				self.guns.g_m,
                self.guns.g_b
				
			)
            self.group.x = xxx
            self.group.y = -self.image.h+y_offset
			
			layers.land_targets:add( self.group )
			
			
			--default battleship animation animation
			self.stages[0] = function(b,seconds)
				--fly downwards
				b.group.y = b.group.y +b.approach_speed*seconds
				
				--fire bullets
				b:rotate_guns_and_fire(seconds)
				
				--see if you reached the end
				if b.group.y >= screen_h + b.image.h then
					b.group:unparent()
					remove_from_render_list(b)
				end
			end
			self.turr_h = self.guns.stern.h
		end,
        
        wake_thresh = .1,
        last_wake_change = 0,
		
		render = function(self,seconds)
			
            if self.moving then
                self.last_wake_change = self.last_wake_change + seconds
                
                if self.last_wake_change >= self.wake_thresh then
                self.last_wake_change = 0
                self.bow_wake_r[self.b_w_i].opacity=0
                self.bow_wake_l[self.b_w_i].opacity=0
                self.bow_wake_t[self.b_w_i%4+1].opacity=0
                self.stern_wake[self.s_w_i].opacity=0
                self.b_w_i = self.b_w_i%(#self.bow_wake_r)+1
                self.s_w_i = self.s_w_i%(#self.stern_wake)+1
                self.bow_wake_r[self.b_w_i].opacity=255
                self.bow_wake_l[self.b_w_i].opacity=255
                self.bow_wake_t[self.b_w_i%4+1].opacity=255
                self.stern_wake[self.s_w_i].opacity=255
                end
            end
			--animate the zeppelin based on the current stage
			self.stages[self.stage](self,seconds)
            
            table.insert(b_guys_land,
                {
                    obj = self,
                    x1  = self.group.x+10,
                    x2  = self.group.x+self.image.w-10,
                    y1  = self.group.y+40,
                    y2  = self.group.y+self.image.h-20,
                }
            )
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
                    error("render_list object with out a .group or a .image collided with the battleship")
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
    } end
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
    hor_row_tanks = function(x,y,num,spacing)
        assert(x == 1 or x == -1)
        
        local t
        for i = 1,num do
            t = enemies.tank()
            t.moving = true
            t.stages = {
                function(t,seconds)
                    --move downwards with the ground
                    t.group.y = t.group.y +t.approach_speed*seconds
                    --move across the screen
                    t.group.x = t.group.x -x*80*seconds
                    t.base_clip.z_rotation={90,t.base_strip.w/(2*t.num_frames),t.base_strip.h/2}
                    --fire bullets
                    t:rotate_guns_and_fire(seconds)
                    
                    --see if you reached the end
                    if t.group.x < -(t.image.w/t.num_frames) then
                    	t.group:unparent()
                    	remove_from_render_list(t)
                    end
                    if t.group.y >= screen_h + t.image.h then
                    	t.group:unparent()
                    	remove_from_render_list(t)
                    end
                end,
            }
            t.stage = 1
            add_to_render_list(t,screen_w/2+(screen_w/2+spacing*i)*x,y)
        end
    end,
    vert_row_tanks = function(x,y,num,spacing)
        assert(y==1 or y==-1)
        local t
        for i = 1,num do
            t = enemies.tank()
            t.moving         = true
            t.approach_speed = -y*60+40
            t.stages[1] = function(t,seconds)
				--move downwards
				t.group.y = t.group.y +t.approach_speed*seconds
				
				--fire bullets
				t:rotate_guns_and_fire(seconds)
				
				--see if you reached the end
				if (y == -1 and t.group.y >= screen_h + t.image.h) or
                    (y == 1 and t.group.y < -t.image.h) then
					t.group:unparent()
					remove_from_render_list(t)
				end
			end
            t.stage = 1
            add_to_render_list(t,x+spacing*(i-1),screen_h/2+y*(screen_h/2+100))
        end
    end,
    
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
                if z.group.y >= screen_h +
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
                    
                    if f.group.y >= screen_h + f.image.h then
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
    zig_zag = function(x,r, rot)
        e = enemies.basic_fighter()
        local dir = rot/math.abs(rot)
        e.group.x = x
        e.group.y = -e.image.h
        e.shoot_time      = 1.25
        e.last_shot_time = 1
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
                    turn(f.group,r,dir,f.attack_speed,secs)
                    
                f:fire(secs)
                    
                if f.deg_counter[f.stage] >= math.abs(rot) then
                    f.deg_counter[f.stage] = 0
                    f.stage = f.stage + 1
                        
                    f.group.z_rotation = {rot,0,0}
                end
                    
            end,
            --zig
            function(f,secs)
                    
                f.deg_counter[f.stage] = f.deg_counter[f.stage] +
                    turn(f.group,r,-dir,f.attack_speed,secs)
                    
                f:fire(secs)
                    
                if f.group.y >= screen_h + f.image.h then
					f.group:unparent()
					remove_from_render_list(f)
                end
                if f.deg_counter[f.stage] >= math.abs(2*rot) then
                    f.deg_counter[f.stage] = 0
                    f.stage = f.stage + 1
                        
                    f.group.z_rotation = {-rot,0,0}
                end
            end,
            --zag
            function(f,secs)
                    
                f.deg_counter[f.stage] = f.deg_counter[f.stage] +
                    turn(f.group,r,dir,f.attack_speed,secs)
                    
                f:fire(secs)
                if f.group.y >= screen_h + f.image.h then
					f.group:unparent()
					remove_from_render_list(f)
                end
                if f.deg_counter[f.stage] >= math.abs(2*rot) then
                    f.deg_counter[f.stage] = 0
                    f.stage = f.stage - 1
                        
                    f.group.z_rotation = {rot,0,0}
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
                        turn(f.group,250,dir,f.approach_speed,secs)
                    
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
                                            
                    if f.group.y >= screen_h + f.image.h then
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
