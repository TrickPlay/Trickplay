
smoke = function(i)   return {
    index = i,

    duration = 0.5,
    time     = 0,
    speed    = 80,
    halted   = true,
    plumes   = {},

    setup = function( self, num )
        self.num = num
        for i = 1,num do
            self.plumes[i] =
            {
                image = Clone{ source = imgs.smoke },
                group = Group{},
                time  = -(i-1)/num*self.duration
            }
            self.plumes[i].group.size =
                	{
                		self.plumes[i].image.w / 4 ,
                		self.plumes[i].image.h
                	}
            self.plumes[i].group.clip =
                	{
                		0 ,
                		0 ,
                		self.plumes[i].image.w / 4 ,
                		self.plumes[i].image.h
                	}
            self.plumes[i].group:add(self.plumes[i].image)
            self.plumes[i].group.anchor_point =
                	{
                		( self.plumes[i].image.w / 4 ) / 2 ,
                		  self.plumes[i].image.h / 2
                	}
            if self.index == 1 then
                self.plumes[i].group.x = my_plane.group.x + 10
                self.plumes[i].group.y = my_plane.group.y + 50
            elseif self.index == 2 then
                self.plumes[i].group.x = my_plane.group.x + my_plane.image.w/(my_plane.num_frames)-30
                self.plumes[i].group.y = my_plane.group.y + 50
            else
                self.plumes[i].group.x = my_plane.group.x + 30
                self.plumes[i].group.y = my_plane.group.y + my_plane.image.h-20
            end
            self.plumes[i].image.x =  - ( ( self.plumes[i].image.w / 4 ) * 5 )
            layers.planes:add( self.plumes[i].group )
        end
        --[[
        self.group = Group
		{
			size =
			{
				self.image.w / 4 ,
				self.image.h
			},
			clip =
			{
				0 ,
				0 ,
				self.image.w / 4 ,
				self.image.h
			},
			children = { self.image },
            anchor_point =
			{
				( self.image.w / 4 ) / 2 ,
				  self.image.h / 2
			},
		}
        self.time    = -self.duration*(num-1)/tot
        --]]
        self.halted  = true
        --self.image.x =  - ( ( self.image.w / 4 ) * 5 ) --not visible
		
    end,
    reset = function(self,i)
        if self.index == 1 then
            self.plumes[i].group.x = my_plane.group.x + 10
            self.plumes[i].group.y = my_plane.group.y + 50
        elseif self.index == 2 then
            self.plumes[i].group.x = my_plane.group.x + my_plane.image.w/(my_plane.num_frames)-30
            self.plumes[i].group.y = my_plane.group.y + 50
        else
            self.plumes[i].group.x = my_plane.group.x + 30
            self.plumes[i].group.y = my_plane.group.y + my_plane.image.h-20
        end
        --self.plumes[i].time = 0
    end,
    halt = function(self)
        self.halted = true
    end,
    unhalt = function(self)
        self.halted = false
        for i = 1,self.num do
            if self.index == 1 then
                self.plumes[i].group.x = my_plane.group.x + 10
                self.plumes[i].group.y = my_plane.group.y + 50
            elseif self.index == 2 then
                self.plumes[i].group.x = my_plane.group.x + my_plane.image.w/(my_plane.num_frames)-30
                self.plumes[i].group.y = my_plane.group.y + 50
            else
                self.plumes[i].group.x = my_plane.group.x + 30
                self.plumes[i].group.y = my_plane.group.y + my_plane.image.h-20
            end
            self.plumes[i].time = -(i-1)/self.num*self.duration
            layers.planes:add( self.plumes[i].group )
        end
    end,
	render = function( self , seconds )
        local frame
        for i = 1,self.num do
            
            if self.plumes[i].time == 0 and self.halted then break end
            self.plumes[i].time = self.plumes[i].time + seconds
            self.plumes[i].group.y = self.plumes[i].group.y + self.speed*seconds
            frame  = math.floor( self.plumes[i].time / ( self.duration / 4 ) )
            self.plumes[i].image.x = - ( ( self.plumes[i].image.w / 4 ) * frame )
            
            if self.plumes[i].time > self.duration then
                self.plumes[i].time =0
                if not self.halted then
                    self:reset(i)
                end
                --self.plumes[i].time = self.plumes[i].time%self.duration
                    
            end
        end
    end,
} end
-------------------------------------------------------------------------------
-- This is my plane. It spawns bullets
--r = Rectangle{w=1,h=1,color="FFFFFFA0"}
--screen:add(r)
my_plane =
{
	firing_powerup = 1,
    firing_powerup_max = 5,

    damage = 0,

    type = TYPE_MY_PLANE,
    
    num_frames = 4,
    
    smoke_stream = {},
    
    plumes_per_stream = 1,
    
    max_h_speed = 600,
    
    max_v_speed = 175,
    
    friction = 0.85,
    
    friction_bump = 1000, -- per second
    
    speed_bump = 200,
    
    group = Group{},
    
    image = Clone{ source = imgs.my_plane_strip },
    
    bullet = imgs.my_bullet,
    
    v_speed = 0,
    
    h_speed = 0,
    
    dead = false,
    
    dead_blinks = 5,
    
    dead_time = 0,
    
    smoke_rate_base = .1,
    
    last_smoke = 0,
    
    smoke_thresh = 2,
    
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
    render_items = {},
    
    setup = function( self )
        	self.prop.g_l:add( self.prop.l )
			self.prop.g_r:add( self.prop.r )
            self.num_prop_frames = 3
            
            self.prop_index = 1
            self.image.opacity = 255
            
            self.group:add( self.image)
            self.group:add( self.prop.g_r)
            self.group:add( self.prop.g_l)
            
            layers.planes:add( self.group )
            
            self.group.position = { screen.w / 2 - self.image.w / 2 , screen.h - self.image.h }
            self.group.clip = {0,0,self.image.w/self.num_frames,self.image.h}

            for i = 1, self.num_frames - 1 do
                self.smoke_stream[i] = smoke(i)
                    self.smoke_stream[i]:setup(self.plumes_per_stream)
                    table.insert(self.render_items,self.smoke_stream[i])
                
            end
            
        end,
    hit = function(self)
        self.damage = self.damage + 1
        self.image.x = -1*self.damage*self.image.w/self.num_frames
        --for j = 1,self.plumes_per_stream do
                self.smoke_stream[self.damage]:unhalt()
        --end
        
    end,
    heal = function(self)
        for i = 1, self.num_frames - 1 do
            --for j = 1,self.plumes_per_stream do
                self.smoke_stream[i]:halt()
            --end
        end
        self.image.x = 0
    end,
    render =
    
        function( self , seconds )
            for _ , item in ipairs( self.render_items ) do
                item.render( item , seconds ) 
            end
            --[[
            if self.damage > 0 then
                self.last_smoke = self.last_smoke + self.smoke_rate_base
                if self.last_smoke >self.smoke_thresh then
                    local s
                    if self.damage >= 1 then
                        s = smoke(self.group.x + 10,self.group.y + 50)
                        s:setup(self.render_items)
                        table.insert(self.render_items,s)
                    end
                    if self.damage >= 2 then
                        s = smoke(self.group.x +self.image.w/(self.num_frames)-30,
                            self.group.y + 50)
                        s:setup(self.render_items)
                        table.insert(self.render_items,s)
                    end
                    if self.damage >= 3 then
                        s = smoke(self.group.x +30,
                            self.group.y + self.image.h-20)
                        s:setup(self.render_items)
                        table.insert(self.render_items,s)
                    end
                    self.last_smoke = 0
                end
            else
                for i = 1, self.num_frames - 1 do
                    for j = 1,self.plumes_per_stream do
                        self.smoke_stream[i][j]:halt()
                    end
                end
            end
            --]]
            
			self.prop_index = self.prop_index%
				self.num_prop_frames + 1
			self.prop.l.y = -(self.prop_index - 1)*self.prop.l.h/
				self.num_prop_frames
			self.prop.r.y = -(self.prop_index - 1)*self.prop.r.h/
				self.num_prop_frames
            
            --self.group:raise_to_top()
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
                table.insert(good_guys_collision_list,
                    {
                        obj = self,
                        x1  = self.group.x+20,--self.image.w/(2*self.num_frames),
                        x2  = self.group.x+self.image.w/(self.num_frames)-20,
                        y1  = self.group.y+20,--self.image.h/2,
                        y2  = self.group.y+self.image.h,--/2,
                    }
                )
                --[[
                add_to_collision_list( self ,
					{self.group.x+self.image.w/(2*self.num_frames),self.group.y+self.image.h/2},
					{self.group.x+self.image.w/(2*self.num_frames),self.group.y+self.image.h/2},
					{self.image.w/(2*self.num_frames),self.image.h},
					TYPE_ENEMY_PLANE)-- start_point , self.group.center , { self.group.w - 10 , self.group.h - 30 } , TYPE_ENEMY_PLANE )
                --]]
