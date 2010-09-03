
local roughness = 0.7
local initial_random_range = screen.h/3.5
local random_range

local line_segments = {}

local terrain_canvas = Canvas { size = { screen.w, screen.h } }
screen:add(terrain_canvas)
screen:show()

local function display_line_segments(segments)
	terrain_canvas:begin_painting()
	terrain_canvas:set_source_color("00ff00")
	terrain_canvas:clear_surface()
	terrain_canvas:set_line_width(10)
	terrain_canvas:move_to(segments[1].start.x, segments[1].start.y)
	terrain_canvas:curve_to(
								segments[1].start.x, segments[1].start.y,
								(2*segments[1].start.x+segments[2].fin.x)/3, (2*segments[1].start.y+segments[2].fin.y)/3,
								segments[1].fin.x, segments[1].fin.y
							)
	local i
	for i = 2,#segments-1 do
		terrain_canvas:curve_to(
									(segments[i-1].start.x+2*segments[i].fin.x)/3, 2*segments[i].start.y-(segments[i-1].start.y+2*segments[i].fin.y)/3,
									(2*segments[i].start.x+segments[i+1].fin.x)/3, (2*segments[i].start.y+segments[i+1].fin.y)/3,
									segments[i].fin.x, segments[i].fin.y
		)
	end
	terrain_canvas:curve_to(
								(segments[#segments-1].start.x+2*segments[#segments].fin.x)/3, 2*segments[#segments].start.y-(segments[#segments-1].start.y+2*segments[#segments].fin.y)/3,
								segments[#segments].fin.x, segments[#segments].fin.y,
								segments[#segments].fin.x, segments[#segments].fin.y
							)
	terrain_canvas:stroke()
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
						{ start = { x=0, y=screen.h/2 }, fin = { x=screen.w, y=screen.h/2 } }
					}

	-- Now repeat n times
	local i
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
