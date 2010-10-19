--Spawns enemies

--Enemy Spawner launches enemy formations
--Formations:
--		Figure_8	flies in from top
--		Row			flies in from side
--		cluster		formation of 3 from the top
local imgs = 
{
    enemy1          = Image{ src = "assets/e1_4x_test.png" },
    enemy2          = Image{ src = "assets/e2_4x_test.png" },
    enemy3          = Image{ src = "assets/e3_4x_test.png" },
}

for _ , v in pairs( imgs ) do
    
    v.opacity = 0
        
    screen:add( v )
    
end

formations = 
{
	row_fly_in = 
	{
		num     = 5,
	--	end_y   = start_y+screen.h*3/4,
		add_enemy = function(self,num,start_x,start_y)
			return
			{
				type    = TYPE_ENEMY_PLANE,
				enemies = self,
				setup = function(self)
				end,
				render = function(self,seconds)
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
		setup = function(self,num)
			local start_x = math.random(0,1)*(screen.w+imgs.enemy1.w/3) - 100 --assumes a strip with 3 imgs
			local start_y = math.random(0,200)+screen.h*3/4
		end,
		render
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

