-- Test Set up --
local test_description = "Animate the rotation of a rectangle using animator"
local test_group = "smoke"
local test_area = "animator"
local test_api = "rotation"

test_question = "Does the red rectangle rotate 45 degrees CW for 2.5 secs then rotate 90 degrees CW in the final 2.5 secs?"

function generate_test_image ()

	local rect1 = Rectangle {
				size = {200, 200}, 
				position = { 400, 500}, 
				color = "FF0000"
			}
	rect1.anchor_point = { rect1.w/2, rect1.h/2 }
	screen:add (rect1)

	--Animator
	ani0 = Animator 
	{
			duration = 5000, 
			properties = 
			{			
		   		{
				source = rect1, 
				name = "z_rotation", 
				ease_in = false, 
				keys = {
				{0.0, "LINEAR", 0},
				{0.5, "LINEAR", 45},
				{0.9, "LINEAR", -45}
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











