--[[
Filename: Path4.lua
Author: Peter von dem Hagen
Date: November 14, 2011
Description:  Test path using curve_to
--]]

-- Test Set up --



-- Testing length and get_position
local globe2 = Image ()
local path2 = Path()
globe2.src = "packages/engine_unit_tests/tests/assets/globe.png"
globe2.scale = {0.1, 0.1}
globe2.position = {0, 0}
test_group:add(globe2)

path2:move_to (0, 0)
path2:curve_to (0, 0, 1200, 1200, 1920, 0, true )


local lastGetPosition = {}
local timeline = Timeline
{
	duration = 2000,
	loop = false,
	on_new_frame =
		function( timeline , duration , progress )
			globe2.position = path2:get_position( progress )
			lastGetPosition = path2:get_position( progress )
		end
}

timeline:start()


-- Tests --

-- Verify that curve_to finishes up at the expected location.
function test_Path_curve_to ()
    assert_equal( lastGetPosition[1], 1920, "Result: "..  lastGetPosition[1].." Expected: 1920" )
    assert_equal( lastGetPosition[2], 0, "Result: "..  lastGetPosition[2].." Expected: 0" )
end

--]]

-- Test Tear down --













