local base = {
    straight_road = Image{ src="road-straight.png", tile={false,true}, h=50*250},
    curve_road    = Image{ src="road-curvdde-2.png"   },
    curve_piece   = Image{ src="curve-piece.png"},
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

function make_right_curved_section()
    local rad = base.curve_road.w-base.straight_road.w/2
    local rot=90
    local section = {
        end_point = {-rad*math.cos(math.pi/180*rot)+rad,-rad*math.sin(math.pi/180*rot),rot},
        path = {
            dist  = (2*math.pi*(rad))*(rot/360),
            radius=-rad,
            rot=rot
        },
        line_up  = {0,0},
        setup = function(self)
            self.group = Group{
                name = "Right Curve",
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

function make_left_curved_section()
    local rad = -(base.curve_road.w-base.straight_road.w/2)
    local rot=-90
    local section = {
        end_point = {-rad*math.cos(math.pi/180*rot)+rad,-rad*math.sin(math.pi/180*rot),rot},
        path = {
            dist  = (2*math.pi*(rad))*(rot/360),
            radius=-rad,
            rot=rot
        },
        line_up  = {0,0},
        setup = function(self)
            self.group = Group{
                name = "Left Curve",
                children = {
                    Clone{
                        name   = "Road",
                        source = base.curve_road,
                        anchor_point = {
                             base.straight_road.w/2,
                            base.curve_road.h
                        },
                        y_rotation={180,0,0}
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
function make_right_curved_piece()
    local rad = 1724
    local rot = 22.5
    local section = {
        end_point = {-rad*math.cos(math.pi/180*rot)+rad,-rad*math.sin(math.pi/180*rot),rot},
        path = {
            dist  = (2*math.pi*(rad))*(rot/360),
            radius=-rad,
            rot=rot
        },
        line_up  = {0,0},
        setup = function(self)
            self.group = Group{
                name = "Right 22.5* Curve",
                children = {
                    Clone{
                        name   = "Road",
                        source = base.curve_piece,
                        anchor_point = {
                             base.straight_road.w/2,
                            base.curve_piece.h
                        },
                    },
                }
            }
            return self.group
        end,
    }
    
    return section
end
function make_left_curved_piece()
    local rad = -1724
    local rot = -22.5
    local section = {
        end_point = {-rad*math.cos(math.pi/180*rot)+rad,-rad*math.sin(math.pi/180*rot),rot},
        path = {
            dist  = (2*math.pi*(rad))*(rot/360),
            radius=-rad,
            rot=rot
        },
        line_up  = {0,0},
        setup = function(self)
            self.group = Group{
                name = "Left 22.5* Curve",
                children = {
                    Clone{
                        name   = "Road",
                        source = base.curve_piece,
                        anchor_point = {
                             base.straight_road.w/2,
                            base.curve_piece.h
                        },
                        y_rotation={180,0,0}
                    },
                    Rectangle{name="r",w=70,h=70,color="0000ff",anchor_point={45,45},position={-rad*math.cos(math.pi/180*rot)+rad,-rad*math.sin(math.pi/180*rot)}}
                }
            }
            self.group:find_child("r"):raise_to_top()
            return self.group
        end,
    }
    
    return section
end

table.insert(sections,make_right_curved_piece())
table.insert(sections,make_straight_section())
table.insert(sections,make_left_curved_piece())
table.insert(sections,make_left_curved_piece())
table.insert(sections,make_left_curved_piece())
table.insert(sections,make_left_curved_piece())
table.insert(sections,make_straight_section())
table.insert(sections,make_left_curved_piece())

table.insert(sections,make_right_curved_piece())
table.insert(sections,make_left_curved_piece())

table.insert(sections,make_right_curved_piece())
table.insert(sections,make_straight_section())

table.insert(sections,make_left_curved_piece())
table.insert(sections,make_straight_section())
table.insert(sections,make_straight_section())
table.insert(sections,make_right_curved_piece())
table.insert(sections,make_right_curved_piece())

table.insert(sections,make_right_curved_piece())
table.insert(sections,make_straight_section())

--[[
table.insert(sections,make_straight_section())
table.insert(sections,make_straight_section())
table.insert(sections,make_left_curved_section())
table.insert(sections,make_right_curved_section())
table.insert(sections,make_right_curved_section())

table.insert(sections,make_straight_section())

table.insert(sections,make_straight_section())
table.insert(sections,make_straight_section())
table.insert(sections,make_right_curved_section())
table.insert(sections,make_straight_section())
table.insert(sections,make_straight_section())
table.insert(sections,make_right_curved_section())
table.insert(sections,make_left_curved_section())
table.insert(sections,make_straight_section())
table.insert(sections,make_straight_section())
table.insert(sections,make_right_curved_section())
table.insert(sections,make_straight_section())
table.insert(sections,make_straight_section())
table.insert(sections,make_right_curved_section())
--]]