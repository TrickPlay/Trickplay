test_steps = "View the device."
test_description = "Use move_by to move the green square by 100, 100"
test_verify = "Verify a green square appears, then moves 100, 100 then is removed."
test_group = "acceptance"
test_area = "ui_element"
test_api = "move_by"


function generate_test_image (controller, factory)

	local g = factory:Group{ x = 0, y = 0}

	local r1 = factory:Rectangle{color = "00EB75", x = 10, y = 10, size = { 100 , 100 }}


	local first_stage = false
	local second_stage = false
	local total = 0
 	function idle.on_idle( idle , seconds )
	      total = total + seconds
	      if total > 1 and first_stage == false then
				first_stage = true
				g:add(r1)
				controller.screen:add(g)
		  elseif total > 3 and first_stage == true and second_stage == false then
				r1:move_by (100, 100 )
				second_stage = true
 		  elseif total > 5 and second_stage == true then
				idle.on_idle = nil
				r1 = nil
				total =nil
				controller.screen:remove(g)
	      end
    end

	return g
end


	
