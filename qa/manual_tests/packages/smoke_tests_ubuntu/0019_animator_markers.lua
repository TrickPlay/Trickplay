
-- Test Set up --
local test_description = "Change the color of a UI element"
local test_group = "acceptance"
local test_area = "animator"
local test_api = "markers"

test_question = "Does the white rectangle stop jump to just before green rectangle and stop?"

function generate_test_image ()

	local rect1 = Rectangle {
				size = {50, 50}, 
				position = { 100, 250}, 
				color = "FFFFFF"
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
			}
}

	ani0.timeline:add_marker("four", 4000)


	ani0:start()
	total = 0
	function idle.on_idle( idle, seconds )
		total = total + seconds
		if total > 2 then
			ani0.timeline:advance_to_marker("four")
		end 
		if total > 4.9 then
			idle.on_idle = nil
			screen:remove(rect1)
			screen:remove(start_rect)
			screen:remove(end_rect)
			rect1 = nil
			start_rect = nil
			end_rect = nil
			ani0 = nil 
		end 
	end
	

	return nil
end











