local base = {
    straight_road = Image{ src="road-straight.png", tile={false,true}, h=50*250},
    curve_road    = Image{ src="road-curve-2.png"   },
    straight_rail = Image{ src="guardrail.png",     tile={true,false}, w=50*250},
}
for _,v in pairs(base) do
    clone_sources:add(v)
end

sections = {}

function make_straight_section()
    local section = {
        end_point = {0,-base.straight_road.h,0},
        
        line_up  = {0,0},
        setup = function(self)
            self.group = Group{
                name = "A Straight Section",
                children = {
                    Clone{
                        name   = "Road",
                        source = base.straight_road,
                        x_rotation = {180,0,0},
                        ---[[
                        anchor_point = {
                             base.straight_road.w/2,
                            0
                        },--]]
                    },
                    Clone{
                        name   = "Left Rail",
                        source = base.straight_rail,
                        anchor_point = {
                            0,
                            base.straight_rail.h
                        },
                        x=-base.straight_road.w/2,
                        z_rotation = {-90,0,0},
                        x_rotation={-90,0,0}
                    },
                    Clone{
                        name   = "Right Rail",
                        source = base.straight_rail,
                        anchor_point = {
                            base.straight_rail.w,
                            base.straight_rail.h
                        },
                        x = base.straight_road.w/2,
                        z_rotation = {90,0,0},
                        x_rotation={-90,0,0}
                    },
                }
            }
            dumptable(self.end_point)
            return self.group
        end,
    }
    
    return section
end

local function make_curved_to_straight_section(dir)
    local section = {
        endpoint = {0,0,0},
        line_up  = {0,0},
        setup = function(self)
            self.group = Group{
                name = "A Straight Section",
                children = {
                    Clone{
                        name   = "Road",
                        source = base.straight_road,
                        x_rotation = {180,0,0},
                        
                        --[[
                        anchor_point = {
                             base.straight_road.w/2,
                            -base.straight_road.h
                        },--]]
                    },
                    Clone{
                        name   = "Left Rail",
                        source = base.straight_rail,
                        anchor_point = {
                            0,
                            base.straight_rail.h
                        },
                        --x=-base.straight_road.w/2,
                        z_rotation = {-90,0,0},
                        x_rotation={-90,0,0}
                    },
                    Clone{
                        name   = "Right Rail",
                        source = base.straight_rail,
                        anchor_point = {
                            base.straight_rail.w,
                            base.straight_rail.h
                        },
                        x = base.straight_road.w,
                        z_rotation = {90,0,0},
                        x_rotation={-90,0,0}
                    },
                }
            }
            return self.group
        end,
    }
    
    return section
end

function make_curved_section()
    local section = {
        end_point = {base.curve_road.w-base.straight_road.w/2,-base.curve_road.h+base.straight_road.w/2,90},
        line_up  = {0,0},
        setup = function(self)
            self.group = Group{
                name = "A Straight Section",
                children = {
                    Clone{
                        name   = "Road",
                        source = base.curve_road,
                        anchor_point = {
                             base.straight_road.w/2,
                            base.curve_road.h
                        },
                        --[[
                        anchor_point = {
                             base.straight_road.w/2,
                            -base.straight_road.h
                        },--]]
                    },
                }
            }
            return self.group
        end,
    }
    
    return section
end

sections[1] = make_straight_section()
sections[2] = make_straight_section()
sections[3] = make_curved_section()
sections[4] = make_straight_section()
sections[5] = make_straight_section()
sections[6] = make_curved_section()
sections[7] = make_straight_section()
sections[8] = make_straight_section()
sections[9] = make_curved_section()
sections[10] = make_straight_section()
sections[11] = make_straight_section()
sections[12] = make_curved_section()