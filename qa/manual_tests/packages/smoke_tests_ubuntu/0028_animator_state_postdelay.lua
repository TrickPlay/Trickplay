-- Test Set up --
local test_description = "Animate a rectangle using animatorState with post delay set to 1/2 of 4 seconds."
local test_group = "acceptance"
local test_area = "animatorState"
local test_api = "postdelay"

test_question = "Does the white rectangle start moving at the same time as the red rectangle and complete when the red rectangle is halfway?"

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
   	  	duration = 4000, 
       	keys = { 
		 { rect1, "position", "LINEAR", {600 ,500}, 0, 0}
		}
	},
	{
		source = "first", 
		target = "second",             
   	  	duration = 4000, 
       	keys = { 
		 { rect1, "position", "LINEAR", {200 ,500}, 0, 0}
		}
	},
	{
		source = "second", 
		target = "third",             
   	  	duration = 4000, 
       	keys = { 
		 { rect1, "position", "LINEAR", {200 ,500}, 0, 0}
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


local rect2 = Rectangle {
				size = {100, 100}, 
				position = { 200, 700}, 
				color = "FFFFFF"
			}
	rect2.anchor_point = { rect2.w/2, rect2.h/2 }
	screen:add (rect2)

	local start_rect2 = Rectangle {
				size = {100, 100}, 
				position = { 200, 700}, 
				color = "00FF00"
			}
	start_rect2.anchor_point = { start_rect2.w/2, start_rect2.h/2 }
	screen:add (start_rect2)


	local end_rect2 = Rectangle {
				size = {100, 100}, 
				position = { 600, 700}, 
				color = "33AAFF"
			}
	end_rect2.anchor_point = { end_rect2.w/2, end_rect2.h/2 }
	screen:add (end_rect2)


	local state2 = AnimationState {
	duration  = 5000, 
	transitions = {
	{
		source = "begin", 
		target = "first",             
   	  	duration = 4000, 
       	keys = { 
		 { rect2, "position", "LINEAR", {600 ,700}, 0, 0.5}
		}
	},
	{
		source = "first", 
		target = "second",             
   	  	duration = 4000, 
       	keys = { 
		 { rect2, "position", "LINEAR", {200 ,700}, 0, 0.5}
		}
	},
	{
		source = "second", 
		target = "third",             
   	  	duration = 4000, 
       	keys = { 
		 { rect2, "position", "LINEAR", {200 ,700}, 0, 0.5}
		}
	}
}
}

	if state2.state == nil then 
		state2.state = "begin"
	end 
	state2.state = "first"

	function state2.on_completed()
		if state2.state == "first" then 
			state2.state = "second"
		elseif state2.state == "second" then 
			state2.state = "third"
		elseif state2.state == "third" then
			screen:remove(rect2)
			screen:remove(start_rect2)
			screen:remove(end_rect2)
			rect2 = nil
			start_rect2 = nil
			end_rect2 = nil
		end
	end 

	return nil
end











