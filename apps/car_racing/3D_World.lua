local road = {
	newest_segment = nil,
	curr_segment   = nil,
	oldest_segment = nil,
	segments       = {}
}

Game_State.end_point           = {0,0,0}
local dist_to_end_point   = {0,0}


local sky = Assets:Clone{src="assets/world/skyline.png",x=screen.w/2,y=-17,scale={2,2}}--Rectangle{name="THE SKY",w=screen.w,h=screen.h,color="172e57"}
local sky_w = sky.w
sky.anchor_point={sky.w/2,0}

--tail_lights = Assets:Clone{name="brake lights",src="assets/Lambo/brake.png",position={screen.w/2,5*screen.h/6+63},opacity=0}
--tail_lights.anchor_point = {tail_lights.w/2,tail_lights.h/2}
local horizon_grad = Assets:Clone{name="Fog of... Racing...",src="assets/world/gradient.png",tile={true,false},w=screen_w,y=2*sky.h-17,scale={1,2}}
section_i = 1
--active_sections = {}
local ground_backing = Rectangle{w=screen_w,h=screen_h,color="362818"}


local World = {
    road    = Group{name="Road Layer",   x_rotation={90,0,0},position={screen.w/2,screen.h}},
    cars    = Group{name="Car Layer",    x_rotation={90,0,0},position={screen.w/2,screen.h}},
    lanes   = {}
}
for i = 1, NUM_LANES do
    World.lanes[i] = Group{}
    World.cars:add(World.lanes[i])
end

local new_pos = {}
local w_ap_x = 0
local w_ap_y = 0
local y_rot  = 0
local dist_from_center = 0

local adjust_position = function()
    
    World.road.anchor_point = {
        w_ap_x+dist_from_center*math.cos(math.pi/180*y_rot),
        w_ap_y+dist_from_center*math.sin(math.pi/180*y_rot)
    }
    World.cars.anchor_point = {
        (w_ap_x+dist_from_center*math.cos(math.pi/180*y_rot)),
        (w_ap_y+dist_from_center*math.sin(math.pi/180*y_rot))
    }
end

local self = World
local add_next_section = function()

    next_section = sections[section_i]()
    
    
    road.segments[next_section] = next_section.path
    if road.newest_segment then
        next_section.prev_segment        = road.newest_segment
        road.newest_segment.next_segment = next_section
    end
    road.newest_segment = next_section
    
    self.road:add( next_section )
    
    --position the next section of road
    --print(next_section.x,next_section.y,"\t",Game_State.end_point[1], Game_State.end_point[2])
    next_section:move_by( Game_State.end_point[1], Game_State.end_point[2] )
    next_section.z_rotation={Game_State.end_point[3],0,0}
    
    --factor in the end point of the next section
    Game_State.end_point[1] = Game_State.end_point[1] +
        next_section.end_point[1]*math.cos(math.pi/180*Game_State.end_point[3]) -
        next_section.end_point[2]*math.sin(math.pi/180*Game_State.end_point[3])
    
    Game_State.end_point[2] = Game_State.end_point[2] +
        next_section.end_point[1]*math.sin(math.pi/180*Game_State.end_point[3]) +
        next_section.end_point[2]*math.cos(math.pi/180*Game_State.end_point[3])
    
    Game_State.end_point[3] = Game_State.end_point[3] + next_section.end_point[3]
    
    dist_to_end_point[1] = Game_State.end_point[1]-w_ap_x
    dist_to_end_point[2] = Game_State.end_point[2]-w_ap_y
    
    --next index
    section_i = section_i%#sections + 1
    
end

