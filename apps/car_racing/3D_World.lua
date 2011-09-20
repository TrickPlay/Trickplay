local road = {
	newest_segment = nil,
	curr_segment   = nil,
	oldest_segment = nil,
	segments       = {}
}

Game_State.end_point           = {0,0,0}
local dist_to_end_point   = {0,0}


local sky = Assets:Clone{src="assets/world/skyline.png",x=screen_w/2,y=-20,scale={2,2}}--Rectangle{name="THE SKY",w=screen.w,h=screen.h,color="172e57"}
local sky_w = sky.w
sky.anchor_point={sky.w/2,0}

--tail_lights = Assets:Clone{name="brake lights",src="assets/Lambo/brake.png",position={screen.w/2,5*screen.h/6+63},opacity=0}
--tail_lights.anchor_point = {tail_lights.w/2,tail_lights.h/2}
local horizon_grad = Assets:Clone{name="Fog of... Racing...",src="assets/world/gradient.png",tile={true,false},w=screen_w,y=2*sky.h-20,scale={1,2}}
section_i = 1
--active_sections = {}
local ground_backing = Rectangle{w=screen_w,h=screen_h,color="362818"}


local World = {
    road    = Group{name="Road Layer",   x_rotation={90,0,0},position={screen.w/2,screen.h}},
    cars    = Group{name="Car Layer",    x_rotation={90,0,0},position={screen.w/2,screen.h}},
    doodads = Group{name="Doodad Layer", x_rotation={90,0,0},position={screen.w/2,screen.h}},
    lanes   = {}
}
for i = 1, NUM_LANES do
    World.lanes[i] = Group{}
    World.cars:add(World.lanes[i])
end

local doodad_counter = 0
local doodad_thresh = 0
local plant_counter = 0
local plant_thresh = 0
local new_pos = {}
Game_State.draw_point = {
    
    curr_section = nil,
    
    dx_remaining_in_path = 0,
    
    dr_remaining_in_path = 0,
    
    x=0,
    
    y=0,
    
    y_rot=0,
}
local w_ap_x = 0
local w_ap_y = 0
local y_rot  = 0
local dist_from_center = 0

