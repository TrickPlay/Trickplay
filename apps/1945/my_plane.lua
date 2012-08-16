local old_impacts = {}
local can_fire = true
local fire_rate = Timer{interval=200}
function fire_rate:on_timer()
    can_fire = true
    fire_rate:stop()
end
local old_bullets = {}
local tot_bullets_created = 0
impact = function(x,y)
    local imp
    
    if #old_impacts == 0 then
        imp = {
            images = {},
            num    = 0,
            index  = 0,
            duration_p_frame = 0.1, 
            time = 0,
            remove = function(self)
                for i =1,self.num do
                    self.images[i]:unparent()
                end
                table.insert(old_impacts,self)
            end,
            setup = function( self )
                play_sound_wrapper("audio/taking-damage.mp3")
                if #self.images == 0 then
                    self.num = #base_imgs.impact
                    for i =1,self.num do
                        self.images[i] = Clone{ source = base_imgs.impact[i], opacity = 0, position = {x,y} }
                    end
                end
                for i =1,self.num do
                    layers.air_doodads_2:add( self.images[i] )
                end
                self.index = 1
                self.time  = 0
                self.images[self.index].opacity=255
            end,
                    
            render = function( self , seconds )
                self.time = self.time + seconds
                    
                if self.time > self.duration_p_frame then
                    if self.index < self.num then
                        self.images[self.index].opacity=0
                        self.index = self.index + 1
                        self.time = 0
                        self.images[self.index].opacity=255
                    else
                        remove_from_render_list( self )
                    end
                end
            end,
        }
        add_to_render_list(imp)
    else
        --print(x,y)
        imp = table.remove(old_impacts)
        add_to_render_list(imp)
        for i =1,imp.num do
            imp.images[i].position = {x,y}
        end
    end
    
