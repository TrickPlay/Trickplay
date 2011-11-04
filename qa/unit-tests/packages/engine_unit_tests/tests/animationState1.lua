--[[
Filename: animationState1.lua
Author: Peter von dem Hagen
Date: October 13, 2011
Description:  Create an animator and test verify its setters.
--]]


-- Test Set up --
animation_state2_completed = false

local rect1 = Rectangle {
		size = {100, 100}, 
		position = { 100, 250, 0}, 
		color = "AA44CC"
		}

local rect2 = Rectangle {
		size = {100, 100}, 
		position = { 400, 250, 0}, 
		color = "44AA44"
		}

local rect3 = Rectangle {
		size = {100, 100}, 
		position = { 600, 450, 0}, 
		color = "AAAAAA"
		}
test_group:add (rect1, rect2, rect3)



--AnimationState
local state1 = AnimationState {
	duration  = 5000, 
	transitions = {
	{
		source = "begin", 
		target = "first",             
   	  	duration = 1000, 
       	keys = { 
		 { rect1, "x", "LINEAR", 1000},
		 { rect1, "y", "LINEAR", 800},
		 { rect1, "z", "LINEAR", 10},
		 { rect3, "size", "LINEAR", { 200, 200}},
		 { rect2, "position", "LINEAR", {1200, 400} },
		 { rect2, "depth", "LINEAR", 10},
		 { rect1, "x_rotation", "LINEAR", -45},
		 { rect1, "y_rotation", "LINEAR", -45},
		 { rect1, "z_rotation", "LINEAR", -45},
		}
	}, 
	{
       source = "first", 
       target = "second",
   		duration = 1000,
	  	keys = {
		 { rect1, "opacity", "LINEAR", 50},
		 { rect1, "width", "LINEAR", 50},
		 { rect1, "height", "LINEAR", 50},
		 { rect2, "w", "LINEAR", 200},
		 { rect2, "h", "LINEAR", 200},
		 { rect1, "opacity", "LINEAR", 50},
		 { rect1, "opacity", "LINEAR", 50},
		 { rect3, "scale", "LINEAR", { 2, 0.5}},
		 { rect2, "color", "LINEAR", "FFAA00AA"}
	 	  }
	}, 
	{
       source = "second", 
       target = "third",
   		duration = 1000,
	  	keys = {
	 	  }
	}
}
}

	if state1.state == nil then 
		state1.state = "begin"
	end 
	state1.state = "first"

	function state1.on_completed()
		if state1.state == "first" then 
			state1.state = "second"
		elseif state1.state == "second" then 
			--state1.state = "third"
			animation_state2_completed = true
		end
	end 


-- Tests --

function test_animationState_duration ()
   	assert_equal( state1.duration , 5000 , "state1.duration failed" )
end

function test_animationState_end_state ()
 	assert_equal( rect1.x, 1000, "animationState end X position state failed" )
	assert_equal( rect1.y, 800, "animationState end Y position state failed" )
	assert_equal( rect1.z, 10, "animationState end Z position state failed")
	assert_equal( rect3.size[1], 200, "animationState end size[1] state failed" )
	assert_equal( rect3.size[2], 200, "animationState end size[2] state failed" )
	assert_equal( rect2.w, 200, "animationState end w state failed" )
	assert_equal( rect2.h, 200, "animationState end h state failed" )
	assert_equal( rect1.width, 50, "animationState end w state failed" )
	assert_equal( rect1.height, 50, "animationState end h state failed" )
	assert_equal( rect3.scale[1], 2, "animationState end scale[1] state failed" )
	assert_equal( rect3.scale[2], 0.5, "animationState end scale[2] state failed" )
	assert_equal( rect1.opacity, 50, "animationState end opacity position state failed" )
	assert_equal( rect2.position[1], 1200, "animationState position[1] state failed" )
	assert_equal( rect2.position[2], 400, "animationState end position[2] state failed" )
 	assert_equal( rect1.z_rotation[1], -45, "animationState end z_rotation state failed" )
 	assert_equal( rect1.y_rotation[1], -45, "animationState end y_rotation state failed" )
 	assert_equal( rect1.x_rotation[1], -45, "animationState end x_rotation state failed" )
	assert_equal( rect2.color[1], 255, "animationState end color[1] state failed" )
	assert_equal( rect2.color[2], 170, "animationState end color[2] state failed" )
	assert_equal( rect2.color[3], 0, "animationState end color[3] state failed" )
	assert_equal( rect2.color[4], 170, "animationState end color[4] state failed" )


end

function test_animationState_completed ()
   assert_true ( animation_state2_completed, "state2.on_completed failed" )
end

-- Test Tear down --













