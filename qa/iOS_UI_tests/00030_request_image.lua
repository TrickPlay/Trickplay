test_steps = "Run test twice with pre-existing pic and with camera.\n Try to scale and rotate."
test_description = "Testing request_image parameter scale/rotate = false."
test_verify = "After taking picture and selecting 'Use', it should send the picture immediately to the screen."
test_group = "acceptance"
test_area = "request_image"
test_api = "request_image"


function generate_test_image (controller, factory)
	  
	controller:request_image({}, false, "", "")
	local total = 0
	local photo = Image()

    function controller:on_image(bitmap)


	  photo = bitmap:Image()
		
	  photo.size = { 320, 480}
	  photo.position = { 675, 470 }        
	  screen:add(photo)

	 	function idle.on_idle( idle , seconds )
	      total = total + seconds
	      if total >= 5 then
			idle.on_idle = nil
			screen:remove(photo)
			photo = nil
	      end
    	end
	end

	return nil
end

