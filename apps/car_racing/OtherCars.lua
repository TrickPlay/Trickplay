local lambo = {
    Image{ src="assets/Lambo/0.png"  },
    Image{ src="assets/Lambo/1.png"  },
    Image{ src="assets/Lambo/2.png"  },
    Image{ src="assets/Lambo/3.png"  },
    Image{ src="assets/Lambo/4.png"  },
    Image{ src="assets/Lambo/5.png"  },
    Image{ src="assets/Lambo/6.png"  },
    Image{ src="assets/Lambo/7.png"  },
    Image{ src="assets/Lambo/8.png"  },
    Image{ src="assets/Lambo/9.png"  },
    Image{ src="assets/Lambo/10.png" },
}
for _,v in pairs(lambo) do
    clone_sources:add(v)
end
local curr, dx, dr
make_on_coming_lambo = function(last_section,end_point, dist_from_center)
    print("carr with atributes",last_section.path.dist,end_point[1],end_point[2])
    return Clone{
        
        source       =  lambo[9],
        
        anchor_point = {lambo[9].w/2,lambo[9].h},
        
        --scale={.25,.25,.25},
        
        x_rotation   = {-90,0,0},
        
        --scale={1.2,1.1},
        
        position = {
            4*(end_point[1]+dist_from_center*math.cos(math.pi/180*-end_point[3])),
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
            
            move = function(self,seconds)
                
                
                dx = self.speed*seconds
                dr = -self.curr_path.rot*dx/self.curr_path.dist
                
                while self.dx_remaining_in_path > dx do
                    self.position = {
                        (self.x + 4*self.dx_remaining_in_path*math.sin(math.pi/180*self.y_rot)),
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
                    (self.x + 4*dx*math.sin(math.pi/180*self.y_rot)),
                    (self.y + dx*math.cos(math.pi/180*self.y_rot)),
                }
                
                self.perceived_angle = 180/math.pi*math.atan(
                    (self.x-world.cars.anchor_point[1])/
                    (self.y-world.cars.anchor_point[2])) +
                    world.cars.y_rotation[1]
                --print(self.perceived_angle,self.y_rot,world.cars.y_rotation[1])
                self.source_i = 1+math.floor(((self.y_rot-world.road.y_rotation[1])-self.perceived_angle)/(180/#lambo))
                print(self.perceived_angle,self.y_rot,world.road.y_rotation[1],self.source_i)
                print(self.source_i)
                self.source=lambo[self.source_i]
                self.anchor_point = {lambo[self.source_i].w/2,lambo[self.source_i].h}
                self.dx_remaining_in_path = self.dx_remaining_in_path - dx
                self.dr_remaining_in_path = self.dr_remaining_in_path - dr
                self.y_rot = self.y_rot - dr
                return false
            end
        }
    }
end
