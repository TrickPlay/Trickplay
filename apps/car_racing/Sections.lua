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
        path = {dist=base.straight_road.h,rot=0,radius=0},
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
            self.group.check = function(the_world)
                if self.group.x > the_world.anchor_point[1] then
                    
                end
            end
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
        path = {
            dist  = (2*math.pi*base.curve_road.w-base.straight_road.w/2)*(90/360),
            radius=-base.curve_road.w-base.straight_road.w/2,
            rot=90
        },
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

table.insert(sections,make_straight_section())
table.insert(sections,make_straight_section())
table.insert(sections,make_curved_section())
table.insert(sections,make_straight_section())
table.insert(sections,make_straight_section())
table.insert(sections,make_curved_section())
table.insert(sections,make_straight_section())
table.insert(sections,make_straight_section())
table.insert(sections,make_curved_section())
table.insert(sections,make_straight_section())
table.insert(sections,make_straight_section())
table.insert(sections,make_curved_section())