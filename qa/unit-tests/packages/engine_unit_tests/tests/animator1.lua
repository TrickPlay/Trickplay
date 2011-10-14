--[[
Filename: animator1.lua
Author: Peter von dem Hagen
Date: October 13, 2011
Description:  Create an animator and test verify its setters.
--]]


-- Test Set up --
local timeline_completed_called = false

local rect1 = Rectangle {
		size = {50, 50}, 
		position = { 100, 250}, 
		color = "002EB8"
		}
test_group:add (rect1)


--Animator
local ani0 = Animator 
{
		duration = 1000, 
		properties = 
		{			
	   		{
			source = rect1, 
			name = "x", 
			ease_in = true, 
			keys = {
				{0.1, "LINEAR", 900}
					}
			},
			{
			source = rect1, 
			name = "y", 
			ease_in = true, 
			keys = {
				{0.1, "LINEAR", 650}
					}
			},
			{
			source = rect1, 
			name = "opacity", 
			ease_in = true, 
			keys = {
				{0.1, "LINEAR", 0},
				{0.2, "LINEAR", 0},
				{0.5, "LINEAR", 255},
				{0.9, "LINEAR", 50},
					}
			}
		}

}

ani0:start()

function ani0.timeline.on_completed()
	timeline_completed_called = true
end



-- Tests --

function test_animator_duration ()
   assert_equal( ani0.timeline.duration , 1000 , "ani0.timeline.duration failed" )
end

function test_animator_end_state ()
   assert_equal( rect1.position[1] , 900 , "animator end X position state failed" )
   assert_equal( rect1.position[2] , 650 , "animator end Y position state failed" )
   assert_equal( rect1.opacity , 50 , "animator end opacity position state failed" )
   rect1 = nil
end

function test_animator_timeline_completed ()
   assert_true ( timeline_completed_called, "ani0.timeline.completed failed" )
   ani0 = nil
end



-- Test Tear down --













