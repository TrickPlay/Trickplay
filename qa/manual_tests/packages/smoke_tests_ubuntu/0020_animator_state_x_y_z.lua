-- Test Set up --
local test_description = "Animate the x, y & z vlaues of a rectangle using animatorState"
local test_group = "acceptance"
local test_area = "animatorState"
local test_api = "x_y_z"

test_question = "Does the red rectangle animate linearly with a 90 degree turn from the green rect to the blue rect ?"

function generate_test_image ()

		local start_rect = Rectangle {
				size = {100, 100}, 
				position = { 200, 500}, 
				color = "00FF00"
			}
	start_rect.anchor_point = { start_rect.w/2, start_rect.h/2 }
	screen:add (start_rect)


	local end_rect = Rectangle {
				size = {100, 100}, 
				position = { 600, 200}, 
				color = "33AAFF"
			}
	end_rect.anchor_point = { end_rect.w/2, end_rect.h/2 }
	screen:add (end_rect)

	local rect1 = Rectangle {
				size = {100, 100}, 
				position = { 200, 500, 0}, 
				color = "FF0000"
			}
	rect1.anchor_point = { rect1.w/2, rect1.h/2 }
	screen:add (rect1)



	local state1 = AnimationState {
	duration  = 5000, 
	transitions = {
	{
		source = "begin", 
		target = "first",             
   	  	duration = 2000, 
       	keys = { 
		 { rect1, "x", "LINEAR", 600}
		}
	}, 
	{
       source = "first", 
       target = "second",
   		duration = 2000,
	  	keys = {
		 { rect1, "y", "LINEAR", 200}
	 	  }
	}, 
	{
       source = "second", 
       target = "third",
   		duration = 2000,
	   	keys = {
		 { rect1, "z", "LINEAR", 100}, 
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
			screen:remove(start_rect)
			screen:remove(end_rect)
			rect1 = nil
			start_rect = nil
			end_rect = nil			
		end
	end 

	return nil
end











