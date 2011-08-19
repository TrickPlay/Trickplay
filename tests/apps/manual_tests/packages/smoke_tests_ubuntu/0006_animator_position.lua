--[[
Filename: 0001_rectangle_basic.lua
Author: Peter von dem Hagen
Date: January 19, 2011
Test type: Manual GUI Test
Description: Create several rectangles and verify that they display as expected
--]]

-- Test Set up --
local test_description = "Animate the postion of a rectangle using animator"
local test_group = "smoke"
local test_area = "animator"
local test_api = "position"

test_question = "Does the blue rectangle start at the red square and take 5 secs to move to the green square?"

function generate_test_image ()

	local rect1 = Rectangle {
				size = {50, 50}, 
				position = { 100, 250}, 
				color = "002EB8"
			}
	rect1.anchor_point = { rect1.w/2, rect1.h/2 }
	screen:add (rect1)


	-- Create start and finish points
	local start_rect = Rectangle {
				size = {50, 50}, 
				position = {100,250}, 
				color = "FF0033"
				}
	start_rect.anchor_point = { start_rect.w/2, start_rect.h/2 }
	screen:add(start_rect)

	local end_rect = Rectangle {
				size = {50, 50}, 
				position = { 900,650}, 
				color = "448844"
				}
	end_rect.anchor_point = { end_rect.w/2, end_rect.h/2 }

	screen:add (end_rect)


	--Animator
	ani0 = Animator 
	{
			duration = 5000, 
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
				}
			}
	
	}

	ani0:start()
	
	function ani0.timeline.on_completed()
		screen:remove(rect1)
		screen:remove(start_rect)
		screen:remove(end_rect)
		rect1 = nil
		start_rect = nil
		end_rect = nil
		ani0 = nil
	end

	return nil
end











