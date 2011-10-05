--[[
Filename: Path1.lua
Author: Peter von dem Hagen
Date: January 24, 2011
Description:  Test Path, move_to, length and get_position
--]]

-- Test Set up --

-- Testing move_to by using to it move the position of a image and then verifying it with position
local globe1 = Image ()
local path1 = Path()
globe1.src = "packages/engine_unit_tests/tests/assets/globe.png"
globe1.scale = {0.1, 0.1}
test_group:add (globe1)
path1:move_to (1100,610)


-- Testing length and get_position
local globe2 = Image ()
local path2 = Path()
globe2.src = "packages/engine_unit_tests/tests/assets/globe.png"
globe2.scale = {0.1, 0.1}
globe2.position = {50, 50}
test_group:add(globe2)

path2:move_to (1100, 610)
path2:line_to (1040,780)
path2:line_to (1190,660)
path2:line_to (1010,660) 
path2:line_to (1160,780)
path2:line_to (1100,610) 

local lastGetPosition = {}
local timeline = Timeline
{
	duration = 2000,
	on_new_frame =
		function( timeline , duration , progress )
			globe1.position = path1:get_position( progress )
			globe2.position = path2:get_position( progress )
			lastGetPosition = globe2.position
		end
}
timeline:start()


-- Tests --

-- Make one move_to call to an image and then verify its position
function test_Path_move_to ()
    assert_equal( globe1.position[1], 1100, "path.move_to.x failed" )
    assert_equal( globe1.position[2], 610, "path.move_to.y failed" )
end

-- Make verify that length returns a value.
function test_Path_length ()
    assert_equal( path2.length , 924, "path.length failed" )
end

-- Verify that get_position returns position value by saving the last value and checking it.
function test_Path_get_position ()
    assert_equal( lastGetPosition[1] , 1100, "path:get_position.x failed" )
    assert_equal( lastGetPosition[2] , 610, "path:get_position.y failed" )
end

-- Test Tear down --













