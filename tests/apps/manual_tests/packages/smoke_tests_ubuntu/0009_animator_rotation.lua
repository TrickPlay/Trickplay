--[[
Filename: 0001_rectangle_basic.lua
Author: Peter von dem Hagen
Date: January 19, 2011
Test type: Manual GUI Test
Description: Create several rectangles and verify that they display as expected
--]]

-- Test Set up --
local test_description = "Animate the scaling of a rectangle using animator"
local test_group = "smoke"
local test_area = "animator"
local test_api = "scale"

test_question = "Does the red rectangle scale quickly to 0.5 then double size in 5 secs then go back to original size in 5 seconds?"

function generate_test_image ()

	local rect1 = Rectangle {
				size = {200, 200}, 
				position = { 400, 500}, 
				color = "FF0000"
			}
	rect1.anchor_point = { rect1.w/2, rect1.h/2 }
	screen:add (rect1)

	--Animator
	ani0 = Animator 
	{
			duration = 5000, 
			properties = 
			{			
		   		{
				source = rect1, 
				name = "z_rotation", 
				ease_in = true, 
				keys = {
				{0.5, "LINEAR", 45},
				{0.9, "LINEAR", 90}
					}
				}			
			}	
	}

	ani0:start()
	
	function ani0.timeline.on_completed()
		screen:remove(rect1)
		screen:remove(small_rect)
		screen:remove(large_rect)
		rect1 = nil
		large_rect = nil
		small_rect = nil
		ani0 = nil
	end

	return nil
end











