--file globals
local car_scale = 2.5
local angle = tan(screen.perspective[1]/2)
local ratio = 16/9
local spawn_on_coming_self_thresh = 1250
local spawn_passing_self_thresh   = 1.5*spawn_on_coming_self_thresh


local other_cars = make_Linked_List()
--Assets:Clones for the different angles of the cars
local cars = {
    {   -- Blue Impreza
        --[[Assets:Clone{ src=]]"assets/impreza_b/00.png"  ,--},
        --[[Assets:Clone{ src=]]"assets/impreza_b/01.png"  ,--},
        --[[Assets:Clone{ src=]]"assets/impreza_b/02.png"  ,--},
        --[[Assets:Clone{ src=]]"assets/impreza_b/03.png"  ,--},
        --[[Assets:Clone{ src=]]"assets/impreza_b/04.png"  ,--},
        --[[Assets:Clone{ src=]]"assets/impreza_b/05.png"  ,--},
        --[[Assets:Clone{ src=]]"assets/impreza_b/06.png"  ,--},
        --[[Assets:Clone{ src=]]"assets/impreza_b/07.png"  ,--},
        --[[Assets:Clone{ src=]]"assets/impreza_b/08.png"  ,--},
        --[[Assets:Clone{ src=]]"assets/impreza_b/09.png"  ,--},
        --[[Assets:Clone{ src=]]"assets/impreza_b/10.png"  ,--},
        --[[Assets:Clone{ src=]]"assets/impreza_b/11.png"  ,--},
    },
    {   -- Red Subaru
        --[[Assets:Clone{ src=]]"assets/subaru/00.png"  ,--},
        --[[Assets:Clone{ src=]]"assets/subaru/01.png"  ,--},
        --[[Assets:Clone{ src=]]"assets/subaru/02.png"  ,--},
        --[[Assets:Clone{ src=]]"assets/subaru/03.png"  ,--},
        --[[Assets:Clone{ src=]]"assets/subaru/04.png"  ,--},
        --[[Assets:Clone{ src=]]"assets/subaru/05.png"  ,--},
        --[[Assets:Clone{ src=]]"assets/subaru/06.png"  ,--},
        --[[Assets:Clone{ src=]]"assets/subaru/07.png"  ,--},
        --[[Assets:Clone{ src=]]"assets/subaru/08.png"  ,--},
        --[[Assets:Clone{ src=]]"assets/subaru/09.png"  ,--},
        --[[Assets:Clone{ src=]]"assets/subaru/10.png"  ,--},
        --[[Assets:Clone{ src=]]"assets/subaru/11.png"  ,--},
    },
}
--function that calculates the screen pixel position of the car
local perceived_x_y = function(x,y)
    
    return  (y*angle*ratio+x) / 
            (screen_w+2*y*angle*ratio)*screen_w,
            
            screen_h-y*angle / 
            (screen_h+2*y*angle)*screen_h
end

--debugging rectangle
r=Rectangle{name="tracking rect",w=30,h=30}
screen:add(r)
r:hide()


--upvals
local curr, dx, dr,x,y
local t_pt = {x=0,y=0}

local coll_x, coll_y, norm_x, norm_y

