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
local sky = Image{src="skyline.png",x=screen.w/2,y=-17}--Rectangle{name="THE SKY",w=screen.w,h=screen.h,color="172e57"}
local sky_w = sky.w
sky.anchor_point={sky.w/2,0}
car = Image{name="THE CAR",src="assets/Lambo/00.png",position={screen.w/2,5*screen.h/6}}
car.v_y = 0
car.v_x = 0
car:hide()
tail_lights = Image{name="brake lights",src="assets/Lambo/brake.png",position={screen.w/2,5*screen.h/6+12},opacity=0}
car.anchor_point = {car.w/2,car.h/2}
tail_lights.anchor_point = {tail_lights.w/2,tail_lights.h/2}
local horizon_grad = Image{src="gradient.png",tile={true,false},w=screen_w,y=sky.h-17,scale={1,2}}
section_i = 1
--active_sections = {}
local ground_backing = Rectangle{w=screen_w,h=screen_h,color="362818"}


--world = Group{name = "THE WORLD",position={screen.w/2,screen.h},x_rotation={90,0,0},scale={4,4}}
world = {
    road    = Group{name="Road Layer",   x_rotation={90,0,0},position={screen.w/2,screen.h}},
    cars    = Group{name="Car Layer",    x_rotation={90,0,0},position={screen.w/2,screen.h}}
}
screen:add(
    ground_backing,
    --ground_wall,
    sky,
    --ground,
    
    world.road,
    horizon_grad,
    
    world.cars,
    car,
    tail_lights
)

world.road:add(prev_end_marker,end_marker)
end_point = {0,0,0}
dist_to_end_point = {0,0}
local dist_to_start_point = {0,0}


local w_ap_x = 0
local w_ap_y = 0
local y_rot = 0
local new_pos = {}

local delta_x = 0
local delta_y = 0

function world:reset()
    self.road:clear()
    self.cars:clear()
    self.road.anchor_point = {0,0}
    self.cars.anchor_point = {0,0}
    self.road.y_rotation   = {0,0,0}
    self.cars.y_rotation   = {0,0,0}
    section_i = 1
    crashed = false
    num_passing_cars = 0
    car.v_x = 0
    car.v_y = 0
    w_ap_x = 0
    w_ap_y = 0
    other_cars = {}
    
    end_point[1] = 0
    end_point[2] = 0
    end_point[3] = 0
    dist_to_end_point[1] = 0
    dist_to_end_point[2] = 0
    end_game:lower_to_bottom()
    strafed_dist = 1400
    world:add_next_section()
end
function world:adjust_position()
    self.road.anchor_point = {
        w_ap_x+strafed_dist*math.cos(math.pi/180*y_rot),
        w_ap_y+strafed_dist*math.sin(math.pi/180*y_rot)
    }
    self.cars.anchor_point = {
        (w_ap_x+strafed_dist*math.cos(math.pi/180*y_rot)),
        (w_ap_y+strafed_dist*math.sin(math.pi/180*y_rot))
    }
end
local pos = {-960,-960/3,960/3,960}
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
    ---[[
    if next_section.name == "Str8 Road" and road.newest_segment ~= nil  then
        if num_passing_cars < 4 then
            table.insert(other_cars,make_car(road.newest_segment,end_point,pos[math.random(3,4)]))
            world.cars:add(other_cars[#other_cars])
            other_cars[#other_cars]:lower_to_bottom()
            num_passing_cars = num_passing_cars + 1
        end
        print(num_passing_cars)
        table.insert(other_cars,make_car(road.newest_segment,end_point,pos[math.random(1,2)]))
		world.cars:add(other_cars[#other_cars])
        other_cars[#other_cars]:lower_to_bottom()
    end
    --]]
    self.road:add( next_section )
    
    --position the next section of road
    --print(next_section.x,next_section.y,"\t",end_point[1], end_point[2])
    next_section:move_by( end_point[1], end_point[2] )
    next_section.z_rotation={end_point[3],0,0}
    
    --the previous-end-point marker
    --prev_end_marker.position = end_marker.position
    --prev_end_marker:raise_to_top()
    
    --factor in the end point of the next section
    end_point[1] = end_point[1] +
        next_section.end_point[1]*math.cos(math.pi/180*end_point[3]) -
        next_section.end_point[2]*math.sin(math.pi/180*end_point[3])
    
    end_point[2] = end_point[2] +
        next_section.end_point[1]*math.sin(math.pi/180*end_point[3]) +
        next_section.end_point[2]*math.cos(math.pi/180*end_point[3])
    
    end_point[3] = end_point[3] + next_section.end_point[3]
    
    --update the debugging end point marker
    --end_marker.position = {end_point[1],end_point[2]}
    --end_marker:raise_to_top()
    
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
    
    --prev_end_marker.x = prev_end_marker.x - new_pos.x
    --prev_end_marker.y = prev_end_marker.y - new_pos.y
    
    --end_marker.x = end_point[1]
    --end_marker.y = end_point[2]
        
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


local dist_to_car = -1000
local impulse_dampening = .1
-- move forward or backward
function world:move(dx,dr,radius)

    if dr ~= 0 then
        --curve_impulse = curve_impulse - dr
        --radius = radius - strafed_dist
        cent_x = radius*math.cos(math.pi/180*y_rot)
        cent_y = radius*math.sin(math.pi/180*y_rot)
        
        --strafed_dist = strafed_dist + 20*dr
        
        y_rot = y_rot+dr
        --print(w_ap_x-cent_x.."\t"..w_ap_y-cent_y.."\t"..y_rot.."\t\t"..w_ap_x.."\t"..w_ap_y)
        self.road.y_rotation    = {y_rot,0,0}
        self.cars.y_rotation    = {y_rot,0,0}
        sky.x = screen_w/2-sky_w/2*math.sin(math.pi/180*y_rot)
        
        delta_x = radius*math.cos(math.pi/180*y_rot)-cent_x
        delta_y = -radius*math.sin(math.pi/180*y_rot)+cent_y
        
        strafed_dist = strafed_dist - delta_x/2*dr/math.abs(dr)
    else
        delta_x = dx*math.sin(math.pi/180*y_rot)
        delta_y = dx*math.cos(math.pi/180*y_rot)
    end
    --print(delta_y)
    
    w_ap_x = w_ap_x+delta_x
    w_ap_y = w_ap_y-delta_y
    
    --self.anchor_point = { w_ap_x+strafed_dist, w_ap_y }
    world:adjust_position()
    
    dist_to_end_point[1]   = dist_to_end_point[1]   - delta_x
    dist_to_end_point[2]   = dist_to_end_point[2]   + delta_y
    --dist_to_start_point[1] = dist_to_start_point[1] + delta_x
    --dist_to_start_point[2] = dist_to_start_point[2] - delta_y
    
    if math.abs(dist_to_end_point[1]) < 30000 and
       math.abs(dist_to_end_point[2]) < 30000 then
        
        world:add_next_section()
    end
    
    if road.curr_segment ~= road.oldest_segment and
       (math.abs(w_ap_x) > 20000 or
        math.abs(w_ap_y) > 20000) then
        
        world:remove_oldest_section()
    end
end



--world:set_bounds()