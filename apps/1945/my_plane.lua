

-------------------------------------------------------------------------------
-- This is my plane. It spawns bullets
--r = Rectangle{w=1,h=1,color="FFFFFFA0"}
--screen:add(r)
my_plane =
{
	firing_powerup = 1,

    type = TYPE_MY_PLANE,
    
    max_h_speed = 600,
    
    max_v_speed = 175,
    
    friction = 0.85,
    
    friction_bump = 1000, -- per second
    
    speed_bump = 200,
    
    group = Group{ },--size = { --[[65 , 65]]my_plane_sz,my_plane_sz } },
    
    image = Clone{ source = imgs.my_plane_strip },
    
    bullet = imgs.my_bullet,
    
    v_speed = 0,
    
    h_speed = 0,
    
    dead = false,
    
    dead_blinks = 5,
    
    dead_time = 0,
    
    dead_blink_delay = 0.5,
    
    max_dead_time = 2,
    
    prop =
    {
        l = Clone{source=imgs.prop2},
        r = Clone{source=imgs.prop2},
        g_l = Group
        {
            clip =
            {
                0,
                0,
                imgs.prop2.w ,
                --self.num_prop_frames still DNE 
                imgs.prop2.h/3,
            },
            anchor_point = {imgs.prop2.w/2,
                            imgs.prop2.h/2},
            position     = {35,35},
        },
        g_r = Group
        {
            clip =
            {
                0,
                0,
                imgs.prop2.w ,
                --self.num_prop_frames still DNE 
                imgs.prop2.h/3,
            },
            anchor_point = {imgs.prop2.w/2,
                            imgs.prop2.h/2},
            position     = {93,35},
        },
    },
    
    setup = function( self )
        	self.prop.g_l:add( self.prop.l )
			self.prop.g_r:add( self.prop.r )
            self.num_prop_frames = 3

	self.prop_index = 1
        self.image.opacity = 255
            
            self.group:add( self.image)
            self.group:add( self.prop.g_r)
            self.group:add( self.prop.g_l)
            
            screen:add( self.group )
            
            self.group.position = { screen.w / 2 - self.image.w / 2 , screen.h - self.image.h }
            
        end,
        
    render =
    
        function( self , seconds )
			self.prop_index = self.prop_index%
				self.num_prop_frames + 1
			self.prop.l.y = -(self.prop_index - 1)*self.prop.l.h/
				self.num_prop_frames
			self.prop.r.y = -(self.prop_index - 1)*self.prop.r.h/
				self.num_prop_frames
            
            self.group:raise_to_top()
            -- Move
            
            --if game_is_running then--not self.dead then
if self.dead then
                -- Figure the total time we have been dead
                self.dead_time = self.dead_time + seconds
                
                -- If it is the maximum time, we go back to being alive
                
                if self.dead_time >= self.max_dead_time then
                    self.dead = false
                    
                    self.dead_time = 0
                    
                    self.group:show()
                    
                -- Otherwise, we blink
                    
                elseif self.dead_time > self.dead_blink_delay then
                
                    local blink_on = math.floor( self.dead_time / ( 1 / self.dead_blinks ) ) % 2 == 0
                    
                    if blink_on then
                    
                        self.group:show()
                        
                    else
                        
                        self.group:hide()
                        
                    end
                
                end

end

            
                local start_point = self.group.center
                
                if self.h_speed > 0 then
                
                    local x = self.group.x + ( self.h_speed * seconds )
                    
                    if x > screen.w - my_plane_sz then
                    
                        x = screen.w -my_plane_sz 
                        
                        self.h_speed = 0
                    
                    else
                    
                        self.h_speed = clamp( ( self.h_speed * ( self.friction ^ seconds ) ) - ( self.friction_bump * seconds ) , 0 , self.max_h_speed )
                        
                    end
                    
                    self.group.x = x
                                
                elseif self.h_speed < 0 then
                
                    local x = self.group.x + ( self.h_speed * seconds )
                    
                    if x < 0 then
                    
                        x = 0
                        
                        self.h_speed = 0
                    
                    else
                    
                        self.h_speed = clamp( ( self.h_speed * ( self.friction ^ seconds ) ) + ( self.friction_bump * seconds )  , - self.max_h_speed , 0 )
                    end
                    
                    self.group.x = x
                
                end
                
                if self.v_speed > 0 then
    
                    local y = self.group.y + ( self.v_speed * seconds )
                    
                    if y > screen.h - my_plane_sz then
                    
                        y = screen.h -my_plane_sz 
                        
                        self.v_speed = 0
                    
                    else
                    
                        self.v_speed = clamp( ( self.v_speed * ( self.friction ^ seconds ) ) - ( self.friction_bump * seconds ) , 0 , self.max_v_speed )
                        
                    end
                    
                    self.group.y = y
                
                elseif self.v_speed < 0 then
                
                    local y = self.group.y + ( self.v_speed * seconds )
                    
                    if y < 0 then
                    
                        y = 0
                        
                        self.v_speed = 0
                    
                    else
                    
                        self.v_speed = clamp( ( self.v_speed * ( self.friction ^ seconds ) ) + ( self.friction_bump * seconds )  , - self.max_v_speed , 0 )
                    end
                    
                    self.group.y = y
                end
    if not self.dead then
                add_to_collision_list( self ,
					{self.group.x+self.image.w/2,self.group.y+self.image.h/2},
					{self.group.x+self.image.w/2,self.group.y+self.image.h/2},
					{self.image.w,self.image.h},
					TYPE_ENEMY_PLANE)-- start_point , self.group.center , { self.group.w - 10 , self.group.h - 30 } , TYPE_ENEMY_PLANE )
