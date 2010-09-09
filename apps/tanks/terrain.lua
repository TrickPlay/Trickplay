
local ROUGHNESS = 0.5
local INITIAL_RANDOM_RANGE = screen.h/3.5

local GRASS_WIDTH = 20



local line_segments = {} -- list of the endpoints of each terrain segment
local terrain_canvas = Canvas { size = { screen.w, screen.h } }
screen:add(terrain_canvas)
screen:show()

--[[

    The hillside is made up of a chain of cubic bezier curves.  Each curve is defined by 4 points,
    P0, P1, P2, P3
    The curve starts at P0 going toward P1 and arrives at P3 coming from the direction of P2
    To guarantee smoothness, the control point at which two curves meet must be on the line between the two control points on either side.
    In other words, segment 1 of P0_1, P1_1, P2_1, P3_1 and segment 2 of P0_2, P1_2, P2_2, P3_2, then P3_1=P0_2 must be on the line from P2_1 to P1_2

    The array of points we've come up algorithmically for the hillside is just the connecting points, not the control points (ie the P0's and P3's, but no P1's or P2's).  So we'll now come up with some P1's and P2's to satisfy the continuity issue, while making a nice smooth hillside.  Note these are calculated heuristically as a function of the connection points, so we can do math later to figure out the x-y shape of the curve, so that tanks and bombs can know what the y-altitude of the hillside is at every point along the x-direction.

]]--

local function control_points(segments, i)
    local p = {}
    p[0] = {
            x = segments[i].start.x,
            y = segments[i].start.y
         }
    p[3] = {
            x = segments[i].fin.x,
            y = segments[i].fin.y,
         }
    -- p1 which we head towards from when moving from p0, is built as a weighted average
    -- of 2 parts the previous start point and 1 part our own end point
    -- If there was no previous segment, then don't curve away from the starting point
    p[1] = segments[i-1] and {
                x = 2*p[0].x-(2*segments[i-1].start.x+p[3].x)/3,
                y = 2*p[0].y-(2*segments[i-1].start.y+p[3].y)/3,
             } or {
                x = p[0].x,
                y = p[0].y,
             }

    -- p2 which we come from when moving towards p3, is built as a weighted average
    -- of 2 parts our own start point and 1 part the end point of the next segment
    -- If there is no next point, then don't curve into the end point
    p[2] = segments[i+1] and {
                x = (2*p[0].x+segments[i+1].fin.x)/3,
                y = (2*p[0].y+segments[i+1].fin.y)/3,
             } or {
                x = p[3].x,
                y = p[3].y,
             }
    return p
end

local function split_line_segment(orig_segment, break_point, offset)
    return {
                {
                    start = orig_segment.start,
                    fin   = {
                                x = break_point.x + offset.x,
                                y = break_point.y + offset.y
                            }
                },
                {
                    start = {
                                x = break_point.x + offset.x,
                                y = break_point.y + offset.y
                            },
                    fin = orig_segment.fin
                }
    }
end

local function midpoint(segment)
    return {
                x = (segment.start.x+segment.fin.x)/2,
                y = (segment.start.y+segment.fin.y)/2
           }
end

function draw_terrain()
    terrain_canvas:begin_painting()
    terrain_canvas:clear_surface()
    terrain_canvas:move_to(-GRASS_WIDTH, terrain_canvas.height+GRASS_WIDTH)
    terrain_canvas:line_to(line_segments[1].start.x, line_segments[1].start.y)
    for i = 1,#line_segments do
        local p = control_points(line_segments,i)
        terrain_canvas:curve_to(
                                    p[1].x, p[1].y,
                                    p[2].x, p[2].y,
                                    p[3].x, p[3].y
        )
    end
    terrain_canvas:line_to(terrain_canvas.width+GRASS_WIDTH, terrain_canvas.height+GRASS_WIDTH)
    terrain_canvas:set_source_color("608000")
    terrain_canvas:fill(true)
    terrain_canvas:set_source_color("40a000")
    terrain_canvas:set_line_width(GRASS_WIDTH)
    terrain_canvas:stroke()
