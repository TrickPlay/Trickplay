-- Test Set up --
local test_description = "Animate the depth of a rectangle using animatorState"
local test_group = "acceptance"
local test_area = "animatorState"
local test_api = "depth"

test_question = "Does the red rectangle animate behind the green rectangle and then come back over it?"

function generate_test_image ()

	local rect1 = Rectangle {
				size = {100, 100}, 
				position = { 200, 200, 40 }, 
				color = "FF0000"
			}
	--rect1.anchor_point = { rect1.w/2, rect1.h/2 }
	screen:add (rect1)

	local rect2 = Rectangle {
				size = {100, 100}, 
				position = { 210, 210, 30 }, 
				color = "00FF00"
			}
	--rect2.anchor_point = { start_rect.w/2, start_rect.h/2 }
	screen:add (rect2)



	local state1 = AnimationState {
	duration  = 5000, 
	transitions = {
	{
		source = "begin", 
		target = "first",             
   	  	duration = 3000, 
       	keys = { 
		 { rect1, "depth", "LINEAR", 1, 0, 0}
		}
	},
	{
		source = "first", 
		target = "second",             
   	  	duration = 3000, 
       	keys = { 
		 { rect1, "depth", "LINEAR", 40, 0,0}
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