end
--[[
            r.x = self.group.x
r.y=self.group.y
r.w=self.image.w
r.h=self.image.h
r:raise_to_top()
--]]
            --end
        end,
        
    -- Adds a bullet to the render list
        
    new_bullet = function( self, x, y, z_rot )
        
            return
            
            {
                type = TYPE_MY_BULLET,
                
				z_rot = z_rot,

                speed = -400,
                
                image =
                    
                    Clone
                    {                    
                        source = self.bullet,
                        opacity = 255,
                        anchor_point = { self.bullet.w / 2 , self.bullet.h / 2 },
                        position = { x, y },
						z_rotation = {z_rot,0,0}
                    },
                    
                setup =
                
                    function( self )
                    
                        screen:add( self.image )
                        
                    end,
                    
                render =
                
                    function( self , seconds )
                    
                        local y = self.image.y + self.speed * seconds * math.cos(-1*self.z_rot*math.pi/180)
                        local x = self.image.x + self.speed * seconds * math.sin(-1*self.z_rot*math.pi/180)
                        
                        if y < -self.image.h or y > (screen.h + self.image.h) or x < -self.image.w  or x > (screen.w + self.image.w)then
                            
                            remove_from_render_list( self )
                            
                            screen:remove( self.image )
                        
                        else
                        
                            add_to_collision_list(
                                self ,
                                { self.image.x , self.image.y },
                                { self.image.x , y },
                                { self.image.w , self.image.h },
                                TYPE_ENEMY_PLANE )
                        
                            self.image.y = y
                            self.image.x = x
                        
                        end
                    
                    end,
                    
                collision =
                
                    function( self , other )
                    
                        remove_from_render_list( self )
                        
                        local location = other.group.position

                        screen:remove( self.image )
                        
                        -- Now, we create a score bubble
                        
                        local score =
                            {
                                speed = 80,
                                
                                text = Clone{ source = txt.score },
                                
                                setup =
                                
                                    function( self )
                               
if point_counter < 999990 then     
	point_counter = point_counter+10
	if point_counter > high_score then
		high_score = point_counter
	end
	if (point_counter % 1000) == 0 and lives[number_of_lives + 1] ~= nil then
		number_of_lives = number_of_lives + 1
		lives[number_of_lives].opacity =255
		self.text = Clone{source=txt.up_life}
	end
	redo_score_text()
end

                                        self.text.position = { location[ 1 ] + 30 , location[ 2 ] }
                                        
                                        self.text.anchor_point = { self.text.w / 2 , self.text.h / 2 }
                                        
                                        self.text.opacity = 255;
                                    
                                        screen:add( self.text )
                                        
                                    end,
                                    
                                render =
                                
                                    function( self , seconds )
                                   -- print("aaaa")
                                        local o = self.text.opacity - self.speed * seconds
                                        
                                        local scale = self.text.scale
                                        
                                        scale = { scale[ 1 ] + ( 2 * seconds ) , scale[ 2 ] + ( 2 * seconds ) }
                                        
                                        if o <= 0 then
                                        
                                            remove_from_render_list( self )
                                            
                                            screen:remove( self.text )
                                        
                                        else
                                        
                                            self.text.opacity = o
                                            
                                            self.text.scale = scale
                                        
                                        end
                                    
                                    end,
                            }
                            
                        add_to_render_list( score )
                    
                    end
            }
        
        end,
        
    -- When we crash with an enemy plane
    
    collision =
    
        function( self , other )


