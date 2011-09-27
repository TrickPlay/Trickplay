test_steps = "Select Camera.\nTake a picture.\nRotate and rescale pic.\nSelect Use & Test Cancel.\nRun test again.\Select Photo Library.\n Select Photo Library and a photo."
test_description = "Testing request_image parameters - max dimensions, dialog and cancel label."
test_verify = "Verify:\n - The picture displays on the TV and is pixelated due to resizing from {20, 20] dimensions.\n - The text on the dialog says 'Test Test Test'\n - The text on the cancel button says 'Test Cancel'\n - The image can be scaled and rotated."
test_group = "acceptance"
test_area = "request_image"
test_api = "request_image"


function generate_test_image (controller, factory)
	  
	controller:request_image({20, 20}, true, "", "Test Test Test", "Test Cancel")
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