end

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
                image = Clone{ source = base_imgs.smoke },
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
                self.plumes[i].group.x = my_plane.group.x + my_plane.img_w-30
                self.plumes[i].group.y = my_plane.group.y + 50
            else
                self.plumes[i].group.x = my_plane.group.x + 30
                self.plumes[i].group.y = my_plane.group.y + my_plane.img_h-20
            end
            self.plumes[i].image.x =  - ( ( self.plumes[i].image.w / 4 ) * 5 )
            layers.planes:add( self.plumes[i].group )
        end
        
        self.halted  = true
        --print("m")
        if type(o) == "table"  then
                --print("AMOK", o)
                recurse_and_apply(  self, o  )
        end
        
    end,
    reset = function(self,i)
        if self.index == 1 then
            self.plumes[i].group.x = my_plane.group.x + 10
            self.plumes[i].group.y = my_plane.group.y + 50
        elseif self.index == 2 then
            self.plumes[i].group.x = my_plane.group.x + my_plane.img_w-30
            self.plumes[i].group.y = my_plane.group.y + 50
        else
            self.plumes[i].group.x = my_plane.group.x + 30
            self.plumes[i].group.y = my_plane.group.y + my_plane.img_h-20
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
                self.plumes[i].group.x = my_plane.group.x + my_plane.img_w-30
                self.plumes[i].group.y = my_plane.group.y + 50
            else
                self.plumes[i].group.x = my_plane.group.x + 30
                self.plumes[i].group.y = my_plane.group.y + my_plane.img_h-20
            end
            self.plumes[i].time = -(i-1)/self.num*self.duration
            --layers.planes:add( self.plumes[i].group )
        end
    end,
	render = function( self , seconds )
    --[[
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
        --]]
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
    
    num_frames = 0,
    
    smoke_stream = {},
    
    plumes_per_stream = 1,
    
    max_h_speed = 500,
    
    max_v_speed = 300,
    
    friction = 200,
    
    speed_bump = 250,
    
    group = Group{},
    
    images = {},
    
    bullet = base_imgs.my_bullet,
    
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
    
    duration_p_frame = 0.1,
    
    prop =
    {
        l = {},
        r = {}
    },
    render_items = {},
    x =0,
    y=0,
    coll_box = {},
    remove = function(self)
        self.group:unparent()
    end,
    setup = function( self,o )
            self.coll_box.obj = self
            self.firing_powerup = 1
            self.damage = 0
            self.group:show()
            
            self.num_frames = #base_imgs.my_plane_strip
            for i = 1,self.num_frames do
                self.images[i] = Clone{source=base_imgs.my_plane_strip[i],opacity=0}
            end
            self.num_prop_frames = #base_imgs.my_prop
            for i = 1,self.num_prop_frames do
                self.prop.l[i] = Clone{source=base_imgs.my_prop[i],position = {35,35},opacity=0}
                self.prop.r[i] = Clone{source=base_imgs.my_prop[i],position = {93,35},opacity=0}
                self.prop.l[i].anchor_point = {base_imgs.my_prop[i].w/2,base_imgs.my_prop[i].h}
                self.prop.r[i].anchor_point = {base_imgs.my_prop[i].w/2,base_imgs.my_prop[i].h}
            end
            
            self.images[1].opacity=255
            self.prop.l[1].opacity=255
            self.prop.r[1].opacity=255
            --self.bombing_crosshair:add(self.bombing_crosshair_strip)
            
            self.prop_index = 1
            self.group:add( unpack(self.images) )
            self.group:add( unpack(self.prop.r) )
            self.group:add( unpack(self.prop.l) )
            layers.planes:add( self.group )
            self.group.position = { screen_w / 2 - self.images[1].w / 2 , screen_h - self.images[1].h }
            --[[
            for i = 1, self.num_frames - 1 do
                if self.overwrite_vars ~= nil and self.overwrite_vars.smoke_stream ~= nil then
                    print("wtf",self.overwrite_vars.smoke_stream[i])
                    self.smoke_stream[i] = smoke(i,self.overwrite_vars.smoke_stream[i])
                else
                    self.smoke_stream[i] = smoke(i)
                end
                    
                    --self.smoke_stream[i]:setup(self.plumes_per_stream)
                    --table.insert(self.render_items,self.smoke_stream[i])
                    --add_to_render_list(self.smoke_stream[i],self.plumes_per_stream)
                
            end
	    --]]
            self.img_h = self.images[1].h
            self.img_w = self.images[1].w
            if type(o) == "table"  then
                recurse_and_apply(  self, o  )
                self.overwrite_vars = nil
            end
            --print("my_plane setup end")
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
        if self.damage ~= (2*self.num_frames - 1) then
        self.images[math.ceil((self.damage+1)/2)].opacity=0
        self.damage = self.damage + 1
        self.images[math.ceil((self.damage+1)/2)].opacity=255
        --for j = 1,self.plumes_per_stream do
                --self.smoke_stream[self.damage]:unhalt()
        --end
        end
    end,
    heal = function(self)
        for i = 1, self.num_frames - 1 do
            --for j = 1,self.plumes_per_stream do
                --self.smoke_stream[i]:halt()
            --end
        end
        self.damage = 0
        for i = 1,self.num_frames do
            self.images[i].opacity=0
        end
        self.images[1].opacity=255
    end,
    render = function( self , seconds )
            
            --animate the prop
            self.prop.l[self.prop_index].opacity=0
            self.prop.r[self.prop_index].opacity=0
			self.prop_index = self.prop_index%
				self.num_prop_frames + 1
			self.prop.l[self.prop_index].opacity=255
            self.prop.r[self.prop_index].opacity=255
            
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
            local x = self.group.x
	    
	    if not using_keys then
		
		self.h_speed = clamp( (cursor.x - x-my_plane_sz/2)*5 ,
                        -self.max_h_speed , self.max_h_speed )
		
	    end
	    
	    x = x + self.h_speed * seconds
	    
            
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
            
            self.group.x = x
            
            local y = self.group.y
	    
	    
	    if not using_keys then
		
		self.v_speed = clamp( (cursor.y - y-my_plane_sz/2-4)*5 ,
                        -self.max_v_speed , self.max_v_speed )
		
	    end
	    
	    y = y + self.v_speed * seconds
            
            if y > screen_h - my_plane_sz then
                
                y = screen_h -my_plane_sz 
                self.v_speed = 0
                
            elseif y < 0 then
                
                y = 0
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
            
            self.group.y = y
            self.coll_box.x1  = self.group.x+20
            self.coll_box.x2  = self.group.x+self.img_w-20
            self.coll_box.y1  = self.group.y+20
            self.coll_box.y2  = self.group.y+self.img_h
            if not self.dead then
                table.insert(g_guys_air,self.coll_box)
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
                        source = base_imgs.my_bomb,
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
                                    x1  = self.image.x-base_imgs.explosion1[1].w/2-10,
                                    x2  = self.image.x+base_imgs.explosion1[1].w/2+10,
                                    y1  = self.image.y-base_imgs.explosion1[1].h/2-10,
                                    y2  = self.image.y+base_imgs.explosion1[1].h/2+10,
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
    dolater(add_to_render_list,explosions.small(x,y)
    )
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
                    
                    end
            }
        
        end,
    new_bullet = function( self, x, y )
        
            if #old_bullets == 0 then
                    tot_bullets_created = tot_bullets_created + 1
                    --print(tot_bullets_created)
                return
                
                {
                    type = TYPE_MY_BULLET,
                    
                        
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
                    remove = function(self)
                        self.image:unparent()
                        table.insert(old_bullets,self)
                    end,
                    render =
                    
                        function( self , seconds )
                        
                            local y = self.image.y + self.speed * seconds
                            if y < -self.img_h then
                                
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
                        end
                }
            else
            --print(x,y)
                local bullet = table.remove(old_bullets)
                bullet.image.y = y
                bullet.image.x = x
                return bullet
            end
            
        end,
        
    -- When we crash with an enemy plane
    
    collision =
    
        function( self , other )

