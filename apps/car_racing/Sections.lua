local base = {
    straight_road = Image{ src="road.png", tile={false,true}, h=50*250},
    curve_road    = Image{ src="road-curvdde-2.png"   },
    curve_piece   = Image{ src="curve-piece.png"},
    straight_rail = Image{ src="guardrail.png",     tile={true,false}, w=50*250},
    cactus        = Image{ src="cactus3.png"},
    cactus2       = Image{ src="cactus2.png"},
    sign          = Image{ src="sign-road.png"},
    tree          = Image{ src="tree.png"},
    tree2         = Image{ src="tree2.png"},
    t_weed          = Image{ src="tumble-weed.png"},
}
for _,v in pairs(base) do
    clone_sources:add(v)
end

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
                    
                    --[[
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
                    --]]
                }
            }
            self.group:add(doodads[2]())--math.random(1,#doodads)]())
            self.path.parent=self
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
            self.path.parent=self
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
            self.path.parent=self
            return self.group
        end,
    }
    
    return section
end
function make_right_curved_piece()
    local rad = 1000
    local rot = 45/4
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
            self.path.parent=self
            return self.group
        end,
    }
    
    return section
end
function make_left_curved_piece()
    local rad = -1000
    local rot = -45/4
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
            self.path.parent=self
            return self.group
        end,
    }
    
    return section
end

--table.insert(sections,make_right_curved_piece())
table.insert(sections,make_straight_section())
table.insert(sections,make_straight_section())
table.insert(sections,make_left_curved_piece())
table.insert(sections,make_straight_section())
table.insert(sections,make_straight_section())
table.insert(sections,make_straight_section())
table.insert(sections,make_right_curved_piece())
table.insert(sections,make_straight_section())
table.insert(sections,make_right_curved_piece())
table.insert(sections,make_straight_section())
table.insert(sections,make_left_curved_piece())


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