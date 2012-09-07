test_steps = "View the device."
test_description = "Add a rectangle. Then hide and show it."
test_verify = "Verify a rectangle displays at test start, then is hidden at 2 seconds and is shown again at 4 seconds."
test_group = "acceptance"
test_area = "ui_element"
test_api = "hide/show"


function generate_device_image (controller, factory)

	local r1 = factory:Rectangle{color = "FF4411", x = 100, y =  100, size = { 140 , 140 }}	
	controller.screen:add(r1)

	local first_stage = false
	local second_stage = false
	local total = 0
 	function idle.on_idle( idle , seconds )
	      total = total + seconds
	      if total > 2 and first_stage == false then
				first_stage = true
				r1:hide()
		  elseif total > 4 and first_stage == true and second_stage == false then
				r1:show()
				second_stage = true
 			elseif total > 6 and second_stage == true then
				idle.on_idle = nil
				controller.screen:remove(r1)
				first_stage =nil
				--r1 = nil
				total =nil
	      end
    end

	return r1
end


function generate_match_image (resize_ratio_w, resize_ratio_h)

	local g = Group{ x = 0, y = 0}

	local r1 = Rectangle{color = "FF4411", x = 100 * resize_ratio_w, y =  100 * resize_ratio_h, size = { 140 * resize_ratio_w , 140 * resize_ratio_h }}

	g:add(r1)

	return g
end



	
