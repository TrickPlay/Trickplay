--[[
Filename: Path1.lua
Author: Peter von dem Hagen
Date: October, 2011
Description:  Test path using relative positioning.
--]]

-- Test Set up --



-- Testing length and get_position
local globe2 = Image ()
local path2 = Path()
globe2.src = "packages/engine_unit_tests/tests/assets/globe.png"
globe2.scale = {0.1, 0.1}
globe2.position = {0, 0}
test_group:add(globe2)

path2:move_to (400, 400, true)
path2:line_to (150, 0, true)
path2:line_to (0, 150, true)
path2:line_to (-150, 0, true)
path2:line_to (0, -150, true)


local lastGetPosition = {}
local timeline = Timeline
{
	duration = 500,
	on_new_frame =
		function( timeline , duration , progress )
			globe2.position = path2:get_position( progress )
			lastGetPosition = path2:get_position( progress )
		end
}

timeline:start()


-- Tests --

-- Verify that the animation path finishes up at the expected location.
function test_Path_move_to_relative ()
    assert_equal( lastGetPosition[1], 400, "Result: "..  lastGetPosition[1].." Expected: 400" )
    assert_equal( lastGetPosition[2], 400, "Result: "..  lastGetPosition[2].." Expected: 400" )
end

--]]

-- Test Tear down --