local adjust_position = function()
    
    World.road.anchor_point = {
        w_ap_x+dist_from_center*cos(y_rot),
        w_ap_y+dist_from_center*sin(y_rot)
    }
    World.cars.anchor_point = {
        (w_ap_x+dist_from_center*cos(y_rot)),
        (w_ap_y+dist_from_center*sin(y_rot))
    }
    World.doodads.anchor_point = {
        (w_ap_x+dist_from_center*cos(y_rot)),
        (w_ap_y+dist_from_center*sin(y_rot))
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
        next_section.end_point[1]*cos(Game_State.end_point[3]) -
        next_section.end_point[2]*sin(Game_State.end_point[3])
    
    Game_State.end_point[2] = Game_State.end_point[2] +
        next_section.end_point[1]*sin(Game_State.end_point[3]) +
        next_section.end_point[2]*cos(Game_State.end_point[3])
    
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
    
    Game_State.draw_point.x = Game_State.draw_point.x - new_pos.x
    Game_State.draw_point.y = Game_State.draw_point.y - new_pos.y
    
    w_ap_x = w_ap_x - new_pos.x
    w_ap_y = w_ap_y - new_pos.y
    
    adjust_position()
    
    for next_section,path in pairs(road.segments) do
        next_section.x = next_section.x - new_pos.x
        next_section.y = next_section.y - new_pos.y
    end
    
    for car,_ in pairs(self.other_cars_ref.list) do
    --for _,car in ipairs(self.other_cars_ref) do
        car.x = car.x - new_pos.x
        car.y = car.y - new_pos.y
    end
    
    for doodad,_ in pairs(Doodads.listing) do
        doodad.x = doodad.x - new_pos.x
        doodad.y = doodad.y - new_pos.y
    end
end

function World:normalize_to(section)
    
    --print("normalized by:",w_ap_x-section.x,w_ap_y-section.y)
    w_ap_x = section.x
    w_ap_y = section.y
    
    remove_oldest_section()
    
    adjust_position()
end



Game_State.draw_point.update = function(self,dy)
    
    dr = dy/self.curr_section.path.dist*self.curr_section.path.rot
    
    while dy > self.dx_remaining_in_path do
        self.x = Game_State.end_point[1]--self.x - self.dx_remaining_in_path*sin(self.y_rot)
        self.y = Game_State.end_point[2]--self.y - self.dx_remaining_in_path*cos(self.y_rot)
        
        self.y_rot = -Game_State.end_point[3]--self.y_rot - self.dr_remaining_in_path 
        
        dy = dy - self.dx_remaining_in_path
        dr = dy/self.curr_section.path.dist*self.curr_section.path.rot
        
        add_next_section()
        
        self.curr_section = self.curr_section.next_segment
        
        self.dx_remaining_in_path = self.curr_section.path.dist
        self.dr_remaining_in_path = self.curr_section.path.rot
    end
    
    self.x = self.x - dy*sin(self.y_rot)
    self.y = self.y - dy*cos(self.y_rot)
    
    self.y_rot = self.y_rot - dr
    
    self.dx_remaining_in_path = self.dx_remaining_in_path - dy
    self.dr_remaining_in_path = self.dr_remaining_in_path - dr
    
end


do
    
    local cent_x,cent_y,delta_x,delta_y, upval
    
    
    function World:move(dy,dx,dr,radius)
        dist_from_center = dx
        if dr ~= 0 then
            --curve_impulse = curve_impulse - dr
            --radius = radius - car.dx
            cent_x = radius*cos(y_rot)
            cent_y = radius*sin(y_rot)
            
            --car.dx = car.dx + 20*dr
            
            y_rot = y_rot+dr
            --print(w_ap_x-cent_x.."\t"..w_ap_y-cent_y.."\t"..y_rot.."\t\t"..w_ap_x.."\t"..w_ap_y)
            self.road.y_rotation    = {y_rot,0,0}
            self.cars.y_rotation    = {y_rot,0,0}
            self.doodads.y_rotation = {y_rot,0,0}
            
            
            delta_x =  radius*cos(y_rot)-cent_x
            delta_y = -radius*sin(y_rot)+cent_y
            
            --car.dx = car.dx - delta_x/2*dr/math.abs(dr)
        else
            delta_x = dy*sin(y_rot)
            delta_y = dy*cos(y_rot)
        end
        
        sky.x = screen_w/2-sky_w/2*sin(y_rot)
        
        doodad_counter = doodad_counter + dy
        
        if doodad_counter > doodad_thresh and Game_State.current_state() ~= STATES.CRASH then
            
            doodad_counter = 0
            
            doodad_thresh = DRAW_THRESH+20000*(2*(math.random()+1)-3)
            
            upval = Doodads:random(Game_State.end_point)
            
            self.doodads:add(upval)
            
            Idle_Loop:add_function(upval.check,upval)
            
            upval:lower_to_bottom()
            
        end
        
        plant_counter = plant_counter + dy
        
        if plant_counter > plant_thresh and Game_State.current_state() ~= STATES.CRASH then
            
            plant_counter = 0
            
            plant_thresh = 10000+3000*(2*(math.random()+1)-3)
            
            upval = Doodads:random_plant(Game_State.end_point)
            
            self.doodads:add(upval)
            
            Idle_Loop:add_function(upval.check,upval)
            
            upval:lower_to_bottom()
            
        end
        
        
        --print(delta_y)
        
        w_ap_x = w_ap_x+delta_x
        w_ap_y = w_ap_y-delta_y
        
        adjust_position(dx)
        
        dist_to_end_point[1]   = dist_to_end_point[1]   - delta_x
        dist_to_end_point[2]   = dist_to_end_point[2]   + delta_y
        --[[
        if  math.abs(dist_to_end_point[1]) < DRAW_THRESH and
            math.abs(dist_to_end_point[2]) < DRAW_THRESH then
            
            add_next_section()
        end--]]
        
        Game_State.draw_point:update(dy)
        
        if road.curr_segment ~= road.oldest_segment and
        (math.abs(w_ap_x) > 20000 or
            math.abs(w_ap_y) > 20000) then
            
            remove_oldest_section()
        end
    end
end

local setup_draw_point = function()
    --initialize/reset the initial values
    Game_State.draw_point.curr_section         = road.curr_segment
    Game_State.draw_point.dx_remaining_in_path = road.curr_segment.path.dist
    Game_State.draw_point.dr_remaining_in_path = road.curr_segment.path.rot
    Game_State.draw_point.x     = 0
    Game_State.draw_point.y     = 0
    Game_State.draw_point.y_rot = 0
    --push out the draw point to satisfy the threshold
    Game_State.draw_point:update(DRAW_THRESH)
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
    --for i = 1, NUM_LANES do
    --    world.lanes[i]:clear()
    --end
    self.road.anchor_point    = {0,0}
    self.cars.anchor_point    = {0,0}
    self.doodads.anchor_point = {0,0}
    self.road.y_rotation      = {0,0,0}
    self.cars.y_rotation      = {0,0,0}
    self.doodads.y_rotation   = {0,0,0}
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
    setup_draw_point()
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
    World.cars,
    World.doodads
)


return World, road