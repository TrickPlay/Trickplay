local impreza = {
    Image{ src="assets/impreza/0.png"  },
    Image{ src="assets/impreza/1.png"  },
    Image{ src="assets/impreza/2.png"  },
    Image{ src="assets/impreza/3.png"  },
    Image{ src="assets/impreza/4.png"  },
    Image{ src="assets/impreza/5.png"  },
    Image{ src="assets/impreza/6.png"  },
    Image{ src="assets/impreza/7.png"  },
    Image{ src="assets/impreza/8.png"  },
    Image{ src="assets/impreza/9.png"  },
}

for _,v in pairs(impreza) do
    clone_sources:add(v)
end

local subaru = {
    Image{ src="assets/subaru/0.png"  },
    Image{ src="assets/subaru/1.png"  },
    Image{ src="assets/subaru/2.png"  },
    Image{ src="assets/subaru/3.png"  },
    Image{ src="assets/subaru/4.png"  },
    Image{ src="assets/subaru/5.png"  },
    Image{ src="assets/subaru/6.png"  },
    Image{ src="assets/subaru/7.png"  },
    Image{ src="assets/subaru/8.png"  },
    Image{ src="assets/subaru/9.png"  },
}

for _,v in pairs(subaru) do
    clone_sources:add(v)
end


local curr, dx, dr
local r=Rectangle{w=100,h=100}
screen:add(r)
local prev_pt = {x=0,y=0}
local t_pt = {x=0,y=0}
make_on_coming_impreza = function(last_section,end_point, dist_from_center)
    print("carr with atributes",last_section.path.dist,end_point[1],end_point[2],end_point[3])
    return Clone{
        
        source       =  impreza[3],
        
        anchor_point = {impreza[3].w/2,impreza[3].h},
        
        --scale={.25,.25,.25},
        
        x_rotation   = {-90,0,0},
        
        scale={1.2,1.2},
        
        position = {
            (end_point[1]+dist_from_center*math.cos(math.pi/180*-end_point[3])),
             end_point[2]+dist_from_center*math.sin(math.pi/180*-end_point[3])
        },
        
        extra = {
            
            curr_section = last_section,
            
            curr_path    = last_section.path,
            
            speed = -500,
            
            dx_remaining_in_path = -last_section.path.dist,
            
            dr_remaining_in_path = -last_section.path.rot,
            
            y_rot = 180-end_point[3],
            
            perceived_angle = 0,
            
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
                
                r.x = t_pt.x
                r.y = t_pt.y
                self.perceived_angle = 180/math.pi*math.atan(
                    (self.transformed_position[1]/screen.scale[1]-screen_w/2)/
                    (screen_h-self.transformed_position[2]/screen.scale[2])) +
                    world.cars.y_rotation[1]
                    
                self.perceived_dir = math.atan((prev_pt.x-t_pt.x)/(prev_pt.y-t_pt.y))*180/math.pi
                --if self.perceived_angle < 75 then self.perceived_angle = 75 end
                --print(self.perceived_angle,self.y_rot,world.cars.y_rotation[1])
                
                
                self.source_i = 1
                ---[[
                if self.perceived_dir < -1 then
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
                --((self.y_rot-world.road.y_rotation[1])-self.perceived_angle),"\t",
                --[[
                print(self.perceived_angle,"\t",self.source_i,"\t",
                    self.perceived_dir,
                    
                    
                    t_pt.x,   t_pt.y,"\t", prev_pt.x-t_pt.x,prev_pt.y-t_pt.y )
                --]]
                prev_pt.x = t_pt.x
                prev_pt.y = t_pt.y
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
        
        scale={1.2,1.2},
        
        position = {
            (end_point[1]+dist_from_center*math.cos(math.pi/180*-end_point[3])),
             end_point[2]+dist_from_center*math.sin(math.pi/180*-end_point[3])
        },
        
        extra = {
            
            curr_section = last_section,
            
            curr_path    = last_section.path,
            
            speed = 500,
            
            dx_remaining_in_path = last_section.path.dist,
            
            dr_remaining_in_path = last_section.path.rot,
            
            y_rot = 180-end_point[3],
            
            perceived_angle = 0,
            
            move = function(self,seconds)
                
                if self.curr_section.parent == nil then
                    self:unparent()
                    print("the section i was driving on got deleted, gg")
                    return true
                end
                dx = self.speed*seconds
                dr = -self.curr_path.rot*dx/self.curr_path.dist
                --print(self.dx_remaining_in_path,dx)
                while self.dx_remaining_in_path < dx do
                    self.position = {
                        (self.x + self.dx_remaining_in_path*math.sin(math.pi/180*self.y_rot)),
                        (self.y + self.dx_remaining_in_path*math.cos(math.pi/180*self.y_rot)),
                    }
                    self.y_rot = self.y_rot - self.dr_remaining_in_path 
                    
                    if self.curr_section.next_segment == nil then
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
                if self.z_rotation[1] == 0 then
                    t_pt.x = (self.transformed_position[1]+self.transformed_size[1]/2)/screen.scale[1]
                else
                    t_pt.x = (self.transformed_position[1]-self.transformed_size[1]/2)/screen.scale[1]
                end
                t_pt.y = (self.transformed_position[2]+self.transformed_size[2])/screen.scale[2]
                
                r.x = t_pt.x
                r.y = t_pt.y
                self.perceived_angle = 180/math.pi*math.atan(
                    (self.transformed_position[1]/screen.scale[1]-screen_w/2)/
                    (screen_h-self.transformed_position[2]/screen.scale[2])) +
                    world.cars.y_rotation[1]
                    
                self.perceived_dir = math.atan((prev_pt.x-t_pt.x)/(prev_pt.y-t_pt.y))*180/math.pi
                --if self.perceived_angle < 75 then self.perceived_angle = 75 end
                --print(self.perceived_angle,self.y_rot,world.cars.y_rotation[1])
                
                
                self.source_i = 1
                ---[[
                if self.perceived_dir < -1 then
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
                --((self.y_rot-world.road.y_rotation[1])-self.perceived_angle),"\t",
                --[[
                print(self.perceived_angle,"\t",self.source_i,"\t",
                    self.perceived_dir,
                    
                    
                    t_pt.x,   t_pt.y,"\t", prev_pt.x-t_pt.x,prev_pt.y-t_pt.y )
                --]]
                prev_pt.x = t_pt.x
                prev_pt.y = t_pt.y
                --print("x",self.x-world.cars.anchor_point[1],"y",self.y-world.cars.anchor_point[2])
                --print("angles",self.perceived_angle,self.y_rot,world.road.y_rotation[1],self.source_i)
                --
                --print(self.source_i)
                self.source=subaru[self.source_i]
                self.anchor_point = {subaru[self.source_i].w/2,subaru[self.source_i].h}
                self.dx_remaining_in_path = self.dx_remaining_in_path - dx
                self.dr_remaining_in_path = self.dr_remaining_in_path - dr
                self.y_rot = self.y_rot - dr
                return false
            end
        }
    }
end
