-- Test Set up --
local test_description = "Animate the position of a rectangle using animatorState"
local test_group = "smoke"
local test_area = "animatorState"
local test_api = "position"

test_question = "Does the red rectangle animate linearly from the green rect to the blue rect then back to the green rect, the ease_out_elastic to the blue?"

function generate_test_image ()

	local rect1 = Rectangle {
				size = {100, 100}, 
				position = { 200, 500}, 
				color = "FF0000"
			}
	rect1.anchor_point = { rect1.w/2, rect1.h/2 }
	screen:add (rect1)

	local start_rect = Rectangle {
				size = {100, 100}, 
				position = { 200, 500}, 
				color = "00FF00"
			}
	start_rect.anchor_point = { start_rect.w/2, start_rect.h/2 }
	screen:add (start_rect)


	local end_rect = Rectangle {
				size = {100, 100}, 
				position = { 600, 500}, 
				color = "33AAFF"
			}
	end_rect.anchor_point = { end_rect.w/2, end_rect.h/2 }
	screen:add (end_rect)


	state1 = AnimationState {
	duration  = 5000, 
	transitions = {
	{
		source = "begin", 
		target = "first",             
   	  	duration = 2000, 
       	keys = { 
		 { rect1, "position", "LINEAR", {600 ,500}, 0,0}
		}
	}, 
	{
       source = "first", 
       target = "second",
   		duration = 2000,
	   keys = {
		 { rect1, "position", "LINEAR", {200,500}, 0,0}, 
	 	  }, 
	},
	{
       source = "second", 
       target = "third",
   		duration = 2000,
	   keys = {
		 { rect1, "position", "EASE_OUT_ELASTIC", {600,500}, 0,0}
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
			state1.state = "third"
		elseif state1.state == "third" then 
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











