local ADD_THRESH
local DEL_THRESH
local TILE_W=240*4
local TILE_H=240*4

local end_marker = Rectangle{
    w=100, h=100, color = "ff0000", anchor_point = {50,50}
}
end_marker:hide()
local prev_end_marker = Rectangle{
    w=100, h=100, color = "ffff00", anchor_point = {50,50}
}
prev_end_marker:hide()
local sky = Image{src="skyline.png",x=screen.w/2}--Rectangle{name="THE SKY",w=screen.w,h=screen.h,color="172e57"}
sky.anchor_point={sky.w/2,0}
car = Image{name="THE CAR",src="assets/Lambo/0.png",position={screen.w/2,5*screen.h/6},scale={1.2,1.1}}
car.anchor_point = {car.w/2,car.h/2}
local horizon_grad = Image{src="gradient.png",tile={true,false},w=screen_w,y=sky.h-17,scale={1,2}}
section_i = 1
--active_sections = {}
local ground = Image{
    name  = "THE GROUND",
    src   = "desert.png",
    tile  = {true,true},
    size  = {40000,40000},
    scale = {4,4},
    position={screen.w/2,screen.h},
    x_rotation={90,0,0},
}
ground.anchor_point={ground.w/2,ground.h-1000}

--world = Group{name = "THE WORLD",position={screen.w/2,screen.h},x_rotation={90,0,0},scale={4,4}}
world = {
    road    = Group{name="Road Layer",   x_rotation={90,0,0},position={screen.w/2,screen.h}},
    doodads = Group{name="Doodad Layer", x_rotation={90,0,0},position={screen.w/2,screen.h}},
    cars    = Group{name="Car Layer",    x_rotation={90,0,0},position={screen.w/2,screen.h}}
}
screen:add(
    ground,
    world.road,
    horizon_grad,
    sky,
    world.doodads,
    world.cars,
    car
)

world.road:add(prev_end_marker,end_marker)
end_point = {0,0,0}
dist_to_end_point = {0,0}
local dist_to_start_point = {0,0}


local w_ap_x = 0
local w_ap_y = 0
local y_rot = 0
local new_pos = {}

local g_dx = 0
local g_dy = 0
local g_cent_x = ground.anchor_point[1]
local g_cent_y = ground.anchor_point[2]

local delta_x = 0
local delta_y = 0

function world:adjust_position()
    self.road.anchor_point = {
        w_ap_x+strafed_dist*math.cos(math.pi/180*y_rot),
        w_ap_y+strafed_dist*math.sin(math.pi/180*y_rot)
    }
    self.doodads.anchor_point = {
        w_ap_x+strafed_dist*math.cos(math.pi/180*y_rot),
        w_ap_y+strafed_dist*math.sin(math.pi/180*y_rot)
    }
    self.cars.anchor_point = {
        (w_ap_x+strafed_dist*math.cos(math.pi/180*y_rot)),
        (w_ap_y+strafed_dist*math.sin(math.pi/180*y_rot))
    }
end

local next_section