local back_of_car_x, back_of_car_y
local car_len = 1200
local car_w   = 600
local old_source_i = 0
local the_car
--car constructor
make_car = function(last_section,start_pos, dist_from_center,debug)
    
    --print("carr with atributes",last_section,last_section.path.dist,start_pos[1],start_pos[2],start_pos[3])
    
    --local upvals
    local model = cars[math.random(1,#cars)]
    local orientation = 1
    if dist_from_center < 0 then orientation = -1 end
    local next_road = "next_segment"
    if orientation == -1 then next_road = "prev_segment" end
    --print(model)
    the_car = Assets:source_from_src(model[3])
    return Clone{
        
        source       =  the_car,
        
        anchor_point = {the_car.w/2,the_car.h*2/3},
        
        x_rotation   = {-90,0,0},
        --y_rotation   = {start_pos[3],0,0},
        opacity=0,
        scale={car_scale,1},
        
        position = {
            start_pos[1]+dist_from_center*math.cos(math.pi/180*-start_pos[3]),
            start_pos[2]+dist_from_center*math.sin(math.pi/180*-start_pos[3])
        },
        
        extra = {
            dist_from_center = dist_from_center,
            screen_y = 0,
            hit = false,
            
            curr_section = last_section,
            
            curr_path    = last_section.path,
            
            speed = orientation*65*pixels_per_mile,
            
            dx_remaining_in_path = orientation*last_section.path.dist,
            
            dr_remaining_in_path = orientation*last_section.path.rot,
            
            perceived_angle = 0,
            
            y_rot = 180-start_pos[3],
            
            prev_pt = {x=0,y=0},
            
            remove = function(self)
                other_cars:remove(self)
                Idle_Loop:remove_function(self.move)
                self:unparent()
            end,
            
            move = function(self,msecs)
                --print("move",self)
                if self.y < Game_State.end_point[2]+1000 then
                    self.opacity = math.abs(self.y-Game_State.end_point[2])/1000*255
                else
                    self.opacity = 255
                end
                if self.curr_section.parent == nil then
                    print("my road was deleted")
                    self:remove()
                    return
                end
                
                
                
                --a positive y value means that the car is behind the user
                if self.y > 0 then
                    print("behind you",self)
                    self:remove()
                    return
                end
                if self.hit then
                    self.speed = self.speed -200*msecs/1000
                    if self.speed<1 then
                        self.speed = orientation*1
                        
                    end
                end
                
                --determine the amount the car has moved by during this iteration
                dx = self.speed*msecs/1000
                dr = -self.curr_path.rot*dx/self.curr_path.dist
                
                --if the amount the car moved by is greater than the amount
                --remaining in the current segment of road
                while math.abs(self.dx_remaining_in_path) < math.abs(dx)  do
                    
                    --move the car by the amount remaining
                    self.position = {
                        (self.x + self.dx_remaining_in_path*math.sin(math.pi/180*self.y_rot)),
                        (self.y + self.dx_remaining_in_path*math.cos(math.pi/180*self.y_rot)),
                    }
                    self.y_rot = self.y_rot - self.dr_remaining_in_path 
                    
                    --if there is no more road segments left, then delete the car
                    if self.curr_section[next_road] == nil then
                        --edge case for when the car was collided with
                        if self.hit then
                            self.speed = orientation*1
                            if self.y < 0 then
                                return false
                            end
                        end
                        self:remove()
                        print("no more road")
                        return
                    end
                    --load the next path 
                    self.curr_section = self.curr_section[next_road]
                    
                    --update the counters
                    self.curr_path = self.curr_section.path
                    dx = dx - self.dx_remaining_in_path
                    dr = -self.curr_path.rot*dx/self.curr_path.dist
                    
                    
                    --set the new 'amount remaining' values
                    self.dx_remaining_in_path = orientation*self.curr_path.dist
                    self.dr_remaining_in_path = orientation*self.curr_path.rot
                    
                end
                --print(self.dx_remaining_in_path,dx)
                
                --update position inside world.cars
                self.position = {
                    (self.x + dx*math.sin(math.pi/180*self.y_rot)),
                    (self.y + dx*math.cos(math.pi/180*self.y_rot)),
                }
                
                
                
                --update the amount remaining in the current path
                self.dx_remaining_in_path = self.dx_remaining_in_path - dx
                self.dr_remaining_in_path = self.dr_remaining_in_path - dr
                self.y_rot = self.y_rot - dr
                
                
                
                --calculate current screen position
                norm_x = screen_w/2+(self.x-world.cars.anchor_point[1])
                norm_y = -(self.y-world.cars.anchor_point[2])
                
                x = norm_x*cos(world.cars.y_rotation[1]) - norm_y*sin(world.cars.y_rotation[1])
                y = norm_x*sin(world.cars.y_rotation[1]) + norm_y*cos(world.cars.y_rotation[1])
                
                
                curr_x = x
                curr_y = y
                t_pt.x, t_pt.y = perceived_x_y(x,y*10.8/16)
                self.screen_y = t_pt.y
                
                if other_cars.list[self].next ~= nil and
                    self.screen_y  < other_cars.list[self].next.screen_y then
                    
                    world.cars:lower_child(self,other_cars.list[self].next)
                    other_cars:move_down(self)
                    
                end
                
                back_of_car_x = self.x + car_len*math.sin(math.pi/180*self.y_rot)
                back_of_car_y = self.y + car_len*math.cos(math.pi/180*self.y_rot)
                
                --compare against previous screen position
                norm_x = screen_w/2+(back_of_car_x-world.cars.anchor_point[1])
                norm_y = -(back_of_car_y-world.cars.anchor_point[2])
                
                x = norm_x*cos(world.cars.y_rotation[1]) - norm_y*sin(world.cars.y_rotation[1])
                y = norm_x*sin(world.cars.y_rotation[1]) + norm_y*cos(world.cars.y_rotation[1])
                
                self.prev_pt.x, self.prev_pt.y = perceived_x_y(x,y*10.8/16)
                
                
                
                --use screen positions to estimate the perceived angle of the car
                self.perceived_dir = math.abs(
                    math.atan(
                        (self.prev_pt.x-t_pt.x)/
                        (self.prev_pt.y-t_pt.y)
                    ) * 180/math.pi
                )
                
                
                
                
                --save the current screen position for next time around
                --self.prev_pt.x = self.x
                --self.prev_pt.y = self.y
                
                --determine which side of the player's car this car is on
                if t_pt.x < self.prev_pt.x then
                    if orientation == -1 then
                        self.scale = {-car_scale,1}
                    else
                        self.scale = {car_scale,1}
                    end
                    --self.z_rotation={0,0,0}
                else
                    if orientation == -1 then
                        self.scale = {car_scale,1}
                    else
                        self.scale = {-car_scale,1}
                    end
                    --self.z_rotation={180,0,0}
                end
                --self.z_rotation = {world.cars.y_rotation[1],0,0}
                --if orientation == -1 then self.z_rotation={self.z_rotation[1]+180,0,0} end
                old_source_i = self.source_i
                --determine which car image to use to match the perceived angle
                if math.abs(self.perceived_dir) < 10 then
                    self.source_i =6.5-orientation*5.5         --1 or 12
                elseif math.abs(self.perceived_dir) < 30 then
                    self.source_i =6.5-orientation*4.5         --2 or 11
                elseif math.abs(self.perceived_dir) < 57 then
                    self.source_i =6.5-orientation*3.5         --3 or 10
                elseif math.abs(self.perceived_dir) < 67 then
                    self.source_i =6.5-orientation*2.5         --4 or 9
                elseif math.abs(self.perceived_dir) < 70 then
                    self.source_i =6.5-orientation*1.5         --5 or 8
                else
                    self.source_i =6.5-orientation*.5          --6 or 7
                end
                
                --using the distance of the car from the anchor_point of its group
                --for the collision detection
                
                
                --if the distances is less than the threshold, collision
                if not self.hit and math.abs(screen_w/2-curr_x) < car_w/2 and curr_y < car_len and curr_y > 0 then
                    coll_x = curr_x
                    coll_y = curr_y
                    
                    self.hit = true
                    --user_car.crashed  = true
                    end_game:raise_to_top()
                    print("Print",coll_x,coll_y)
                    local new_coll_str_x = car_w/2-math.abs(coll_x)--(330-math.abs(coll_x))*coll_x/math.abs(coll_x)
                    local new_coll_str_y = car_len-(coll_y)
                    
                    local new_angle = math.atan2(new_coll_str_y,new_coll_str_x)*180/math.pi
                    print(new_coll_str_x,new_coll_str_y,new_angle)
                    local new_mag = (user_car.v_y - self.speed)*.6
                    
                    new_coll_str_x = new_mag*math.sin(math.pi/180*new_angle)
                    new_coll_str_y = new_mag*math.cos(math.pi/180*new_angle)
                    print(new_coll_str_y,new_coll_str_x,new_mag)
                    
                    new_coll_str_x = new_coll_str_x + user_car.v_x
                    new_coll_str_y = new_coll_str_y + user_car.v_y
                    
                    collision_strength = -math.sqrt(
                        new_coll_str_x*new_coll_str_x +
                        new_coll_str_y*new_coll_str_y
                    )
                    collision_angle = math.atan2(new_coll_str_x,new_coll_str_y)*180/math.pi
                    
                    self.speed = self.speed + new_mag
                    self.curr_section = {path={dist=8000,rot=-20,radius=-100},parent="some bullshit to pass my check"}
                        self.curr_path = self.curr_section.path
                        self.dx_remaining_in_path = self.curr_path.dist
                        self.dr_remaining_in_path = self.curr_path.rot
                    
                    user_car.v_y = user_car.v_y - new_coll_str_y
                    user_car.v_x = user_car.v_x - new_coll_str_x
                    
                    print("Collision",collision_strength,collision_angle,"y",collision_strength*math.cos(math.pi/180*collision_angle),"x",collision_strength*math.sin(math.pi/180*collision_angle))
                    
                    Game_State:change_state_to(STATES.CRASH)
                end
                
                
                --[[
                print("\n\n"..
                    "pre-transformed\t x's: ",self.x,back_of_car_x,"y's:",self.y,back_of_car_y,"y_rot",self.y_rot,dr,self.curr_path.rot,
                    "\nnormalizesd\t x's: ",curr_x,x,"y's:",curr_y,y,
                    "\ntransformed\t x's: ",t_pt.x,self.prev_pt.x,"y's:",t_pt.y,self.prev_pt.y,
                    "\nsource_i:\t",self.source_i,"angle: \t ",self.perceived_dir,
                    "\n\nrotations:\t",self.x_rotation[1],self.y_rotation[1],self.z_rotation[1]
                )
                --]]
                if debug then
                    --print(self.source_i,self.perceived_dir)
                    r.x = t_pt.x
                    r.y = t_pt.y
                    r:raise_to_top()
                end
                
                --set the new image for the car
                if old_source_i ~= self.source_i then
                    self.source=Assets:source_from_src(model[self.source_i])
                end
                return false
            end,
            post_collision = function(self,msecs)
            end
        }
    }
end
local lane_pos = {
	-lane_dist * 3/2,
	-lane_dist/2,
	 lane_dist/2,
	 lane_dist * 3/2
}

local lane3,lane4, rand, car, old_car, car_y
--Car Spawner
local passing_self_timer = Timer{
	interval = spawn_passing_self_thresh,
	on_timer = function()
		lane3 = false
		lane4 = false
        car_y = road.newest_segment.y + car_len
        for car,_ in pairs(other_cars.list) do
		--for i = #other_cars,1,-1 do
            --if there is a car too close in that lane, then mark that lane
            --print(other_cars[i].y, (road.newest_segment.y + car_len*10),road.newest_segment.y)
			if car.y < car_y then
                print("match")
				if car.dist_from_center == lane_pos[3] then
					lane3 = true
					print(3)
				elseif car.dist_from_center == lane_pos[4] then
					lane4 = true
					print(4)
				end
			end
		end
		
		if not(lane3 and lane4) then
			if lane3 then rand = 4
			elseif lane4 then rand = 3
			else rand = math.random(3,4)
			end
            
            old_car = other_cars.tail
            car = make_car(
				road.newest_segment,
				{
					road.newest_segment.x,
					road.newest_segment.y,
					road.newest_segment.z_rotation[1]
				},
				lane_pos[rand]
			)
			
            world.cars:add(car)
            car_y = car.y
            while(old_car ~= nil and old_car.y < car_y) do
                old_car = other_cars.list[old_car].prev
            end
            
            other_cars:insert(car,old_car)
            
			world.cars:lower_child(car,old_car)
			
            Idle_Loop:add_function(car.move,car)
		end
	end
}
passing_self_timer:stop()
local on_coming_self_timer = Timer{
	interval = spawn_passing_self_thresh,
	on_timer = function()
        
        rand = math.random(1,2)
        old_car = other_cars.tail
        car = make_car(
			road.newest_segment,
			Game_State.end_point,
			lane_pos[rand]
		)
		
        world.cars:add(car)
        car_y = car.y
        while(old_car ~= nil and old_car.y < car_y) do
            old_car = other_cars.list[old_car].prev
        end
        
        other_cars:insert(car,old_car)
        
		world.cars:lower_child(car,old_car)
		
        Idle_Loop:add_function(car.move,car)
        
	end
}
on_coming_self_timer:stop()


--Game State Change Behaviors
----
Game_State:add_state_change_function(
    function(old_state,new_state)
        passing_self_timer:start()
        on_coming_self_timer:start()
    end,
    nil,
    STATES.PLAYING
)
Game_State:add_state_change_function(
    function(old_state,new_state)
        for car,car_node in pairs(other_cars.list) do
        --for i = #other_cars,1,-1 do
            car:remove()
        end
        other_cars:clear()
    end,
    STATES.CRASH,
    STATES.PLAYING
)
Game_State:add_state_change_function(
    function(old_state,new_state)
        for car,car_node in pairs(other_cars.list) do
        --for i = #other_cars,1,-1 do
            Idle_Loop:add_function(car.move,car)
        end
    end,
    STATES.PAUSED,
    STATES.PLAYING
)
------------------------------------
Game_State:add_state_change_function(
    function(old_state,new_state)
        passing_self_timer:stop()
        on_coming_self_timer:stop()
    end,
    STATES.PLAYING,
    nil
)
Game_State:add_state_change_function(
    function(old_state,new_state)
        for car,car_node in pairs(other_cars.list) do
        --for i = #other_cars,1,-1 do
            Idle_Loop:remove_function(car.move)
        end
    end,
    STATES.PLAYING,
    STATES.PAUSED
)

return other_cars