local remove_oldest_section = function()
    
    --table.remove(active_sections,1):remove()
    --print("delete ",road.oldest_segment.name)
    road.oldest_segment:remove()
    road.segments[road.oldest_segment] = nil
    road.oldest_segment = road.oldest_segment.next_segment
    road.oldest_segment.prev_segment = road.oldest_segment
    
    assert(road.oldest_segment ~= nil)
    
    new_pos.x = road.oldest_segment.x
    new_pos.y = road.oldest_segment.y
    
    Game_State.end_point[1] = Game_State.end_point[1] - new_pos.x
    Game_State.end_point[2] = Game_State.end_point[2] - new_pos.y
    
    w_ap_x = w_ap_x - new_pos.x
    w_ap_y = w_ap_y - new_pos.y
    
    adjust_position()
    
    for next_section,path in pairs(road.segments) do
        next_section.x = next_section.x - new_pos.x
        next_section.y = next_section.y - new_pos.y
    end
    
    for _,car in ipairs(self.other_cars_ref) do
        car.x = car.x - new_pos.x
        car.y = car.y - new_pos.y
    end
end

function World:normalize_to(section)
    
    print("normalized by:",w_ap_x-section.x,w_ap_y-section.y)
    w_ap_x = section.x
    w_ap_y = section.y
    
    remove_oldest_section()
    
    adjust_position()
end

do
    
    local cent_x,cent_y,delta_x,delta_y
    
    function World:move(dy,dx,dr,radius)
        dist_from_center = dx
        if dr ~= 0 then
            --curve_impulse = curve_impulse - dr
            --radius = radius - car.dx
            cent_x = radius*math.cos(math.pi/180*y_rot)
            cent_y = radius*math.sin(math.pi/180*y_rot)
            
            --car.dx = car.dx + 20*dr
            
            y_rot = y_rot+dr
            --print(w_ap_x-cent_x.."\t"..w_ap_y-cent_y.."\t"..y_rot.."\t\t"..w_ap_x.."\t"..w_ap_y)
            self.road.y_rotation    = {y_rot,0,0}
            self.cars.y_rotation    = {y_rot,0,0}
            sky.x = screen_w/2-sky_w/2*math.sin(math.pi/180*y_rot)
            
            delta_x =  radius*math.cos(math.pi/180*y_rot)-cent_x
            delta_y = -radius*math.sin(math.pi/180*y_rot)+cent_y
            
            --car.dx = car.dx - delta_x/2*dr/math.abs(dr)
        else
            delta_x = dy*math.sin(math.pi/180*y_rot)
            delta_y = dy*math.cos(math.pi/180*y_rot)
        end
        --print(delta_y)
        
        w_ap_x = w_ap_x+delta_x
        w_ap_y = w_ap_y-delta_y
        
        adjust_position(dx)
        
        dist_to_end_point[1]   = dist_to_end_point[1]   - delta_x
        dist_to_end_point[2]   = dist_to_end_point[2]   + delta_y
        
        if math.abs(dist_to_end_point[1]) < 30000 and
        math.abs(dist_to_end_point[2]) < 30000 then
            
            add_next_section()
        end
        
        if road.curr_segment ~= road.oldest_segment and
        (math.abs(w_ap_x) > 20000 or
            math.abs(w_ap_y) > 20000) then
            
            remove_oldest_section()
        end
    end
end
local setup_road = function()
    section_i = 1
    road.segments={}
    add_next_section()
    road.curr_segment   = road.newest_segment
    road.oldest_segment = road.newest_segment
    road.newest_segment.prev_segment = road.newest_segment
    dumptable(road)
end

World.reset = function(self)
    self.road:clear()
    self.cars:clear()
    self.road.anchor_point = {0,0}
    self.cars.anchor_point = {0,0}
    self.road.y_rotation   = {0,0,0}
    self.cars.y_rotation   = {0,0,0}
    --section_i = 1
    w_ap_x  = 0
    w_ap_y  = 0
    y_rot=0
    
    
    
    --road={segments={}}
    Game_State.end_point[1] = 0
    Game_State.end_point[2] = 0
    Game_State.end_point[3] = 0
    dist_to_end_point[1] = 0
    dist_to_end_point[2] = 0
    --end_game:lower_to_bottom()
    --car.dx = 1000
    setup_road()
end
--[[
Game_State:add_state_change_function(
    reset_World,
    STATES.CRASH,
    STATES.PLAYING
)
Game_State:add_state_change_function(
    reset_World,
    STATES.SPLASH,
    STATES.PLAYING
)
--]]
screen:add(
    ground_backing,
    sky,    
    World.road,
    horizon_grad,
    World.cars
)


return World, road