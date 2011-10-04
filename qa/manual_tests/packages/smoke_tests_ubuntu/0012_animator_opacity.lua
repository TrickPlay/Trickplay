
-- Test Set up --
local test_description = "Reduce the opacity of an animation from 255 to 60"
local test_group = "acceptance"
local test_area = "animator"
local test_api = "opacity"

test_question = "Does the blue rectangle reduce in opacity until it is invisible at the red square?"

function generate_test_image ()

	local rect1 = Rectangle {
				size = {50, 50}, 
				position = { 100, 250}, 
				color = "002EB8"
			}
	rect1.anchor_point = { rect1.w/2, rect1.h/2 }
	screen:add (rect1)


	-- Create start and finish points
	local start_rect = Rectangle {
				size = {50, 50}, 
				position = {100,250}, 
				color = "FF0033"
				}
	start_rect.anchor_point = { start_rect.w/2, start_rect.h/2 }
	screen:add(start_rect)

	local end_rect = Rectangle {
				size = {50, 50}, 
				position = { 900,650}, 
				color = "448844"
				}
	end_rect.anchor_point = { end_rect.w/2, end_rect.h/2 }

	screen:add (end_rect)


	--Animator
	local ani0 = Animator 
	{
			duration = 5000, 
			properties = 
			{			
		   		{
				source = rect1, 
				name = "x", 
				ease_in = true, 
				keys = {
					{0.1, "LINEAR", 900}
						}
				},
				{
				source = rect1, 
				name = "y", 
				ease_in = true, 
				keys = {
					{0.1, "LINEAR", 650}
						}
				}
,
				{
				source = rect1, 
				name = "opacity", 
				ease_in = true, 
				keys = {
					{0.1, "LINEAR", 255},					
					{1.0, "LINEAR", 60}
						}
				}
			}
	
	}

	ani0:start()
	
	function ani0.timeline.on_completed()
		screen:remove(rect1)
		screen:remove(start_rect)
		screen:remove(end_rect)
		rect1 = nil
		start_rect = nil
		end_rect = nil
		ani0 = nil
	end

	return nil
end











