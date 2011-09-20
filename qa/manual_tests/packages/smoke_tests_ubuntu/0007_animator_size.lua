
-- Test Set up --
local test_description = "Animate the size of a rectangle using animator"
local test_group = "smoke"
local test_area = "animator"
local test_api = "size"

test_question = "Does the blue rectangle start at size 50,50 and take 5 secs to resize over the green square?"

function generate_test_image ()

	local end_rect = Rectangle {
				size = {800, 600}, 
				position = { 100,250}, 
				color = "448844",
				opacity = 100
				}
--	end_rect.anchor_point = { end_rect.w/2, end_rect.h/2 }

	screen:add (end_rect)

	local rect1 = Rectangle {
				size = {50, 50}, 
				position = { 100, 250}, 
				color = "002EB8"
			}
--	rect1.anchor_point = { rect1.w/2, rect1.h/2 }
	screen:add (rect1)


	--Animator
	ani0 = Animator 
	{
			duration = 5000, 
			properties = 
			{			
		   		{
				source = rect1, 
				name = "width", 
				ease_in = true, 
				keys = {
					{0.1, "LINEAR", 800}
						}
				},
				{
				source = rect1, 
				name = "height", 
				ease_in = true, 
				keys = {
					{0.1, "LINEAR", 600}
						}
				}
			}
	
	}

	ani0:start()
	
	function ani0.timeline.on_completed()
		screen:remove(rect1)
		screen:remove(end_rect)
		rect1 = nil
		end_rect = nil
		ani0 = nil
	end

	return nil
end