if self.damage ~= (2*self.num_frames - 1) then
    self:hit()
    if other.group ~= nil then
        impact(other.group.x,other.group.y)
    elseif other.image ~= nil then
        impact(other.image.x,other.image.y)
    end
    play_sound_wrapper("audio/taking-damage.mp3")
    return
else
    self:heal()
end

--more Alex code
if state.hud.num_lives == 0 then

	remove_from_render_list( my_plane )
	
    local index = 0
    for i=1,8 do
        --print(state.hud.curr_score, state.high_scores[i].score)
        if state.hud.curr_score > tonumber(state.high_scores[i].score) then
            index = i
            break
        end
    end
    if index ~= 0 then
        game_over_save:animate_in(state.hud.curr_score,index)
    else
        game_over_no_save:animate_in(state.hud.curr_score)
    end
    play_sound_wrapper("audio/game-over.mp3")

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
            
            local location = {self.group.x + self.img_w/2, self.group.y+self.img_h/2}
            
            self.group.position = { screen_w / 2 - self.group.w / 2 , screen_h - self.group.h }

            -- Spawn an explosion
            add_to_render_list(explosions.big(location[1],location[2],nil,0,"audio/player-explosion.mp3"))
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
		                add_to_render_list( self:new_bullet(self.group.x + self.img_w / 2 , self.group.y,0) )
					end,
					function()
		                add_to_render_list( self:new_bullet(self.group.x + self.img_w / 2 -20, self.group.y,0) )
		                add_to_render_list( self:new_bullet(self.group.x + self.img_w / 2 +20, self.group.y,0) )
					end,
					function()
		                add_to_render_list( self:new_bullet(self.group.x + self.img_w / 2 -40, self.group.y,-45) )
		                add_to_render_list( self:new_bullet(self.group.x + self.img_w / 2,    self.group.y,0) )
		                add_to_render_list( self:new_bullet(self.group.x + self.img_w / 2+40, self.group.y,45) )
					end,
					function()
		                add_to_render_list( self:new_bullet(self.group.x + self.img_w / 2 -40, self.group.y,-45) )
		                add_to_render_list( self:new_bullet(self.group.x + self.img_w / 2 ,    self.group.y,0) )
		                add_to_render_list( self:new_bullet(self.group.x + self.img_w / 2 ,    self.group.y+self.img_h,180) )
		                add_to_render_list( self:new_bullet(self.group.x + self.img_w / 2 +40, self.group.y,45) )
					end,
					function()
		                add_to_render_list( self:new_bullet(self.group.x + self.img_w / 2 -40, self.group.y,-45) )
		                add_to_render_list( self:new_bullet(self.group.x + self.img_w / 2 -20, self.group.y,0) )
		                add_to_render_list( self:new_bullet(self.group.x + self.img_w / 2 +20, self.group.y,0) )
		                add_to_render_list( self:new_bullet(self.group.x + self.img_w / 2 ,    self.group.y+self.img_h,180) )
		                add_to_render_list( self:new_bullet(self.group.x + self.img_w / 2 +40, self.group.y,45) )
					end,


				}
                if not self.dead then
                if self.bombing_mode then
                    add_to_render_list(
                        self:new_bomb(self.group.x + self.img_w/2 ,
                        self.group.y+60,0)
                    )
                    play_sound_wrapper("audio/drop-bomb.mp3")
				else
                    if can_fire then
                        fire_rate:start()
                        can_fire = false
                        shoot[self.firing_powerup]()
                        play_sound_wrapper("audio/player-shooting.mp3")
                    end
                    
                end
                end
                
            end
                
        end
}
powerups =
{
    guns = function(xxx,green) 
    local p =  {
        image = Clone{source=base_imgs.guns},--Rectangle{w=60,h=60,color="FFFF00",},
        speed = 30,
        setup = function(self)
            if green == true then
                self.image = Clone{source=base_imgs.guns_g}
            end
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
                my_plane.group.x+my_plane.img_w-20 <
                    self.image.x or 
                my_plane.group.y+20 > self.image.y+self.image.h or 
                my_plane.group.y+my_plane.img_h < self.image.y 
                ) then
                
                if my_plane.firing_powerup < my_plane.firing_powerup_max then
                    my_plane.firing_powerup = my_plane.firing_powerup + 1
                    play_sound_wrapper("audio/power-up.mp3")
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
    health = function(xxx,green) 
    local p =  {
        image = Clone{source=base_imgs.health},--Rectangle{w=60,h=60,color="FFFFFF",},
        speed = 30,
        setup = function(self)
            if green == true then
                self.image = Clone{source=base_imgs.health_g}
            end
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
                my_plane.group.x+my_plane.img_w-20 <
                    self.image.x or 
                my_plane.group.y+20 > self.image.y+self.image.h or 
                my_plane.group.y+my_plane.img_h < self.image.y 
                ) then
                
                my_plane:heal()
                play_sound_wrapper("audio/power-up.mp3")
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
    life = function(xxx,green)
    local p = {
        image = Clone{source=base_imgs.up_life},--Rectangle{w=60,h=60,color="654321",},
        speed = 30,
        setup = function(self)
            if green == true then
                self.image = Clone{source=base_imgs.up_life_g}
            end
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
                my_plane.group.x+my_plane.img_w-20 <
                    self.image.x or 
                my_plane.group.y+20 > self.image.y+self.image.h or 
                my_plane.group.y+my_plane.img_h < self.image.y 
                ) then
                
                if state.hud.num_lives < state.hud.max_lives then
                    state.hud.num_lives = state.hud.num_lives + 1
                    lives[state.hud.num_lives].opacity =255
                    play_sound_wrapper("audio/power-up.mp3")
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
    add_to_render_list(my_plane,o)
    
end