--more Alex code
if state.num_lives == 0 then

	remove_from_render_list( my_plane )
	add_to_render_list(
                
                            {
                                speed = 40,
                                
                                text = Clone{ source = img.g_over },
                                
                                setup =
                                
                                    function( self )
                                    
                                        self.text.position = { screen.w/2,screen.h/2}--location[ 1 ] + 30 , location[ 2 ] }
                                        
                                        self.text.anchor_point = { self.text.w / 2 , self.text.h / 2 }
                                        
                                        self.text.opacity = 255;
                                    
                                        screen:add( self.text )
                                        
                                    end,
                                    
                                render =
                                
                                    function( self , seconds )
                                    
                                        local o = self.text.opacity - self.speed * seconds
                                        
                                        local scale = self.text.scale
                                        
                                        scale = { scale[ 1 ] + ( 2 * seconds ) , scale[ 2 ] + ( 2 * seconds ) }
                                        
                                        if o <= 0 then
                                        
                                            remove_from_render_list( self )
                                            
                                            screen:remove( self.text )
                                        
                                        else
                                        
                                            self.text.opacity = o
                                            
                                            self.text.scale = scale
                                        
                                        end
                                    
                                    end,
                            })
                            --[[
	add_to_render_list(
                
                            {
                                elapsed = 0,
                                
                                --text = Clone{ source = txt.g_over },
                                
                                setup =
                                
                                    function( self )
						if curr_level ~= nil then
print("hhhhhhh")

							remove_from_render_list(curr_level)
							curr_level = nil
						end

					self.save_keys = screen.on_key_down
					screen.on_key_down = nil

                                    end,
                                    
                                render =
                                
                                    function( self , seconds )
                                   	self.elapsed = self.elapsed + seconds
					if self.elapsed > 5 then
						remove_from_render_list( self )
						screen.on_key_down = self.save_keys
					elseif self.elapsed >4 then
						splash.opacity = 255
					end
                                    end,
                            })
                            --]]


elseif state.curr_mode ~= "TEST_MODE" then
	lives[state.hud.num_lives].opacity=0
	state.hud.num_lives = state.hud.num_lives - 1
end
redo_score_text()

--------


            self.dead = true
            
            self.group:hide()
            
            self.h_speed = 0
            
            self.v_speed = 0
            
            local location = self.group.center
            
            self.group.position = { screen.w / 2 - self.group.w / 2 , screen.h - self.group.h }

            -- Spawn an explosion
            
            local explosion =
                
                {
                    image = Clone{ source = imgs.explosion2 , opacity = 255 },
                    
                    group = nil,
                    
                    duration = 0.4, 
                    
                    time = 0,
                    
                    setup =
                    
                        function( self )
                        
                            self.group = Group
                                {
                                    size = { self.image.w / 7 , self.image.h },
                                    position = location,
                                    clip = { 0 , 0 , self.image.w / 7 , self.image.h },
                                    children = { self.image },
                                    anchor_point = { ( self.image.w / 7 ) / 2 , self.image.h / 2 }
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
                                
                                self.image.x = - ( ( self.image.w / 7 ) * frame )
                            
                            end
                        
                        end,
                }
            
            add_to_render_list( explosion )
        
        end,
        
    on_key =
    
        function( self , key )
        print(self,key)
        --[[
            if number_of_lives == 0 then--self.dead then
            
                return
                
            end
            --]]   
            if key == keys.Right then
            print("right")
                self.h_speed = clamp( self.h_speed + self.speed_bump , -self.max_h_speed , self.max_h_speed )
                
            elseif key == keys.Left then
            
                self.h_speed = clamp( self.h_speed - self.speed_bump , -self.max_h_speed , self.max_h_speed )
                
            elseif key == keys.Down then
            
                self.v_speed = clamp( self.v_speed + self.speed_bump , -self.max_v_speed , self.max_v_speed )
                
            elseif key == keys.Up then
            
                self.v_speed = clamp( self.v_speed - self.speed_bump , -self.max_v_speed , self.max_v_speed )
            
            elseif key == keys.Return then
            	local shoot = {
					function()
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w / 2 , self.group.y,0) )
					end,
					function()
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w / 2 -20, self.group.y,0) )
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w / 2 +20, self.group.y,0) )
					end,
					function()
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w / 2 -40, self.group.y,-45) )
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w / 2 ,    self.group.y,0) )
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w / 2 +40, self.group.y,45) )
					end,
					function()
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w / 2 -40, self.group.y,-45) )
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w / 2 ,    self.group.y,0) )
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w / 2 ,    self.group.y+self.image.h,180) )
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w / 2 +40, self.group.y,45) )
					end,
					function()
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w / 2 -40, self.group.y,-45) )
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w / 2 -20, self.group.y,0) )
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w / 2 +20, self.group.y,0) )
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w / 2 ,    self.group.y+self.image.h,180) )
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w / 2 +40, self.group.y,45) )
					end,


				}
				shoot[self.firing_powerup]()
                
            end
                
        end
}

