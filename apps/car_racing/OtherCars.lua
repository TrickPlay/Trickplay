local cars = {}
cars.impreza_b = {
    Image{ src="assets/impreza_b/00.png"  },
    Image{ src="assets/impreza_b/01.png"  },
    Image{ src="assets/impreza_b/02.png"  },
    Image{ src="assets/impreza_b/03.png"  },
    Image{ src="assets/impreza_b/04.png"  },
    Image{ src="assets/impreza_b/05.png"  },
    Image{ src="assets/impreza_b/06.png"  },
    Image{ src="assets/impreza_b/07.png"  },
    Image{ src="assets/impreza_b/08.png"  },
    Image{ src="assets/impreza_b/09.png"  },
    Image{ src="assets/impreza_b/10.png"  },
    Image{ src="assets/impreza_b/11.png"  },
}

for _,v in pairs(cars.impreza_b) do
    clone_sources:add(v)
end
--[[
cars.impreza_w = {
    Image{ src="assets/impreza_w/00.png"  },
    Image{ src="assets/impreza_w/01.png"  },
    Image{ src="assets/impreza_w/02.png"  },
    Image{ src="assets/impreza_w/03.png"  },
    Image{ src="assets/impreza_w/04.png"  },
    Image{ src="assets/impreza_w/05.png"  },
    Image{ src="assets/impreza_w/06.png"  },
    Image{ src="assets/impreza_w/07.png"  },
    Image{ src="assets/impreza_w/08.png"  },
    Image{ src="assets/impreza_w/09.png"  },
    Image{ src="assets/impreza_w/10.png"  },
    Image{ src="assets/impreza_w/11.png"  },
}

for _,v in pairs(cars.impreza_w) do
    clone_sources:add(v)
end
--]]
cars.subaru = {
    Image{ src="assets/subaru/00.png"  },
    Image{ src="assets/subaru/01.png"  },
    Image{ src="assets/subaru/02.png"  },
    Image{ src="assets/subaru/03.png"  },
    Image{ src="assets/subaru/04.png"  },
    Image{ src="assets/subaru/05.png"  },
    Image{ src="assets/subaru/06.png"  },
    Image{ src="assets/subaru/07.png"  },
    Image{ src="assets/subaru/08.png"  },
    Image{ src="assets/subaru/09.png"  },
    Image{ src="assets/subaru/10.png"  },
    Image{ src="assets/subaru/11.png"  },
}

for _,v in pairs(cars.subaru) do
    clone_sources:add(v)
end
local angle = math.tan(screen.perspective[1]/2*math.pi/180)

local curr, dx, dr,x,y
r=Rectangle{name="tracking rect",w=30,h=30}
screen:add(r)
local t_pt = {x=0,y=0}

local coll_x, coll_y

