local road_scale = 4

--the global list of sections
local sections = {}

--upvals
local section
local prev_straights = {}
local prev_sing_straights = {}
local prev_curves = {}

function make_straight_section()
    
    if #prev_straights ~= 0 then
        section = table.remove(prev_straights)
        section.position   = {0,0}
        return section
        
    else
        
        section =  Assets:Clone{
            
            name   = "Str8 Road",
            
            src="assets/world/road.png",
            
            x_rotation = {180,0,0},
            
            scale={road_scale,road_scale},
            
            
            
            extra = {
                
                
                
                remove = function(self)
                    table.insert(prev_straights,self)
                    self:unparent()
                end
            }
        }
        
        section.anchor_point = { section.w/2, 0 }
        section.end_point = { 0, -road_scale*section.h, 0 }
                
        section.path = {
                    dist   = road_scale*section.h,
                    rot    = 0,
                    radius = 0
                }
        section.path.parent = section
        
        return section
    end
    
end
function make_right_curved_piece()
    local rad = 8000*20
    local rot = 1.4065/5
    
    if #prev_curves ~= 0 then
        
        section = table.remove(prev_curves)
        
        section.extra.end_point = {
            -rad*math.cos(math.pi/180*rot)+rad,
            -rad*math.sin(math.pi/180*rot),rot
        }
        section.extra.path = {
            dist   = (2*math.pi*(rad))*(rot/360),
            radius = -rad,
            rot    = rot,
            parent = section,
        }
        
        section.y_rotation={0,0,0}
        section.position   = {0,0}
        
        return section
        
    else
        
        section = Assets:Clone{
            
            name   = "Curved Road",
            
            src="assets/world/road_curve.png",
            
            
            
            scale={4,4},
            
            extra = {
                
                end_point = {
                    -rad*math.cos(math.pi/180*rot)+rad,
                    -rad*math.sin(math.pi/180*rot),rot
                },
                
                path = {
                    
                    dist   = (2*math.pi*(rad))*(rot/360),
                    
                    radius = -rad,
                    
                    rot    = rot
                },
                
                remove = function(self)
                    table.insert(prev_curves,self)
                    self:unparent()
                end
            }
        }
        
        section.path.parent = section
        section.anchor_point = {
                
                section.w/2,
                
                section.h
                
            }
        
        return section
    end
    
end
function make_left_curved_piece()
    local rad = -8000*20
    local rot = -1.4065/5
    
    if #prev_curves ~= 0 then
        
        section = table.remove(prev_curves)
        
        section.end_point = {
            -rad*math.cos(math.pi/180*rot)+rad,
            -rad*math.sin(math.pi/180*rot),rot
        }
        section.path = {
            dist   = (2*math.pi*(rad))*(rot/360),
            radius = -rad,
            rot    = rot,
            parent = section,
        }
        
        section.y_rotation = {180,0,0}
        section.position   = {0,0}
        
        return section
        
    else
        
        section = Assets:Clone{
            
            name   = "Curved Road",
            
            src="assets/world/road_curve.png",
            
            
            
            y_rotation={180,0,0},
            
            scale={4,4},
            
            extra = {
                
                end_point = {
                    -rad*math.cos(math.pi/180*rot)+rad,
                    -rad*math.sin(math.pi/180*rot),rot
                },
                
                path = {
                    
                    dist   = (2*math.pi*(rad))*(rot/360),
                    
                    radius = -rad,
                    
                    rot    = rot
                },
                
                remove = function(self)
                    table.insert(prev_curves,self)
                    self:unparent()
                end
            }
        }
        
        section.path.parent = section
        
        section.anchor_point = {
            
            section.w/2,
            
            section.h
            
        }
        
        return section
    end
    
end

table.insert(sections,make_straight_section  )
--table.insert(sections,make_straight_section  )
--table.insert(sections,make_straight_section  )
--table.insert(sections,make_straight_section  )
---[[
table.insert(sections,make_right_curved_piece)
table.insert(sections,make_right_curved_piece)
table.insert(sections,make_right_curved_piece)
table.insert(sections,make_right_curved_piece)
table.insert(sections,make_right_curved_piece)

table.insert(sections,make_right_curved_piece)
table.insert(sections,make_right_curved_piece)
table.insert(sections,make_right_curved_piece)
table.insert(sections,make_right_curved_piece)
table.insert(sections,make_right_curved_piece)
table.insert(sections,make_right_curved_piece)
table.insert(sections,make_right_curved_piece)
table.insert(sections,make_right_curved_piece)
table.insert(sections,make_right_curved_piece)
table.insert(sections,make_right_curved_piece)
--]]
table.insert(sections,make_straight_section  )
table.insert(sections,make_straight_section  )
table.insert(sections,make_straight_section  )
table.insert(sections,make_straight_section  )

--table.insert(sections,make_left_curved_piece)
--table.insert(sections,make_left_curved_piece)
--table.insert(sections,make_left_curved_piece)
--table.insert(sections,make_left_curved_piece)
--table.insert(sections,make_left_curved_piece)
--table.insert(sections,make_left_curved_piece)
--table.insert(sections,make_left_curved_piece)
--table.insert(sections,make_left_curved_piece)
--table.insert(sections,make_left_curved_piece)
--table.insert(sections,make_left_curved_piece)
--table.insert(sections,make_left_curved_piece)
--table.insert(sections,make_left_curved_piece)
--table.insert(sections,make_left_curved_piece)
--table.insert(sections,make_left_curved_piece)
--table.insert(sections,make_left_curved_piece)
--[[
table.insert(sections,make_left_curved_piece )
table.insert(sections,make_left_curved_piece )
table.insert(sections,make_left_curved_piece )
table.insert(sections,make_left_curved_piece )
table.insert(sections,make_left_curved_piece )
--]]
return sections