end
--[[
            r.x = self.group.x
r.y=self.group.y
r.w=self.image.w
r.h=self.image.h
--r:raise_to_top()
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
						z_rotation = {z_rot,0,0},
                    },
                    
                setup =
                
                    function( self )
                    
                        layers.air_bullets:add( self.image )
                    end,
                    
                render =
                
                    function( self , seconds )
                    
                        local y = self.image.y + self.speed * seconds * math.cos(-1*self.z_rot*math.pi/180)
                        local x = self.image.x + self.speed * seconds * math.sin(-1*self.z_rot*math.pi/180)
                        
                        if y < -self.image.h or y > (screen.h + self.image.h) or x < -self.image.w  or x > (screen.w + self.image.w)then
                            
                            remove_from_render_list( self )
                            
                            self.image:unparent()
                        
                        else
                        
                            table.insert(good_guys_collision_list,
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
                                self ,
                                { self.image.x , self.image.y },
                                { self.image.x , y },
                                { self.image.w , self.image.h },
                                TYPE_ENEMY_PLANE )
                        --]]
                            self.image.y = y
                            self.image.x = x
                        
                        end
                    
                    end,
                    
                collision =
                
                    function( self , other )
                        if other.type == TYPE_ENEMY_BULLET then return end
                    
                        remove_from_render_list( self )
                        local location
                        if other.group ~= nil then
                            location = other.group.position
                        else
                            location = other.image.position
                        end
                        
                        self.image:unparent()
                        
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
        if not state.set_highscore then
            state.set_highscore = true
            mediaplayer:play_sound("audio/Air Combat High Score.mp3")
        end
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
                                    
                                        layers.planes:add( self.text )
                                        
                                    end,
                                    
                                render =
                                
                                    function( self , seconds )
                                   -- print("aaaa")
                                        local o = self.text.opacity - self.speed * seconds
                                        
                                        --local scale = self.text.scale
                                        
                                        --scale = { scale[ 1 ] + ( 2 * seconds ) , scale[ 2 ] + ( 2 * seconds ) }
                                        
                                        if o <= 0 then
                                        
                                            remove_from_render_list( self )
                                            
                                            self.text:unparent()
                                        
                                        else
                                        
                                            self.text.opacity = o
                                            
                                            --self.text.scale = scale
                                        
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