function world:add_next_section()
    
    next_section = sections[section_i]()
    
    --table.insert( active_sections, next_section )
    
    
    road.segments[next_section] = next_section.path
    if road.newest_segment then
        next_section.prev_segment        = road.newest_segment
        road.newest_segment.next_segment = next_section
    end
    road.newest_segment = next_section
    --table.insert( path, next_section.path )
    if next_section.name == "Str8 Road" and road.newest_segment ~= nil then
        table.insert(other_cars,make_passing_subaru(road.newest_segment,end_point,1000))
		world.cars:add(other_cars[#other_cars])
    end
    self.road:add( next_section )
    
    --position the next section of road
    --print(next_section.x,next_section.y,"\t",end_point[1], end_point[2])
    next_section:move_by( end_point[1], end_point[2] )
    next_section.z_rotation={end_point[3],0,0}
    
    --the previous-end-point marker
    prev_end_marker.position = end_marker.position
    prev_end_marker:raise_to_top()
    
    --factor in the end point of the next section
    end_point[1] = end_point[1] +
        next_section.end_point[1]*math.cos(math.pi/180*end_point[3]) -
        next_section.end_point[2]*math.sin(math.pi/180*end_point[3])
    
    end_point[2] = end_point[2] +
        next_section.end_point[1]*math.sin(math.pi/180*end_point[3]) +
        next_section.end_point[2]*math.cos(math.pi/180*end_point[3])
    
    end_point[3] = end_point[3] + next_section.end_point[3]
    
    --update the debugging end point marker
    end_marker.position = {end_point[1],end_point[2]}
    end_marker:raise_to_top()
    
    dist_to_end_point[1] = end_point[1]-w_ap_x
    dist_to_end_point[2] = end_point[2]-w_ap_y
    
    --next index
    section_i = section_i%#sections + 1
    
end


function world:remove_oldest_section()
    
    --table.remove(active_sections,1):remove()
    --print("delete ",road.oldest_segment.name)
    road.oldest_segment:remove()
    road.oldest_segment = road.oldest_segment.next_segment
    road.oldest_segment.prev_segment = road.oldest_segment
    
    assert(road.oldest_segment ~= nil)
    --assert(#active_sections > 0)
    
    --new_pos.x = active_sections[1].x
    --new_pos.y = active_sections[1].y
    new_pos.x = road.oldest_segment.x
    new_pos.y = road.oldest_segment.y
    
    --dist_to_start_point[1] = dist_to_start_point[1] - new_pos.x
    --dist_to_start_point[2] = dist_to_start_point[2] - new_pos.y
    
    end_point[1] = end_point[1] - new_pos.x
    end_point[2] = end_point[2] - new_pos.y
    
    --self.anchor_point = { dist_to_start_point[1]+strafed_dist, dist_to_start_point[2] }
    w_ap_x = w_ap_x - new_pos.x
    w_ap_y = w_ap_y - new_pos.y
    
    world:adjust_position()
    
    for next_section,path in pairs(road.segments) do
        next_section.x = next_section.x - new_pos.x
        next_section.y = next_section.y - new_pos.y
    end
    
    for _,car in ipairs(other_cars) do
        car.x = car.x - new_pos.x
        car.y = car.y - new_pos.y
    end
    
    prev_end_marker.x = prev_end_marker.x - new_pos.x
    prev_end_marker.y = prev_end_marker.y - new_pos.y
    
    end_marker.x = end_point[1]
    end_marker.y = end_point[2]
        
end

function world:normalize_to(section)
    
    w_ap_x = section.x
    w_ap_y = section.y
    world:remove_oldest_section()
    --print(world.road.y_rotat)
    
    --dist_to_start_point[1] = w_ap_x
    --dist_to_start_point[2] = w_ap_y
    
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


local dist_to_car = -1000

-- move forward or backward
function world:move(dx,dr,radius)

    if dr ~= 0 then
        
        --radius = radius - strafed_dist
        cent_x = radius*math.cos(math.pi/180*y_rot)
        cent_y = radius*math.sin(math.pi/180*y_rot)
        
        strafed_dist = strafed_dist + 18*dr
        
        y_rot = y_rot+dr
        --print(w_ap_x-cent_x.."\t"..w_ap_y-cent_y.."\t"..y_rot.."\t\t"..w_ap_x.."\t"..w_ap_y)
        self.road.y_rotation   = {y_rot,dist_to_car*math.sin(math.pi/180*y_rot),dist_to_car*math.cos(math.pi/180*y_rot)}
        self.doodads.y_rotation   = {y_rot,dist_to_car*math.sin(math.pi/180*y_rot),dist_to_car*math.cos(math.pi/180*y_rot)}
        self.cars.y_rotation   = {y_rot,dist_to_car*math.sin(math.pi/180*y_rot),dist_to_car*math.cos(math.pi/180*y_rot)}
        ground.y_rotation = {y_rot,dist_to_car*math.sin(math.pi/180*y_rot),dist_to_car*math.cos(math.pi/180*y_rot)}
        sky.x = screen_w/2-sky.w/2*math.sin(math.pi/180*y_rot)
        
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
    
    ground.anchor_point = { g_cent_x + g_dx,  g_cent_y + g_dy }
    
    dist_to_end_point[1]   = dist_to_end_point[1]   - delta_x
    dist_to_end_point[2]   = dist_to_end_point[2]   + delta_y
    --dist_to_start_point[1] = dist_to_start_point[1] + delta_x
    --dist_to_start_point[2] = dist_to_start_point[2] - delta_y
    
    if math.abs(dist_to_end_point[1]) < 10000 and
       math.abs(dist_to_end_point[2]) < 10000 then
        
        world:add_next_section()
    end
    
    if road.curr_segment ~= road.oldest_segment and
       (math.abs(w_ap_x) > 20000 or
        math.abs(w_ap_y) > 20000) then
        
        world:remove_oldest_section()
    end
end

world:add_next_section()

road.curr_segment   = road.newest_segment
road.oldest_segment = road.newest_segment
road.newest_segment.prev_segment = road.newest_segment
--world:set_bounds()