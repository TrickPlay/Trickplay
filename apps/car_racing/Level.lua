local ADD_THRESH
local DEL_THRESH
local TILE_W=240*4
local TILE_H=240*4

local end_marker = Rectangle{
    w=100, h=100, color = "ff0000", anchor_point = {50,50}
}
local prev_end_marker = Rectangle{
    w=100, h=100, color = "ffff00", anchor_point = {50,50}
}
local sky = Image{src="skyline.png",x=screen.w/2}--Rectangle{name="THE SKY",w=screen.w,h=screen.h,color="172e57"}
sky.anchor_point={sky.w/2,0}
car = Image{name="THE CAR",src="car.png",position={screen.w/2,5*screen.h/6},z=10}
car.anchor_point = {car.w/2,car.h/2}

section_i = 1
active_sections = {}
local ground = Image{
    name  = "THE GROUND",
    src   = "desert.png",
    tile  = {true,true},
    size  = {40000,40000},
    scale = {4,4},
    position={screen.w/2,screen.h},
    x_rotation={90,0,0},
}
ground.anchor_point={ground.w/2,ground.h/2}

world = Group{name = "THE WORLD",x_rotation={90,0,0},position={screen.w/2,screen.h},scale={4,4}}
world:add(prev_end_marker,end_marker)
end_point = {0,0,0}
dist_to_end_point = {0,0}
local dist_to_start_point = {0,0}


local w_ap_x = 0
local w_ap_y = 0
local y_rot = 0

function world:adjust_position()
    self.anchor_point = {
        w_ap_x+strafed_dist*math.cos(math.pi/180*y_rot),
        w_ap_y+strafed_dist*math.sin(math.pi/180*y_rot)
    }
end