car_options={cars.impreza_b,cars.subaru}
make_car = function(last_section,start_pos, dist_from_center,debug)
        print("carr with atributes",last_section.path.dist,start_pos[1],start_pos[2],start_pos[3])
    local model = car_options[math.random(1,#car_options)]
    local orientation = 1
    if dist_from_center < 0 then orientation = -1 end
    local next_road = "next_segment"
    if orientation == -1 then next_road = "prev_segment" end
    print(model)
    return Clone{
        
        source       =  model[3],
        
        anchor_point = {model[3].w/2,model[3].h},
        
        x_rotation   = {-90,0,0},
        opacity=0,
        scale={2.5,1},
        
        position = {
            start_pos[1]+dist_from_center*math.cos(math.pi/180*-start_pos[3]),
            start_pos[2]+dist_from_center*math.sin(math.pi/180*-start_pos[3])
        },
        
        extra = {
            
            hit = false,
            
            curr_section = last_section,
            
            curr_path    = last_section.path,
            
            speed = orientation*65*pixels_per_mile,
            
            dx_remaining_in_path = last_section.path.dist,
            
            dr_remaining_in_path = last_section.path.rot,
            
            perceived_angle = 0,
            
            y_rot = 180-start_pos[3],
            
            prev_pt = {x=0,y=0},
            
            move = function(self,seconds)
                
                if self.y < end_point[2]+1000 then
                    self.opacity = math.abs(self.y-end_point[2])/1000*255
                else
                    self.opacity = 255
                end
                if self.curr_section.parent == nil then
                    self:unparent()
                    return true
                end
                
                --using the distance of the car from the anchor_point of its group
                --for the collision detection
                coll_x = self.x - self.parent.anchor_point[1]
                coll_y = self.parent.anchor_point[2]- self.y
                
                --if the distances is less than the threshold, collision
                if not self.hit and math.abs(coll_x) < 300 and coll_y < 1200 and coll_y > 0 then
                    self.hit = true
                    crashed  = true
                    end_game:raise_to_top()
                    print("Print",coll_x,coll_y)
                    local new_coll_str_x = 300-math.abs(coll_x)--(330-math.abs(coll_x))*coll_x/math.abs(coll_x)
                    local new_coll_str_y = 1200-(coll_y)
                    
                    local new_angle = math.atan2(new_coll_str_y,new_coll_str_x)*180/math.pi
                    print(new_coll_str_x,new_coll_str_y,new_angle)
                    local new_mag = (speed - self.speed)*.6
                    
                    new_coll_str_x = new_mag*math.sin(math.pi/180*new_angle)
                    new_coll_str_y = new_mag*math.cos(math.pi/180*new_angle)
                    print(new_coll_str_y,new_coll_str_x,new_mag)
                    
                    new_coll_str_x = new_coll_str_x + car.v_x
                    new_coll_str_y = new_coll_str_y + car.v_y
                    
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
                    
                    car.v_y = car.v_y - new_coll_str_y
                    car.v_x = car.v_x - new_coll_str_x
                    
                    print("Collision",collision_strength,collision_angle,"y",collision_strength*math.cos(math.pi/180*collision_angle),"x",collision_strength*math.sin(math.pi/180*collision_angle))
                end
                
                --a positive y value means that the car is behind the user
                if self.y > 0 then
                    self:unparent()
                    return true
                end
                if self.hit then
                    self.speed = self.speed -200*seconds
                    if self.speed<1 then
                        self.speed = orientation*1
                        
                    end
                end
                
                --determine the amount the car has moved by during this iteration
                dx = self.speed*seconds
                dr = -self.curr_path.rot*dx/self.curr_path.dist
                
                --if the amount the car moved by is greater than the amount
                --remaining in the current segment of road
                while self.dx_remaining_in_path < dx  do
                    
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
                        self:unparent()
                        return true
                    end
                    --load the next path 
                    self.curr_section = self.curr_section[next_road]
                    
                    --update the counters
                    self.curr_path = self.curr_section.path
                    dx = dx - self.dx_remaining_in_path
                    dr = -self.curr_path.rot*dx/self.curr_path.dist
                    
                    --set the new 'amount remaining' values
                    self.dx_remaining_in_path = self.curr_path.dist
                    self.dr_remaining_in_path = self.curr_path.rot
                    
                end
                
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
                x = screen_w/2+(self.x-self.parent.anchor_point[1])
                y = -(self.y-self.parent.anchor_point[2])
                
                t_pt.x = (y*angle+x)/(screen_w+2*y*angle)*screen_w
                t_pt.y = screen_h-y*angle/(screen_h+2*y*angle)*screen_h
                
                --compare against previous screen position
                x = screen_w/2+(self.prev_pt.x-self.parent.anchor_point[1])
                y = -(self.prev_pt.y-self.parent.anchor_point[2])
                
                self.prev_pt.x = (y*angle+x)/(screen_w+2*y*angle)*screen_w
                self.prev_pt.y = screen_h-y*angle/(screen_h+2*y*angle)*screen_h
                
                --use screen positions to estimate the perceived angle of the car
                self.perceived_dir = math.abs(math.atan((self.prev_pt.x-t_pt.x)/(self.prev_pt.y-t_pt.y))*180/math.pi)
                
                --save the current screen position for next time around
                self.prev_pt.x = self.x
                self.prev_pt.y = self.y
                
                --determine which side of the player's car this car is on
                if t_pt.x < screen_w/2 then
                    self.z_rotation={0,0,0}
                else
                    self.z_rotation={180,0,0}
                end
                if orientation == -1 then self.z_rotation={self.z_rotation[1]+180,0,0} end
                --determine which car image to use to match the perceived angle
                if math.abs(self.perceived_dir) < 10 then
                    self.source_i =6.5-orientation*5.5         --1 or 12
                elseif math.abs(self.perceived_dir) < 30 then
                    self.source_i =6.5-orientation*4.5         --2 or 11
                elseif math.abs(self.perceived_dir) < 57 then
                    self.source_i =6.5-orientation*3.5         --3 or 10
                elseif math.abs(self.perceived_dir) < 67 then
                    self.source_i =6.5-orientation*2.5         --4 or 9
                elseif math.abs(self.perceived_dir) < 80 then
                    self.source_i =6.5-orientation*1.5         --5 or 8
                else
                    self.source_i =6.5-orientation*.5          --6 or 7
                end
                
                if debug then
                    print(self.source_i,self.perceived_dir)
                    r.x = t_pt.x
                    r.y = t_pt.y
                    r:raise_to_top()
                end
                
                --set the new image for the car
                self.source=model[self.source_i]
                self.anchor_point = {model[self.source_i].w/2,model[self.source_i].h*2/3}
                
                return false
            end
        }
    }
end