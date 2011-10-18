-- Test Set up --
local test_description = "Animate the size using animatorState"
local test_group = "acceptance"
local test_area = "animatorState"
local test_api = "scale"

test_question = "Do the rectangles rotate 45 degrees for 2 secs then rotate negative 45 degrees in the final 2 secs (red = x, light green = y & dark green = z)"

function generate_test_image ()

	local rect1 = Rectangle {
				size = {100, 100}, 
				position = { 200, 400}, 
				color = "FF0000"
			}
	rect1.anchor_point = { rect1.w/2, rect1.h/2 }
	screen:add (rect1)

	local rect2 = Rectangle {
				size = {100, 100}, 
				position = { 400, 400}, 
				color = "00FF00"
			}
	rect2.anchor_point = { rect2.w/2, rect2.h/2 }
	screen:add (rect2)

	local rect3 = Rectangle {
				size = {100, 100}, 
				position = { 600, 400}, 
				color = "448844"
			}
	rect3.anchor_point = { rect3.w/2, rect3.h/2 }
	screen:add (rect3)



	state1 = AnimationState {
	duration  = 5000, 
	transitions = {
	{
		source = "begin", 
		target = "first",             
   	  	duration = 6000, 
       	keys = { 
 		{ rect1, "x_rotation", "LINEAR", 45, 0, 0 },
		{ rect2, "y_rotation", "LINEAR", 45, 0, 0 },
		{ rect3, "z_rotation", "LINEAR", 45, 0, 0 }
		}
	},
	{
		source = "first", 
		target = "second",             
   	  	duration = 6000, 
       	keys = { 
 		{ rect1, "x_rotation", "LINEAR", -45, 0, 0 },
		{ rect2, "y_rotation", "LINEAR", -45, 0, 0 },
		{ rect3, "z_rotation", "LINEAR", -45, 0, 0 }
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
			screen:remove(rect1)
			screen:remove(rect2)
			screen:remove(rect3)
			rect1 = nil
			rect2 = nil
			rect3 = nil	
		end
	end 

	return nil
end











