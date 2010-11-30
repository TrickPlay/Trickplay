
smoke = function(i,o)   return {
    index = i,

    duration = 0.5,
    time     = 0,
    speed    = 80,
    halted   = true,
    plumes   = {},
remove = function(self)
    for i = 1,self.num do
        self.plumes[i].group:unparent()
    end
end,
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
        
        self.halted  = true
        print("m")
        if type(o) == "table"  then
                print("AMOK", o)
                recurse_and_apply(  self, o  )
        end
        
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
        self.plumes[i].image.x =  self.plumes[i].image.w / 4
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
            --layers.planes:add( self.plumes[i].group )
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
                self.plumes[i].image.x =  self.plumes[i].image.w / 4 
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

setup_my_plane = nil

my_plane =
{
    overwrite_vars = {},
	firing_powerup = 1,
    firing_powerup_max = 5,

    damage = 0,

    type = TYPE_MY_PLANE,
    
    num_frames = 4,
    
    smoke_stream = {},
    
    plumes_per_stream = 1,
    
    max_h_speed = 500,
    
    max_v_speed = 300,
    
    friction = 200,
    
    
    speed_bump = 250,
    
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
    
    bombing_mode = false,
    
    bombing_crosshair_strip =
        Clone{
            source=imgs.target,
            --x=-imgs.target.w/2,
            --anchor_point={imgs.target.w/4,imgs.target.h/2},
            --y=-100
        },
    bombing_crosshair =
        Group{
            y=-100,
            anchor_point={imgs.target.w/4,imgs.target.h/2},
            clip={0,0,imgs.target.w/2,imgs.target.h}
        },
    
    shadow = Clone{source=imgs.player_shadow,opacity=0, x=100,y=30},
        
    prop =
    {
        l = Clone{source=imgs.my_prop},
        r = Clone{source=imgs.my_prop},
        g_l = Group
        {
            clip =
            {
                0,
                0,
                imgs.my_prop.w ,
                --self.num_prop_frames still DNE 
                imgs.my_prop.h/3,
            },
            anchor_point = {imgs.my_prop.w/2,
                            imgs.my_prop.h/2},
            position     = {35,35},
        },
        g_r = Group
        {
            clip =
            {
                0,
                0,
                imgs.my_prop.w ,
                --self.num_prop_frames still DNE 
                imgs.my_prop.h/3,
            },
            anchor_point = {imgs.my_prop.w/2,
                            imgs.my_prop.h/2},
            position     = {93,35},
        },
    },
    render_items = {},
    x =0,
    y=0,
remove = function(self)
    self.group:unparent()
end,
    setup = function( self )
            self.damage = 0
            self.image.x = 0
            self.bombing_crosshair:add(self.bombing_crosshair_strip)
        	self.prop.g_l:add( self.prop.l )
			self.prop.g_r:add( self.prop.r )
            self.num_prop_frames = 3
            
            self.prop_index = 1
            self.image.opacity = 255
            local g = Group{}
            self.group:add( self.shadow   )
            --self.group:add(self.bombing_crosshair)
            g:add( self.image    )
            g:add( self.prop.g_r )
            g:add( self.prop.g_l )
            self.group:add(g)
            layers.planes:add( self.group )
            self.bombing_crosshair.x = self.image.w / (2*self.num_frames)
            self.group.position = { screen_w / 2 - self.image.w / (2*self.num_frames) , screen_h - self.image.h }
            self.x = screen_w / 2 - self.image.w / (2*self.num_frames)
            self.y = screen_h - self.image.h 
            g.clip = {0,0,self.image.w/self.num_frames,self.image.h}

            for i = 1, self.num_frames - 1 do
                if self.overwrite_vars.smoke_stream ~= nil then
                    print("wtf",self.overwrite_vars.smoke_stream[i])
                    self.smoke_stream[i] = smoke(i,self.overwrite_vars.smoke_stream[i])
                else
                    self.smoke_stream[i] = smoke(i)
                end
                    
                    --self.smoke_stream[i]:setup(self.plumes_per_stream)
                    --table.insert(self.render_items,self.smoke_stream[i])
                    add_to_render_list(self.smoke_stream[i],self.plumes_per_stream)
                
            end
            self.img_h = self.image.h
            self.prop_h = self.prop.l.h
            if type(self.overwrite_vars) == "table"  then
                print("self.overwrite_vars", self.overwrite_vars)
                recurse_and_apply(  self, self.overwrite_vars  )
            end
        end,
        salvage = function( self, salvage_list )
            
            s = {
                func         = {"setup_my_plane"},
                table_params = {},
                setup_params = {},
            }
            table.insert(s.table_params,{
                prop_index     = self.prop_index,
                v_speed        = self.v_speed,
                h_speed        = self.h_speed,
                damage         = self.damage, 
                last_shot_time = self.last_shot_time,
                bombing_mode   = self.bombing_mode,
                last_smoke     = last_smoke,
                deg_counter    = {},
                dead           = self.dead,
                dead_time      = self.dead_time,
                firing_powerup = self.firing_powerup,
                smoke_stream   = {},
                group = {
                    x = self.group.x,
                    y = self.group.y,
                },
                image = {
                    x = self.image.x,
                    y = self.image.y
                }
            })
            local sm = s.table_params[#s.table_params].smoke_stream
            for i = 1,#self.smoke_stream do
                sm[i] = {}
                sm[i].time   = self.smoke_stream[i].time
                sm[i].halted = self.smoke_stream[i].halted
                sm[i].plumes = {}
                for j = 1, #self.smoke_stream[i].plumes do
                    sm[i].plumes[j] = {}
                    sm[i].plumes[j].group    = {}
                    sm[i].plumes[j].image    = {}
                    sm[i].plumes[j].group.x  = self.smoke_stream[i].plumes[j].group.x
                    sm[i].plumes[j].group.y  = self.smoke_stream[i].plumes[j].group.y
                    sm[i].plumes[j].image.x  = self.smoke_stream[i].plumes[j].image.x
                    sm[i].plumes[j].time     = self.smoke_stream[i].plumes[j].time

                end
            end
            return s
        end,
    hit = function(self)
        if self.damage ~= (self.num_frames - 1) then
        self.damage = self.damage + 1
        self.image.x = -1*self.damage*self.image.w/self.num_frames
        --for j = 1,self.plumes_per_stream do
                self.smoke_stream[self.damage]:unhalt()
        --end
        end
    end,
    heal = function(self)
        for i = 1, self.num_frames - 1 do
            --for j = 1,self.plumes_per_stream do
                self.smoke_stream[i]:halt()
            --end
        end
        self.damage = 0
        self.image.x = 0
    end,
    render =
    
        function( self , seconds )
            
            --animate the prop
			self.prop_index = self.prop_index%
				self.num_prop_frames + 1
			self.prop.l.y = -(self.prop_index - 1)*self.prop_h/
				self.num_prop_frames
			self.prop.r.y = -(self.prop_index - 1)*self.prop_h/
				self.num_prop_frames
            
            --if respawned, then blink
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
                    
                    if blink_on then self.group:show()
                    else             self.group:hide() end
                end
            end
            
            --update position
            --print(self.h_speed)
            --self.x = self.x + ( self.h_speed * seconds )
            local x = self.group.x + ( self.h_speed * seconds )
            
            if x > screen_w - my_plane_sz then
                
                x = screen_w -my_plane_sz 
                self.h_speed = 0
                
            elseif x < 0 then
                x = 0
                self.h_speed = 0
            else
                if self.h_speed > 0 then
                    self.h_speed =  self.h_speed - ( 3/2*self.friction * seconds )
                    if self.h_speed < 0 then self.h_speed = 0 end
                elseif self.h_speed < 0 then
                    self.h_speed =  self.h_speed + ( 3/2*self.friction * seconds )
                    if self.h_speed > 0 then self.h_speed = 0 end
                end
            end
            self.group.x = x--math.ceil(self.x/4)*4
            
            
            --self.y = self.y + ( self.v_speed * seconds )
            local y = self.group.y + ( self.v_speed * seconds )
            
            if y > screen_h - my_plane_sz then
                
                self.y = screen_h -my_plane_sz 
                self.v_speed = 0
                
            elseif y < 0 then
                
                self.y = 0
                self.v_speed = 0
                
            else
                if self.v_speed > 0 then
                    self.v_speed =  self.v_speed - ( 3/2*self.friction * seconds )
                    if self.v_speed < 0 then self.v_speed = 0 end
                elseif self.v_speed < 0 then
                    self.v_speed =  self.v_speed + ( 3/2*self.friction * seconds )
                    if self.v_speed > 0 then self.v_speed = 0 end
                end
            end
            
            self.group.y = y--math.ceil(self.y/4)*4
            
            if not self.dead then
                table.insert(g_guys_air,
                    {
                        obj = self,
                        x1  = self.group.x+20,--self.image.w/(2*self.num_frames),
                        x2  = self.group.x+self.image.w/(self.num_frames)-20,
                        y1  = self.group.y+20,--self.image.h/2,
                        y2  = self.group.y+self.img_h,--/2,
                    }
                )
            end
        end,
        
    -- Adds a bullet to the render list
        
    new_bomb   = function( self, x, y, z_rot )
    return
            
            {
                type = TYPE_MY_BULLET,
                
                
				z_rot = z_rot,
                
                speed = -200,
                time = 0,
                dur  = 1,
                
                image =
                    
                    Clone
                    {                    
                        source = imgs.my_bomb,
                        opacity = 255,
                        anchor_point = { self.bullet.w / 2 , self.bullet.h / 2 },
                        position = { x, y },
						z_rotation = {z_rot,0,0},
                    },
                    
                remove = function(self)
                    self.image:unparent()
                end,
                setup =
                
                    function( self )
                    
                        layers.air_bullets:add( self.image )
                        self.img_w = self.image.w
                        self.img_h = self.image.h
                    end,
                    
                render =
                    
                    function( self , seconds )
                    --print((1-self.time/self.dur), self.speed)
                        self.time = self.time + seconds
                         
                        local y = self.image.y + self.speed * seconds*(1-self.time/self.dur)
                        --local x = self.image.x + self.speed * seconds * math.sin(-1*self.z_rot*math.pi/180)*(1-self.time/self.dur)
                        
                        self.image.scale = {1-.7*(self.time/self.dur),1-.7*(self.time/self.dur)}
                        
                        
                        
                        if y < -self.img_h or y > (screen_h + self.img_h) then--or x < -self.image.w  or x > (screen_w + self.image.w)then
                            
                            remove_from_render_list( self )
                            
                            self.image:unparent()
                        
                        elseif self.time > self.dur then
                            table.insert(g_guys_land,
                                {
                                    obj = self,
                                    x1  = self.image.x-self.img_w/2,
                                    x2  = self.image.x+self.img_w/2,
                                    y1  = self.image.y-self.img_h/2,
                                    y2  = self.image.y+self.img_h/2,
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
                            
                            --self.image.x = x
                            remove_from_render_list( self )
                            
                            self.image:unparent()
                            local x = self.image.x
                            local y = self.image.y
    dolater(add_to_render_list,
    {
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
                    
			layers.land_targets:add( self.group )
            
            self.img_w = self.image.w/6
            self.img_h = self.image.h
        end,
        remove = function(self)
            self.group:unparent()
        end,
		render = function( self , seconds )
			self.time = self.time + seconds
				
			if self.time > self.duration then
					
				remove_from_render_list( self )
				self.group:unparent()
                --[[
                            table.insert(g_guys_land,
                                {
                                    obj = self,
                                    x1  = self.group.x-self.img_w/2,
                                    x2  = self.group.x+self.img_w/2,
                                    y1  = self.group.y-self.img_h/2,
                                    y2  = self.group.y+self.img_h/2,
                                }
                            )
					--]]
			else
				local frame = math.floor( self.time /
					( self.duration / 6 ) )
				self.image.x = - ( ( self.image.w / 6 )
					* frame )
			end

        end,
        collision = function( self , other )

        end,
	})
                        else
                            self.image.y = y
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
                               
if state.hud.curr_score < 999990 then     
	state.hud.curr_score = state.hud.curr_score+10
    state.counters[state.curr_level].lvl_points = state.counters[state.curr_level].lvl_points + 10
	if state.hud.curr_score > state.hud.high_score then
		state.hud.high_score = state.hud.curr_score
        if not state.set_highscore then
            state.set_highscore = true
            mediaplayer:play_sound("audio/Air Combat High Score.mp3")
        end
	end
    --[[
	if (point_counter % 1000) == 0 and lives[number_of_lives + 1] ~= nil then
		number_of_lives = number_of_lives + 1
		lives[number_of_lives].opacity =255
		self.text = Clone{source=txt.up_life}
	end
    --]]
	redo_score_text()
end

                                        self.text.position = { location[ 1 ] + 30 , location[ 2 ] }
                                        
                                        self.text.anchor_point = { self.text.w / 2 , self.text.h / 2 }
                                        
                                        self.text.opacity = 255;
                                    
                                        layers.planes:add( self.text )
                                        
                                    end,
                                remove = function(self)
                                    self.text:unparent()
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
                remove = function(self)
                    self.image:unparent()
                end,
                setup =
                
                    function( self )
                    
                        layers.air_bullets:add( self.image )
                        self.img_w = self.image.w
                        self.img_h = self.image.h
                    end,
                    
                render =
                
                    function( self , seconds )
                    
                        local y = self.image.y + self.speed * seconds * math.cos(-1*self.z_rot*math.pi/180)
                        local x = self.image.x + self.speed * seconds * math.sin(-1*self.z_rot*math.pi/180)
                        
                        if y < -self.img_h or y > (screen_h + self.img_h) or x < -self.image.w  or x > (screen_w + self.image.w)then
                            
                            remove_from_render_list( self )
                            
                            self.image:unparent()
                        
                        else
                        
                            table.insert(g_guys_air,
                                {
                                    obj = self,
                                    x1  = self.image.x-self.img_w/2,
                                    x2  = self.image.x+self.img_w/2,
                                    y1  = self.image.y-self.img_h/2,
                                    y2  = self.image.y+self.img_h/2,
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
                                remove = function(self)
                                    self.text:unparent()
                                end,
                                setup =
                                
                                    function( self )
                               
if state.hud.curr_score < 999990 then     
	state.hud.curr_score = state.hud.curr_score+10
    state.counters[state.curr_level].lvl_points = state.counters[state.curr_level].lvl_points + 10
	if state.hud.curr_score > state.hud.high_score then
		state.hud.high_score = state.hud.curr_score
        if not state.set_highscore then
            state.set_highscore = true
            mediaplayer:play_sound("audio/Air Combat High Score.mp3")
        end
	end
    --[[
	if (state.hud.curr_score % 1000) == 0 and lives[number_of_lives + 1] ~= nil then
		number_of_lives = number_of_lives + 1
		lives[number_of_lives].opacity =255
		self.text = Clone{source=txt.up_life}
	end
    --]]
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
    mediaplayer:play_sound("audio/Air Combat Damaged Plane.mp3")
    return
else
    self:heal()
end

--more Alex code
if state.hud.num_lives == 0 then

	remove_from_render_list( my_plane )
	
    local index = 0
    for i=1,8 do
        print(state.hud.curr_score, state.high_scores[i].score)
        if state.hud.curr_score > state.high_scores[i].score then
            index = i
            break
        end
    end
    if index ~= 0 then
        game_over_save:animate_in(state.hud.curr_score,index)
    else
        game_over_no_save:animate_in(state.hud.curr_score)
    end
    mediaplayer:play_sound("audio/Air Combat Game Over.mp3")

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
            
            local location = {self.group.x + self.image.w/(2*self.num_frames), self.group.y+self.image.h/2}
            
            self.group.position = { screen_w / 2 - self.group.w / (2*self.num_frames) , screen_h - self.group.h }

            -- Spawn an explosion
            
            local explosion =
                
                {
                    num_frames = 7,
                    
                    image = Clone{ source = imgs.explosion3 , opacity = 255 },
                    
                    group = nil,
                    
                    duration = 0.4, 
                    
                    time = 0,
                    
                    setup =
                    
                        function( self )
                            
                            mediaplayer:play_sound("audio/Air Combat 1P Explosion.mp3")
                            
                            self.group = Group
                                {
                                    size = { self.image.w / self.num_frames , self.image.h },
                                    position = location,
                                    clip = { 0 , 0 , self.image.w / self.num_frames , self.image.h },
                                    children = { self.image },
                                    anchor_point = { ( self.image.w / self.num_frames ) / 2 , self.image.h / 2 },
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
                            
                                local frame = math.floor( self.time / ( self.duration / self.num_frames ) )
                                
                                self.image.x = - ( ( self.image.w / self.num_frames ) * frame )
                            
                            end
                        
                        end,
                }
            
            add_to_render_list( explosion )
        
        end,
        
    on_key =
    
        function( self , key, second_key )
        --[[
            if number_of_lives == 0 then--self.dead then
            
                return
                
            end
            --]]

            if key == keys.Right then
                --if second_key == keys.Right then
                --    print("double right")
                --    self.h_speed = self.max_h_speed
                --else
                    if self.h_speed < 0 then self.h_speed = 0 
                    elseif self.h_speed == 0 then
                        self.h_speed = self.h_speed + self.speed_bump/2
                    else
                    self.h_speed = clamp( self.h_speed + self.speed_bump ,
                        -self.max_h_speed , self.max_h_speed )
                end
                
            elseif key == keys.Left then
                --if second_key == keys.Left then
                --    print("double left")
                --    self.h_speed = -self.max_h_speed
                --else
                if self.h_speed > 0 then self.h_speed = 0
                elseif self.h_speed == 0 then
                        self.h_speed = self.h_speed - self.speed_bump/2
                else
                    self.h_speed = clamp( self.h_speed - self.speed_bump ,
                        -self.max_h_speed , self.max_h_speed )
                end
                
            elseif key == keys.Down then
                --if second_key == keys.Down then
                --    print("double down")
                --    self.v_speed = self.max_v_speed
                --else
                if self.v_speed < 0 then self.v_speed = 0
                elseif self.v_speed == 0 then
                    self.v_speed = self.v_speed + self.speed_bump/2
                else
                    self.v_speed = clamp( self.v_speed + self.speed_bump ,
                        -self.max_v_speed , self.max_v_speed )
                end
                
            elseif key == keys.Up then
                --if second_key == keys.Up then
                --  print("double up")
                --    self.v_speed = -self.max_v_speed
                --else
                if self.v_speed > 0 then self.v_speed = 0
                elseif self.v_speed == 0 then
                    self.v_speed = self.v_speed - self.speed_bump/2
                else
                    self.v_speed = clamp( self.v_speed - self.speed_bump ,
                        -self.max_v_speed , self.max_v_speed )
                end
            
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
                if self.bombing_mode then add_to_render_list( self:new_bomb(self.group.x + self.image.w / (2*self.num_frames) , self.group.y+60,0) )
				else  shoot[self.firing_powerup]() end
                mediaplayer:play_sound("audio/Air Combat 1P Fire.mp3")
                
            end
                
        end
}
powerups =
{
    guns = function(xxx) 
    local p =  {
        image = Clone{source=imgs.guns},--Rectangle{w=60,h=60,color="FFFF00",},
        speed = 30,
        setup = function(self)
            self.image.position = {xxx,-self.image.h}
            layers.planes:add(self.image)
        end,
        remove = function(self)
            self.image:unparent()
        end,
        render = function(self,seconds)
            self.image.y = self.image.y + self.speed * seconds

            if not (                    
                my_plane.group.x+20 > self.image.x+self.image.w or 
                my_plane.group.x+my_plane.image.w/(my_plane.num_frames)-20 <
                    self.image.x or 
                my_plane.group.y+20 > self.image.y+self.image.h or 
                my_plane.group.y+my_plane.img_h < self.image.y 
                ) then
                
                if my_plane.firing_powerup < my_plane.firing_powerup_max then
                    my_plane.firing_powerup = my_plane.firing_powerup + 1
                    mediaplayer:play_sound("audio/Air Combat Player Guns Up.mp3")
                end
                self.image:unparent()
                remove_from_render_list(self)
            elseif self.image.y > screen_h + self.image.h then
                self.image:unparent()
                remove_from_render_list(self)
                end
        end,
    } 
    add_to_render_list(p)
    return p
    end,
    health = function(xxx) 
    local p =  {
        image = Clone{source=imgs.health},--Rectangle{w=60,h=60,color="FFFFFF",},
        speed = 30,
        setup = function(self)
            self.image.position = {xxx,-self.image.h}
            layers.planes:add(self.image)
        end,
        remove = function(self)
            self.image:unparent()
        end,
        render = function(self,seconds)
            self.image.y = self.image.y + self.speed * seconds

            if not (                    
                my_plane.group.x+20 > self.image.x+self.image.w or 
                my_plane.group.x+my_plane.image.w/(my_plane.num_frames)-20 <
                    self.image.x or 
                my_plane.group.y+20 > self.image.y+self.image.h or 
                my_plane.group.y+my_plane.img_h < self.image.y 
                ) then
                
                my_plane:heal()
                mediaplayer:play_sound("audio/Air Combat Player Guns Up.mp3")
                self.image:unparent()
                remove_from_render_list(self)
            elseif self.image.y > screen_h + self.image.h then
                self.image:unparent()
                remove_from_render_list(self)
                end
        end,
    } 
    add_to_render_list(p)
    return p
    end,
    life = function(xxx)
    local p = {
        image = Clone{source=imgs.up_life},--Rectangle{w=60,h=60,color="654321",},
        speed = 30,
        setup = function(self)
            self.image.position = {xxx,-self.image.h}
            layers.planes:add(self.image)
        end,
        remove = function(self)
            self.image:unparent()
        end,
        render = function(self,seconds)
            self.image.y = self.image.y + self.speed * seconds

            if not (                    
                my_plane.group.x+20 > self.image.x+self.image.w or 
                my_plane.group.x+my_plane.image.w/(my_plane.num_frames)-20 <
                    self.image.x or 
                my_plane.group.y+20 > self.image.y+self.image.h or 
                my_plane.group.y+my_plane.img_h < self.image.y 
                ) then
                
                if state.hud.num_lives < state.hud.max_lives then
                    state.hud.num_lives = state.hud.num_lives + 1
                    lives[state.hud.num_lives].opacity =255
                    mediaplayer:play_sound("audio/Air Combat Player Guns Up.mp3")
                end
                self.image:unparent()
                remove_from_render_list(self)
            elseif self.image.y > screen_h + self.image.h then
                self.image:unparent()
                remove_from_render_list(self)
                end
        end,
    }
    add_to_render_list(p)
    return p
    end,
}
setup_my_plane = function(o)
    add_to_render_list(my_plane)
    my_plane.overwrite_vars = o
end