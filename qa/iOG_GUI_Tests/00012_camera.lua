
test_description = "Check that the iOS device request image dialog appears."
test_steps = "Select camera or photo library on the device.\n Take a picture or select one."
test_verify = "Verify it appears in the screenshot box."
test_group = "smoke"
test_area = "camera"
test_api = "request_image"


function generate_test_image (controller, factory)
	  
	controller:request_image()
	local total = 0
	local photo = Image()

    function controller:on_image(bitmap)


	  photo = bitmap:Image()
		
	  photo.size = { 320, 480}
	  photo.position = { 675, 470 }        
	  screen:add(photo)
	end

 	function idle.on_idle( idle , seconds )
      total = total + seconds
      if total >= 10 then
		print ("aaa")
        idle.on_idle = nil
		screen:remove(photo)
		photo = nil
 		test_verify_txt.text = "Photo cleared for next test."
      end
    end

	return nil
end

--[[
 key_handler[keys.p] = function()
        print("submit picture")
        controller:request_image()
    end
    size = {640, 960}
    key_handler[keys.q] = function()
        print("submit picture with size and mask but no labels")
        controller:request_image(size, true, "chip")
    end
    key_handler[keys.w] = function()
        print("submit picture with size and lables but no mask")
        controller:request_image(size, true, "", "i am your title label", "cancel label")
    end
--]]
