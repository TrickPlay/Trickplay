-- Test Set up --
local test_description = "Animate the size using animatorState"
local test_group = "acceptance"
local test_area = "animatorState"
local test_api = "color"

test_question = "Does the white rectangle change color as it moves until it matches the blue rectangle?"

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
				position = { 600, 500}, 
				color = "000080"
			}
	end_rect.anchor_point = { end_rect.w/2, end_rect.h/2 }
	screen:add (end_rect)

	local rect1 = Rectangle {
				size = {100, 100}, 
				position = { 200, 500, 0}, 
				color = "FFFFFF"
			}
	rect1.anchor_point = { rect1.w/2, rect1.h/2 }
	screen:add (rect1)



	local state1 = AnimationState {
	duration  = 5000, 
	transitions = {
	{
		source = "begin", 
		target = "first",             
   	  	duration = 3000, 
       	keys = { 
		 { rect1, "x", "LINEAR", 600, 0,0},
		 { rect1, "color", "LINEAR", { 0, 0, 128 }, 0, 0 }
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











