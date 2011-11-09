test_steps = "View the device.\nVerify that on_completed_called = pass and is_animating = true below."
test_description = "Animate a rectangle so that it:\n moves\n rotates\n scales\n returns is_animating = true\n on_complete callback"
test_verify = "Verify that in 2 seconds the green square moves to (250, 150), doubles in size and rotates on z_axis 180 degrees. "
test_group = "acceptance"
test_area = "ui_element"
test_api = "animate"


function generate_test_image (controller, factory)
	local callback_test = false

	local g = factory:Group{ x = 0, y = 0}

	local r1 = factory:Rectangle{color = "00EB75", x = 10, y = 10, size = { 50 , 50 }, anchor_point = {25, 25} }

	local r2 = factory:Rectangle{color = "00FF00", x = 250, y = 150, size = { 50 , 50 }, anchor_point = {25, 25}}

	function animate_over ()
		callback_test = true
	end

	local first_stage = false
	local second_stage = false
	local total = 0
 	function idle.on_idle( idle , seconds )
	      total = total + seconds
	      if total > 1 and first_stage == false then
				first_stage = true
				g:add(r1, r2)
				controller.screen:add(g)
				r1:animate ( {duration = 2000, loop = true, x = 250, y = 150, z_rotation = 180, opacity = 150, scale = { 2, 2}, on_completed = animate_over } )
		  elseif total > 3 and first_stage == true and second_stage == false then
				test_verify = test_verify.."\nis_animating = "..tostring(r1.is_animating)
				second_stage = true
 		  elseif total > 4 and second_stage == true then
				if callback_test == true then
					test_verify_txt.text = test_verify.."\non_completed called = pass"
				else
					test_verify_txt.text = test_verify.."\non_completed called = fail"
				end
				idle.on_idle = nil
				r1 = nil
				total =nil
				controller.screen:remove(g)
	      end
    end


	
	

	return g
end


	
