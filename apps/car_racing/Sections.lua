local base = {
    straight_road = Image{ src="assets/world/road.png", tile={false,true}, h=20*200},
    --single_straight_road = Image{ src="road.png",tile={false,true}, h=2*200 },
    --curve_road    = Image{ src="road-curvdde-2.png"   },
    curve_piece   = Image{ src="assets/world/road_curve.png"},
    --straight_rail = Image{ src="guardrail.png",     tile={true,false}, w=50*250},
    --cactus        = Image{ src="cactus3.png"},
    --cactus2       = Image{ src="cactus2.png"},
    --sign          = Image{ src="sign-road.png"},
    --tree          = Image{ src="tree.png"},
    --tree2         = Image{ src="tree2.png"},
    --t_weed        = Image{ src="tumble-weed.png"},
}

local road_scale = 4

for _,v in pairs(base) do
    clone_sources:add(v)
end
--[[
local doodads = {
    function() return Clone{
        name = "Cactus",
        source = base.cactus,
        anchor_point = {0,base.cactus.h},
        x_rotation = {-90,0,0},
        x= base.straight_road.w/2 + 10,
        y= -base.straight_road.h/2
    } end,
    function() return Clone{
        name = "Cactus",
        source = base.cactus2,
        anchor_point = {0,base.cactus2.h},
        x_rotation = {-90,0,0},
        x= base.straight_road.w/2 + 10,
        y= -base.straight_road.h/2
    } end,
    function() return Clone{
        name = "Sign",
        source = base.sign,
        anchor_point = {base.sign.w,base.sign.h},
        x_rotation = {-90,0,0},
        x= -base.straight_road.w/2 - 10,
        y= -base.straight_road.h/2
    } end,
    function() return Clone{
        name = "Tree",
        source = base.tree,
        anchor_point = {base.tree.w,base.tree.h},
        x_rotation = {-90,0,0},
        x= -base.straight_road.w/2 - 10,
        y= -base.straight_road.h/2
    } end,
    function() return Clone{
        name = "Tree",
        source = base.tree2,
        anchor_point = {base.tree2.w,base.tree2.h},
        x_rotation = {-90,0,0},
        x= -base.straight_road.w/2 - 10,
        y= -base.straight_road.h/2
    } end,
    function() return Clone{
        name = "t_weed",
        source = base.t_weed,
        anchor_point = {base.t_weed.w,base.t_weed.h},
        x_rotation = {-90,0,0},
        x= base.straight_road.w/2 - 10,
        y= -base.straight_road.h/2
    } end,
}
--]]
--the global list of sections
sections = {}

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
        
        section =  Clone{
            
            name   = "Str8 Road",
            
            source = base.straight_road,
            
            x_rotation = {180,0,0},
            
            scale={road_scale,road_scale},
            
            anchor_point = { base.straight_road.w/2, 0 },
            
            extra = {
                
                end_point = { 0, -road_scale*base.straight_road.h, 0 },
                
                path = {
                    dist   = road_scale*base.straight_road.h,
                    rot    = 0,
                    radius = 0
                },
                
                remove = function(self)
                    table.insert(prev_straights,self)
                    self:unparent()
                end
            }
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
        
        section = Clone{
            
            name   = "Curved Road",
            
            source = base.curve_piece,
            
            anchor_point = {
                
                base.straight_road.w/2,
                
                base.curve_piece.h
                
            },
            
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
        
        section = Clone{
            
            name   = "Curved Road",
            
            source = base.curve_piece,
            
            anchor_point = {
                
                base.straight_road.w/2,
                
                base.curve_piece.h
                
            },
            
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
        
        return section
    end
    
end

table.insert(sections,make_straight_section  )
table.insert(sections,make_straight_section  )
table.insert(sections,make_straight_section  )
table.insert(sections,make_straight_section  )
--
--table.insert(sections,make_right_curved_piece)
--table.insert(sections,make_right_curved_piece)
--table.insert(sections,make_right_curved_piece)
--table.insert(sections,make_right_curved_piece)
--table.insert(sections,make_right_curved_piece)
--
--table.insert(sections,make_right_curved_piece)
--table.insert(sections,make_right_curved_piece)
--table.insert(sections,make_right_curved_piece)
--table.insert(sections,make_right_curved_piece)
--table.insert(sections,make_right_curved_piece)
--table.insert(sections,make_right_curved_piece)
--table.insert(sections,make_right_curved_piece)
--table.insert(sections,make_right_curved_piece)
--table.insert(sections,make_right_curved_piece)
--table.insert(sections,make_right_curved_piece)

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
