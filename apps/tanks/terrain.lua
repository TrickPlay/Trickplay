
local roughness = 0.3
local random_range = screen.h/4

local line_segments = {
}

local terrain_group = Group {}
screen:add(terrain_group)

local function display_line_segment(segments)
	
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

function draw_terrain(n)

	-- Start with one line-segment which goes from half-way up screen on left to half-way up on right
	table.insert(line_segments, { start = { x=0, y=screen.h/2 }, fin = { x=screen.w, y=screen.h/2 } })

	-- Now repeat n times
	local i
	for i = 1,n do
		local new_segments = {}

		local segment
		for _,segment in pairs(line_segments) do
			split_line_segment_into(segment, new_segments)
		end

		dumptable(new_segments)

		line_segments = new_segments
	end
end
