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
		position = { 300, 150, 0}, 
		color = "002EB8"
		}

local rect2 = Rectangle {
		size = {100, 100}, 
		position = { 700, 150, 0}, 
		color = "44AA44"
		}

local rect3 = Rectangle {
		size = {100, 100}, 
		position = { 800, 150, 0}, 
		color = "AAAAAA"
		}
test_group:add (rect1, rect2, rect3)


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
			name = "z", 
			ease_in = true, 
			keys = {
				{0.1, "LINEAR", 10}
					}
			},
			{
			source = rect2, 
			name = "depth", 
			ease_in = true, 
			keys = {
				{0.1, "LINEAR", 10}
					}
			},
			{
			source = rect1, 
			name = "width", 
			ease_in = true, 
			keys = {
				{0.1, "LINEAR", 50}
					}
			},
			{
			source = rect1, 
			name = "height", 
			ease_in = true, 
			keys = {
				{0.1, "LINEAR", 50}
					}
			},
			{
			source = rect2, 
			name = "w", 
			ease_in = true, 
			keys = {
				{0.1, "LINEAR", 200}
					}
			},
			{
			source = rect2, 
			name = "h", 
			ease_in = true, 
			keys = {
				{0.1, "LINEAR", 200}
					}
			},
			{
			source = rect3, 
			name = "size", 
			ease_in = true, 
			keys = {
				{0.9, "LINEAR", { 200, 200}}
					}
			},
			{
			source = rect3, 
			name = "scale", 
			ease_in = true, 
			keys = {
				{0.1, "LINEAR", { 2.0, 0.5 }}
					}
			},
			{
			source = rect1, 
			name = "x_rotation", 
			ease_in = true, 
			keys = {
				{0.4, "LINEAR", 90}
					}
			},
			{
			source = rect1, 
			name = "y_rotation", 
			ease_in = true, 
			keys = {
				{0.4, "LINEAR", 90}
					}
			},
			{
			source = rect1, 
			name = "z_rotation", 
			ease_in = true, 
			keys = {
				{0.4, "LINEAR", -45}
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
			},
			{
			source = rect3, 
			name = "color", 
			ease_in = true, 
			keys = {
				{0.2, "LINEAR", { 100, 20, 190, 255}}
					}
			},
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
	assert_equal( rect1.position[1], 900 , "animator end position[1] state failed" )
	assert_equal( rect1.position[2], 650 , "animator end position[2] state failed" )
	assert_equal( rect1.z, 10, "animator end z position state failed" )
	assert_equal( rect1.opacity, 50, "animator end opacity position state failed" )
	assert_equal( rect1.depth, 10, "animator end depth position state failed" )
	assert_equal( rect3.size[1], 200, "animator end size[1] state failed" )
	assert_equal( rect3.size[2], 200, "animator end size[2] state failed" )
	assert_equal( rect2.w, 200, "animator end w state failed" )
	assert_equal( rect2.h, 200, "animator end h state failed" )
	assert_equal( rect1.width, 50, "animator end w state failed" )
	assert_equal( rect1.height, 50, "animator end h state failed" )
	assert_equal( rect3.scale[1], 2, "animator end scale[1] state failed" )
	assert_equal( rect3.scale[2], 0.5, "animator end scale[2] state failed" )
	assert_equal( rect1.z_rotation[1], -45, "animator end z_rotation state failed" )
 	assert_equal( rect1.y_rotation[1], 90, "animationState end y_rotation state failed" )
 	assert_equal( rect1.x_rotation[1], 90, "animator end x_rotation state failed" )
	assert_equal( rect3.color[1], 100, "animator end color[1] state failed" )
	assert_equal( rect3.color[2], 20, "animator end color[2] state failed" )
	assert_equal( rect3.color[3], 190, "animator end color[3] state failed" )
	assert_equal( rect3.color[4], 255, "animator end color[4] state failed" )
        rect1 = nil
end

function test_animator_timeline_completed ()
   	assert_true ( timeline_completed_called, "ani0.timeline.completed failed" )
end



-- Test Tear down --













