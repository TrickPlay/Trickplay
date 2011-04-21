local impreza = {
    Image{ src="assets/impreza/00.png"  },
    Image{ src="assets/impreza/01.png"  },
    Image{ src="assets/impreza/02.png"  },
    Image{ src="assets/impreza/03.png"  },
    Image{ src="assets/impreza/04.png"  },
    Image{ src="assets/impreza/05.png"  },
    Image{ src="assets/impreza/06.png"  },
    Image{ src="assets/impreza/07.png"  },
    Image{ src="assets/impreza/08.png"  },
    Image{ src="assets/impreza/09.png"  },
    Image{ src="assets/impreza/10.png"  },
    Image{ src="assets/impreza/11.png"  },
    Image{ src="assets/impreza/12.png"  },
}

for _,v in pairs(impreza) do
    clone_sources:add(v)
end

local subaru = {
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

for _,v in pairs(subaru) do
    clone_sources:add(v)
end
local angle = math.tan(screen.perspective[1]/2*math.pi/180)

local curr, dx, dr,x,y
r=Rectangle{name="tracking rect",w=30,h=30}
screen:add(r)
local t_pt = {x=0,y=0}
make_on_coming_impreza = function(last_section,end_point, dist_from_center)
    print("carr with atributes",last_section.path.dist,end_point[1],end_point[2],end_point[3])
    return Clone{
        
        source       =  impreza[3],
        
        anchor_point = {impreza[3].w/2,impreza[3].h},
        
        --scale={.25,.25,.25},
        
        x_rotation   = {-90,0,0},
        
        scale={2.5,1},
        
        position = {
            (end_point[1]+dist_from_center*math.cos(math.pi/180*-end_point[3])),
             end_point[2]+dist_from_center*math.sin(math.pi/180*-end_point[3])
        },
        
        extra = {
            
            curr_section = last_section,
            
            curr_path    = last_section.path,
            
            speed = -1000,
            
            dx_remaining_in_path = -last_section.path.dist,
            
            dr_remaining_in_path = -last_section.path.rot,
            
            y_rot = 180-end_point[3],
            
            perceived_angle = 0,
            
            prev_pt = {x=0,y=0},
            
            move = function(self,seconds)
                
                
                dx = self.speed*seconds
                dr = -self.curr_path.rot*dx/self.curr_path.dist
                
                while self.dx_remaining_in_path > dx do
                    self.position = {
                        (self.x + self.dx_remaining_in_path*math.sin(math.pi/180*self.y_rot)),
                        (self.y + self.dx_remaining_in_path*math.cos(math.pi/180*self.y_rot)),
                    }
                    self.y_rot = self.y_rot - self.dr_remaining_in_path 
                    
                    if self.curr_section.prev_segment == self.curr_section then
                        self:unparent()
                        return true
                    end
                    self.curr_section = self.curr_section.prev_segment
                    
                    self.curr_path = self.curr_section.path
                    dx = dx - self.dx_remaining_in_path
                    dr = -self.curr_path.rot*dx/self.curr_path.dist
                    
                    self.dx_remaining_in_path = -self.curr_path.dist
                    self.dr_remaining_in_path = -self.curr_path.rot
                    
                end
                
                self.position = {
                    (self.x + dx*math.sin(math.pi/180*self.y_rot)),
                    (self.y + dx*math.cos(math.pi/180*self.y_rot)),
                }
                if self.z_rotation[1] == 0 then
                    t_pt.x = (self.transformed_position[1]+self.transformed_size[1]/2)/screen.scale[1]
                else
                    t_pt.x = (self.transformed_position[1]-self.transformed_size[1]/2)/screen.scale[1]
                end
                t_pt.y = (self.transformed_position[2]+self.transformed_size[2])/screen.scale[2]
                
                
                r:raise_to_top()
                self.perceived_angle = 180/math.pi*math.atan(
                    (self.x-screen_w/2)/
                    (screen_h-self.y)) +
                    world.cars.y_rotation[1]
                    
                self.perceived_dir =math.atan((self.prev_pt.x-t_pt.x)/(self.prev_pt.y-t_pt.y))*180/math.pi
                    --)
                --if self.perceived_angle < 75 then self.perceived_angle = 75 end
                --print(self.perceived_angle,self.y_rot,world.cars.y_rotation[1])
                
                
                self.source_i = 1
                ---[[
                if t_pt.x < screen_w/2 then
                    --self.scale = {1.2,1.2}
                    self.z_rotation={0,0,0}
                else
                    --self.scale = {-1.2,1.2}
                    self.z_rotation={180,0,0}
                end
                --]]
                if math.abs(self.perceived_dir) < 2.5 then
                    --self.source_i = 1+math.floor(((self.y_rot-world.road.y_rotation[1])-self.perceived_angle)/(180/#impreza))
                    self.source_i = 1
                elseif math.abs(self.perceived_dir) < 15 then
                    self.source_i = 2
                elseif math.abs(self.perceived_dir) < 30 then
                    self.source_i = 3
                elseif math.abs(self.perceived_dir) < 55 then
                    self.source_i = 4
                else
                    self.source_i = 5
                end
                
                print(self.perceived_dir,self.source_i)
                --((self.y_rot-world.road.y_rotation[1])-self.perceived_angle),"\t",
                --[[
                print(self.perceived_angle,"\t",self.source_i,"\t",
                    self.perceived_dir,
                    
                    
                    t_pt.x,   t_pt.y,"\t", prev_pt.x-t_pt.x,prev_pt.y-t_pt.y )
                --]]
                self.prev_pt.x = t_pt.x
                self.prev_pt.y = t_pt.y
                --print("x",self.x-world.cars.anchor_point[1],"y",self.y-world.cars.anchor_point[2])
                --print("angles",self.perceived_angle,self.y_rot,world.road.y_rotation[1],self.source_i)
                --
                --print(self.source_i)
                self.source=impreza[self.source_i]
                self.anchor_point = {impreza[self.source_i].w/2,impreza[self.source_i].h}
                self.dx_remaining_in_path = self.dx_remaining_in_path - dx
                self.dr_remaining_in_path = self.dr_remaining_in_path - dr
                self.y_rot = self.y_rot - dr
                return false
            end
        }
    }
end

make_passing_subaru = function(last_section,end_point, dist_from_center)
        print("carr with atributes",last_section.path.dist,end_point[1],end_point[2],end_point[3])
    return Clone{
        
        source       =  subaru[3],
        
        anchor_point = {subaru[3].w/2,subaru[3].h},
        
        --scale={.25,.25,.25},
        
        x_rotation   = {-90,0,0},
        
        scale={2.5,1},
        
        position = {
            (end_point[1]+dist_from_center*math.cos(math.pi/180*-end_point[3])),
             end_point[2]+dist_from_center*math.sin(math.pi/180*-end_point[3])
        },
        
        extra = {
            
            hit = false,
            
            coll_box = {w=300,l=600},
            
            curr_section = last_section,
            
            curr_path    = last_section.path,
            
            speed = 25*pixels_per_mile,
            
            dx_remaining_in_path = last_section.path.dist,
            
            dr_remaining_in_path = last_section.path.rot,
            
            y_rot = 180-end_point[3],
            
            perceived_angle = 0,
            
            prev_pt = {x=0,y=0},
            
            move = function(self,seconds)
                
                if self.curr_section.parent == nil then
                    self:unparent()
                    print("the section i was driving on got deleted, gg")
                    return true
                end
                
                --print(self.x - self.parent.anchor_point[1],self.parent.anchor_point[2]- self.y)
                if not self.hit and math.abs(self.x - self.parent.anchor_point[1]) < 310 and self.parent.anchor_point[2]- self.y < 1200 and self.parent.anchor_point[2]- self.y > 0 then
                    self.hit = true
                    --[[
                    if self.parent.anchor_point[2]- self.y > 1000 then
                        print("I got rear-ended")
                        
                        if self.speed/pixels_per_mile < mph-10 then
                            self.speed = mph*.9*pixels_per_mile
                            mph = mph*.5
                        else
                            self.speed = mph*.9*pixels_per_mile
                            mph = mph*.5
                        end
                        
                        
                        self.curr_section = {path={dist=8000,rot=-20,radius=-100},parent="some bullshit to pass my check"}
                        self.curr_path = self.curr_section.path
                        self.dx_remaining_in_path = self.curr_path.dist
                        self.dr_remaining_in_path = self.curr_path.rot
                    elseif self.parent.anchor_point[2]- self.y < 100 then
                        print("I rear-ended you")
                    elseif self.x - self.parent.anchor_point[1] > 250 then
                        print("you side swiped my left side")
                        mph = mph*.9
                        self.curr_section = {path={dist=8000,rot=-20,radius=-100},parent="some bullshit to pass my check"}
                        self.curr_path = self.curr_section.path
                        self.dx_remaining_in_path = self.curr_path.dist
                        self.dr_remaining_in_path = self.curr_path.rot
                    elseif self.x - self.parent.anchor_point[1] < -250 then
                        print("you side swiped my right side")
                    else
                        print("we are inside each other")
                    end
                    --]]
                    local new_coll_str_x = self.parent.anchor_point[1] - self.x 
                    local new_coll_str_y = self.parent.anchor_point[2] - self.y
                    
                    local old_coll_str_x = collision_strength*math.sin(math.pi/180*collision_angle)
                    local old_coll_str_y = collision_strength*math.cos(math.pi/180*collision_angle)
                    
                    new_coll_str_x = new_coll_str_x - old_coll_str_x
                    new_coll_str_y = new_coll_str_y - old_coll_str_y
                    
                    collision_strength = math.sqrt(
                        new_coll_str_x*new_coll_str_x +
                        new_coll_str_y*new_coll_str_y
                    )
                    collision_angle = math.atan2(new_coll_str_x,new_coll_str_y)
                end
                if self.hit then
                    self.speed = self.speed -20*seconds
                    if self.speed<1 then
                        self.speed = 1
                        if self.y > 0 then
                            self:unparent()
                            return true
                        end
                    end
                end
                dx = self.speed*seconds
                dr = -self.curr_path.rot*dx/self.curr_path.dist
                --print(self.dx_remaining_in_path,dx)
                while self.dx_remaining_in_path < dx  do
                    self.position = {
                        (self.x + self.dx_remaining_in_path*math.sin(math.pi/180*self.y_rot)),
                        (self.y + self.dx_remaining_in_path*math.cos(math.pi/180*self.y_rot)),
                    }
                    self.y_rot = self.y_rot - self.dr_remaining_in_path 
                    
                    if self.curr_section.next_segment == nil then
                        if self.hit then
                            self.speed = 1
                            if self.y < 0 then
                                return
                            end
                        end
                        self:unparent()
                        print("no more road, gg")
                        return true
                    end
                    --print("new")
                    self.curr_section = self.curr_section.next_segment
                    
                    self.curr_path = self.curr_section.path
                    dx = dx - self.dx_remaining_in_path
                    dr = -self.curr_path.rot*dx/self.curr_path.dist
                    
                    self.dx_remaining_in_path = self.curr_path.dist
                    self.dr_remaining_in_path = self.curr_path.rot
                    
                end
                
                self.position = {
                    (self.x + dx*math.sin(math.pi/180*self.y_rot)),
                    (self.y + dx*math.cos(math.pi/180*self.y_rot)),
                }
                --[[
                if self.z_rotation[1] == 0 then
                    t_pt.x = (self.transformed_position[1]+self.transformed_size[1]/2)/screen.scale[1]
                else
                    t_pt.x = (self.transformed_position[1]-self.transformed_size[1]/2)/screen.scale[1]
                end
                t_pt.y = (self.transformed_position[2]+self.transformed_size[2])/screen.scale[2]
                --]]
                
                x = screen_w/2+(self.x-self.parent.anchor_point[1])
                y = -(self.y-self.parent.anchor_point[2])
                
                t_pt.x = (y*angle+x)/(screen_w+2*y*angle)*screen_w
                t_pt.y = screen_h-y*angle/(screen_h+2*y*angle)*screen_h
                
                
                x = screen_w/2+(self.prev_pt.x-self.parent.anchor_point[1])
                y = -(self.prev_pt.y-self.parent.anchor_point[2])
                
                self.prev_pt.x = (y*angle+x)/(screen_w+2*y*angle)*screen_w
                self.prev_pt.y = screen_h-y*angle/(screen_h+2*y*angle)*screen_h

                self.perceived_angle = 180/math.pi*math.atan(
                    (self.transformed_position[1]/screen.scale[1]-screen_w/2)/
                    (screen_h-self.transformed_position[2]/screen.scale[2])) +
                    world.cars.y_rotation[1]
                    
                self.perceived_dir = math.atan((self.prev_pt.x-t_pt.x)/(self.prev_pt.y-t_pt.y))*180/math.pi
                --if self.perceived_angle < 75 then self.perceived_angle = 75 end
                --print(self.perceived_angle,self.y_rot,world.cars.y_rotation[1])
                
                self.source_i = 1
                ---[[
                if t_pt.x < screen_w/2 then
                    --self.scale = {1.2,1.2}
                    self.z_rotation={0,0,0}
                else
                    --self.scale = {-1.2,1.2}
                    self.z_rotation={180,0,0}
                end
                --]]
                if math.abs(self.perceived_dir) < 10 then
                    --self.source_i = 1+math.floor(((self.y_rot-world.road.y_rotation[1])-self.perceived_angle)/(180/#impreza))
                    self.source_i = 1
                elseif math.abs(self.perceived_dir) < 30 then
                    self.source_i = 2
                elseif math.abs(self.perceived_dir) < 43 then
                    self.source_i = 3
                elseif math.abs(self.perceived_dir) < 55 then
                    self.source_i = 4
                else
                    self.source_i = 5
                end
                
                
                r.x = (y*angle+x)/(screen_w+2*y*angle)*screen_w
                r.y = screen_h-y*angle/(screen_h+2*y*angle)*screen_h
                
                --print(self.source_i,self.perceived_dir)
                --    x, y, math.floor(t_pt.x),
                --    math.floor(r.x),math.floor(r.y)
                --)
                
                
                r:raise_to_top()
                --((self.y_rot-world.road.y_rotation[1])-self.perceived_angle),"\t",
                --[[
                print(self.perceived_angle,"\t",self.source_i,"\t",
                    self.perceived_dir,
                    t_pt.x,   t_pt.y,"\t", prev_pt.x-t_pt.x,prev_pt.y-t_pt.y )
                --]]
                self.prev_pt.x = self.x
                self.prev_pt.y = self.y
                --print("x",self.x-world.cars.anchor_point[1],"y",self.y-world.cars.anchor_point[2])
                --print("angles",self.perceived_angle,self.y_rot,world.road.y_rotation[1],self.source_i)
                --
                --print(self.source_i)
                self.source=subaru[self.source_i]
                self.anchor_point = {subaru[self.source_i].w/2,subaru[self.source_i].h*2/3}
                self.dx_remaining_in_path = self.dx_remaining_in_path - dx
                self.dr_remaining_in_path = self.dr_remaining_in_path - dr
                self.y_rot = self.y_rot - dr
                return false
            end
        }
    }
end
