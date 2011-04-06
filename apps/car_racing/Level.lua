local ADD_THRESH
local DEL_THRESH
sections = {}
section_i = 1
active_sections = {}
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
    
    end_point[1] = end_point[1] + sections[section_i].end_point[1]
    end_point[2] = end_point[2] + sections[section_i].end_point[2]
    
    section_i = section_i + 1
end

function world:remove_oldest_section()
    
end




-------------------------------------------------------------------------------
-- Movement functions
local y_rot = 0
-- turn
function world:rotate_by(deg)
    
    y_rot = y_rot+deg
    self.y_rotation={y_rot,0,0}
    
end

local ap_x = 0
local ap_y = 0
-- move forward or backward
function world:move_by(delta)
    
    ap_x = ap_x-delta*math.sin(math.pi/180*y_rot)
    ap_y = ap_y+delta*math.cos(math.pi/180*y_rot)
    
    self.anchor_point = { ap_x, ap_y }
    
end