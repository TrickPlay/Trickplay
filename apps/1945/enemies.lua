--Spawns enemies

--Enemy Spawner launches enemy formations
--Formations:
--		Figure_8	flies in from top
--		Row			flies in from side
--		cluster		formation of 3 from the top


--base images for clones
points = function(x,y,num_points)
    local t = make_table()

    t.speed = 80
    t.text = Text{
        font  = my_font,
        text  = "+",
        color = "FFFF00"
    }
    t.remove = function(self)
        self.text:unparent()
    end
    t.setup = function( self )
        self.text.text = "+"..num_points
        if state.hud.curr_score < 999990 then     
        	state.hud.curr_score = state.hud.curr_score+num_points
            state.counters[state.curr_level].lvl_points = state.counters[state.curr_level].lvl_points + num_points
        	if state.hud.curr_score > state.hud.high_score then
        		state.hud.high_score = state.hud.curr_score
                if not state.set_highscore then
                    state.set_highscore = true
                    play_sound_wrapper("audio/level-complete.mp3")
                end
            end
            redo_score_text()
        end
        self.text.position = { x , y }
        self.text.anchor_point = { self.text.w / 2 , self.text.h / 2 }
        self.text.opacity = 255;
        layers.planes:add( self.text )
    end
    t.render = function( self , seconds )
        local o = self.text.opacity - self.speed * seconds
        
        if o <= 0 then
            remove_from_render_list( self )
            self.text:unparent()
        else
            self.text.opacity = o
        end
    end
    add_to_render_list(t)
end
wake = 
    function(x,y) return {
        left  = {},
        right = {},
        group = Group{x=x-curr_lvl_imgs.rear_wake[1].w/2,y=y},
        speed = 80,
        rot_speed = 20,
        curr_rot = 0,
        duration = 6,
        index = 1,
        time = 0,
        remove = function(self)
            self.group:unparent()
        end,
        setup = function( self )
            self.num_frames = #curr_lvl_imgs.rear_wake
            for i = 1,self.num_frames do
                self.left[i] = Clone{
                    source=curr_lvl_imgs.rear_wake[i],
                    opacity=0,
                    x = 10,
                    anchor_point={
                        curr_lvl_imgs.rear_wake[i].w/2,
                        curr_lvl_imgs.rear_wake[i].h/2
                    }
                }
                self.right[i] = Clone{
                    source=curr_lvl_imgs.rear_wake[i],
                    opacity=0,
                    x=curr_lvl_imgs.rear_wake[i].w-10,
                    anchor_point={
                        curr_lvl_imgs.rear_wake[i].w/2,
                        curr_lvl_imgs.rear_wake[i].h/2
                    }
                }
                self.group:add(self.left[i],self.right[i])
            end
            self.left[1].opacity  = 255
            self.right[1].opacity = 255
            
			layers.land_doodads_1:add( self.group )
        end,
                
		render = function( self , seconds )
			self.time = self.time + seconds
			
			if self.time > self.duration then
					
				remove_from_render_list( self )
				self.group:unparent()
					
			else
            
                self.left[self.index].opacity = 0
                self.right[self.index].opacity = 0
				self.index = math.floor( self.time /
                			( self.duration / self.num_frames ) )+1
				self.left[self.index].opacity = 255
                self.right[self.index].opacity = 255
				
                self.curr_rot = self.curr_rot + self.rot_speed*seconds
                self.left[self.index].z_rotation  = {self.curr_rot,0,0}
                self.right[self.index].z_rotation = {-self.curr_rot,0,0}
                
                self.group.y = self.group.y + self.speed*seconds
			end
        end,
	} end

local big_explos = {}
local num_big_explos = 0
local sm_explos = {}
local num_sm_explos = 0


explosions =
{
	big = function(x,y,dam_list,delay,sound)
        if delay == nil then
            delay = 0
        end
        local e
        if #big_explos == 0 then
            num_big_explos = num_big_explos + 1
            e = {
                images    = {},
                index    = 1,
                duration = 0.5, 
                time     = delay,
                num_frames = 0,
                timer    = Timer
                {
                    interval = -delay,
                    on_timer = function(t)
                        t:stop()
                        if sound then
                            play_sound_wrapper(sound)
                        else
                            play_sound_wrapper("audio/big-explosion.mp3")
                        end
                        t=nil
                    end
                },
                remove = function(self)
                    for i = 1,self.num_frames do
                        self.images[i]:unparent()
                    end
                    table.insert(big_explos,self)
                end,
                setup = function( self )
                    if  self.time == nil then
                        self.time =  0
                    end
                    if self.num_frames == 0 then
                        self.num_frames = #base_imgs.explosion3
                        for i = 1,self.num_frames do
                            self.images[i] = Clone{
                                source = base_imgs.explosion3[i],
                                x=x,
                                y=y,
                                anchor_point =
                                {
                                	base_imgs.explosion3[i].w / 2 ,
                                	base_imgs.explosion3[i].h / 2
                                },
                                opacity=0
                            }
                            layers.planes:add(self.images[i])
                        end
                    end
                    self.images[1].opacity=255
                    if delay == 0 then
                        if sound then
                            play_sound_wrapper(sound)
                        else
                            play_sound_wrapper("audio/big-explosion.mp3")
                        end
                    else
                        self.timer:start()
                    end
                    
                    
                end,
                hit = false,
                render = function( self , seconds )
                	self.time = self.time + seconds
                		
                	if self.time > self.duration then
                		
                		remove_from_render_list( self )
                		
                	else
                        if self.index > 0 then
                            self.images[self.index].opacity=0
                        end
                		self.index = math.floor( self.time /
                			( self.duration / self.num_frames ) )+1
                        
                        if self.index > 0 then
                            self.images[self.index].opacity=255
                        end
                	end
                    
                    if (not self.hit) and type(dam_list) == "table" then
                        table.insert(b_guys_air,
                            {
                                obj=self,
                                x1=self.images[1].x-( self.images[1].w ) / 2,
                                x2=self.images[1].x+( self.images[1].w ) / 2,
                                y1=self.images[1].y-self.images[1].h / 2,
                                y2=self.images[1].y+self.images[1].h / 2,
                            }
                        )
                        
                    end
                end,
                collision = function( self , other )
                	self.hit = true
                end	
            }
        else
            e = table.remove(big_explos)
            for i = 1,e.num_frames do
                e.images[i].x = x
                e.images[i].y = y
                e.images[i].opacity=0
                layers.planes:add(e.images[i])
            end
            e.time    = delay
            e.hit     = false
        end
        return e
    end,
	small = function(x,y,sound)
    
        local e
        if #sm_explos == 0 then
        num_sm_explos = num_sm_explos + 1
            e = {
                images   = {},
                duration = 0.2, 
                time     = 0,
                num_frames = 0,
                index    = 1,
                remove = function(self)
                    for i = 1,self.num_frames do
                        self.images[i]:unparent()
                    end
                    table.insert(sm_explos,self)
                end,
                setup = function( self )
                    if sound then
                            play_sound_wrapper(sound)
                        else
                            play_sound_wrapper("audio/enemy-explosion.mp3")
                        end
                    if  self.time == nil then
                        self.time =  0
                    end
                    
                    if self.num_frames == 0 then
                        self.num_frames = #base_imgs.explosion1
                        for i = 1,self.num_frames do
                            self.images[i] = Clone{
                                source = base_imgs.explosion1[i],
                                x=x,
                                y=y,
                                anchor_point =
                                {
                                	base_imgs.explosion1[i].w / 2 ,
                                	base_imgs.explosion1[i].h / 2
                                },
                                opacity=0
                            }
                            layers.planes:add(self.images[i])
                        end
                    end
                    self.images[1].opacity=255
                end,
                hit = false,
                render = function( self , seconds )
                	self.time = self.time + seconds
                		
                	if self.time > self.duration then
                			
                		remove_from_render_list( self )
                			
                	else
                		
                        self.images[self.index].opacity=0
                		self.index = math.ceil( self.time /
                			( self.duration / self.num_frames ) )
                		self.images[self.index].opacity=255--<<<<<<<<<<<<<<<<<<<
                	end
            
                    if (not self.hit) and type(dam_list) == "table" then
                    --print("hhhheeeeerrrrreeee")
                        table.insert(b_guys_air,
                            {
                                obj=self,
                                x1=x-( self.image.w / 6 ) / 2,
                                x2=x+( self.image.w / 6 ) / 2,
                                y1=y-self.image.h / 2,
                                y2=y+self.image.h / 2,
                            }
                        )
                        
                    end
                end,
                collision = function( self , other )
                	self.hit = true
                end	
            }
        else
            e = table.remove(sm_explos)
            for i = 1,e.num_frames do
                e.images[i].x = x
                e.images[i].y = y
                e.images[i].opacity=0
                layers.planes:add(e.images[i])
            end
            e.time    = delay
            e.hit     = false
        end
        return e
    end,
    splash = function(x,y) return {
        images = {},--Clone{ source = curr_lvl_imgs.splash },
        group = nil,
        duration = 0.5,
        index    = 1,
        time = 0,
        remove = function(self)
            for i = 1,self.num_frames do
                self.images[i]:unparent()
            end
        end,
        setup = function( self )
            play_sound_wrapper("audio/enemy-explosion.mp3")
            --[[
            self.group = Group
			{
				size =
				{
					self.image.w / 8 ,
					self.image.h
				},
				clip =
				{
					0 ,
					0 ,
					self.image.w / 8 ,
					self.image.h
				},
				children = { self.image },
				anchor_point =
				{
					( self.image.w / 8 ) / 2 ,
					  self.image.h / 2
				},
                position = {x,y},
			}--]]
            self.num_frames = #base_imgs.splash
            for i = 1,self.num_frames do
                self.images[i] = Clone{source=base_imgs.splash[i],opacity=0,position = {x,y},anchor_point={base_imgs.splash[i].w/2,base_imgs.splash[i].h/2}}
                layers.planes:add( self.images[i] )
            end
            self.images[1].opacity = 255
            self.index = 1
        end,
                
		render = function( self , seconds )
			self.time = self.time + seconds
				
			if self.time > self.duration then
					
				remove_from_render_list( self )
					
			else
                self.images[self.index].opacity = 0
				self.index = math.floor( self.time /
                			( self.duration / self.num_frames ) )+1
				self.images[self.index].opacity = 255
			end
        end,
	} end
}
local bullet_sound_playing = false
local bullet_sound = Timer{interval=400}
function bullet_sound:on_timer()
    bullet_sound_playing = false
    bullet_sound:stop()
