local ADD_THRESH
local DEL_THRESH
local TILE_W=240*4
local TILE_H=240*4



section_i = 1
active_sections = {}
local ground = Image{
    src="grass1.png",
    tile={true,true},
    size={20000,20000},
    scale={4,4},
    position={screen.w/2,screen.h},
    x_rotation={90,0,0},
}
ground.anchor_point={ground.w/2,ground.h/2}

world = Group{x_rotation={90,0,0}}

local end_point = {0,0}








function world:add_next_section()
    
    table.insert(
        active_sections,
        sections[section_i]:setup()
    )
    
    --it is expected that setup sets the section's x and y at the line-up point
    
    self:add( active_sections[#active_sections] )
    
    active_sections[#active_sections].position = {
        active_sections[#active_sections].x+end_point[1],
        active_sections[#active_sections].y+end_point[2],
    }
    
    --new end_point
    end_point[1] = end_point[1] + sections[section_i].end_point[1]
    end_point[2] = end_point[2] + sections[section_i].end_point[2]
    
    section_i = section_i + 1
    
end

function world:remove_oldest_section()
    
    table.remove(active_sections,1):unparent()
    
end




-------------------------------------------------------------------------------
-- Movement functions
local y_rot = 0
-- turn
function world:rotate_by(deg)
    
    y_rot = y_rot+deg
    self.y_rotation={y_rot,0,0}
    ground.y_rotation={y_rot,0,0}
end

local w_ap_x = 0
local w_ap_y = 0
local g_dx = 0
local g_dy = 0
local g_cent = ground.w/2
-- move forward or backward
function world:move(delta)
    
    w_ap_x = w_ap_x-delta*math.sin(math.pi/180*y_rot)
    w_ap_y = w_ap_y+delta*math.cos(math.pi/180*y_rot)
    
    self.anchor_point = { w_ap_x, w_ap_y }
    
    g_dx = (g_dx+delta*math.sin(math.pi/180*y_rot))%TILE_W
    g_dy = (g_dy-delta*math.cos(math.pi/180*y_rot))%TILE_H
    
    ground.anchor_point = { g_cent + g_dx,  g_cent + g_dy }
end

screen:add(ground,world)