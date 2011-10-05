
test_description = "Check that the up and down touch events are being returned."
test_steps = "Touch on the blue rect (20 <-> 70), drag and release on the red one (200 <-> 250).\n\nVerify it says Pass below."
test_verify = ""
test_group = "acceptance"
test_area = "touch"
test_api = "touch_down/touch_up"


function generate_test_image (controller, factory)
	local g = factory:Group{ x = 0, y = 0}

	local t_start = factory:Rectangle{color = "0070E0", x = 20, y = 20, size = { 50 , 50 }}
	local t_end = factory:Rectangle{color = "CC0000", x = 200, y = 200, size = { 50 , 50 }}
	g:add(t_start, t_end)
	controller.screen:add(g)

	start_touch = false
	end_touch = false
	test_status = ""

 	if controller.has_touches then

		local down_x, down_y, up_x, up_y
	 
		controller:start_touches()

		function controller:on_touch_down(finger, x, y)
			down_x = x
			down_y = y

			if down_x > 20 and down_x < 70 and down_y > 20 and down_y < 70 then
				start_touch = true
			end

			test_verify_txt.text = "\t\t\tX\t\Y\nTouch down:\t"..tostring(down_x).."\t"..tostring(down_y).."\n\nTouch up:\t\t"..tostring(up_x).."\t"..tostring(up_y).."\n\nTest Result = "..test_status

		end


		function controller:on_touch_up(finger, x, y)
			up_x = x
			up_y = y

			if up_x > 200 and up_x < 250 and up_y > 200 and up_y < 250 then
				end_touch = true
			end 

			if start_touch == true and end_touch == true then
				test_status = "Pass"
			end

			test_verify_txt.text = "\t\t\tX\t\Y\nTouch down:\t"..tostring(down_x).."\t"..tostring(down_y).."\n\nTouch up:\t\t"..tostring(up_x).."\t"..tostring(up_y).."\n\nTest Result = "..test_status

		 end


	end

	return g
end