if self.damage ~= (self.num_frames - 1) then
    self:hit()
    return
else
    self:heal()
end

--more Alex code
if state.hud.num_lives == 0 then

	remove_from_render_list( my_plane )
	add_to_render_list(
                
                            {
                                speed = 40,
                                
                                text = Clone{ source = txt.g_over },
                                
                                setup =
                                    
                                    function( self )
                                        
                                        self.text.position = { screen.w/2,screen.h/2}--location[ 1 ] + 30 , location[ 2 ] }
                                        
                                        self.text.anchor_point = { self.text.w / 2 , self.text.h / 2 }
                                        
                                        self.text.opacity = 255;
                                        
                                        layers.hud:add( self.text )
                                        mediaplayer:play_sound("audio/Air Combat Game Over.mp3")
                                    end,
                                    
                                render =
                                
                                    function( self , seconds )
                                    
                                        local o = self.text.opacity - self.speed * seconds
                                        
                                        local scale = self.text.scale
                                        
                                        scale = { scale[ 1 ] + ( 2 * seconds ) , scale[ 2 ] + ( 2 * seconds ) }
                                        
                                        if o <= 0 then
                                        
                                            remove_from_render_list( self )
                                            
                                            self.text:unparent()
                                        
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
                            mediaplayer:play_sound("audio/Air Combat 1P Explosion.mp3")

                            self.group = Group
                                {
                                    size = { self.image.w / 7 , self.image.h },
                                    position = location,
                                    clip = { 0 , 0 , self.image.w / 7 , self.image.h },
                                    children = { self.image },
                                    anchor_point = { ( self.image.w / 7 ) / 2 , self.image.h / 2 },
                                }
                            
                            layers.planes:add( self.group )
                            
                        end,
                        
                    render =
                    
                        function( self , seconds )
                        
                            self.time = self.time + seconds
                            
                            if self.time > self.duration then
                                
                                remove_from_render_list( self )
                                
                                self.group:unparent()
                            
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
        --[[
            if number_of_lives == 0 then--self.dead then
            
                return
                
            end
            --]]

            if key == keys.Right then
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
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w / (2*self.num_frames) , self.group.y,0) )
					end,
					function()
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w /(2*self.num_frames) -20, self.group.y,0) )
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w /(2*self.num_frames) +20, self.group.y,0) )
					end,
					function()
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w /(2*self.num_frames) -40, self.group.y,-45) )
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w /(2*self.num_frames),    self.group.y,0) )
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w / (2*self.num_frames)+40, self.group.y,45) )
					end,
					function()
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w /(2*self.num_frames) -40, self.group.y,-45) )
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w /(2*self.num_frames) ,    self.group.y,0) )
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w /(2*self.num_frames) ,    self.group.y+self.image.h,180) )
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w /(2*self.num_frames) +40, self.group.y,45) )
					end,
					function()
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w /(2*self.num_frames) -40, self.group.y,-45) )
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w /(2*self.num_frames) -20, self.group.y,0) )
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w /(2*self.num_frames) +20, self.group.y,0) )
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w /(2*self.num_frames) ,    self.group.y+self.image.h,180) )
		                add_to_render_list( self:new_bullet(self.group.x + self.image.w /(2*self.num_frames) +40, self.group.y,45) )
					end,


				}
				shoot[self.firing_powerup]()
                mediaplayer:play_sound("audio/Air Combat 1P Fire.mp3")
                
            end
                
        end
}
powerups =
{
    guns = function(xxx) return {
        image = Rectangle{w=60,h=60,color="FFFF00",},
        speed = 50,
        setup = function(self)
            self.image.position = {xxx,-self.image.h}
            layers.planes:add(self.image)
        end,
        render = function(self,seconds)
            self.image.y = self.image.y + self.speed * seconds

            if not (                    
                my_plane.group.x+20 > self.image.x+self.image.w or 
                my_plane.group.x+my_plane.image.w/(my_plane.num_frames)-20 <
                    self.image.x or 
                my_plane.group.y+20 > self.image.y+self.image.h or 
                my_plane.group.y+my_plane.image.h < self.image.y 
                ) then
                
                if my_plane.firing_powerup < my_plane.firing_powerup_max then
                    my_plane.firing_powerup = my_plane.firing_powerup + 1
                end
                self.image:unparent()
                remove_from_render_list(self)
            elseif self.image.y > screen.h + self.image.h then
                self.image:unparent()
                remove_from_render_list(self)
                end
        end,
    } end,
    health = function(xxx) return {
        image = Rectangle{w=60,h=60,color="FFFFFF",},
        speed = 50,
        setup = function(self)
            self.image.position = {xxx,-self.image.h}
            layers.planes:add(self.image)
        end,
        render = function(self,seconds)
            self.image.y = self.image.y + self.speed * seconds

            if not (                    
                my_plane.group.x+20 > self.image.x+self.image.w or 
                my_plane.group.x+my_plane.image.w/(my_plane.num_frames)-20 <
                    self.image.x or 
                my_plane.group.y+20 > self.image.y+self.image.h or 
                my_plane.group.y+my_plane.image.h < self.image.y 
                ) then
                
                my_plane:heal()
                self.image:unparent()
                remove_from_render_list(self)
            elseif self.image.y > screen.h + self.image.h then
                self.image:unparent()
                remove_from_render_list(self)
                end
        end,
    } end,
    life = function(xxx) return {
        image = Rectangle{w=60,h=60,color="654321",},
        speed = 50,
        setup = function(self)
            self.image.position = {xxx,-self.image.h}
            layers.planes:add(self.image)
        end,
        render = function(self,seconds)
            self.image.y = self.image.y + self.speed * seconds

            if not (                    
                my_plane.group.x+20 > self.image.x+self.image.w or 
                my_plane.group.x+my_plane.image.w/(my_plane.num_frames)-20 <
                    self.image.x or 
                my_plane.group.y+20 > self.image.y+self.image.h or 
                my_plane.group.y+my_plane.image.h < self.image.y 
                ) then
                
                if state.hud.num_lives < state.hud.max_lives then
                    state.hud.num_lives = state.hud.num_lives + 1
                    lives[state.hud.num_lives].opacity =255
                end
                self.image:unparent()
                remove_from_render_list(self)
            elseif self.image.y > screen.h + self.image.h then
                self.image:unparent()
                remove_from_render_list(self)
                end
        end,
    } end,
}
