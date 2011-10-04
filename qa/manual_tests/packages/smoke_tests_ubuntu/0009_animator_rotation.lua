-- Test Set up --
local test_description = "Animate the rotation of a rectangle using animator"
local test_group = "acceptance"
local test_area = "animator"
local test_api = "rotation"

test_question = "Do the red rectangle rotate 45 degrees for 4 secs then rotate negative 90 degrees in the final 4 secs (red = x, light green = y & dark green = z)"

function generate_test_image ()

	local rect1 = Rectangle {
				size = {100, 100}, 
				position = { 100, 400}, 
				color = "FF0000"
			}
	rect1.anchor_point = { rect1.w/2, rect1.h/2 }
	screen:add (rect1)

	local rect2 = Rectangle {
				size = {100, 100}, 
				position = { 300, 400}, 
				color = "00FF00"
			}
	rect2.anchor_point = { rect2.w/2, rect2.h/2 }
	screen:add (rect2)

	local rect3 = Rectangle {
				size = {100, 100}, 
				position = { 500, 400}, 
				color = "448844"
			}
	rect3.anchor_point = { rect3.w/2, rect3.h/2 }
	screen:add (rect3)

	--Animator
	ani0 = Animator 
	{
			duration = 8000, 
			properties = 
			{			
		   		{
				source = rect1, 
				name = "x_rotation", 
				ease_in = false, 
				keys = {
				{0.0, "LINEAR", 0},
				{0.5, "LINEAR", 45},
				{0.9, "LINEAR", -45}
					}
				},
				{
				source = rect2, 
				name = "y_rotation", 
				ease_in = false, 
				keys = {
				{0.0, "LINEAR", 0},
				{0.5, "LINEAR", 45},
				{0.9, "LINEAR", -45}
					}
				},
				{
				source = rect3, 
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
		screen:remove(rect2)
		screen:remove(rect3)
		screen:remove(small_rect)
		screen:remove(large_rect)
		rect1 = nil
		rect2 = nil
		rect3 = nil
		large_rect = nil
		small_rect = nil
		ani0 = nil
	end

	return nil
end











