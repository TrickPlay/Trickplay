test_steps = "View the device."
test_description = "Use hide_all to hide all elements in the group."
test_verify = "Verify that the 3 squares display briefly then are hidden."
test_group = "acceptance"
test_area = "ui_element"
test_api = "hide_all"


function generate_test_image (controller, factory)

	local g = factory:Group{ x = 0, y = 0}

	local r1 = factory:Rectangle{color = "00EB75", x = 110, y = 110, size = { 100 , 100 }}

	local r2 = factory:Rectangle{color = "FF3333", x = 120, y = 120, size = { 100 , 100 }}

	local r3 = factory:Rectangle{color = "0582FF", x = 130, y = 130, size = { 100 , 100 }}

	local first_stage = false
	local second_stage = false
	local total = 0
 	function idle.on_idle( idle , seconds )
	      total = total + seconds
	      if total > 2 and first_stage == false then
				first_stage = true
				g:add(r1, r2, r3)
				controller.screen:add(g)
		  elseif total > 4 and first_stage == true and second_stage == false then
				g:hide_all()
				second_stage = true
 		  elseif total > 6 and second_stage == true then
				idle.on_idle = nil
				controller.screen:remove(g)
				first_stage =nil
				g = nil
				r1 = nil
				r2 = nil
				r3 = nil
				total =nil
	      end
    end

	return g
end


	
