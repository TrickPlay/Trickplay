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

	local small_rect = Rectangle {
				size = {100, 100}, 
				position = {400,500}, 
				color = "00FF33",
				opacity = 80	
				}
	small_rect.anchor_point = { small_rect.w/2, small_rect.h/2 }
	screen:add(small_rect)

	local large_rect = Rectangle {
				size = {400, 400}, 
				position = { 400,500}, 
				color = "448844",
				opacity = 80
				}
	large_rect.anchor_point = { large_rect.w/2, large_rect.h/2 }

	screen:add (large_rect)

	--Animator
	ani0 = Animator 
	{
			duration = 5000, 
			properties = 
			{			
		   		{
				source = rect1, 
				name = "scale", 
				ease_in = true, 
				keys = {
				{0.0, "LINEAR", {0.1, 0.1}}, -- seems like a bug here. Shouldn't need this line.
				{0.3, "LINEAR",{ 0.5,0.5}},
				{0.5, "LINEAR", {2.0, 2.0 }},
				{0.9, "LINEAR", {1.0, 1.0 }},
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