--[[
    terrain_canvas:move_to(line_segments[1].start.x,line_segments[1].start.y)
    for i = 1,#line_segments do
        terrain_canvas:line_to(line_segments[i].fin.x, line_segments[i].fin.y)
    end
    terrain_canvas:set_source_color("800000")
    terrain_canvas:stroke()
]]--
    terrain_canvas:finish_painting()
end

function make_terrain(n)

    -- Start with one line-segment which goes from half-way up screen on left to half-way up on right
    line_segments = {
                        {
                            start = { x=-GRASS_WIDTH, y=screen.h/2 },
                            fin = { x=screen.w+GRASS_WIDTH, y=screen.h/2 }
                        }
                    }

    -- Now repeat n times
    local random_range = INITIAL_RANDOM_RANGE
    local random_split = { x=0, y=0 }
    for i = 1,n do
        -- iterate downwards since splitting points will make list grow longer
        for i=#line_segments,1,-1 do
            local seg = table.remove(line_segments,i)
            random_split.y = math.random(-random_range, random_range)
            local broken = split_line_segment(
                                                seg,
                                                midpoint(seg),
                                                random_split
                                            )
            table.insert( line_segments, i, broken[2] )
            table.insert( line_segments, i, broken[1] )
        end

        random_range = random_range * ROUGHNESS
    end
end


local function segment_from_t(t)
    return math.min(math.floor(t*#line_segments)+1,#line_segments)
end

local function t_within_t(t)
    return (t*#line_segments+1)-segment_from_t(t)
end

local function point_on_curve(t)
    local seg = segment_from_t(t)
    local t = t_within_t(t)
    local p = control_points(line_segments, seg)
    return {
        x = (1-t)^3*p[0].x + 3*(1-t)^2*t*p[1].x + 3*(1-t)*t^2*p[2].x + t^3*p[3].x,
        y = (1-t)^3*p[0].y + 3*(1-t)^2*t*p[1].y + 3*(1-t)*t^2*p[2].y + t^3*p[3].y
    }
end
--[[
    This function will cause the terrain to "break" at the given point (given by a "t" parameter relative to the whole screen).  The segment at that point will be broken in half, with the break point being lowered by bang_size; the curve will then be re-calculated and redrawn
]]--
function explode_terrain_at(t, bang_size)
    print("Breaking at ",t)
    local seg = segment_from_t(t)
    local breakpoint = point_on_curve(t)

    local the_seg = table.remove(line_segments,seg)
    print("Breaking: ",serialize(the_seg))
    local broken = split_line_segment(
                                        the_seg,
                                        breakpoint,
                                        { x = 0, y = -bang_size }
                                  )

    print("Result of break: ",serialize(broken))

    table.insert(line_segments, seg, broken[2])
    table.insert(line_segments, seg, broken[1])
    
    print("Line segments are now:")
    dumptable(line_segments)
end


--[[
    Wikipedia gives the parametric form of a cubic Bézier curve as:
    B(t) = (1-t)³.P0 + 3(1-t)².t.P1 + 3(1-t).t².P2 + t³.P3, t∈[0,1]
]]--

local marker = Rectangle { size = { GRASS_WIDTH, GRASS_WIDTH }, color = "ff0000", anchor_point = { GRASS_WIDTH/2, GRASS_WIDTH/2 } }
local marker2 = Rectangle { size = { 3, screen.h }, color = "0000ff", anchor_point = { 2, 0 } }
function trace_terrain()
    screen:add(marker, marker2)
    marker.position = { 0, screen.h/2 }
    local t = Timeline {
        duration = 3000,
        on_new_frame = function(t, msec, progress)
            local point = point_on_curve(progress)
            marker.position = { point.x, point.y-GRASS_WIDTH }
            marker2.x = screen.w*progress
        end,
        on_completed = function()
            marker:unparent()
            marker2:unparent()
        end
    }
    t:start()
end
