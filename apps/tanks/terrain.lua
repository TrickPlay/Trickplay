
local roughness = 0.5
local initial_random_range = screen.h/3.5
local random_range

local grass_width = 20

local line_segments = {}

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

local function display_line_segments(segments)
	terrain_canvas:begin_painting()
	terrain_canvas:clear_surface()
	terrain_canvas:move_to(-grass_width, terrain_canvas.height+grass_width)
	terrain_canvas:line_to(segments[1].start.x, segments[1].start.y)
	for i = 1,#segments do
	    local p = control_points(segments,i)
        terrain_canvas:curve_to(
									p[1].x, p[1].y,
									p[2].x, p[2].y,
									p[3].x, p[3].y
		)
	end
	terrain_canvas:line_to(terrain_canvas.width+grass_width, terrain_canvas.height+grass_width)
	terrain_canvas:set_source_color("608000")
	terrain_canvas:fill(true)
	terrain_canvas:set_source_color("40a000")
	terrain_canvas:set_line_width(grass_width)
	terrain_canvas:stroke()
--[[
    terrain_canvas:move_to(segments[1].start.x,segments[1].start.y)
    for i = 1,#segments do
        terrain_canvas:line_to(segments[i].fin.x, segments[i].fin.y)
    end
    terrain_canvas:set_source_color("800000")
    terrain_canvas:stroke()
]]--
	terrain_canvas:finish_painting()
end

local function split_line_segment_into(orig_segment, new_segments)
	-- Find midpoint of existing segment
	local midpoint = {
						x = (orig_segment.fin.x + orig_segment.start.x) / 2,
						y = (orig_segment.fin.y + orig_segment.start.y) / 2
					}

	-- Now fudge the y component by some random amount
	midpoint.y = midpoint.y + math.random(-random_range, random_range)

	-- Now create 2 new points with this new midpoint as their end/start
	table.insert(new_segments, {
									start = orig_segment.start,
									fin = midpoint
								} )
	table.insert(new_segments, {
									start = midpoint,
									fin = orig_segment.fin
								} )
end

function draw_terrain()
	display_line_segments(line_segments)
end

function make_terrain(n)

	-- Start with one line-segment which goes from half-way up screen on left to half-way up on right
	line_segments = {
						{ start = { x=-grass_width, y=screen.h/2 }, fin = { x=screen.w+grass_width, y=screen.h/2 } }
					}

	-- Now repeat n times
	random_range = initial_random_range
	for i = 1,n do
		local new_segments = {}

		local segment
		for _,segment in pairs(line_segments) do
			split_line_segment_into(segment, new_segments)
		end

		line_segments = new_segments
		random_range = random_range / math.exp(roughness)
	end
end


--[[
    Wikipedia gives the parametric form of a cubic Bézier curve as:
    B(t) = (1-t)³.P0 + 3(1-t)².t.P1 + 3(1-t).t².P2 + t³.P3, t∈[0,1]
]]--

local marker = Rectangle { size = { grass_width, grass_width }, color = "ff0000", anchor_point = { grass_width/2, grass_width/2 } }
local marker2 = Rectangle { size = { 3, screen.h }, color = "0000ff", anchor_point = { 2, 0 } }
function trace_terrain()
    screen:add(marker, marker2)
    marker.position = { 0, screen.h/2 }
    local t = Timeline {
        duration = 3000,
        on_new_frame = function(t, msec, progress)
            local seg = math.min(math.floor(progress*#line_segments)+1,#line_segments)
            local t = (progress*#line_segments+1)-seg
            local p = control_points(line_segments, seg)
            local point = {
                x = (1-t)^3*p[0].x + 3*(1-t)^2*t*p[1].x + 3*(1-t)*t^2*p[2].x + t^3*p[3].x,
                y = (1-t)^3*p[0].y + 3*(1-t)^2*t*p[1].y + 3*(1-t)*t^2*p[2].y + t^3*p[3].y
            }
            marker.position = { point.x, point.y-grass_width }
            marker2.x = screen.w*progress
        end,
        on_completed = function()
            marker:unparent()
            marker2:unparent()
        end
    }
    t:start()
end