function world:add_next_section()
    
    table.insert(
        active_sections,
        sections[section_i]:setup()
    )
    
    table.insert(path,sections[section_i].path)
    --dumptable(path)
    
    --it is expected that setup sets the section's x and y at the line-up point
    
    self:add( active_sections[#active_sections] )
    
    active_sections[#active_sections].position = {
        active_sections[#active_sections].x+end_point[1],
        active_sections[#active_sections].y+end_point[2],
    }
    active_sections[#active_sections].z_rotation={end_point[3],0,0}
    
    --new end_point
    prev_end_marker.position = end_marker.position
    prev_end_marker:raise_to_top()
    --dumptable(end_point)
    --dumptable(dist_to_end_point)
    --dumptable(sections[section_i].end_point)
    end_point[1] = end_point[1] +
        sections[section_i].end_point[1]*math.cos(math.pi/180*end_point[3]) -
        sections[section_i].end_point[2]*math.sin(math.pi/180*end_point[3])
    
    --print("x",sections[section_i].end_point[1]*math.cos(math.pi/180*end_point[3]),
    --      sections[section_i].end_point[2]*math.sin(math.pi/180*end_point[3]))
        
    end_point[2] = end_point[2] +
        sections[section_i].end_point[1]*math.sin(math.pi/180*end_point[3]) +
        sections[section_i].end_point[2]*math.cos(math.pi/180*end_point[3])
    --print("y",sections[section_i].end_point[1]*math.sin(math.pi/180*end_point[3]),
    --    sections[section_i].end_point[2]*math.cos(math.pi/180*end_point[3]))
    end_point[3] = end_point[3] + sections[section_i].end_point[3]
    end_marker.position = {end_point[1],end_point[2]}
    
    end_marker:raise_to_top()
    section_i = section_i + 1
    
    
    dist_to_end_point[1] = end_point[1]-w_ap_x
    dist_to_end_point[2] = end_point[2]-w_ap_y
    --dumptable(end_point)
    --print(w_ap_x,w_ap_y)
    --dumptable(dist_to_end_point)
    if section_i > #sections then
        section_i = 1
    end
    --print("END ADD NEXT SECTION\n\n")
end

local new_pos = {}

local g_dx = 0
local g_dy = 0
local g_cent = ground.w/2

local delta_x = 0
local delta_y = 0
function world:remove_oldest_section()
    
    table.remove(active_sections,1):unparent()
    
    assert(#active_sections > 0)
    
    new_pos.x = active_sections[1].x
    new_pos.y = active_sections[1].y
    
    dist_to_start_point[1] = dist_to_start_point[1] - new_pos.x
    dist_to_start_point[2] = dist_to_start_point[2] - new_pos.y
    
    end_point[1] = end_point[1] - new_pos.x
    end_point[2] = end_point[2] - new_pos.y
    
    --self.anchor_point = { dist_to_start_point[1]+strafed_dist, dist_to_start_point[2] }
    w_ap_x = dist_to_start_point[1]
    w_ap_y = dist_to_start_point[2]
    
    world:adjust_position()
    
    for _,section in ipairs(active_sections) do
        section.x = section.x - new_pos.x
        section.y = section.y - new_pos.y
    end
    
    prev_end_marker.x = prev_end_marker.x - new_pos.x
    prev_end_marker.y = prev_end_marker.y - new_pos.y
    
    end_marker.x = end_marker.x - new_pos.x
    end_marker.y = end_marker.y - new_pos.y
    
    print("delete, num active sections is: ",#active_sections)
    
    
    
end

function world:normalize_to(section)
    
    w_ap_x = section.x
    w_ap_y = section.y
    
    dist_to_start_point[1] = w_ap_x
    dist_to_start_point[2] = w_ap_y
    
    --self.anchor_point = { w_ap_x+strafed_dist, w_ap_y }
    world:adjust_position()
end


-------------------------------------------------------------------------------
-- Movement functions

-- turn
function world:rotate_by(deg)
    --if deg ~= 0 then print(deg)end
    y_rot = y_rot+deg
    self.y_rotation={y_rot,0,0}
    ground.y_rotation={y_rot,0,0}
end




-- move forward or backward
function world:move(dx,dr,radius)

    if dr ~= 0 then
        
        
        --radius = radius - strafed_dist
        cent_x = radius*math.cos(math.pi/180*y_rot)
        cent_y = radius*math.sin(math.pi/180*y_rot)
        
        y_rot = y_rot+dr
        --print(w_ap_x-cent_x.."\t"..w_ap_y-cent_y.."\t"..y_rot.."\t\t"..w_ap_x.."\t"..w_ap_y)
        self.y_rotation={y_rot,0,0}
        ground.y_rotation={y_rot,0,0}
        sky.x = sky.w/2-sky.w/2*math.sin(math.pi/180*y_rot)
        
        delta_x = radius*math.cos(math.pi/180*y_rot)-cent_x
        delta_y = -radius*math.sin(math.pi/180*y_rot)+cent_y
        
        --delta_x = dx*math.sin(math.pi/180*y_rot)
        --delta_y = dx*math.cos(math.pi/180*y_rot)
    else
        delta_x = dx*math.sin(math.pi/180*y_rot)
        delta_y = dx*math.cos(math.pi/180*y_rot)
    end
    --print(delta_y)
    
    w_ap_x = w_ap_x+delta_x
    w_ap_y = w_ap_y-delta_y
    
    --self.anchor_point = { w_ap_x+strafed_dist, w_ap_y }
    world:adjust_position()
    
    g_dx = (g_dx+delta_x)%TILE_W
    g_dy = (g_dy-delta_y)%TILE_H
    
    ground.anchor_point = { g_cent + g_dx,  g_cent + g_dy }
    
    dist_to_end_point[1]   = dist_to_end_point[1]   - delta_x
    dist_to_end_point[2]   = dist_to_end_point[2]   + delta_y
    dist_to_start_point[1] = dist_to_start_point[1] + delta_x
    dist_to_start_point[2] = dist_to_start_point[2] - delta_y
    
    if math.abs(dist_to_end_point[1]) < 10000 and
       math.abs(dist_to_end_point[2]) < 10000 then
        
        world:add_next_section()
    end
    
    if math.abs(dist_to_start_point[1]) > 20000 or
       math.abs(dist_to_start_point[2]) > 20000 then
        
        world:remove_oldest_section()
    end
end

screen:add(sky,ground,world,car)
world:add_next_section()

--world:set_bounds()