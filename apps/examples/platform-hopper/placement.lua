--[[
	Platform placement
	------------------
	One critical aspect of the game is placement of the platforms.  A jump must always be possible to move upward.  The platforms must not be too close together.
]]--


function place_new_platform( container, platform_prototype, jump_height )
	-- Find height of the highest platform already placed; new platform can be no higher than this height + jump_height
	local min_height = screen.h
	container:foreach_child(	function (child)
									if child.y < min_height then
										min_height = child.y
									end
								end
							)

	min_height = min_height - jump_height

	local candidate_position = {}

	local fail_count = 0
	-- We need to check that platforms are not too close to each other
	local too_close = false
	while fail_count < 10 do
		candidate_position =
								{
									x = math.floor((screen.w - platform_prototype.size[1]) * math.random()),
									y = math.floor(((screen.h - min_height) - platform_prototype.size[2]) * math.random()) + min_height
								}

		too_close = false
		-- We're too close if we're within a platform width by 2 high of any existing platform
		container:foreach_child(	function (child)
										-- If candidate is within 2 heights of existing
										if math.abs(candidate_position.y - child.y) < 2 * child.h then
											-- Check that it's not close horizontally then
											if (candidate_position.x < child.x+1.5*child.w) and (candidate_position.x > child.x-2.5*child.w) then
												too_close = true
											end
										end
									end
								)
		if not too_close then break end
		fail_count = fail_count+1
	end

	if too_close then return false end

	local platform = Clone {
								source = platform_prototype,
								position = { candidate_position.x, candidate_position.y },
							}
	container:add(platform)
end