end
local old_flak    = {}
local tot_flak_created = 0
local old_flak_shot    = {}
local tot_flak_shot_created = 0
local old_bullets = {}
local tot_bullets_created = 0
scrap_caches = function()
    --print("scrapping",#big_explos,#sm_explos,#old_bullets,#old_flak,#old_flak_shot)
    big_explos = {}
    num_big_explos = 0
    sm_explos = {}
    num_sm_explos = 0
    old_bullets = {}
    tot_bullets_created = 0
    old_flak    = {}
    tot_flak_created = 0
    old_flak_shot    = {}
    tot_flak_shot_created = 0
    collectgarbage("collect")
end
function fire_bullet(enemy,source)
    local deg    = enemy.group.z_rotation[1] + 90
    local bullet
    --print("num in old list",#old_bullets,"num created",tot_bullets_created)
    if #old_bullets == 0 then
        tot_bullets_created = tot_bullets_created + 1
        bullet = {
            speed_x = math.cos(deg*math.pi/180) * 500,
            speed_y = math.sin(deg*math.pi/180) * 500,
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
            remove = function(self)
                self.image:unparent()
                table.insert(old_bullets,self)
            end,
            coll_box = {},
            setup = function( self )
                --enemies are assumed to be facing downwards
                self.coll_box.obj=self
                
                --set up the velocities for x and y
                self.image.x = self.image.x + self.speed_x *.1
                self.image.y = self.image.y + self.speed_y *.1
                layers.air_bullets:add( self.image )
                if not (self.image.x > screen_w or self.image.x < 0 or
                    self.image.y < 0 or self.image.y > screen_h) then
                    
                    if not bullet_sound_playing then
                        play_sound_wrapper("audio/enemy-firing.mp3")
                        bullet_sound_playing = true
                    end
                end
            end,
            
            render = function( self , seconds )
            
                --calculate the next position of the bullet
                local x = self.image.x + self.speed_x *seconds
                local y = self.image.y + self.speed_y *seconds
                --remove it from the screen, if it travels off screen
                if y > screen_h or x > screen_w or y < 0 or x < 0 then
                    remove_from_render_list( self )
                    --self.image:unparent()
                --otherwise, update the position
                else
                    local start_point = self.image.center
                    self.image.y = y
                    self.image.x = x
                    --check for collisions
                    self.coll_box.x1  = self.image.x-self.image.w/2
                    self.coll_box.x2  = self.image.x+self.image.w/2
                    self.coll_box.y1  = self.image.y-self.image.h/2
                    self.coll_box.y2  = self.image.y+self.image.h/2
                    
                    table.insert(b_guys_air,self.coll_box)
                end
            end,
            
            collision = function( self , other )
                
                if other.type == TYPE_MY_BULLET then return end
                
                remove_from_render_list( self )
                
            end
        }
    else
        bullet = table.remove(old_bullets)
	bullet.image.source = source
        bullet.image.x      = enemy.group.x
        bullet.image.y      = enemy.group.y
        bullet.speed_x      = math.cos(deg*math.pi/180) * 500
        bullet.speed_y      = math.sin(deg*math.pi/180) * 500
        
    end
    add_to_render_list( bullet )
    bullet_sound:start()
end
function flak(x,y)
    local f
    --print("num in old list",#old_bullets,"num created",tot_bullets_created)
    if #old_flak == 0 then
        tot_flak_created = tot_flak_created + 1
        --print(tot_flak_created)
    --add_to_render_list(
    f = {
        images = {},
        duration = 0.5,
        hit = false,
        num_frames = 0,
        x=x,
        y=y,
        time = 0,
        remove = function(self)
            for i = 1,self.num_frames do
                self.images[i]:unparent()
            end
            table.insert(old_flak,self)
        end,
        setup = function( self )
            if self.num_frames == 0 then
                self.num_frames = #curr_lvl_imgs.flak
                for i = 1,self.num_frames do
                    self.images[i] = Clone{
                        source=curr_lvl_imgs.flak[i],
                        opacity=0,
                        position = {self.x,self.y},
                        anchor_point={
                            curr_lvl_imgs.flak[i].w/2,
                            curr_lvl_imgs.flak[i].h/2
                        },
                        name="flak "..i
                    }
                    layers.planes:add( self.images[i] )
                end
            else
                for i = 1,self.num_frames do
                    self.images[i].x = self.x
                    self.images[i].y = self.y
                    self.images[i].opacity = 0
                    layers.planes:add( self.images[i] )
                end
            end
            self.images[1].opacity = 255
            self.index = 1
            self.time = 0
            
            play_sound_wrapper("audio/flak-mortar-explosion.mp3")
        end,
                
		render = function( self , seconds )
            self.time = self.time + seconds
				
			if self.time > self.duration then
					
				remove_from_render_list( self )
					
			else
                self.images[self.index].opacity = 0
				self.index = math.floor( self.time /
                			( self.duration / self.num_frames ) )+1
				self.images[self.index].opacity = 255
			end
			
            if not self.hit then
            table.insert(b_guys_air,
                {
                    obj = self,
                    x1  = self.x,--curr_lvl_imgs.flak[1].w/2,
                    x2  = self.x+curr_lvl_imgs.flak[1].w,--/2,
                    y1  = self.y,--curr_lvl_imgs.flak[1].h/2,
                    y2  = self.y+curr_lvl_imgs.flak[1].h,--/2,
                }
            )
            end
        end,
        collision = function( self , other )
            
			self.hit = true
            
		end	
	}
    else
        f = table.remove(old_flak)
        f.x = x
        f.y = y
        f.hit = false
    end
    add_to_render_list( f )
end
function fire_flak(enemy, dist_x,dist_y)
    local f
    --print("num in old list",#old_bullets,"num created",tot_bullets_created)
    if #old_flak_shot == 0 then
        tot_flak_shot_created = tot_flak_shot_created + 1
        --print(tot_flak_shot_created)
    f =
    {
        dist_x = dist_x,
        dist_y = dist_y,
        speed = 600,
        num_frames = 1,
        image = Clone
        {
            source = curr_lvl_imgs.t_bullet ,
            opacity = 255,
            anchor_point =
            {
                curr_lvl_imgs.t_bullet.w/2,
                curr_lvl_imgs.t_bullet.h/2
            },
            position =
            {
                enemy.group.x+curr_lvl_imgs.t_bullet.w,
                enemy.group.y+curr_lvl_imgs.t_bullet.h/2
            },
            z_rotation = {enemy.group.z_rotation[1]+90,0,0},
            name="flak_shot"
        },
        remove = function(self)
                    self.image:unparent()
                    table.insert(old_flak_shot,self)
                end,
        type = TYPE_ENEMY_BULLET,
            
        setup = function( self )
        if not (self.image.x > screen_w or self.image.x < 0 or self.image.y < 0 or self.image.y > screen_h) then
            play_sound_wrapper("audio/flak-shot.mp3")
        end
            
		--enemies are assumed to be facing downwards
		local deg    = self.image.z_rotation[1]
		
		--set up the velocities for x and y
		self.speed_x = math.cos(deg*math.pi/180) * self.speed
		self.speed_y = math.sin(deg*math.pi/180) * self.speed
		self.image.x = self.image.x + self.speed_x *.1
        self.image.y = self.image.y + self.speed_y *.1
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
                --otherwise, update the position
                elseif self.dist_y < 0 and self.dist_x < 0 then
                    remove_from_render_list( self )
                    flak(x,y)
                else
                    local start_point = self.image.center
                    self.image.y = y
                    self.image.x = x
                end
                
            end,
            
            collision =
                function( self , other )
                    if other.type == TYPE_MY_BULLET then return end
                    remove_from_render_list( self )
                end
        }
	else
        f = table.remove(old_flak_shot)
        f.image.position =
            {
                enemy.group.x+curr_lvl_imgs.t_bullet.w,
                enemy.group.y+curr_lvl_imgs.t_bullet.h/2
            }
        f.image.z_rotation = {enemy.group.z_rotation[1]+90,0,0}
        f.dist_x = dist_x
        f.dist_y = dist_y
    end
    add_to_render_list( f )
end
function fire_big_flak(enemy, dist_x,dist_y)
    local bullet =
    {
        dist_x = dist_x,
        dist_y = dist_y,
        speed = 600,
        num_frames = 1,
        image = Clone
        {
            source = curr_lvl_imgs.t_bullet ,
            opacity = 255,
            anchor_point =
            {
                curr_lvl_imgs.t_bullet.w/2,
                curr_lvl_imgs.t_bullet.h/2
            },
            position =
            {
                enemy.group.x+curr_lvl_imgs.t_bullet.w,
                enemy.group.y+curr_lvl_imgs.t_bullet.h/2
            },
            z_rotation = {enemy.group.z_rotation[1]+90,0,0},
            scale = {2,2}
        },
        
        type = TYPE_ENEMY_BULLET,
            
        setup = function( self )
        if not (self.image.x > screen_w or self.image.x < 0 or self.image.y < 0 or self.image.y > screen_h) then
            play_sound_wrapper("audio/Air Combat Enemy Fire.mp3")
        end
            
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
function fire_mortar(enemy, dist_x,dist_y)
    local bullet =
    {
        dist_x  = dist_x,
        dist_y  = dist_y,
        speed   = 600,
        speed_y = 0,
        speed_x = 0,
        x       = 0,
        y       = 0,
        num_frames = 1,
        images = {},
        --[[
        { source = curr_lvl_imgs.trench_bullet },
        g = Group
        {
            clip = {0,0,curr_lvl_imgs.trench_bullet.w/3,curr_lvl_imgs.trench_bullet.h},
            position =
            {
                enemy.group.x+curr_lvl_imgs.trench_bullet.w,
                enemy.group.y+curr_lvl_imgs.trench_bullet.h/2
            },
            scale = {.5,.5}
        },
        --]]
        type = TYPE_ENEMY_BULLET,
            
        setup = function( self )
            self.num_frames = #curr_lvl_imgs.trench_bullet
            for i = 1,self.num_frames do
                self.images[i] = Clone{
                    source=curr_lvl_imgs.trench_bullet[i],
                    opacity=0,
                    position = {
                        enemy.group.x+curr_lvl_imgs.trench_bullet[1].w/2,
                        enemy.group.y+curr_lvl_imgs.trench_bullet[1].h/2
                    },
                    --[[
                    anchor_point = {
                        curr_lvl_imgs.trench_bullet[i].w/2,
                        curr_lvl_imgs.trench_bullet[i].h/2
                    },--]]
                    scale = { .5, .5 }
                }
                layers.air_bullets:add( self.images[i] )
            end
            self.x = enemy.group.x+curr_lvl_imgs.trench_bullet[1].w
            self.y = enemy.group.y+curr_lvl_imgs.trench_bullet[1].h/2
            self.images[1].opacity = 255
            self.index = 1
            
            play_sound_wrapper("audio/mortar-shot.mp3")
            
            --enemies are assumed to be facing downwards
            local tot = math.abs(dist_x)+math.abs(dist_y)
            --set up the velocities for x and y
            self.speed_x = dist_x/tot * self.speed
            self.speed_y = dist_y/tot * self.speed
            
            if math.abs(self.speed_x) > 70 then
                self.speed_x = 70*dist_x/math.abs(self.dist_x)
                self.speed_y = self.speed - self.speed_x
            end
        end,
        
        num_frames  =  3,
        anim_thresh = .2,
        last_anim   =  0,
        anim_i      =  1,
        
        render = function( self , seconds )
            
            self.last_anim = self.last_anim+seconds
            if self.last_anim >= self.anim_thresh then
                self.images[self.anim_i].opacity = 0
                self.anim_i    = self.anim_i % self.num_frames + 1
                self.images[self.anim_i].opacity = 255
                self.last_anim = 0
                
            end
            
            --self.dist_x = self.dist_x - self.speed_x *seconds
            self.dist_y = self.dist_y - self.speed_y *seconds
            self.images[self.anim_i].scale={
                1-.5*self.dist_y/dist_y,
                1-.5*self.dist_y/dist_y
            }
            --print(self.g.scale[1],self.g.scale[2])
            --calculate the next position of the bullet
            local x = self.x + self.speed_x *seconds
            local y = self.y + self.speed_y *seconds
            --remove it from the screen, if it travels off screen
            if y > screen_h or x > screen_w or y < 0 or x < 0 then
                remove_from_render_list( self )
                for i = 1,self.num_frames do
                    self.images[i]:unparent()
                end
            --otherwise, update the position
            elseif self.dist_y < 0  then
                remove_from_render_list( self )
                for i = 1,self.num_frames do
                    self.images[i]:unparent()
                end
                add_to_render_list(explosions.big(x,y,b_guys_air))
            else
                --local start_point = self.image.center
                self.y = y
                self.x = x
                self.images[self.anim_i].x = x
                self.images[self.anim_i].y = y
            end
            
        end,
        
        
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




enemies =
{

	basic_fighter = function(color) return {
		num   = nil,    --number of fighters in formation
		index = nil,    --number of this fighter in its formation,
        salvage_func   = {"enemies","basic_fighter"},
        overwrite_vars = {},
        setup_params   = {},
        salvage_params = { color },
		
		type = TYPE_ENEMY_PLANE,
		
		stage  = 0,     --the current stage the fighter is in
		stages = {},    --the stages, must be set by formations{}
		approach_speed = 300,
		attack_speed   = 120,
		
		--graphics for the fighter
		num_prop_frames = 0,
		frame_index = 1,
		image  = Clone{source=color},
		prop   = {},
		group  = Group{anchor_point = {curr_lvl_imgs.fighter.w/2,curr_lvl_imgs.fighter.h/2}},
		
		shoot_time      = 3,	--how frequently the plane shoots
		last_shot_time = 3,--math.random()*2,	--how long ago the plane last shot
		deg_counter = {},
        
		fire = function(f,secs)
			f.last_shot_time = f.last_shot_time + secs
				
			if f.last_shot_time >= f.shoot_time then
				f.last_shot_time = 0
				fire_bullet(f,curr_lvl_imgs.fighter_bullet)
			end
		end,
		remove = function(self)
            self.group:unparent()
        end,
		setup = function(self)
			self.num_prop_frames=#curr_lvl_imgs.fighter_prop
            for i = 1, self.num_prop_frames do
                self.prop[i] = Clone{source = curr_lvl_imgs.fighter_prop[i],opacity=0,x=self.image.w/2,y=self.image.h-curr_lvl_imgs.fighter_prop[i].h/2}
                self.prop[i].anchor_point={self.prop[i].w/2,self.prop[i].h/2}
                self.group:add(self.prop[i])
            end
            self.prop[1].opacity=255
			self.group:add( self.image )
			
			layers.planes:add( self.group )
			
			--default fighter animation
			self.stages[0] = function(f,seconds)
				
				--fly downwards

				f.group.y = f.group.y +f.attack_speed*seconds

				f:fire(seconds)
				
				--see if you reached the end
				if f.group.y >= screen_h + self.image.h then
					self.group:unparent()
					remove_from_render_list(self)
				end
			end
			
            if type(self.overwrite_vars) == "table"  then
                recurse_and_apply(  self, self.overwrite_vars  )
            end
		end,
		
		render = function(self,seconds)
			--animate the propeller
            self.prop[self.frame_index].opacity=0
			self.frame_index = self.frame_index%
				self.num_prop_frames + 1
            self.prop[self.frame_index].opacity=255
			
				
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
            
		end,
		salvage = function( self, salvage_list )
            
            s = {
                func         = {},
                table_params = {},
                setup_params = {},
            }
            
            
            for i = 1, #self.salvage_params do
                s.table_params[i] = self.salvage_params[i]
            end
            for i = 1, #self.setup_params do
                s.setup_params[i] = self.setup_params[i]
            end
            for i = 1, #self.salvage_func do
                s.func[i] = self.salvage_func[i]
            end
            table.insert(s.table_params,{
                prop_index     = self.prop_index,
                stage          = self.stage,
                last_shot_time = self.last_shot_time,
                deg_counter    = {},
                group = {
                    x = self.group.x,
                    y = self.group.y,
                    z_rotation = {self.group.z_rotation[1],0,0}
                },
            })
            for i = 1, #self.deg_counter do
                s.table_params[#s.table_params].deg_counter[i] = self.deg_counter[i]
            end
            table.insert(s.table_params,self.index)
            return s
        end,
        collision = function( self , other )
            self.group:unparent()
            remove_from_render_list( self )
            state.counters[1].fighters.killed = state.counters[1].fighters.killed + 1
            -- Explode
            add_to_render_list(
                explosions.small(
                self.group.center[1],
                self.group.center[2])
			)
            points(self.group.x,self.group.y,50)
		end	
	} end,
	zeppelin  = function(x,o)
        local z = {
        salvage_func = {"enemies","zeppelin"},
        overwrite_vars = o or {},
        setup_params = {},
        salvage_params = { x },
		health = 20,
		type = TYPE_ENEMY_PLANE,
        bulletholes = {},
		
		stage  = 0,	--the current stage the fighter is in
		stages = {},	--the stages, must be set by formations{}
		approach_speed = 40,
		attack_speed   = 15,
		drop_speed = .3,
        turn_speed = 8,
		
		num_prop_frames = 3,
		prop_index = 1,
		image    = Clone{source=curr_lvl_imgs.zepp},
        
        e_fire_l_i = 0,
        e_fire_r_i = 0,
        
        e_fire_r = Clone{ source=curr_lvl_imgs.engine_fire, opacity=0,position={185,260} },
        e_r_dam  = Clone{ source=curr_lvl_imgs.z_d_e,       opacity=0,position={185,260} },
        e_fire_l = Clone{ source=curr_lvl_imgs.engine_fire, opacity=0,position={ 22,260} },
        e_l_dam  = Clone{ source=curr_lvl_imgs.z_d_e,       opacity=0,position={ 22,260} },
        
        --e_fire_r_g = Group{position={185,260},clip={0,0,curr_lvl_imgs.engine_fire.w/6,curr_lvl_imgs.engine_fire.h}},
        --e_fire_l_g = Group{position={ 22,260},clip={0,0,curr_lvl_imgs.engine_fire.w/6,curr_lvl_imgs.engine_fire.h}},
        
        right_engine_dam = 0,
        left_engine_dam = 0,
		
		is_boss = false,
		
		prop =
		{
			l = {},--Clone{source=curr_lvl_imgs.zepp_prop},
			r = {},--Clone{source=curr_lvl_imgs.zepp_prop},
            --[[
			g_l = Group
			{
				clip =
				{
					0,
					0,
					curr_lvl_imgs.zepp_prop.w ,
					--self.num_prop_frames still DNE 
					curr_lvl_imgs.zepp_prop.h/3,
				},
				--anchor_point = {curr_lvl_imgs.zepp_prop.w/2,
				--                curr_lvl_imgs.zepp_prop.h/2},
				position     = {16,252},
			},
			g_r = Group
			{
				clip =
				{
					0,
					0,
					curr_lvl_imgs.zepp_prop.w ,
					--self.num_prop_frames still DNE 
					curr_lvl_imgs.zepp_prop.h/3,
				},
				--anchor_point = {curr_lvl_imgs.zepp_prop.w/2,
				--                curr_lvl_imgs.zepp_prop.h/2},
				position     = {180,252},
			},
            --]]
		},
		
		guns =
		{
			
			l = Clone
			{
				source       = curr_lvl_imgs.z_barrel,
				anchor_point = {0,curr_lvl_imgs.z_barrel.h/2},
				z_rotation   = {90,0,0},
                x =  56,
				y = 135,
			},
			
			r = Clone
			{
				source       = curr_lvl_imgs.z_barrel,
				anchor_point = {0,curr_lvl_imgs.z_barrel.h/2},
				z_rotation   = {90,0,0},
                x = 182,
				y = 135,
			},
			--[[
			g_l = Group
			{
				x =  56,
				y = 130,
			},
			
			g_r = Group
			{
				x = 182,
				y = 130,
			},--]]
		},
        dam = {},
		
		group    = Group{x=x,y=-curr_lvl_imgs.zepp.h},
		
		shoot_time      = 2,	--how frequently the plane shoots
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
				x = (my_plane.group.x+my_plane.img_w/2), 
				y = (my_plane.group.y+my_plane.img_h/2)
			}
			local zepp =
			{
				r =
				{ --absolute position of the zeppelin's right gun
					x = (self.guns.r.x+self.group.x-self.group.anchor_point[1]),
					y = (self.guns.r.y+self.group.y-self.group.anchor_point[2])
				},
				l =
				{ --absolute position of the zeppelin's left gun
					x = (self.guns.l.x+self.group.x-
						self.group.anchor_point[1]),
					y = (self.guns.l.y+self.group.y-
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
					fire_bullet(mock_obj,curr_lvl_imgs.z_bullet)
					
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
					fire_bullet(mock_obj,curr_lvl_imgs.z_bullet)
					
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
						
						fire_bullet(mock_obj,curr_lvl_imgs.z_bullet)
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
						fire_bullet(mock_obj,curr_lvl_imgs.z_bullet)
						
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
		    	                        
						fire_bullet(mock_obj,curr_lvl_imgs.z_bullet)
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
						fire_bullet(mock_obj,curr_lvl_imgs.z_bullet)
						
					end
				end
			end
			--]]
		end,
		
        fire_thresh = .1,
        fire_r = 0,
        fire_l = 0,
        
        speed_x = 0,
        speed_x_cap = 20,
		
		remove = function(self)
            self.group:unparent()
            if self.is_boss then
                levels[state.curr_level]:level_complete()
            end
        end,
		setup = function(self)
            state.counters[1].zepp.spawned = state.counters[1].zepp.spawned + 1
			--self.e_fire_l_g:add(self.e_l_dam, self.e_fire_l)
            --self.e_fire_r_g:add(self.e_r_dam, self.e_fire_r)
			--self.prop.g_l:add( self.prop.l )
			--self.prop.g_r:add( self.prop.r )
			
            self.num_prop_frames = #curr_lvl_imgs.zepp_prop
            for i = 1,self.num_prop_frames do
                self.prop.l[i] = Clone{source=curr_lvl_imgs.zepp_prop[i],position = { 16,252},opacity=0}
                self.prop.r[i] = Clone{source=curr_lvl_imgs.zepp_prop[i],position = {180,252},opacity=0}
                --self.prop.l[i].anchor_point = {curr_lvl_imgs.zepp_prop[i].w/2,curr_lvl_imgs.zepp_prop[i].h/2}
                --self.prop.r[i].anchor_point = {curr_lvl_imgs.zepp_prop[i].w/2,curr_lvl_imgs.zepp_prop[i].h/2}
            end
            
            self.prop.l[1].opacity=255
            self.prop.r[1].opacity=255
            --[[
			self.guns.g_l:add( self.guns.l,
            Clone{
                source=curr_lvl_imgs.z_cannon_l,
                x = -curr_lvl_imgs.z_cannon_l.w+8,
                y = -curr_lvl_imgs.z_cannon_l.h/2
            } )
			self.guns.g_r:add( self.guns.r,
            Clone{
                source=curr_lvl_imgs.z_cannon_r,
                x=-2,
                y = -curr_lvl_imgs.z_cannon_l.h/2
            } )
            --]]
			self.group:add(unpack(self.prop.l))
            self.group:add(unpack(self.prop.r))
			self.group:add(
				
                self.guns.l,
				self.guns.r,
				self.image,
				
                self.e_l_dam,
				self.e_r_dam
                
				
				
                --self.e_fire_l_g,
                --self.e_fire_r_g
			)
			
			layers.air_doodads_1:add( self.group )
			
			
			--default zeppelin animation
			self.stages =
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
                    if not self.dying then
                        z:rotate_guns_and_fire(secs)
                    end
                    --check if it left the screen
                    if z.group.y >= screen_h  then
                        z.group:unparent()
                        remove_from_render_list(z)
                        
                    end
                end,
                function(self,secs)
                    move(self.group,80,secs)
                    local scale = self.group.scale[1] - self.drop_speed * secs
                    self.group.scale={scale,scale}
                    --self.group.x_rotation={self.group.x_rotation[1]+self.turn_speed*secs,0,0}
                    if scale <= .1 then
                        self.group:unparent()
                        remove_from_render_list(self)
                        add_to_render_list(
                        explosions.splash(
                            self.group.x,
                            self.group.y
                        )
                        )
                        add_to_render_list(
                            {
                                group = Group{x=self.group.x,y=self.group.y},
                                pieces = {},
                                setup = function(self)
                                    self.pieces[1] = Clone{source=curr_lvl_imgs.z_debris_1,x= 10,y= 20}
                                    self.pieces[2] = Clone{source=curr_lvl_imgs.z_debris_2,x=-30,y= 5}
                                    self.pieces[3] = Clone{source=curr_lvl_imgs.z_debris_3,x= 0, y=-40}
                                    self.group:add(unpack(self.pieces))
                                    layers.land_doodads_1:add(self.group)
                                end,
                                render = function(self,seconds)
                                    self.group.y = self.group.y + 50*seconds
                                    if self.group.y > screen_h+100 then
                                        remove_from_render_list(self)
                                    end
                                end,
                                remove = function(self,seconds)
                                    self.group:unparent()
                                    self.group:clear()
                                end,

                            }
                        )
                        
                        
                        
                        --[[
                        if self.is_boss then
                            levels[state.curr_level]:level_complete()
                        end
                        --]]
                        points(self.group.x,self.group.y,200)
                    end
                end,
            }
            self.stage = 1
            if type(self.overwrite_vars) == "table"  then
                recurse_and_apply(  self, self.overwrite_vars  )
            end
			
            for iii = 1,#self.dam do
                self.group:add(Clone
                    {
                        source = curr_lvl_imgs["z_d_"..self.dam[iii].i],
                        x = self.dam[iii].x,
                        y = self.dam[iii].y
                    }
                )
            end
            if      self.left_engine_dam == 1 then
                    self.e_l_dam.opacity  = 255
            elseif  self.left_engine_dam == 2 then
                    self.e_l_dam.opacity  = 255
                    self.e_fire_l.opacity = 255
            end
            if      self.right_engine_dam == 1 then
                    self.e_r_dam.opacity   = 255
            elseif  self.right_engine_dam == 2 then
                    self.e_r_dam.opacity   = 255
                    self.e_fire_r.opacity  = 255
            end 
		end,
		
        
        
        dying = false,
        
		render = function(self,seconds)
            --[[
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
            --]]
			--animate the propellers
            
            self.prop.l[self.prop_index].opacity=0
            self.prop.r[self.prop_index].opacity=0
			self.prop_index = self.prop_index%
				self.num_prop_frames + 1
			self.prop.l[self.prop_index].opacity=255
            self.prop.r[self.prop_index].opacity=255
			
				---[[
            if self.right_engine_dam > 2 and self.left_engine_dam > 2 then
                --self.prop.g_r.y = self.prop.g_r.y - 500*seconds
                --self.prop.g_r.x = self.prop.g_r.x + 200*seconds
                --self.prop.g_l.y = self.prop.g_l.y - 500*seconds
                --self.prop.g_l.x = self.prop.g_l.x - 200*seconds
                self.group.y = self.group.y + self.approach_speed*seconds
            elseif self.right_engine_dam > 2 then
                self.speed_x = self.speed_x + 2*seconds
                if self.speed_x > 20 then
                    self.speed_x = 20
                end
                self.group.x = self.group.x + self.speed_x*seconds
                self.group.y = self.group.y + self.approach_speed*seconds
                --self.prop.g_r.y = self.prop.g_r.y - 500*seconds
                --self.prop.g_r.x = self.prop.g_r.x + 200*seconds

            elseif self.left_engine_dam > 2 then
                self.speed_x = self.speed_x + 2*seconds
                if self.speed_x > 20 then
                    self.speed_x = 20
                end
                self.group.x = self.group.x - self.speed_x*seconds
                --self.prop.g_l.y = self.prop.g_l.y - 500*seconds
                --self.prop.g_l.x = self.prop.g_l.x - 200*seconds
                
            end--]]
                --animate the zeppelin based on the current stage
                self.stages[self.stage](self,seconds)
            if not self.dying then
                table.insert(b_guys_air,
                    {
                        obj = self,
                        x1  = self.group.x+self.guns.l.x+3*self.guns.l.w/4,
                        x2  = self.group.x+self.guns.r.x-3*self.guns.l.w/4-5,
                        y1  = self.group.y+80,
                        y2  = self.group.y+self.image.h-70,
                        p   = 0,
                    }
                )
                
                
                table.insert(b_guys_air,
                    {
                        obj = self,
                        x1  = self.group.x+16,
                        x2  = self.group.x+16+self.prop.l[1].w,
                        y1  = self.group.y+252,
                        y2  = self.group.y+260+self.prop.l[1].h,
                        p   = 1,
                    }
                )
                
                table.insert(b_guys_air,
                    {
                        obj = self,
                        x1  = self.group.x+180,
                        x2  = self.group.x+180+self.prop.r[1].w,
                        y1  = self.group.y+252,
                        y2  = self.group.y+252+self.prop.r[1].h,
                        p   = 2,
                    }
                )
            end
		end,
		salvage = function( self, salvage_list )
            
            s = {
                func         = {},
                table_params = {},
            }
            
            
            for i = 1, #self.salvage_params do
                s.table_params[i] = self.salvage_params[i]
            end

            for i = 1, #self.salvage_func do
                s.func[i] = self.salvage_func[i]
            end
            table.insert(s.table_params,{
                is_boss  = self.is_boss,
                right_engine_dam = self.right_engine_dam,
                left_engine_dam  = self.left_engine_dam,
                fire_r = self.fire_r,
                fire_l = self.fire_l,
                e_fire_l_i     = self.e_fire_l_i,
                e_fire_r_i     = self.e_fire_r_i,
                health         = self.health,
                prop_index     = self.prop_index,
                stage          = self.stage,
                last_shot_time = self.last_shot_time,
                speed_x        = self.speed_x,
                group = {
                    x = self.group.x,
                    y = self.group.y,
                },--[[
                prop = {
                    g_r = {
                        y = self.prop.g_r.y,
                        x = self.prop.g_r.x
                    },
                    g_l = {
                        y = self.prop.g_l.y,
                        x = self.prop.g_l.x
                    }
                },--]]
                dam = {}
            })
            for i = 1,#self.dam do
                s.table_params[#s.table_params].dam[i] = {}
                s.table_params[#s.table_params].dam[i].x = self.dam[i].x
                s.table_params[#s.table_params].dam[i].y = self.dam[i].y
                s.table_params[#s.table_params].dam[i].i = self.dam[i].i
            end
            return s
        end,
        
        
        collision = function( self , other, loc, from_bullethole )
			if self.health > 1 then 
				self.health = self.health - 1
                if from_bullethole == nil then
                local dam = {}
                if other.group ~= nil then
                    if loc == 0 then
                        local i =math.random(1,7)
                        dam.image = Clone{source = curr_lvl_imgs["z_d_"..i]}
                        self.group:add(dam.image)
                        dam.image.x = other.group.x - self.group.x
                        dam.image.y = other.group.y - self.group.y - math.random(0,80)
                        if dam.image.x < self.guns.l.x+3*self.guns.l.w/4 then
                            dam.image.x = self.guns.l.x+3*self.guns.l.w/4+20
                        elseif dam.image.x > self.guns.r.x-3*self.guns.l.w/4-5 then
                            dam.image.x = self.guns.r.x-3*self.guns.l.w/4-20
                        end
                        if dam.image.y < 80 then
                            dam.image.y = 80
                        elseif dam.image.y > self.image.h-70 then
                            dam.image.y = self.image.h-70
                        end
                        table.insert(self.dam, {i=i,x=dam.image.x,y=dam.image.y})
                    elseif loc == 1 then
                        self.left_engine_dam = self.left_engine_dam + 1
                        if self.left_engine_dam == 1 then
                            self.e_l_dam.opacity = 255
                        elseif self.left_engine_dam == 2 then
                            self.e_fire_l.opacity = 255
                        elseif self.left_engine_dam == 3 then
                            self.num_prop_frames = #curr_lvl_imgs.zepp_br_prop
                            for i = 1,self.num_prop_frames do
                                self.prop.l[i]:unparent()
                                self.prop.l[i] = Clone{source=curr_lvl_imgs.zepp_br_prop[i],position = { 16,252},opacity=0,anchor_point={-curr_lvl_imgs.zepp_br_prop[i].w/2,curr_lvl_imgs.zepp_br_prop[i].h/2}}
                                self.group:add(self.prop.l[i])
                            end
                        --[[
                            self.prop.g_l.clip = {
                                curr_lvl_imgs.zepp_prop.w/3,
                                self.prop.g_l.clip[2],
                                curr_lvl_imgs.zepp_prop.w/3,
                                self.prop.g_l.clip[4]
                            }
                            add_to_render_list(
                            {
                                image = Clone{source=curr_lvl_imgs.z_br_prop_1},
                                group = Group{clip={0,0,curr_lvl_imgs.z_br_prop_1.w,curr_lvl_imgs.z_br_prop_1.h/3},
                                    x= self.group.x+16,y= self.group.y+252},
                                pieces = {},
                                setup = function(self)
                                    self.group:add(self.image)
                                    layers.air_doodads_1:add(self.group)
                                end,
                                render = function(self,seconds)
                                    self.group.y = self.group.y - 200*seconds
                                    self.group.x = self.group.x - 500*seconds
                                    if self.group.y < -100 or self.group.x < -100  then
                                        remove_from_render_list(self)
                                    end
                                end,
                                remove = function(self,seconds)
                                    self.group:unparent()
                                end,
                            }
                            )--]]
                        end
                        self.attack_speed = self.approach_speed
                    elseif loc == 2 then
                        self.right_engine_dam = self.right_engine_dam + 1
                        if self.right_engine_dam == 1 then
                            self.e_r_dam.opacity = 255
                        elseif self.right_engine_dam == 2 then
                            self.e_fire_r.opacity = 255
                        elseif self.right_engine_dam == 3 then
                            self.num_prop_frames = #curr_lvl_imgs.zepp_br_prop
                            for i = 1,self.num_prop_frames do
                                self.prop.r[i]:unparent()
                                self.prop.r[i] = Clone{source=curr_lvl_imgs.zepp_br_prop[i],position = {180,252},opacity=0,anchor_point={-curr_lvl_imgs.zepp_br_prop[i].w/2,-curr_lvl_imgs.zepp_br_prop[i].h/2}}
                                self.group:add(self.prop.r[i])
                            end
                            --[[self.prop.g_r.clip = {
                                curr_lvl_imgs.zepp_prop.w/3,
                                self.prop.g_r.clip[2],
                                curr_lvl_imgs.zepp_prop.w/3,
                                self.prop.g_r.clip[4]
                            }
                            add_to_render_list(
                            {
                                image = Clone{source=curr_lvl_imgs.z_br_prop_1},
                                group = Group{clip={0,0,curr_lvl_imgs.z_br_prop_1.w,curr_lvl_imgs.z_br_prop_1.h/3},
                                    x= self.group.x+180,y= self.group.y+252},
                                pieces = {},
                                setup = function(self)
                                    self.group:add(self.image)
                                    layers.air_doodads_1:add(self.group)
                                end,
                                render = function(self,seconds)
                                    self.group.y = self.group.y - 200*seconds
                                    self.group.x = self.group.x + 500*seconds
                                    if self.group.y < -100 or self.group.x < -100  then
                                        remove_from_render_list(self)
                                    end
                                end,
                                remove = function(self,seconds)
                                    self.group:unparent()
                                end,

                            }
                            )--]]
                        end
                        self.attack_speed = self.approach_speed
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
                        
                        d.image = Clone{source = curr_lvl_imgs["z_d_"..math.random(5,7)]}
                        d.image.x = x
                        d.image.y = y-4
                        self.group:add(dam.image)
                        self:collision(other,true)
                    end
                    --]]
                elseif other.image ~= nil then
                    
                    if loc == 0 then
                        local i = math.random(1,7)
                        dam.image = Clone{source = curr_lvl_imgs["z_d_"..i]}
                        self.group:add(dam.image)
                        dam.image.x = other.image.x - self.group.x
                        dam.image.y = other.image.y - self.group.y - math.random(0,80)
                        table.insert(self.dam, {i=i,x=dam.image.x,y=dam.image.y})
                    elseif loc == 1 then
                        self.left_engine_dam = self.left_engine_dam + 1
                        if self.left_engine_dam == 1 then
                            self.e_l_dam.opacity = 255
                        elseif self.left_engine_dam == 2 then
                            self.e_fire_l.opacity = 255
                        elseif self.left_engine_dam == 3 then
                            self.num_prop_frames = #curr_lvl_imgs.zepp_br_prop
                            for i = 1,self.num_prop_frames do
                                self.prop.l[i]:unparent()
                                self.prop.l[i] = Clone{source=curr_lvl_imgs.zepp_br_prop[i],position = { 16,252},opacity=0,anchor_point={-curr_lvl_imgs.zepp_br_prop[i].w/2,-curr_lvl_imgs.zepp_br_prop[i].h/2}}
                                self.group:add(self.prop.l[i])
                            end
                            --[[self.prop.g_l.clip = {
                                curr_lvl_imgs.zepp_prop.w/3,
                                self.prop.g_l.clip[2],
                                curr_lvl_imgs.zepp_prop.w/3,
                                self.prop.g_l.clip[4]
                            }
                            add_to_render_list(
                            {
                                image = Clone{source=curr_lvl_imgs.z_br_prop_1},
                                group = Group{clip={0,0,curr_lvl_imgs.z_br_prop_1.w,curr_lvl_imgs.z_br_prop_1.h/3},
                                    x= self.group.x+16,y= self.group.y+252},
                                pieces = {},
                                setup = function(self)
                                    self.group:add(self.image)
                                    layers.air_doodads_1:add(self.group)
                                end,
                                render = function(self,seconds)
                                    self.group.y = self.group.y - 200*seconds
                                    self.group.x = self.group.x - 500*seconds
                                    if self.group.y < -100 or self.group.x < -100  then
                                        remove_from_render_list(self)
                                    end
                                end,
                                remove = function(self,seconds)
                                    self.group:unparent()
                                end,

                            }
                        )--]]
                        end
                        self.attack_speed = self.approach_speed
                    elseif loc == 2 then
                        self.right_engine_dam = self.right_engine_dam + 1
                        if self.right_engine_dam == 1 then
                            self.e_r_dam.opacity = 255
                        elseif self.right_engine_dam == 2 then
                            self.e_fire_r.opacity = 255
                        elseif self.right_engine_dam == 3 then
                            self.num_prop_frames = #curr_lvl_imgs.zepp_br_prop
                            for i = 1,self.num_prop_frames do
                                self.prop.r[i]:unparent()
                                self.prop.r[i] = Clone{source=curr_lvl_imgs.zepp_br_prop[i],position = { 16,252},opacity=0,anchor_point={-curr_lvl_imgs.zepp_br_prop[i].w/2,-curr_lvl_imgs.zepp_br_prop[i].h/2}}
                                self.group:add(self.prop.r[i])
                            end
                            --[[self.prop.g_r.clip = {
                                curr_lvl_imgs.zepp_prop.w/3,
                                self.prop.g_r.clip[2],
                                curr_lvl_imgs.zepp_prop.w/3,
                                self.prop.g_r.clip[4]
                            }
                            add_to_render_list(
                            {
                                image = Clone{source=curr_lvl_imgs.z_br_prop_1},
                                group = Group{clip={0,0,curr_lvl_imgs.z_br_prop_1.w,curr_lvl_imgs.z_br_prop_1.h/3},
                                    x= self.group.x+180,y= self.group.y+252},
                                pieces = {},
                                setup = function(self)
                                    self.group:add(self.image)
                                    layers.air_doodads_1:add(self.group)
                                end,
                                render = function(self,seconds)
                                    self.group.y = self.group.y - 200*seconds
                                    self.group.x = self.group.x + 500*seconds
                                    if self.group.y < -100 or self.group.x < -100  then
                                        remove_from_render_list(self)
                                    end
                                end,
                                remove = function(self,seconds)
                                    self.group:unparent()
                                end,

                            }
                            )--]]
                        end
                        self.attack_speed = self.approach_speed
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
                        
                        d.image = Clone{source = curr_lvl_imgs["z_d_"..math.random(5,7)]}
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
			
            
            state.counters[1].zepp.killed = state.counters[1].zepp.killed + 1
            
			--self.group:unparent()
			--remove_from_render_list( self )
            self.dying = true
            self.stage = #self.stages
                        
			-- Explode
            add_to_render_list(
			explosions.big(
			self.group.x+curr_lvl_imgs.zepp.w/2,
			self.group.y+curr_lvl_imgs.zepp.h/2+70)
			)
		end	
	}
        add_to_render_list(z)
        return z
    end,
    
    turret = function(xxx,y_offset,o) 
        local t = {
		type = TYPE_ENEMY_PLANE,
		salvage_func = {"enemies","turret"},
        salvage_params = {xxx,y_offset},
		stage  = 0,	--the current stage the fighter is in
		stages = {},	--the stages, must be set by formations{}
		approach_speed = 80,
		last_shot_time = math.random()*4,
        shoot_time = 4,
		image = Clone
        {
            source       = curr_lvl_imgs.turret,
			anchor_point = {curr_lvl_imgs.turret.w/2,curr_lvl_imgs.turret.h/3},
			z_rotation   = {180,0,0}
        },
			
		group = Group{},
		remove = function(self)
            self.group:unparent()
        end,
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
				x = (my_plane.group.x+my_plane.img_w/2), 
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
						x = self.group.x,--+self.img_h*math.cos(self.image.z_rotation[1]*math.pi/180+90),
						y = self.group.y--+self.img_h*math.sin(self.image.z_rotation[1]*math.pi/180+90)
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
        setup = function(self)
			
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
            
            if type(o) == "table"  then
                recurse_and_apply(  self, o  )
            end
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
            points(self.group.x,self.group.y,100)
		end,
        salvage = function( self, salvage_list )
            
            s = {
                func         = {},
                table_params = {},
            }
            
            for i = 1, #self.salvage_params do
                s.table_params[i] = self.salvage_params[i]
            end
            
            for i = 1, #self.salvage_func do
                s.func[i] = self.salvage_func[i]
            end
            
            table.insert(s.table_params,{
                stage          = self.stage,
                last_shot_time = self.last_shot_time,
                image  = {
                    z_rotation = {self.image.z_rotation[1],0,0},
                },
                group = {
                    x = self.group.x,
                    y = self.group.y,
                },
                
            })
            
            return s
        end,
    }
    add_to_render_list(t)
    return t
    end,
    
    trench = function(xxx,o) add_to_render_list({
		type = TYPE_ENEMY_PLANE,
		
		stage  = 0,	--the current stage the fighter is in
		stages = {},	--the stages, must be set by formations{}
		approach_speed = 80,
		last_shot_time = 4,
        shoot_time = 2,
        dead = false,
		image = Clone
        {
            source       = curr_lvl_imgs.trench_gun,
			anchor_point = {curr_lvl_imgs.trench_gun.w/2,curr_lvl_imgs.trench_gun.h/3},
			--z_rotation   = {180,0,0}
        },
			
		
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
				x = my_plane.group.x,--+my_plane.img_w/2, 
				y = my_plane.group.y--+my_plane.img_h/2
			}
			local me =
            {
                x = self.image.x,--self.image.anchor_point[1],
				y = self.image.y+self.image.anchor_point[2]
			}
			self.last_shot_time = self.last_shot_time + secs
            --rotate and fire the turret
            if me.y < screen_h + self.img_h and
               me.y >           -self.img_h then
                
                
                
				if self.last_shot_time >= self.shoot_time and  (math.abs(me.x - targ.x) < 200 and
                    targ.y - me.y > 300) then
					
                    local mock_obj =
                    {
                        group =
                        {
                            z_rotation =
                            {0,--self.image.z_rotation[1],
                                0,0},
                            x = self.image.x, -- curr_lvl_imgs.trench_gun.w/2,--+self.img_h*math.cos(self.image.z_rotation[1]*math.pi/180+90),
                            y = me.y--+self.img_h*math.sin(self.image.z_rotation[1]*math.pi/180+90)
                        }
                    }
					self.last_shot_time = 0
					fire_mortar(mock_obj, targ.x-me.x, targ.y-me.y)
					
				end
            end
			
		end,
        setup = function(self)
			
            self.image.x =  xxx
            self.image.y = -173
			
			layers.land_targets:add( self.image )
			
			
			--default battleship animation animation
			self.stages[0] = function(t,seconds)
				--fly downwards
				t.image.y = t.image.y +self.approach_speed*seconds
				
				--fire bullets
                if not self.dead then
                    t:rotate_guns_and_fire(seconds)
				end
				--see if you reached the end
				if t.image.y >= screen_h + t.image.h then
					t.image:unparent()
					remove_from_render_list(t)
				end
			end
			
            
            self.img_h = self.image.h
            if type(o) == "table"  then
                recurse_and_apply(  self, o  )
            end
            if self.dead then
                local c = Clone{
                    source     = curr_lvl_imgs.trench_crater,
                    x          =  self.image.x,
                    y          =  self.image.y+17,
                    anchor_point = {curr_lvl_imgs.trench_crater.w/2,curr_lvl_imgs.trench_crater.h/2}
                }
                layers.land_targets:add(c)
                self.image:unparent()
                self.image = c
            end
		end,
		
		render = function(self,seconds)
				
            
			--animate the zeppelin based on the current stage
			self.stages[self.stage](self,seconds)
            if self.image == nil then return end
            
            if not self.dead then
                table.insert(b_guys_land,
                    {
                        obj = self,
                        x1  = self.image.x-self.image.w/2,
                        x2  = self.image.x+self.image.w/2,
                        y1  = self.image.y-self.image.h/2,
                        y2  = self.image.y+self.image.h/2,
                    }
                )
            end
		end,
		---[[
        remove = function( self )
            self.image:unparent()
            self.image = nil
        end,
        --]]
        collision = function( self , other )
            
            local c = Clone{
                source     = curr_lvl_imgs.trench_crater,
                x          =  self.image.x,
                y          =  self.image.y+17,
                anchor_point = {curr_lvl_imgs.trench_crater.w/2,curr_lvl_imgs.trench_crater.h/2}
            }
            layers.land_targets:add(c)
            self.image:unparent()
            self.image = c
            self.dead = true
            
            
			-- Explode
            add_to_render_list(
                explosions.small(
                    self.image.x,
                    self.image.y
                )
			)
            points(self.image.x,self.image.y,100)
		end,
        
        
        salvage_func = {"enemies","trench"},
        salvage_params = {xxx},---[[
        salvage = function( self, salvage_list )
            
            s = {
                func         = {},
                table_params = {},
            }
            for i = 1, #self.salvage_func do
                s.func[i] = self.salvage_func[i]
            end
            
            for i = 1, #self.salvage_params do
                s.table_params[i] = self.salvage_params[i]
            end
            
            
            table.insert(s.table_params,{
                last_shot_time = self.last_shot_time,
                stage          = self.stage,
                dead = self.dead,
                image = {
                    y = self.image.y,
                }
            })
            table.insert(s.table_params,self.index)
            return s
        end,
        
    }) end,
    
    
    big_tank = function(m) return{
		type = TYPE_ENEMY_PLANE,
		
		stage  = 0,	--the current stage the fighter is in
		stages = {},	--the stages, must be set by formations{}
		approach_speed = 80,
		last_shot_time = 4,
        shoot_time     = 2,
		image = Clone
        {
            source       =  curr_lvl_imgs.tank_turret,
			anchor_point = {curr_lvl_imgs.tank_turret.w/2,curr_lvl_imgs.tank_turret.h/3},
            position     = {curr_lvl_imgs.tank_strip.w/6,curr_lvl_imgs.tank_strip.h/2},
        },
        base_strip = Clone
        {
            source    = curr_lvl_imgs.tank_strip
        },
        num_frames = 3,
		base_clip = Group{--[[clip={0,0,curr_lvl_imgs.tank_strip.w/3,curr_lvl_imgs.tank_strip.h}--]]},
		group = Group{scale={1.5,1.5}},
		
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
				x = (my_plane.group.x+my_plane.img_w/2), 
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
					fire_big_flak(mock_obj, math.abs(me.x - targ.x)-50, math.abs(me.y - targ.y)-50)
					
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
					t.group:unparent()
					remove_from_render_list(t)
				end
			end
			
            
            self.img_h = self.image.h
		end,
		
        strip_thresh = .1,
        strip_time = 0,
        strip_i = 1,
        moving = m,
        
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
    
    
    
    tank = function(m,xxx,y_offset,o)
        local t = {
        
		type = TYPE_ENEMY_PLANE,
		
		stage  = 0,	--the current stage the fighter is in
		stages = {},	--the stages, must be set by formations{}
		approach_speed = 80,
		last_shot_time = 4,
        shoot_time     = 4,
		image = Clone
        {
            source       =  curr_lvl_imgs.tank_turret,
			anchor_point = {curr_lvl_imgs.tank_turret.w/2,curr_lvl_imgs.tank_turret.h/3},
            position     = {curr_lvl_imgs.tank_base[1].w/2,curr_lvl_imgs.tank_base[1].h/2},
        },
        images = {},
        num_frames = 3,
		--base_clip = Group{clip={0,0,curr_lvl_imgs.tank_strip.w/3,curr_lvl_imgs.tank_strip.h}},
		group = Group{name="tank"},
		remove = function(self)
            self.group:unparent()
        end,
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
				x = (my_plane.group.x+my_plane.img_w/2), 
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
						x = self.group.x,--+self.image.x+self.img_h*math.cos(self.image.z_rotation[1]*math.pi/180+90),
						y = self.group.y--+self.image.y+self.img_h*math.sin(self.image.z_rotation[1]*math.pi/180+90)
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
        setup = function(self)
			self.num_frames = #curr_lvl_imgs.tank_base
            for i = 1,self.num_frames do
                self.images[i] = Clone{
                    source=curr_lvl_imgs.tank_base[i],
                    opacity=0,--[[
                    anchor_point={
                        curr_lvl_imgs.tank_base[i].w/2,
                        curr_lvl_imgs.tank_base[i].h/2
                    }--]]
                }
                self.group:add( self.images[i] )
            end
            self.images[1].opacity = 255
            self.index = 1
			self.group:add( self.image )
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
				if t.group.y >= screen_h + t.images[1].h then
					t.group:unparent()
					remove_from_render_list(t)
				end
			end
			
            
            self.img_h = self.image.h
            if type(o) == "table"  then
                recurse_and_apply(  self, o  )
            end
            --print("end setup",self)
		end,
		
        strip_thresh = .1,
        strip_time = 0,
        strip_i = 1,
        moving = m,
        
		render = function(self,seconds)
			--print("render",self,self.index,self.images,#self.images)
            if self.moving then
                self.strip_time = self.strip_time + seconds
                if self.strip_time > self.strip_thresh then
                    self.strip_time   = 0
                    self.images[self.index].opacity = 0
                    self.index      = self.index%self.num_frames + 1
                    self.images[self.index].opacity = 255
                end
            end
			--animate the tank based on the current stage
			self.stages[self.stage](self,seconds)
            
            
            
            table.insert(b_guys_land,
                {
                    obj = self,
                    x1  = self.group.x,
                    x2  = self.group.x+self.images[1].w,
                    y1  = self.group.y,
                    y2  = self.group.y+self.images[1].h,
                }
            )
		end,
		
        collision = function( self , other )
            
			self.group:unparent()
			remove_from_render_list( self )
            
			-- Explode
            add_to_render_list(
                explosions.small(
                    self.group.x+self.group.w/self.num_frames/2,
                    self.group.center[2],
                    "audio/turret-tank-exploding.mp3"
                )
			)
            points(self.group.x,self.group.y,200)
		end,
        
        salvage_func = {"enemies","tank"},
        salvage_params = {m,xxx,y_offset},---[[
        salvage = function( self, salvage_list )
            
            s = {
                func         = {},
                table_params = {},
            }
            for i = 1, #self.salvage_func do
                s.func[i] = self.salvage_func[i]
            end
            
            for i = 1, #self.salvage_params do
                s.table_params[i] = self.salvage_params[i]
            end
            
            
            table.insert(s.table_params,{
                stage          = self.stage,
                strip_time = self.strip_time,
                moving = self.moving,
                strip_i = self.strip_i,
                group = {
                    x = self.group.x,
                    y = self.group.y,
                    z_rotation = {self.group.z_rotation[1],0,0}
                },

            })
            
            table.insert(s.table_params,self.index)
            return s
        end,--]]
    }
        add_to_render_list(t)
        return t
    end,
        
    jeep = function(hor,xxx,y_offset,o) add_to_render_list({
		type = TYPE_ENEMY_PLANE,
		
		stage  = 0, --the current stage the fighter is in
		stages = {},--the stages, must be set by formations{}
		approach_speed = 300,
		last_shot_time = 4,
        shoot_time     = 2,
		images = {},
        --[[Clone
        {
            source       =  curr_lvl_imgs.jeep_b,
        },--]]
        
        num_frames = 3,
		group = Group{position = {xxx,y_offset},--[[clip={0,0,curr_lvl_imgs.jeep.w/3,curr_lvl_imgs.jeep.h}--]]},
		
        
        setup = function(self)
			self.group:add( self.image )
            --self.group.x = xxx
            --self.group.y = y_offset
            self.num_frames = #curr_lvl_imgs.jeep_b
			for i = 1,self.num_frames do
                self.images[i] = Clone{
                    source=curr_lvl_imgs.jeep_b[i],
                    
                    opacity=0,
                    --[[
                    anchor_point={
                        curr_lvl_imgs.tank_base[i].w/2,
                        curr_lvl_imgs.tank_base[i].h/2
                    }--]]
                }
                self.group:add( self.images[i] )
            end
            self.images[1].opacity = 255
            self.index = 1
			layers.land_targets:add( self.group )
			if hor then
                self.group.z_rotation = {90,0,0}
            end
			
			--default jeep animation
			self.stages[0] = function(t,seconds)
                if hor then
                    --move left
                    t.group.x = t.group.x -t.approach_speed*seconds
                    t.group.y = t.group.y +80*seconds
                else
                    --move downwards
                    t.group.y = t.group.y +t.approach_speed*seconds
				end
				
				--see if you reached the end
				if t.group.y >= screen_h + t.images[1].h then
					t.group:unparent()
					remove_from_render_list(t)
				end
			end
			
            
            self.img_h = self.images[1].h
            if type(o) == "table"  then
                recurse_and_apply(  self, o  )
            end
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
                    self.images[self.index].opacity = 0
                    self.index      = self.index%self.num_frames + 1
                    self.images[self.index].opacity = 255
                end
            end
			--animate the tank based on the current stage
			self.stages[self.stage](self,seconds)
            
            
            
            table.insert(b_guys_land,
                {
                    obj = self,
                    x1  = self.group.x,
                    x2  = self.group.x+self.images[1].w,
                    y1  = self.group.y,
                    y2  = self.group.y+self.images[1].h,
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
            points(self.group.x,self.group.y,1000)
		end,
        salvage_params = {hor,xxx,y_offset},
        salvage = function( self, salvage_list )
            
            s = {
                func         = {"enemies","jeep"},
                table_params = {},
            }
            
            
            for i = 1, #self.salvage_params do
                s.table_params[i] = self.salvage_params[i]
            end
            
            
            table.insert(s.table_params,{
                stage          = self.stage,
                strip_time = self.strip_time,
                moving = self.moving,
                strip_i = self.strip_i,
                group = {
                    x = self.group.x,
                    y = self.group.y,
                    z_rotation = {self.group.z_rotation[1],0,0}
                },

            })
            
            table.insert(s.table_params,self.index)
            return s
        end,
        
    }) end,
    battleship = function(xxx,y_offset,speed,moving,o)
        local b = {
        salvage_func = {"enemies","battleship"},
        salvage_params = {xxx,y_offset,speed,moving},
		health = 5,
		type = TYPE_ENEMY_PLANE,
        bulletholes = {},
        moving = false,
        
        bow_wake_r =
        {
            Clone{source=curr_lvl_imgs.bow_wake_1,opacity = 0,x=curr_lvl_imgs.b_ship.w/2-12},
            Clone{source=curr_lvl_imgs.bow_wake_2,opacity = 0,x=curr_lvl_imgs.b_ship.w/2-12},
            Clone{source=curr_lvl_imgs.bow_wake_3,opacity = 0,x=curr_lvl_imgs.b_ship.w/2-12},
            Clone{source=curr_lvl_imgs.bow_wake_4,opacity = 0,x=curr_lvl_imgs.b_ship.w/2-12},
            Clone{source=curr_lvl_imgs.bow_wake_5,opacity = 0,x=curr_lvl_imgs.b_ship.w/2-12},
            Clone{source=curr_lvl_imgs.bow_wake_6,opacity = 0,x=curr_lvl_imgs.b_ship.w/2-12},
            Clone{source=curr_lvl_imgs.bow_wake_7,opacity = 0,x=curr_lvl_imgs.b_ship.w/2-12},
            Clone{source=curr_lvl_imgs.bow_wake_8,opacity = 0,x=curr_lvl_imgs.b_ship.w/2-12},
        },
        bow_wake_t =
        {
            Clone{source=curr_lvl_imgs.bbow_wake_1,opacity = 0},
            Clone{source=curr_lvl_imgs.bbow_wake_2,opacity = 0},
            Clone{source=curr_lvl_imgs.bbow_wake_3,opacity = 0},
            Clone{source=curr_lvl_imgs.bbow_wake_4,opacity = 0},
        },
        bow_wake_l =
        {
            Clone{source=curr_lvl_imgs.bow_wake_1,opacity = 0,x=curr_lvl_imgs.b_ship.w/2+12,y_rotation={180,0,0}},
            Clone{source=curr_lvl_imgs.bow_wake_2,opacity = 0,x=curr_lvl_imgs.b_ship.w/2+12,y_rotation={180,0,0}},
            Clone{source=curr_lvl_imgs.bow_wake_3,opacity = 0,x=curr_lvl_imgs.b_ship.w/2+12,y_rotation={180,0,0}},
            Clone{source=curr_lvl_imgs.bow_wake_4,opacity = 0,x=curr_lvl_imgs.b_ship.w/2+12,y_rotation={180,0,0}},
            Clone{source=curr_lvl_imgs.bow_wake_5,opacity = 0,x=curr_lvl_imgs.b_ship.w/2+12,y_rotation={180,0,0}},
            Clone{source=curr_lvl_imgs.bow_wake_6,opacity = 0,x=curr_lvl_imgs.b_ship.w/2+12,y_rotation={180,0,0}},
            Clone{source=curr_lvl_imgs.bow_wake_7,opacity = 0,x=curr_lvl_imgs.b_ship.w/2+12,y_rotation={180,0,0}},
            Clone{source=curr_lvl_imgs.bow_wake_8,opacity = 0,x=curr_lvl_imgs.b_ship.w/2+12,y_rotation={180,0,0}},
        },
		b_w_i = 1,
        s_w_i = 1,
		stage  = 0,	--the current stage the fighter is in
		stages = {},	--the stages, must be set by formations{}
		approach_speed = 80,
		--attack_speed   = 15,
		
		image    = Clone{source=curr_lvl_imgs.b_ship},
		
		is_boss = false,
		
		
		guns =
		{
            bow = Clone
            {
                source       = curr_lvl_imgs.turret,
				anchor_point = {curr_lvl_imgs.turret.w/2,curr_lvl_imgs.turret.h/3},
				z_rotation   = {180,0,0}
            },
            mid = Clone
            {
                source       = curr_lvl_imgs.turret,
				anchor_point = {curr_lvl_imgs.turret.w/2,curr_lvl_imgs.turret.h/3},
				z_rotation   = {180,0,0}
            },
            stern = Clone
            {
                source       = curr_lvl_imgs.turret,
				anchor_point = {curr_lvl_imgs.turret.w/2,curr_lvl_imgs.turret.h/3},
				z_rotation   = {180,0,0}
            },
			
			g_b = Group
			{
				x = curr_lvl_imgs.b_ship.w/2,
				y = 130,
			},
			
			g_m = Group
			{
				x = curr_lvl_imgs.b_ship.w/2,
				y = 190,
			},
            g_s = Group
			{
				x = curr_lvl_imgs.b_ship.w/2,
				y = 410,
			},
		},
        
		group    = Group{},
		
		shoot_time      = 4 , --how frequently the ship shoots
		last_shot_time  =    --how long ago the ship last shot
        {
            b = 0,
            m = .5,
            s = 1
        },
        
		
		remove = function(self)
            self.group:unparent()
        end,
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
				x = (my_plane.group.x+my_plane.img_w/2), 
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
						x = b_ship.b.x,--+self.turr_h*math.cos(self.guns.bow.z_rotation[1]*math.pi/180+90),
						y = b_ship.b.y--+self.turr_h*math.sin(self.guns.bow.z_rotation[1]*math.pi/180+90)
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
						x = b_ship.m.x,--+self.turr_h*math.cos(self.guns.mid.z_rotation[1]*math.pi/180+90),
						y = b_ship.m.y--+self.turr_h*math.sin(self.guns.mid.z_rotation[1]*math.pi/180+90)
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
						x = b_ship.s.x,--+self.turr_h*math.cos(self.guns.stern.z_rotation[1]*math.pi/180+90),
						y = b_ship.s.y--+self.turr_h*math.sin(self.guns.stern.z_rotation[1]*math.pi/180+90)
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
		
		
		dead = false,
		setup = function(self)
			
            self.moving = moving
			self.approach_speed = speed
            
			self.guns.g_b:add( self.guns.bow   )
			self.guns.g_m:add( self.guns.mid   )
            self.guns.g_s:add( self.guns.stern )
            self.group:add(Clone{source=curr_lvl_imgs.laminar})
			self.group:add(unpack(self.bow_wake_r))
            self.group:add(unpack(self.bow_wake_l))
            --self.group:add(unpack(self.stern_wake))
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
                if not self.dead then
                    b:rotate_guns_and_fire(seconds)
				end
				--see if you reached the end
				if b.group.y >= screen_h + b.image.h then
					b.group:unparent()
					remove_from_render_list(b)
				end
			end
			self.turr_h = self.guns.stern.h
            if type(o) == "table"  then
                recurse_and_apply(  self, o  )
            end
            
            if self.dead then
                self.group:clear()
                self.image    = Clone{source=curr_lvl_imgs.b_ship_sunk}
                self.group:add(self.image)
                self.moving = false
                self.approach_speed = lvlbg[2].speed
            end
		end,
        
        wake_thresh = .1,
        last_wake_change = 0,
        
        s_wake_thresh = 1,
        s_last_wake_change = 1,
		
		render = function(self,seconds)
			---[[
            if self.moving then
                self.last_wake_change = self.last_wake_change + seconds
                
                if self.last_wake_change >= self.wake_thresh then
                self.last_wake_change = 0
                self.bow_wake_r[self.b_w_i].opacity=0
                self.bow_wake_l[self.b_w_i].opacity=0
                self.bow_wake_t[self.b_w_i%4+1].opacity=0
                --self.stern_wake[self.s_w_i].opacity=0
                self.b_w_i = self.b_w_i%(#self.bow_wake_r)+1
                --self.s_w_i = self.s_w_i%(#self.stern_wake)+1
                self.bow_wake_r[self.b_w_i].opacity=255
                self.bow_wake_l[self.b_w_i].opacity=255
                self.bow_wake_t[self.b_w_i%4+1].opacity=255
                --self.stern_wake[self.s_w_i].opacity=255
                
                end
                --[[
                self.s_last_wake_change = self.s_last_wake_change + seconds
                if self.s_last_wake_change >= self.s_wake_thresh then
                    add_to_render_list(wake(self.group.x+self.image.w/2,self.group.y+self.image.h-80))
                    self.s_last_wake_change = 0
                end--]]
            end
            --]]
			--animate the zeppelin based on the current stage
			self.stages[self.stage](self,seconds)
            if not self.dead then
            table.insert(b_guys_land,
                {
                    obj = self,
                    x1  = self.group.x+10,
                    x2  = self.group.x+self.image.w-10,
                    y1  = self.group.y+40,
                    y2  = self.group.y+self.image.h-20,
                }
            )
            end
		end,
		
        collision = function( self , other, from_bullethole )
			if self.health > 1 then 
				self.health = self.health - 1
                
                --table.insert(self.bulletholes,dam)
                
                --if dam.y > 0 then dam.y =dam.y -50 end
				return
			end
			if self.is_boss then
				levels[state.curr_level]:level_complete()
			end
            
            -- Explode
            add_to_render_list(
                explosions.big(
                    self.group.center[1]-30,
                    self.group.center[2]+20
                )
			)
            add_to_render_list(
                explosions.big(
                    self.group.center[1]-30,
                    self.group.center[2]+140,
                    nil,
                    -.2
                )
			)
            add_to_render_list(
                explosions.big(
                    self.group.center[1]-30,
                    self.group.center[2]+220,
                    nil,
                    -.4
                )
			)
            local timer = Timer{interval=400}
            self.dead = true
            timer.on_timer = function(t)
                t:stop()
                t = nil
                
                self.group:clear()
                self.image    = Clone{source=curr_lvl_imgs.b_ship_sunk}
                self.group:add(self.image)
                self.sunk = true
                self.moving = false
                self.approach_speed = lvlbg[2].speed
                points(self.group.x,self.group.y,300)
            end
			timer:start()
            
		end,
        salvage = function( self, salvage_list )
            
            s = {
                func         = {},
                table_params = {},
            }
            
            for i = 1, #self.salvage_params do
                s.table_params[i] = self.salvage_params[i]
            end
            
            for i = 1, #self.salvage_func do
                s.func[i] = self.salvage_func[i]
            end
            
            table.insert(s.table_params,{
                last_wake_change = self.last_wake_change,
                is_boss        = self.is_boss,
                health         = self.health,
                b_w_i          = self.b_w_i,
                s_w_i          = self.s_w_i,
                stage          = self.stage,
                dead           = self.dead,
                last_shot_time = self.last_shot_time,
                guns  = {
                    bow = {
                        z_rotation = {self.guns.bow.z_rotation[1],0,0},
                    },
                    mid = {
                        z_rotation = {self.guns.mid.z_rotation[1],0,0},
                    },
                    stern = {
                        z_rotation = {self.guns.stern.z_rotation[1],0,0},
                    },
                },
                group = {
                    x = self.group.x,
                    y = self.group.y,
                },
                last_shot_time  =    --how long ago the ship last shot
                {
                    b = self.last_shot_time.b,
                    m = self.last_shot_time.m,
                    s = self.last_shot_time.s
                },
                
            })
            if self.index then
                table.insert(s.table_params,self.index)
            end
            return s
        end,
    }
    add_to_render_list(b)
    return b
    end,
    destroyer = function(xxx,y_offset,speed,moving,o)
        local b = {
        salvage_func = {"enemies","destroyer"},
        salvage_params = {xxx,y_offset,speed,moving},
		health = 2,
		type = TYPE_ENEMY_PLANE,
        bulletholes = {},
        moving = false,
        
        bow_wake_r =
        {
            Clone{source=curr_lvl_imgs.bow_wake_1,opacity = 0,x=curr_lvl_imgs.dest.w/2-12},
            Clone{source=curr_lvl_imgs.bow_wake_2,opacity = 0,x=curr_lvl_imgs.dest.w/2-12},
            Clone{source=curr_lvl_imgs.bow_wake_3,opacity = 0,x=curr_lvl_imgs.dest.w/2-12},
            Clone{source=curr_lvl_imgs.bow_wake_4,opacity = 0,x=curr_lvl_imgs.dest.w/2-12},
            Clone{source=curr_lvl_imgs.bow_wake_5,opacity = 0,x=curr_lvl_imgs.dest.w/2-12},
            Clone{source=curr_lvl_imgs.bow_wake_6,opacity = 0,x=curr_lvl_imgs.dest.w/2-12},
            Clone{source=curr_lvl_imgs.bow_wake_7,opacity = 0,x=curr_lvl_imgs.dest.w/2-12},
            Clone{source=curr_lvl_imgs.bow_wake_8,opacity = 0,x=curr_lvl_imgs.dest.w/2-12},
        },
        bow_wake_t =
        {
            Clone{source=curr_lvl_imgs.bbow_wake_1,opacity = 0},
            Clone{source=curr_lvl_imgs.bbow_wake_2,opacity = 0},
            Clone{source=curr_lvl_imgs.bbow_wake_3,opacity = 0},
            Clone{source=curr_lvl_imgs.bbow_wake_4,opacity = 0},
        },
        bow_wake_l =
        {
            Clone{source=curr_lvl_imgs.bow_wake_1,opacity = 0,x=curr_lvl_imgs.dest.w/2+12,y_rotation={180,0,0}},
            Clone{source=curr_lvl_imgs.bow_wake_2,opacity = 0,x=curr_lvl_imgs.dest.w/2+12,y_rotation={180,0,0}},
            Clone{source=curr_lvl_imgs.bow_wake_3,opacity = 0,x=curr_lvl_imgs.dest.w/2+12,y_rotation={180,0,0}},
            Clone{source=curr_lvl_imgs.bow_wake_4,opacity = 0,x=curr_lvl_imgs.dest.w/2+12,y_rotation={180,0,0}},
            Clone{source=curr_lvl_imgs.bow_wake_5,opacity = 0,x=curr_lvl_imgs.dest.w/2+12,y_rotation={180,0,0}},
            Clone{source=curr_lvl_imgs.bow_wake_6,opacity = 0,x=curr_lvl_imgs.dest.w/2+12,y_rotation={180,0,0}},
            Clone{source=curr_lvl_imgs.bow_wake_7,opacity = 0,x=curr_lvl_imgs.dest.w/2+12,y_rotation={180,0,0}},
            Clone{source=curr_lvl_imgs.bow_wake_8,opacity = 0,x=curr_lvl_imgs.dest.w/2+12,y_rotation={180,0,0}},
        },
        --[[
        stern_wake =
        {
            Clone{source=imgs.stern_wake_1,opacity = 0,y=imgs.dest.h-imgs.stern_wake_1.h+40},
            Clone{source=imgs.stern_wake_2,opacity = 0,y=imgs.dest.h-imgs.stern_wake_2.h+40},
            Clone{source=imgs.stern_wake_3,opacity = 0,y=imgs.dest.h-imgs.stern_wake_3.h+40},
            Clone{source=imgs.stern_wake_4,opacity = 0,y=imgs.dest.h-imgs.stern_wake_4.h+40},
            Clone{source=imgs.stern_wake_5,opacity = 0,y=imgs.dest.h-imgs.stern_wake_5.h+40},
        },
        --]]
		b_w_i = 1,
        s_w_i = 1,
		stage  = 0,	--the current stage the fighter is in
		stages = {},	--the stages, must be set by formations{}
		approach_speed = 80,
		--attack_speed   = 15,
		
		image    = Clone{source=curr_lvl_imgs.dest},
		
		gun_img =
		Clone {
            source       = curr_lvl_imgs.turret,
			anchor_point = {curr_lvl_imgs.turret.w/2,curr_lvl_imgs.turret.h/3},
			z_rotation   = {180,0,0}
        },
		gun_group = Group
		{
			x = curr_lvl_imgs.dest.w/2,
			y = 145,
		},
        
		group    = Group{},
		
		shoot_time      = 4 , --how frequently the ship shoots
		last_shot_time  = math.random()*2,
		remove = function(self)
            self.group:unparent()
        end,
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
				x = (my_plane.group.x+my_plane.img_w/2), 
				y = (my_plane.group.y+my_plane.img_h/2)
			}
			local dest =
			{
                x = (self.gun_group.x+self.group.x-self.group.anchor_point[1]),
				y = (self.gun_group.y+self.group.y-self.group.anchor_point[2])
			}
			
            --rotate and fire the bow turret
            if dest.y < screen_h + curr_lvl_imgs.turret.h and
               dest.y >           -curr_lvl_imgs.turret.h then
                
                self.last_shot_time = self.last_shot_time + secs
                
                self.gun_img.z_rotation =
                {
                    180/math.pi*math.atan2(
                        targ.y - dest.y,
                        targ.x - dest.x
                    )-90,
                    0,
                    0
                }
                
                mock_obj =
				{
					group =
					{
						z_rotation =
						{self.gun_img.z_rotation[1],
							0,0},
						x = dest.x,--+curr_lvl_imgs.turret.h*math.cos(self.gun_img.z_rotation[1]*math.pi/180+90),
						y = dest.y--+curr_lvl_imgs.turret.h*math.sin(self.gun_img.z_rotation[1]*math.pi/180+90)
					}
				}
				if self.last_shot_time >= self.shoot_time and  (math.abs(dest.x - targ.x) > 200 or
                    math.abs(dest.y - targ.y) > 200) and
					math.random(1,20) == 8 then
					
					self.last_shot_time = 0
					fire_flak(mock_obj, math.abs(dest.x - targ.x)-50, math.abs(dest.y - targ.y)-50)
					
				end
            end
		end,
		
		
		dead = false,
		setup = function(self)
			
            self.moving = moving
			self.approach_speed = speed
            
			self.gun_group:add( self.gun_img )
            --self.group:add(Clone{source=curr_lvl_imgs.laminar})
			self.group:add(unpack(self.bow_wake_r))
            self.group:add(unpack(self.bow_wake_l))
            --self.group:add(unpack(self.stern_wake))
            --self.group:add(unpack(self.bow_wake_t))
			self.group:add(
				
				self.image,
                
				self.gun_group
				
			)
            self.group.x = xxx
            self.group.y = -self.image.h+y_offset
			
			layers.land_targets:add( self.group )
			
			
			--default battleship animation animation
			self.stages[0] = function(d,seconds)
				--fly downwards
				d.group.y = d.group.y +d.approach_speed*seconds
				
				--fire bullets
                if not self.dead then
                    d:rotate_guns_and_fire(seconds)
				end
				--see if you reached the end
				if d.group.y >= screen_h + d.image.h then
					d.group:unparent()
					remove_from_render_list(d)
				end
			end
			self.turr_h = self.gun_img.h
            if type(o) == "table"  then
                recurse_and_apply(  self, o  )
            end
            if self.dead then
                self.group:clear()
                self.image    = Clone{source=curr_lvl_imgs.dest_sunk}
                self.group:add(self.image)
                self.moving = false
                self.approach_speed = lvlbg[2].speed
            end
		end,
        
        wake_thresh = .1,
        last_wake_change = 0,
		s_wake_thresh = 1,
        s_last_wake_change = 1,
        
		render = function(self,seconds)
			---[[
            if self.moving then
                self.last_wake_change = self.last_wake_change + seconds
                
                if self.last_wake_change >= self.wake_thresh then
                self.last_wake_change = 0
                self.bow_wake_r[self.b_w_i].opacity=0
                self.bow_wake_l[self.b_w_i].opacity=0
                self.bow_wake_t[self.b_w_i%4+1].opacity=0
                --self.stern_wake[self.s_w_i].opacity=0
                self.b_w_i = self.b_w_i%(#self.bow_wake_r)+1
                --self.s_w_i = self.s_w_i%(#self.stern_wake)+1
                self.bow_wake_r[self.b_w_i].opacity=255
                self.bow_wake_l[self.b_w_i].opacity=255
                self.bow_wake_t[self.b_w_i%4+1].opacity=255
                --self.stern_wake[self.s_w_i].opacity=255
                end--[[
                self.s_last_wake_change = self.s_last_wake_change + seconds
                if self.s_last_wake_change >= self.s_wake_thresh then
                    add_to_render_list(wake(self.group.x+self.image.w/2,self.group.y+self.image.h-80))
                    self.s_last_wake_change = 0
                end--]]
            end
            --]]
			--animate the zeppelin based on the current stage
			self.stages[self.stage](self,seconds)
            
            if not self.dead then
            table.insert(b_guys_land,
                {
                    obj = self,
                    x1  = self.group.x+10,
                    x2  = self.group.x+self.image.w-10,
                    y1  = self.group.y+40,
                    y2  = self.group.y+self.image.h-20,
                }
            )
            end
		end,
		
        collision = function( self , other, from_bullethole )
			if self.health > 1 then 
				self.health = self.health - 1
                --[=[if from_bullethole == nil then
                local dam = {}
                if other.group ~= nil then
                    --dam.image = Clone{source = curr_lvl_imgs["z_d_"..math.random(1,4)]}
                    dam.image = Clone{source = curr_lvl_imgs["z_d_"..math.random(1,7)]}
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
                        
                        d.image = Clone{source = curr_lvl_imgs["z_d_"..math.random(5,7)]}
                        d.image.x = x
                        d.image.y = y-4
                        self.group:add(dam.image)
                        self:collision(other,true)
                    end
                    --]]
                elseif other.image ~= nil then
                    --dam.image = Clone{source = curr_lvl_imgs["z_d_"..math.random(1,4)]}
                    dam.image = Clone{source = curr_lvl_imgs["z_d_"..math.random(1,7)]}
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
                        
                        d.image = Clone{source = curr_lvl_imgs["z_d_"..math.random(5,7)]}
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
                end--]=]
                --if dam.y > 0 then dam.y =dam.y -50 end
				return
			end
			
                        
			-- Explode
            add_to_render_list(
			explosions.big(
			self.group.center[1]-30,
			self.group.center[2]+40)
			)

            add_to_render_list(
                explosions.big(
                    self.group.center[1]-30,
                    self.group.center[2]+130,
                    nil,
                    -.2
                )
			)
            local timer = Timer{interval=200}
            self.dead = true
            timer.on_timer = function(t)
                t:stop()
                t = nil
                
                self.group:clear()
                self.image    = Clone{source=curr_lvl_imgs.dest_sunk}
                self.group:add(self.image)
                
                self.moving = false
                self.approach_speed = lvlbg[2].speed
                points(self.group.x,self.group.y,200)
            end
			timer:start()
		end,
        salvage = function( self, salvage_list )
            
            s = {
                func         = {},
                table_params = {},
            }
            
            for i = 1, #self.salvage_params do
                s.table_params[i] = self.salvage_params[i]
            end
            
            for i = 1, #self.salvage_func do
                s.func[i] = self.salvage_func[i]
            end
            
            table.insert(s.table_params,{
                last_wake_change = self.last_wake_change,
                is_boss        = self.is_boss,
                health         = self.health,
                dead           = self.dead,
                b_w_i          = self.b_w_i,
                s_w_i          = self.s_w_i,
                stage          = self.stage,
                last_shot_time = self.last_shot_time,
                gun_img  = {
                    z_rotation = {self.gun_img.z_rotation[1],0,0},
                },
                group = {
                    x = self.group.x,
                    y = self.group.y,
                },
                last_shot_time  =  self.last_shot_time,
                
            })
            
            return s
        end,
    }
    add_to_render_list(b)
    return b
    end,
    
}





formations = 
{
    b_ship_bosses = function(o,salvage_index)
        local b
        if salvage_index then
            lower = salvage_index
            upper = salvage_index
        else
            lower = 1
            upper = 4
        end
        for i= lower,upper do
            b = enemies.battleship(300+(i-1)*400, 1600, -15, true,o)
            b.salvage_func = {"formations","b_ship_bosses"}
            b.salvage_params = {}
            b.index = i
            b.approach_speed = -20
            b.is_boss = true
            b.stages = {
                function(b,seconds)
                    b.group.y = b.group.y +b.approach_speed*seconds
                    
                    --fire bullets
                    if not b.dead then
                        b:rotate_guns_and_fire(seconds)
                    end
                    if b.group.y <= 300 then
                        b.stage = b.stage + 1
                        b.approach_speed = 0
                    end
                    if b.dead and b.group.y >= screen_h + b.image.h then
                    	b.group:unparent()
                    	remove_from_render_list(b)
                    end
				end,
                function(b,seconds)
                    b.group.y = b.group.y +b.approach_speed*seconds
                    if not b.dead then
                        b:rotate_guns_and_fire(seconds)
                    end
                    if b.dead and b.group.y >= screen_h + b.image.h then
                    	b.group:unparent()
                    	remove_from_render_list(b)
                    end
				end,
            }
            b.stage = 1
            --add_to_render_list(b,300+(i-1)*400, 1600, -15, true )
        end
    end,
    
    hor_row_tanks = function(x,y,num,spacing,o,salvage_index)
        
        if salvage_index then
            lower = salvage_index
            upper = salvage_index
        else
            lower = 1
            upper = num
        end
        
        local t
        for i = lower,upper do
            t = enemies.tank(true,screen_w/2+(screen_w/2+spacing*i)*x,y,o)
            t.salvage_func= {"formations","hor_row_tanks"}
            --t.index = i
            t.salvage_params = {x,y,num,spacing}
            t.stages = {
                function(t,seconds)
                    --move downwards with the ground
                    t.group.y = t.group.y +t.approach_speed*seconds
                    --move across the screen
                    t.group.x = t.group.x -x*80*seconds
                    for i = 1,t.num_frames do
                        t.images[i].z_rotation={x*90,t.images[i].w/2,t.images[i].h/2}
                    end
                    
                    t:rotate_guns_and_fire(seconds)
                    
                    --see if you reached the end
                    if x == 1 and t.group.x < -(t.image.w/t.num_frames) or
                        x == -1 and t.group.x > screen_w+(t.image.w/t.num_frames)then
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
            --add_to_render_list(t,screen_w/2+(screen_w/2+spacing*i)*x,y)
        end
    end,
    vert_row_tanks = function(x,y,num,spacing,o,salvage_index)
        if salvage_index then
            lower = salvage_index
            upper = salvage_index
        else
            lower = 1
            upper = num
        end
        assert(y==1 or y==-1)
        local t
        for i = lower,upper do
            t = enemies.tank(true,x+spacing*(i-1),screen_h/2+y*(screen_h/2+100),o)
            t.salvage_func= {"formations","vert_row_tanks"}
            --t.index = i
            t.salvage_params = {x,y,num,spacing}
            t.approach_speed = -y*60+40
            
            t.stages[1] = function(t,seconds)
				--move downwards
				t.group.y = t.group.y +t.approach_speed*seconds
				if y==1 then
                    --t.base_clip.z_rotation={180,t.base_strip.w/(2*t.num_frames),t.base_strip.h/2}
                    for i = 1,t.num_frames do
                        t.images[i].z_rotation={180,t.images[i].w/2,t.images[i].h/2}
                    end
                end
				--fire bullets
				t:rotate_guns_and_fire(seconds)
				
				--see if you reached the end
				if (y == -1 and t.group.y >= screen_h + t.image.h) or
                    (y == 1 and t.group.y < -2*t.image.h) then
					t.group:unparent()
					remove_from_render_list(t)
				end
			end
            t.stage = 1
            --add_to_render_list(t,x+spacing*(i-1),screen_h/2+y*(screen_h/2+100))
        end
    end,
    
    zepp_boss = function(x,o)
        
        local zepp = enemies.zeppelin(x,o)
        
        zepp.salvage_func = {"formations","zepp_boss"}
        zepp.group.y = -zepp.image.h
        zepp.is_boss = true
		
		--add_to_render_list(zepp)
		
    end,
	
	row_from_side = function(
			num,      -- number of fighters in the formation
            spacing,  -- spacing between the fighters
			
			start_x,  -- start position of the first fighter
			start_y,
			
			rot_at_x, -- position where each fighter performs 
			rot_at_y, --     the first turn
			
			targ_x,    -- position where the last fighter turns to attack
            
            salvage_overwrites, --overwrite vars for the enemy
            salvage_index       --which fighter of the formation is being salvaged
		)                 
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
        
        local lower = 1
        local upper = num
        
        if salvage_index then
            lower = salvage_index
            upper = salvage_index
        end
        
		for i = lower,upper do
            --dumptable(salvage_overwrites)
			e = enemies.basic_fighter(curr_lvl_imgs.fighter_r)
            if type(salvage_overwrites) == "table" then
                e.overwrite_vars = salvage_overwrites
            end
            e.index = i
            e.salvage_func={"formations","row_from_side"}
            e.salvage_params= {num, spacing, start_x,
                start_y, rot_at_x, rot_at_y, targ_x}
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
                        f.stage = f.stage + 1
                        
                        f.group.z_rotation = {l,0,0}
                    end
				end,
                
				--move across the screen
				function(f,secs)
 					
                    move(f.group, f.approach_speed, secs)
                    
                    local limit = targ_x + dir*spacing*(num-i)
					
					if  (dir ==  1 and f.group.x >= limit) or
                        (dir == -1 and f.group.x <= limit) then
                        
                        f.stage   = f.stage + 1
						f.group.x = limit
                        
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
            for j = 1,#e.stages do
                e.deg_counter[j] = 0
            end
            e.stage = 1
            add_to_render_list(e)
		end
	end,
    
    cluster = function(x, salvage_overwrites, salvage_index)
        
        
        if salvage_index == nil or salvage_index == 1 then
            local e1 = enemies.basic_fighter(curr_lvl_imgs.fighter)
            e1.salvage_func   = {"formations","cluster"}
            e1.index          = 1
            e1.salvage_params = {x}
            e1.group.position = {x-e1.image.w,-2*e1.image.h}
            e1.overwrite_vars = salvage_overwrites
            add_to_render_list(e1)
        end
        
        if salvage_index == nil or salvage_index == 2 then
            local e2 = enemies.basic_fighter(curr_lvl_imgs.fighter)
            e2.salvage_func   = {"formations","cluster"}
            e2.index          = 2
            e2.salvage_params = {x}
            e2.group.position = {x,-e2.image.h}
            e2.overwrite_vars = salvage_overwrites
            add_to_render_list(e2)
        end
        
        if salvage_index == nil or salvage_index == 3 then
            local e3 = enemies.basic_fighter(curr_lvl_imgs.fighter)
            e3.salvage_func   = {"formations","cluster"}
            e3.index          = 3
            e3.salvage_params = {x}
            e3.group.position = {x+e3.image.w,-2*e3.image.h}
            e3.overwrite_vars = salvage_overwrites
            add_to_render_list(e3)
        end

    end,
    zig_zag = function(x, r, rot, salvage_overwrites)
        e = enemies.basic_fighter(curr_lvl_imgs.fighter_w)
        e.salvage_func   = {"formations","zig_zag"}
        e.salvage_params = {x,r,rot}
        e.overwrite_vars = salvage_overwrites
        local dir = rot/math.abs(rot)
        e.group.x = x
        e.group.y = -e.image.h
        e.shoot_time      = 1.25
        e.last_shot_time = 1
        e.deg_counter = {}
        e.approach_speed = 150
        e.stages =
        {
            --enter the screen
            function(f,secs)
                move(f.group,f.approach_speed,secs)
                    
                f:fire(secs)
                    
                if f.group.y >= f.image.h/2 then
                        f.stage = f.stage + 1
                end
            end,
            --initial bank
            function(f,secs)
                    
                f.deg_counter[f.stage] = f.deg_counter[f.stage] +
                    turn(f.group,r,dir,f.approach_speed,secs)
                    
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
                    turn(f.group,r,-dir,f.approach_speed,secs)
                    
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
                    turn(f.group,r,dir,f.approach_speed,secs)
                    
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
                
                dir,      -- the direction of the loop
                salvage_overwrites,
                salvage_index       --which fighter of the formation is being salvaged
        )
        
        local e
        if salvage_index then
            lower = salvage_index
            upper = salvage_index
        else
            lower = 1
            upper = num
        end
        for i = lower,upper do
            e = enemies.basic_fighter(curr_lvl_imgs.fighter_w)
            e.salvage_func   = {"formations","one_loop"}
            e.salvage_params = {num, spacing, start_x, rot_at_x, rot_at_y, dir}
            if type(salvage_overwrites) == "table" then
                e.overwrite_vars = salvage_overwrites
            end
            e.index = i
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
